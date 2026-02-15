import 'package:flutter/material.dart';

class MainPageWidget extends StatefulWidget {
	const MainPageWidget({super.key});

	@override
	State<MainPageWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPageWidget> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					const SizedBox(height: 50,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50,),
							GestureDetector(
								onTap: () {
									Navigator.of(context).pushNamed('/zone');
								},
								child: const Text("地区列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						],
					),
					const SizedBox(height: 50,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50,),
							GestureDetector(
								onTap: () {
									Navigator.of(context).pushNamed('/level');
								},
								child: const Text("层级列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						],
					),
					const SizedBox(height: 50,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50,),
							GestureDetector(
								onTap: () {
									Navigator.of(context).pushNamed('/sector');
								},
								child: const Text("大类列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						],
					),
					const SizedBox(height: 50,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50,),
							GestureDetector(
								onTap: () {
									Navigator.of(context).pushNamed('/field');
								},
								child: const Text("学科列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						],
					),
					const SizedBox(height: 50,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50,),
							GestureDetector(
								onTap: () {
									Navigator.of(context).pushNamed('/enterprise');
								},
								child: const Text("企业列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						],
					),
				],
			),
		);
	}
}
