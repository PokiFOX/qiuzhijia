import 'package:flutter/material.dart';

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
			await Future.delayed(const Duration(seconds: 1));
			Navigator.of(context).pushReplacementNamed('/mainpage');
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(),
		);
	}
}
