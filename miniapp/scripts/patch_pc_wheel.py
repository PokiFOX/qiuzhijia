#!/usr/bin/env python3
"""Patch MPFlutter wechat host to bridge PC mouse wheel -> Flutter touch drag.

PC miniprogram does not document wx.onWheel (minigame-only) or bind:mousewheel.
This patch uses a transparent scroll-view trap that receives native PC wheel,
converts bindscroll delta into a synthetic Flutter touch drag, and also binds
Arrow/Page keys via wx.onKeyDown as a fallback.
"""

from __future__ import annotations

import pathlib
import re
import sys

MARKER = "/* PC_WHEEL_BRIDGE */"
MARKER_END = "/* PC_WHEEL_BRIDGE_END */"
WXML_BEGIN = "<!-- PC_WHEEL_OVERLAY_BEGIN -->"
WXML_END = "<!-- PC_WHEEL_OVERLAY_END -->"

BRIDGE_JS = r'''
/* PC_WHEEL_BRIDGE */
function mpIsPcWheelPlatform() {
  try {
    const p = (typeof wxSystemInfo !== "undefined" && wxSystemInfo.platform)
      ? String(wxSystemInfo.platform).toLowerCase()
      : "";
    if (p === "ios" || p === "android" || p === "ohos") return false;
    if (p === "windows" || p === "mac" || p === "devtools" || p === "win" || p === "macos") {
      return true;
    }
    // Empty / unknown: enable (PC build / odd host strings).
    return true;
  } catch (e) {
    return true;
  }
}

function mpWheelHandlersReady() {
  try {
    const host = FlutterHostView && FlutterHostView.shared;
    if (!host) return false;
    return typeof host.ontouchstart === "function"
      && typeof host.ontouchmove === "function"
      && typeof host.ontouchend === "function";
  } catch (e) {
    return false;
  }
}

function mpMakeWheelTouchEvent(type, x, y, target) {
  const touch = {
    identifier: 99001,
    pageX: x,
    pageY: y,
    clientX: x,
    clientY: y,
    x: x,
    y: y,
    force: 1,
    radiusX: 1,
    radiusY: 1,
  };
  return {
    type: type,
    target: target,
    currentTarget: target,
    offsetX: x,
    offsetY: y,
    touches: type === "touchend" || type === "touchcancel" ? [] : [touch],
    changedTouches: [touch],
    timeStamp: Date.now(),
  };
}

function mpEmitSyntheticDrag(dx, dy, x, y) {
  if (!mpWheelHandlersReady()) return;
  if (!FlutterHostView || !FlutterHostView.shared) return;
  if (FlutterHostView.shared.touching) return;
  if (!dx && !dy) return;
  var canvas = null;
  try {
    canvas = getApp() && getApp()._flutter && getApp()._flutter.activeCanvas;
  } catch (e) {}
  if (!canvas) {
    console.log("[PC_WHEEL] skip emit, no activeCanvas");
    return;
  }
  // Prefer sign for WeChat wheel units; keep a minimum step for Flutter threshold.
  const stepY = dy === 0 ? 0 : (dy > 0 ? 1 : -1) * Math.max(48, Math.min(120, Math.abs(dy)));
  const stepX = dx === 0 ? 0 : (dx > 0 ? 1 : -1) * Math.max(48, Math.min(120, Math.abs(dx)));
  const width = (typeof wxSystemInfo !== "undefined" && wxSystemInfo.windowWidth) || 375;
  const height = (typeof wxSystemInfo !== "undefined" && wxSystemInfo.windowHeight) || 667;
  const px = x != null ? x : width / 2;
  const py = y != null ? y : height / 2;
  // Wheel / scroll down (positive deltaY) => content down => finger moves up.
  const x2 = px - stepX;
  const y2 = py - stepY;
  try {
    FlutterHostView.shared.touching = true;
    callFlutterTouchEvent("ontouchstart", [mpMakeWheelTouchEvent("touchstart", px, py, canvas)]);
    callFlutterTouchEvent("ontouchmove", [mpMakeWheelTouchEvent("touchmove", x2, y2, canvas)]);
    callFlutterTouchEvent("onpointerup", [mpMakeWheelTouchEvent("touchend", x2, y2, canvas)]);
    callFlutterTouchEvent("ontouchend", [mpMakeWheelTouchEvent("touchend", x2, y2, canvas)]);
  } catch (e) {
    console.log("[PC_WHEEL] emit error", e);
  } finally {
    FlutterHostView.shared.touching = false;
  }
}

function mpHandlePcWheel(res) {
  if (!mpIsPcWheelPlatform()) return;
  const detail = res && res.detail ? res.detail : res;
  if (!detail) return;
  const dy = detail.deltaY || 0;
  const dx = detail.deltaX || 0;
  if (!dy && !dx) return;
  const now = Date.now();
  if (!mpHandlePcWheel._lastLog || now - mpHandlePcWheel._lastLog > 500) {
    console.log("[PC_WHEEL] mpHandlePcWheel", { dx: dx, dy: dy, src: detail._src || "wheel" });
    mpHandlePcWheel._lastLog = now;
  }
  mpEmitSyntheticDrag(dx, dy, detail.x, detail.y);
}

function setupPcWheelBridge(page) {
  if (!page) return;
  if (setupPcWheelBridge._installed) return;
  setupPcWheelBridge._installed = true;

  const platform = (typeof wxSystemInfo !== "undefined" && wxSystemInfo.platform)
    ? String(wxSystemInfo.platform)
    : "";
  const enabled = mpIsPcWheelPlatform();
  const hasOnWheel = typeof wx !== "undefined" && typeof wx.onWheel === "function";
  const hasOnKeyDown = typeof wx !== "undefined" && typeof wx.onKeyDown === "function";
  console.log("[PC_WHEEL] setup", {
    platform: platform,
    onWheel: hasOnWheel ? "function" : typeof (wx && wx.onWheel),
    onKeyDown: hasOnKeyDown ? "function" : typeof (wx && wx.onKeyDown),
    enabled: enabled,
  });

  if (!enabled) {
    page.setData({ pcWheelEnabled: false });
    return;
  }

  const h = (typeof wxSystemInfo !== "undefined" && wxSystemInfo.windowHeight) || page.data.windowHeight || 667;
  const mid = h;
  const inner = h * 3;
  page._pcWheelMid = mid;
  page._pcWheelLastTop = mid;
  page._pcWheelIgnore = false;
  page.setData({
    pcWheelEnabled: true,
    pcWheelScrollY: true,
    pcWheelScrollTop: mid,
    pcWheelInnerHeight: inner,
  });

  page.onPcWheelScroll = function (e) {
    if (page._pcWheelIgnore) return;
    if (!e || !e.detail) return;
    const top = e.detail.scrollTop || 0;
    const midTop = page._pcWheelMid || mid;
    const last = page._pcWheelLastTop != null ? page._pcWheelLastTop : midTop;
    const dy = top - last;
    page._pcWheelLastTop = top;
    if (Math.abs(dy) < 0.5) return;
    mpHandlePcWheel({ deltaY: dy, deltaX: 0, _src: "scroll-view" });
    const viewH = page.data.windowHeight || h;
    const innerH = page.data.pcWheelInnerHeight || inner;
    if (top < viewH * 0.25 || top > innerH - viewH * 1.25) {
      page._pcWheelIgnore = true;
      page._pcWheelLastTop = midTop;
      page.setData({ pcWheelScrollTop: midTop }, function () {
        setTimeout(function () {
          page._pcWheelIgnore = false;
        }, 32);
      });
    }
  };

  const origStart = page.ontouchstart;
  const origEnd = page.ontouchend;
  const origCancel = page.ontouchcancel;

  page.onPcWheelTouchStart = function (e) {
    if (page.data.pcWheelScrollY !== false) {
      page.setData({ pcWheelScrollY: false });
    }
    if (typeof origStart === "function") return origStart.call(page, e);
  };

  page.onPcWheelTouchEnd = function (e) {
    if (typeof origEnd === "function") origEnd.call(page, e);
    setTimeout(function () {
      page.setData({ pcWheelScrollY: true });
    }, 50);
  };

  page.onPcWheelTouchCancel = function (e) {
    if (typeof origCancel === "function") origCancel.call(page, e);
    setTimeout(function () {
      page.setData({ pcWheelScrollY: true });
    }, 50);
  };

  try {
    if (hasOnWheel) {
      wx.onWheel(function (res) {
        const payload = res || {};
        payload._src = "onWheel";
        mpHandlePcWheel(payload);
      });
    }
  } catch (e) {
    console.log("[PC_WHEEL] onWheel bind error", e);
  }

  try {
    if (hasOnKeyDown) {
      const keyListener = function (res) {
        const key = (res && (res.key || res.code)) || "";
        const code = (res && res.code) || "";
        let dy = 0;
        if (key === "ArrowDown" || code === "ArrowDown") dy = 48;
        else if (key === "ArrowUp" || code === "ArrowUp") dy = -48;
        else if (key === "PageDown" || code === "PageDown") dy = 120;
        else if (key === "PageUp" || code === "PageUp") dy = -120;
        else return;
        mpHandlePcWheel({ deltaY: dy, deltaX: 0, _src: "onKeyDown:" + (code || key) });
      };
      page._pcWheelKeyListener = keyListener;
      wx.onKeyDown(keyListener);
    }
  } catch (e) {
    console.log("[PC_WHEEL] onKeyDown bind error", e);
  }

  const origUnload = page.onUnload;
  page.onUnload = function () {
    try {
      if (page._pcWheelKeyListener && typeof wx.offKeyDown === "function") {
        wx.offKeyDown(page._pcWheelKeyListener);
      }
    } catch (e) {}
    if (typeof origUnload === "function") return origUnload.call(page);
  };
}
/* PC_WHEEL_BRIDGE_END */
'''

