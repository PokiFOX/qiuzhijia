import { urlheader, backendHost, backendPort } from "./reserved";
import { SceneID, EventType } from "./enum";
import { EventManager } from "./class";

export function parseimage(name: string): string {
	return `${urlheader}/images/${name}`;
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
	navigator("/webview", { url: trimmed });
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
