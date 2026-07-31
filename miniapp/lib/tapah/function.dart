import 'package:flutter/material.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;
import 'package:mpflutter_wechat_webview/mpflutter_wechat_webview.dart';

import 'package:qiuzhijia/tapah/class.dart';
import 'package:qiuzhijia/tapah/enum.dart';
import 'package:qiuzhijia/tapah/reserved.dart';

String parseimage(String name) {
	return useNativeCodec('$urlheader/images/$name');
}

String parseurl(String url) {
	return 'https://$backendHost:$backendPort/$url';
}

void KeFu(BuildContext context) {
	navigator(context, '/kefu');
}

class WechatNavMetrics {
	final double statusBarHeight;
	final double navBarHeight;
	final double capsuleTop;
	final double capsuleHeight;
	final double paddingHorizontal;

	const WechatNavMetrics({
		required this.statusBarHeight,
		required this.navBarHeight,
		required this.capsuleTop,
		required this.capsuleHeight,
		required this.paddingHorizontal,
	});
}

/// 读取微信小程序胶囊按钮位置，用于自定义导航栏与系统胶囊垂直对齐。
WechatNavMetrics getWechatNavMetrics(BuildContext context) {
	if (kIsMPFlutter) {
		try {
			final system = wxapi.wx.getSystemInfoSync();
			final capsule = wxapi.wx.getMenuButtonBoundingClientRect();
			final statusBar = system.statusBarHeight.toDouble();
			final capsuleTop = capsule.top.toDouble();
			final capsuleHeight = capsule.height.toDouble();
			final screenWidth = system.screenWidth.toDouble();
			final paddingHorizontal = screenWidth - capsule.right.toDouble();
			final navBarHeight = (capsuleTop - statusBar) * 2 + capsuleHeight + statusBar;
			return WechatNavMetrics(
				statusBarHeight: statusBar,
				navBarHeight: navBarHeight,
				capsuleTop: capsuleTop,
				capsuleHeight: capsuleHeight,
				paddingHorizontal: paddingHorizontal,
			);
		} catch (_) {}
	}
	final statusBar = MediaQuery.of(context).padding.top;
	const capsuleHeight = 32.0;
	const gap = 6.0;
	final capsuleTop = statusBar > 0 ? statusBar + gap : gap;
	final navBarHeight = capsuleTop + capsuleHeight + gap;
	return WechatNavMetrics(
		statusBarHeight: statusBar,
		navBarHeight: navBarHeight,
		capsuleTop: capsuleTop,
		capsuleHeight: capsuleHeight,
		paddingHorizontal: 16,
	);
}

Widget wrapSwipePop(BuildContext context, Widget child) {
	// Only the left edge listens for swipe-back. A full-page HorizontalDrag
	// GestureDetector steals PC wheel synthetic vertical drags from ListViews.
	return Stack(
		fit: StackFit.expand,
		children: [
			child,
			Positioned(
				left: 0,
				top: 0,
				bottom: 0,
				width: 24,
				child: GestureDetector(
					behavior: HitTestBehavior.translucent,
					onHorizontalDragEnd: (details) {
						if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
							if (Navigator.canPop(context)) {
								Navigator.pop(context);
							}
						}
					},
				),
			),
		],
	);
}

Widget backButton(BuildContext context) {
	return GestureDetector(
		onTap: () {
			if (Navigator.canPop(context)) {
				Navigator.pop(context);
			}
		},
		child: const Icon(Icons.arrow_back_ios_new, size: 20),
	);
}

Widget buildWechatNavBar(
	BuildContext context, {
	String? title,
	TextStyle? titleStyle,
	WechatNavMetrics? metrics,
	bool showBack = true,
}) {
	final m = metrics ?? getWechatNavMetrics(context);
	final style = titleStyle ?? const TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
	return SizedBox(
		height: m.navBarHeight,
		child: Stack(
			children: [
				if (title != null)
					Positioned(
						top: m.capsuleTop,
						left: m.paddingHorizontal,
						right: m.paddingHorizontal,
						height: m.capsuleHeight,
						child: Center(
							child: Text(title, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
						),
					),
				if (showBack)
					Positioned(
						top: m.capsuleTop,
						left: m.paddingHorizontal,
						height: m.capsuleHeight,
						child: Align(
							alignment: Alignment.centerLeft,
							child: backButton(context),
						),
					),
			],
		),
	);
}

/// 仅顶部留白，Tab 页等无导航栏控件时使用。
Widget wechatNavTopSpacer(BuildContext context) {
	return SizedBox(height: getWechatNavMetrics(context).navBarHeight);
}

Widget buildMain1(
	BuildContext context,
	List<Widget> children, {
	ScrollController? scrollController,
	String? title,
	TextStyle? titleStyle,
	bool? showBack,
}) {
	final metrics = getWechatNavMetrics(context);
	final back = showBack ?? Navigator.canPop(context);
	return wrapSwipePop(context, Material(
		child: Column(
			children: [
				buildWechatNavBar(context, title: title, titleStyle: titleStyle, metrics: metrics, showBack: back),
				Expanded(
					child: SingleChildScrollView(
						controller: scrollController,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: children,
						),
					),
				),
			],
		),
	));
}