SETUP_CALL = "setupPcWheelBridge(this);"

DATA_FIELDS = (
    "    pcWheelEnabled: false,\n"
    "    pcWheelScrollY: true,\n"
    "    pcWheelScrollTop: 0,\n"
    "    pcWheelInnerHeight: 0,\n"
)

WXML_OVERLAY = (
    WXML_BEGIN
    + "\n"
    + '  <scroll-view wx:if="{{pcWheelEnabled}}" style="z-index:0;position: absolute; top: 0px; left: 0px; width: 100vw; height: {{windowHeight}}px; background-color: transparent;" scroll-y="{{pcWheelScrollY}}" show-scrollbar="{{false}}" enhanced="{{true}}" bounces="{{false}}" scroll-top="{{pcWheelScrollTop}}" bindscroll="onPcWheelScroll" bindtouchstart="onPcWheelTouchStart" bindtouchmove="ontouchmove" bindtouchend="onPcWheelTouchEnd" bindtouchcancel="onPcWheelTouchCancel">'
    + "\n"
    + '    <view style="width: 100%; height: {{pcWheelInnerHeight}}px;"></view>'
    + "\n"
    + "  </scroll-view>"
    + "\n"
    + '  <view wx:else style="z-index:0;position: absolute; top: 0px; left: 0px; width: 100vw; height: {{windowHeight}}px; background-color: transparent;" bindtouchstart="ontouchstart" bindtouchmove="ontouchmove" bindtouchend="ontouchend" bindtouchcancel="ontouchcancel"></view>'
    + "\n"
    + "  "
    + WXML_END
)

