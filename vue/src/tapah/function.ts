import { urlheader, backendHost, backendPort } from "./reserved";
import { SceneID, EventType } from "./enum";
import { EventManager } from "./class";

let cachedPixelRatio: number | null = null;

function getPixelRatio(): number {
	if (cachedPixelRatio != null) return cachedPixelRatio;
	try {
		const info = uni.getSystemInfoSync();
		cachedPixelRatio = info.pixelRatio || 2;
	} catch {
		cachedPixelRatio = 2;
	}
	return cachedPixelRatio;
}

/** foo.png → foo@2x.png / foo@3x.png；已带 @2x/@3x 则原样返回 */
function withDensitySuffix(name: string, dpr: number): string {
	if (/@[23]x(\.[^.]+)?$/i.test(name) || name.includes("@2x.") || name.includes("@3x.")) {
		return name;
	}
	const i = name.lastIndexOf(".");
	if (i <= 0) return name;
	const base = name.slice(0, i);
	const ext = name.slice(i);
	if (dpr >= 3) return `${base}@3x${ext}`;
	if (dpr >= 2) return `${base}@2x${ext}`;
	return name;
}

export function parseimage(name: string): string {
	const densified = withDensitySuffix(name, getPixelRatio());
	return `${urlheader}/images2/${densified}`;
}

/** 企业小图标/顶部大图只有单倍图，不走 @2x/@3x */
export function parseEnterpriseIcon(name: string): string {
	return `${urlheader}/images2/${name}`;
}

/** 专业热门度：后端 0–10，展示时除以 2，固定 5 颗星位（全星 + 半星 + 空星） */
export function fieldStarParts(star: number): { full: number; half: boolean; empty: number } {
	const n = Math.max(0, Math.min(10, Math.floor(star || 0)));
	const full = Math.floor(n / 2);
	const half = n % 2 === 1;
	const empty = 5 - full - (half ? 1 : 0);
	return { full, half, empty };
}

export function parseurl(url: string): string {
	return `https://${backendHost}:${backendPort}/${url}`;
}

export function navigator(url: string, args?: Record<string, any>) {
	let full = url;
	if (!full.startsWith("/pages/")) {
		const name = full.startsWith("/") ? full.substring(1) : full;
		const parts = name.split("/");
		const lastPart = parts[parts.length - 1];
		full = `/pages/${name}/${lastPart}`;
	}
	if (args && Object.keys(args).length > 0) {
		const query = Object.entries(args)
			.map(([key, val]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(val))}`)
			.join("&");
		full += `?${query}`;
	}
	uni.navigateTo({
		url: full,
	});
}

export function navigatorToCase(caseId: number) {
	if (!caseId) return;
	uni.navigateTo({
		url: `/pages/mainpage/casedetail/casedetail?id=${caseId}`,
		fail(err) {
			console.error("navigateTo casedetail failed:", err);
			uni.showToast({ title: "打开案例失败", icon: "none" });
		},
	});
}

export function KeFu() {
	navigator("/kefu");
}

export function activateMainPageTab(index: number) {
	EventManager().call(SceneID.mainpage, EventType.mainpage_activate, [index]);
}

export function openOfficialAccountArticle(url: string) {
	const trimmed = url.trim();
	if (!trimmed) return;

	// @ts-ignore
	if (typeof wx !== "undefined" && wx.openOfficialAccountArticle) {
		// @ts-ignore
		wx.openOfficialAccountArticle({
			url: trimmed,
			success() {
				console.log("openOfficialAccountArticle success");
			},
			fail(err: any) {
				console.error("openOfficialAccountArticle fail", err);
				uni.showToast({
					title: "无法打开文章",
					icon: "none",
				});
			},
		});
	} else {
		console.log("openOfficialAccountArticle unsupported, fallback to web-view:", trimmed);
		openArticleWebView(trimmed);
	}
}

export function openArticleWebView(url: string) {
	const trimmed = url.trim();
	if (!trimmed) return;
	navigator("/pages/webview/webview", { url: trimmed });
}

export function openExternalUrl(url: string) {
	let trimmed = url.trim();
	if (!trimmed) return;
	if (!/^https?:\/\//i.test(trimmed)) {
		trimmed = `https://${trimmed}`;
	}
	navigator("/pages/webview/webview", { url: trimmed });
}

export function isOfficialAccountArticleUrl(url: string): boolean {
	try {
		const trimmed = url.trim();
		if (!trimmed) return false;
		return trimmed.includes("mp.weixin.qq.com");
	} catch {
		return false;
	}
}

export function stagStr(stag?: number | null): string {
	if (stag === 1) return "C9";
	if (stag === 2) return "985";
	if (stag === 3) return "211";
	if (stag === 4) return "双非";
	if (stag === 5) return "海外Top50";
	if (stag === 6) return "海外Top100";
	if (stag === 7) return "其他海外院校";
	return "未知";
}

export interface WechatNavMetrics {
	statusBarHeight: number;
	navBarHeight: number; // Total height including status bar
	capsuleTop: number;
	capsuleHeight: number;
	paddingHorizontal: number;
}

export function getWechatNavMetrics(): WechatNavMetrics {
	try {
		// @ts-ignore
		if (typeof wx !== "undefined" && wx.getMenuButtonBoundingClientRect) {
			// @ts-ignore
			const capsule = wx.getMenuButtonBoundingClientRect();
			const system = uni.getSystemInfoSync();
			const statusBar = system.statusBarHeight || 0;
			const capsuleTop = capsule.top;
			const capsuleHeight = capsule.height;
			const screenWidth = system.screenWidth;
			const paddingHorizontal = screenWidth - capsule.right;
			// navBarHeight is total height including status bar
			const navBarHeight = (capsuleTop - statusBar) * 2 + capsuleHeight + statusBar;
			return {
				statusBarHeight: statusBar,
				navBarHeight: navBarHeight,
				capsuleTop: capsuleTop,
				capsuleHeight: capsuleHeight,
				paddingHorizontal: paddingHorizontal,
			};
		}
	} catch (e) {
		console.error("Failed to get WeChat nav metrics:", e);
	}

	// Fallback for non-WeChat / H5 / error environments
	const system = uni.getSystemInfoSync();
	const statusBar = system.statusBarHeight || 20; // safe default
	const capsuleHeight = 32;
	const gap = 6;
	const capsuleTop = statusBar + gap;
	const navBarHeight = capsuleTop + capsuleHeight + gap;
	return {
		statusBarHeight: statusBar,
		navBarHeight: navBarHeight,
		capsuleTop: capsuleTop,
		capsuleHeight: capsuleHeight,
		paddingHorizontal: 16,
	};
}