Widget buildMain2(
	BuildContext context,
	List<Widget> children,
	Widget bottom, {
	String? title,
	TextStyle? titleStyle,
	bool? showBack,
}) {
	final metrics = getWechatNavMetrics(context);
	final back = showBack ?? Navigator.canPop(context);
	return wrapSwipePop(context, Scaffold(
		body: Column(
			children: [
				buildWechatNavBar(context, title: title, titleStyle: titleStyle, metrics: metrics, showBack: back),
				Expanded(
					child: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: children,
						),
					),
				),
			],
		),
		bottomNavigationBar: bottom,
	));
}

void activateMainPageTab(BuildContext context, int index) {
	final navigator = Navigator.of(context);
	if (navigator.canPop()) {
		navigator.popUntil((route) {
			return route.settings.name == '/mainpage' || route.isFirst;
		});
	}
	EventManager().call(SceneID.mainpage, EventType.mainpage_activate, [index]);
}

void navigator(BuildContext context, String url, {Map<String, dynamic>? arguments}) {
	String full = url;
	if (arguments != null && arguments.isNotEmpty) {
		full += "?";
		arguments.forEach((key, value) {
			full += "$key=$value&";
		});
		full = full.substring(0, full.length - 1);
	}
	if (kIsMPFlutter) {
		wxapi.wx.navigateTo(wxapi.NavigateToOption()
			..url = full
		);
	}
	Navigator.pushNamed(context, url, arguments: arguments);
}

/// 打开公众号文章（wx.openOfficialAccountArticle，基础库 >= 3.4.8）。
/// 正式版不依赖 web-view 业务域名 / 公众号关联；须在原生 tap（如 MPFlutter_Wechat_Button.onTap）里同步调用。
void openOfficialAccountArticle(String url) {
	final trimmed = url.trim();
	if (trimmed.isEmpty) return;

	bool supported = false;
	try {
		supported = wxapi.wx.canIUse('openOfficialAccountArticle');
	} catch (_) {
		supported = false;
	}
	if (!supported) {
		print('openOfficialAccountArticle unsupported, fallback to web-view: $trimmed');
		openArticleWebView(trimmed);
		return;
	}

	final option = wxapi.IAnyObject();
	option.setValue('url', trimmed);
	option.setValue('success', (res) {
		print('openOfficialAccountArticle success');
	});
	option.setValue('fail', (res) {
		final err = _wxCallbackDetail(res);
		print('openOfficialAccountArticle fail: $err');
		final toast = wxapi.ShowToastOption();
		toast.title = '无法打开文章';
		toast.icon = 'none';
		wxapi.wx.showToast(toast);
	});
	wxapi.wx.$$context$$.callMethod('openOfficialAccountArticle', [option.$$context$$]);
}

/// Markdown 等非原生 tap 场景打开公众号/外链时用 web-view。
void openArticleWebView(String url) {
	final trimmed = url.trim();
	if (trimmed.isEmpty) return;
	MPFlutter_Wechat_WebView.open(trimmed, onLoad: (_) {});
}

bool isOfficialAccountArticleUrl(String url) {
	final uri = Uri.tryParse(url.trim());
	if (uri == null) return false;
	return uri.host.contains('mp.weixin.qq.com');
}

String _wxCallbackDetail(dynamic res) {
	try {
		final ctx = res is mpjs.JSObject
			? res
			: (res is wxapi.IAnyObject ? res.$$context$$ : null);
		if (ctx != null) {
			final msg = ctx['errMsg'];
			final code = ctx['errCode'];
			return 'errMsg=$msg errCode=$code';
		}
		if (res is wxapi.IAnyObject) {
			return 'errMsg=${res.getValue('errMsg')} errCode=${res.getValue('errCode')}';
		}
	} catch (e) {
		return 'parseError=$e raw=$res';
	}
	return '$res';
}

String stagStr(int? stag) {
	if (stag == 1) return "C9";
	if (stag == 2) return "985";
	if (stag == 3) return "211";
	if (stag == 4) return "双非";
	if (stag == 3) return "普通";
	if (stag == 4) return "海外Top10";
	if (stag == 5) return "海外Top50";
	if (stag == 6) return "海外Top100";
	if (stag == 7) return "其他海外院校";
	return "未知";
}
