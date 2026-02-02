import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/request.dart' as tapah;

class SplashWidget extends StatefulWidget {
	const SplashWidget({super.key});

	@override
	State<SplashWidget> createState() => SplashState();
}

class SplashState extends State<SplashWidget> {
	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) async {
			if (mounted == false) return;
			await tapah.RequestZoneList();
			await tapah.RequestSectorList();
			await tapah.RequestLevelList();
			await tapah.RequestFieldList();
			await Future.delayed(Duration(seconds: 1));
			Navigator.of(context).pushReplacementNamed('/mainpage');
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
			),
		);
	}
}
