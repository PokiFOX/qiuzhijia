import 'package:flutter/material.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

import 'package:qiuzhijia/tapah/reserved.dart';

String parseimage(String name) {
	return useNativeCodec('$urlheader/images/$name');
}

String parseurl(String url) {
	return 'https://$backendHost:$backendPort/$url';
}

void KeFu(BuildContext context) {
	navigator(context, '/kefu');
	//var option = wxapi.OpenCustomerServiceChatOption();
	//option.corpId = "ww9c9c584173a105cc";
	//var extInfo = wxapi.ExtInfoOption();
	//extInfo.url = 'https://work.weixin.qq.com/kfid/kfcb5ad5f141ba2d45d';
	//option.extInfo = extInfo;
	//option.success = (result) {
	//	print("打开在线咨询成功:" + result.toString());
	//};
	//option.fail = (error) {
	//	try {
	//		final errMsg = error.$$context$$['errMsg'];
	//		print("打开在线咨询失败详情: $errMsg");
	//	} catch (e) {
	//		print("解析错误对象失败: $error");
	//	}
	//};
	//wxapi.wx.openCustomerServiceChat(option);
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
		child: Icon(Icons.arrow_back_ios_new, size: 20),
	);
}

Widget buildMain1(BuildContext context, List<Widget> children) {
	final safeAreaTop = MediaQuery.of(context).padding.top;
	if (safeAreaTop > 0) {
		return wrapSwipePop(context, Material(
			child: Stack(
				children: [
					SafeArea(
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									...children,
								],
							),
						),
					),
					Positioned(
						top: 30,
						left: 30,
						child: SizedBox(
							height: safeAreaTop,
							child: backButton(context),
						),
					),
				],
			),
		));
	}
	else {
		return wrapSwipePop(context, Material(
			child: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						backButton(context),
						const SizedBox(height: 10),
						...children,
					],
				),
			),
		));
	}
}

Widget buildMain2(BuildContext context, List<Widget> children, Widget bottom) {
	final safeAreaTop = MediaQuery.of(context).padding.top;
	if (safeAreaTop > 0) {
		return wrapSwipePop(context, Scaffold(
			body: Stack(
				children: [
					SafeArea(
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									...children,
								],
							),
						),
					),
					Positioned(
						top: 10,
						left: 20,
						child: SizedBox(
							height: safeAreaTop,
							child: backButton(context),
						),
					),
				],
			),
			bottomNavigationBar: bottom,
		));
	}
	else {
		return wrapSwipePop(context, Scaffold(
			body: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						backButton(context),
						const SizedBox(height: 10),
						...children,
					],
				),
			),
			bottomNavigationBar: bottom,
		));
	}
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
