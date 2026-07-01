import 'package:flutter/material.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

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
	return GestureDetector(
		behavior: HitTestBehavior.translucent,
		onHorizontalDragEnd: (details) {
			if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
				if (Navigator.canPop(context)) {
					Navigator.pop(context);
				}
			}
		},
		child: child,
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

String stagStr(int? stag) {
	if (stag == 1) return "985";
	if (stag == 2) return "211";
	if (stag == 3) return "普通";
	return "海外";
}