# Fresh MPFlutter touch overlay (no previous wheel patch).
ORIGINAL_OVERLAY = (
    '<view style="z-index:0;position: absolute; top: 0px; left: 0px; width: 100vw; height: {{windowHeight}}px; background-color: transparent;" '
    'bindtouchstart="ontouchstart" bindtouchmove="ontouchmove" bindtouchend="ontouchend" bindtouchcancel="ontouchcancel"></view>'
)

# Legacy mousewheel-patched overlay.
LEGACY_OVERLAY_RE = re.compile(
    r'<view style="z-index:0;position: absolute; top: 0px; left: 0px; width: 100vw; height: \{\{windowHeight\}\}px; background-color: transparent;" '
    r'bindtouchstart="ontouchstart" bindtouchmove="ontouchmove" bindtouchend="ontouchend" bindtouchcancel="ontouchcancel"'
    r'(?: bind:mousewheel="onmousewheel" catch:mousewheel="onmousewheel")?></view>'
)


def _strip_existing_bridge(text: str) -> str:
    """Remove a previously injected bridge so we can re-apply."""
    if MARKER in text:
        if MARKER_END in text:
            pattern = re.compile(
                re.escape(MARKER) + r".*?" + re.escape(MARKER_END) + r"\n?",
                re.DOTALL,
            )
            text = pattern.sub("", text)
        else:
            pattern = re.compile(
                re.escape(MARKER) + r".*?function setupPcWheelBridge\(page\) \{.*?\n\}\n?",
                re.DOTALL,
            )
            text = pattern.sub("", text)

    text = text.replace("\n    " + SETUP_CALL, "")
    text = text.replace("\n      " + SETUP_CALL, "")
    text = re.sub(
        r"\n  onmousewheel\(e\) \{\n    mpHandlePcWheel\(e\);\n  \},\n",
        "\n",
        text,
    )
    text = text.replace(DATA_FIELDS, "")
    return text


