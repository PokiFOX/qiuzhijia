import 'package:flutter/material.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;

import 'package:bot_toast/bot_toast.dart';

import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/scenes/splash.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage.dart' as scenes;
import 'package:qiuzhijia/scenes/detail.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/profile.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/example.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/field.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/fielddetail.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/qiuzhiziliao.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/shixineitui.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/gangweineitui.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/zixunguwen.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/bishitiku.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/mianshijingyan.dart' as scenes;
import 'package:qiuzhijia/scenes/lanmu/qiuzhifuwu.dart' as scenes;
import 'package:qiuzhijia/scenes/kefu.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/favorite.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/filter.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/casefilter.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/fieldlist.dart' as scenes;

class MainAppDelegate {
	late MPFlutterWechatAppDelegate appDelegate;

	MainAppDelegate() {
		appDelegate = MPFlutterWechatAppDelegate(
			onShow: () {
				print("当应用从后台回到前台，被回调。");
			},
			onHide: () {
				print("当应用从前台切到后台，被回调。");
			},
			onShareAppMessage: (detail) {
				print("当用户点击分享给朋友时，回调，应组装对应的 Map 信息，用于展示和回跳。");
				return onShareAppMessage(detail);
			},
			onLaunch: (query, launchptions) async {
				print(launchptions['path']);
				print("应用冷启动时，会收到回调，应根据 query 决定是否要跳转页面。");
				await Future.delayed(Duration(seconds: 1));
				onLaunchOrEnter(query);
			},
			onEnter: (query, launchptions) {
				print("应用热启动（例如用户从分享卡片进入小程序）时，会收到回调，应根据 query 决定是否要跳转页面。");
				onLaunchOrEnter(query);
			},
		);
	}

	Map onShareAppMessage(mpjs.JSObject detail) {
		return MPFlutterWechatAppShareManager.onShareAppMessage(detail);
	}

	void onLaunchOrEnter(Map query) {
		final navigator = MPNavigatorObserver.currentRoute?.navigator;
		print('navigator: $navigator');
		if (navigator != null) {
			final routeName = query["routeName"];
			print('routeName: $routeName');
			switch (routeName) {
				case "/mainpage":
					navigator.pushNamed("/mainpage");
					break;
			}
		}
	}
}

class MainApp extends StatelessWidget {
	const MainApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: '求职家小程序',
			navigatorKey: tapah.globalkey,
			builder: BotToastInit(),
			navigatorObservers: [BotToastNavigatorObserver(), MPNavigatorObserver()],
			theme: ThemeData(
				useMaterial3: true,
				appBarTheme: AppBarTheme(
					color: Colors.blue,
					foregroundColor: Colors.white,
					elevation: 5.0,
					centerTitle: false,
				),
				fontFamily: "MiniTex",
				fontFamilyFallback: ["MiniTex"],
				platform: TargetPlatform.iOS,
			),
			routes: {
				'/splash': (context) => scenes.SplashWidget(key: GlobalKey()),
				'/mainpage': (context) => scenes.MainPageWidget(key: GlobalKey()),
				'/enterprise/detail': (context) => scenes.DetailWidget(key: GlobalKey()),
				'/mainpage/field': (context) => scenes.FieldWidget(key: GlobalKey()),
				'/mainpage/profile': (context) => scenes.ProfileWidget(key: GlobalKey()),
				'/mainpage/example': (context) => scenes.ExampleWidget(key: GlobalKey(),),
				'/mainpage/fielddetail': (context) => scenes.FieldDetailWidget(key: GlobalKey(),),
				'/lanmu/qiuzhiziliao': (context) => scenes.QiuZhiZiLiaoWidget(key: GlobalKey(),),
				'/lanmu/shixineitui': (context) => scenes.ShiXiNeiTuiWidget(key: GlobalKey(),),
				'/lanmu/gangweineitui': (context) => scenes.GangWeiNeiTuiWidget(key: GlobalKey(),),
				'/lanmu/zixunguwen': (context) => scenes.ZiXunGuWenWidget(key: GlobalKey(),),
				'/lanmu/bishitiku': (context) => scenes.BiShiTiKuWidget(key: GlobalKey(),),
				'/lanmu/mianshijingyan': (context) => scenes.MianShiJingYanWidget(key: GlobalKey(),),
				'/lanmu/qiuzhifuwu': (context) => scenes.QiuZhiFuWuWidget(key: GlobalKey(),),
				'/kefu': (context) => scenes.KeFuWidget(key: GlobalKey(),),
				'/mainpage/favorite': (context) => scenes.FavoriteWidget(key: GlobalKey(),),
				'/mainpage/filter': (context) => scenes.FilterWidget(key: GlobalKey(),),
				'/mainpage/casefilter': (context) => scenes.CaseFilterWidget(key: GlobalKey(),),
				'/mainpage/fieldlist': (context) => scenes.FieldListWidget(key: GlobalKey(),),
			},
			home: scenes.SplashWidget(key: GlobalKey()),
		);
	}
}
