import 'package:flutter/material.dart';

import 'package:frontend/scenes/mainpage.dart' as scenes;
import 'package:frontend/scenes/splash.dart' as scenes;
import 'package:frontend/scenes/zone.dart' as scenes;
import 'package:frontend/scenes/level.dart' as scenes;
import 'package:frontend/scenes/sector.dart' as scenes;

class QZJApp extends StatelessWidget {
	const QZJApp({super.key});
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: '求职家后台',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
				useMaterial3: true,
			),
			home: scenes.SplashWidget(key: GlobalKey()),
			routes: {
				'/splash': (context) => scenes.SplashWidget(key: GlobalKey()),
				'/mainpage': (context) => scenes.MainPageWidget(key: GlobalKey()),
				'/zone': (context) => scenes.ZoneWidget(key: GlobalKey()),
				'/level': (context) => scenes.LevelWidget(key: GlobalKey()),
				'/sector': (context) => scenes.SectorWidget(key: GlobalKey()),
			},
		);
	}
}