def patch_index_js(path: pathlib.Path) -> bool:
    text = path.read_text(encoding="utf-8")
    text = _strip_existing_bridge(text)

    # Page data fields for scroll-view trap.
    data_needle = "  data: {\n    canvasType: \"\","
    data_repl = "  data: {\n" + DATA_FIELDS + "    canvasType: \"\","
    if DATA_FIELDS not in text:
        if data_needle not in text:
            raise RuntimeError(f"cannot find Page data block in {path}")
        text = text.replace(data_needle, data_repl, 1)

    # Install after host view is ready on first load path.
    needle = "setupFlutterHostView(this);\n    setupAppLifeCycleListener();"
    if needle not in text:
        raise RuntimeError(f"cannot find injection point in {path}")
    text = text.replace(
        needle,
        "setupFlutterHostView(this);\n    setupAppLifeCycleListener();\n    " + SETUP_CALL,
        1,
    )

    # Also install on canvas-restore path (hot restart / context restore).
    needle2 = (
        "setupFlutterHostView(this);\n      try {\n"
        "        getApp()._flutter.self.platformViewManager.restoreViews();"
    )
    if needle2 in text:
        text = text.replace(
            needle2,
            "setupFlutterHostView(this);\n      "
            + SETUP_CALL
            + "\n      try {\n"
            "        getApp()._flutter.self.platformViewManager.restoreViews();",
            1,
        )

    # Append helper before callFlutterTouchEvent.
    if "function callFlutterTouchEvent" in text:
        text = text.replace(
            "function callFlutterTouchEvent",
            BRIDGE_JS + "\nfunction callFlutterTouchEvent",
            1,
        )
    else:
        text = text + "\n" + BRIDGE_JS

    path.write_text(text, encoding="utf-8")
    return True


def patch_index_wxml(path: pathlib.Path) -> bool:
    text = path.read_text(encoding="utf-8")

    # Re-apply: replace existing marked overlay block.
    if WXML_BEGIN in text and WXML_END in text:
        pattern = re.compile(
            re.escape(WXML_BEGIN) + r".*?" + re.escape(WXML_END),
            re.DOTALL,
        )
        text = pattern.sub(WXML_OVERLAY, text, count=1)
        path.write_text(text, encoding="utf-8")
        return True

    # Legacy mousewheel overlay -> new overlay.
    if LEGACY_OVERLAY_RE.search(text):
        text = LEGACY_OVERLAY_RE.sub(WXML_OVERLAY, text, count=1)
        path.write_text(text, encoding="utf-8")
        return True

    # Fresh MPFlutter overlay.
    if ORIGINAL_OVERLAY in text:
        text = text.replace(ORIGINAL_OVERLAY, WXML_OVERLAY, 1)
        path.write_text(text, encoding="utf-8")
        return True

    raise RuntimeError(f"cannot find touch overlay in {path}")


def main(argv: list[str]) -> int:
    root = pathlib.Path(argv[1]) if len(argv) > 1 else pathlib.Path("build/wechat/pages/index")
    js_path = root / "index.js"
    wxml_path = root / "index.wxml"
    if not js_path.exists() or not wxml_path.exists():
        print(f"[patch_pc_wheel] skip, missing {root}", file=sys.stderr)
        return 1
    js_changed = patch_index_js(js_path)
    wxml_changed = patch_index_wxml(wxml_path)
    print(
        f"[patch_pc_wheel] js={'patched' if js_changed else 'already'} "
        f"wxml={'patched' if wxml_changed else 'already'} ({root})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
