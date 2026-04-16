import 'dart:async';
import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;
import 'package:qiuzhijia/scenes/mainpage/field.dart';
import 'package:qiuzhijia/scenes/mainpage/example.dart';

class HomeWidget extends StatefulWidget {
	const HomeWidget({super.key});

	@override
	State<HomeWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> with tapah.Callback {
	int topimageindex = 0, lanmuindex = 0, fenyeindex = 0;
	late PageController topimagecontroller;
	late Timer topimagetimer;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_home, widget.key!);
		topimagecontroller = PageController();
		startTopImagePlay();
	}

	@override
	void dispose() {
		topimagetimer.cancel();
		topimagecontroller.dispose();
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			height: double.infinity,
			decoration: const BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topCenter, 
					end: Alignment.bottomCenter,
					colors: [
						Color(0xFF156CFF),
						Color(0xFF7EAEFF),
						Color(0xFFFFFFFF),
					],
				),
			),
			child: SingleChildScrollView(
				scrollDirection: Axis.vertical,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 10),
						buildTopImage(),
						buildLanMuList(),
						SizedBox(height: 10),
						buildFenYeList(),
						SizedBox(height: 10),
					],
				),
			),
		);
	}

	void startTopImagePlay() {
		topimagetimer = Timer.periodic(Duration(seconds: tapah.topimageduration), (timer) {
			int nextIndex = (topimageindex + 1) % tapah.imageurls.length;
			topimagecontroller.animateToPage(
				nextIndex,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeInOut,
			);
		});
	}

	Widget buildTopImage() {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: ConstrainedBox(
				constraints: BoxConstraints(maxHeight: 214),
				child: Stack(
					children: [
						PageView.builder(
							controller: topimagecontroller,
							itemCount: tapah.imageurls.length,
							onPageChanged: (index) {
								setState(() {
									topimageindex = index;
								});
							},
							itemBuilder: (context, index) {
								return Image.network(tapah.parseimage(tapah.imageurls[index]), fit: BoxFit.contain,);
							},
						),
						Positioned(
							bottom: 10,
							left: 0,
							right: 0,
							child: Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: List.generate(tapah.imageurls.length, (index) {
									return Container(
										margin: const EdgeInsets.symmetric(horizontal: 4),
										width: 8,
										height: 8,
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: topimageindex == index ? Colors.blue : Colors.grey,
										),
									);
								}),
							),
						),
					],
				),
			),
		);
	}

	Widget buildLanMuList() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20),
			child: GridView.builder(
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: 4,
					mainAxisSpacing: 18,
					crossAxisSpacing: 18,
				),
				itemCount: tapah.lanmus.length,
				itemBuilder: (context, index) {
					var lanmu = tapah.lanmus[index];
					return GestureDetector(
						onTap: () {
							if (index == 0) {
								tapah.EventManager().call(tapah.SceneID.mainpage, tapah.EventType.mainpage_activate, [1]);
							}
							if (index == 1) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => FieldWidget(key: GlobalKey(),)));
							}
							if (index == 3) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleWidget(key: GlobalKey(),)));
							}
						},
						child: SizedBox(
							width: 53,
							height: 53,
							child: Column(
								children: [
									Image.network(tapah.parseimage(lanmu.image), width: 53, height: 53,),
									Text(lanmu.title, style: TextStyle(fontSize: 12)),
								],
							),
						),
					);
				},
			),
		);
	}

	Widget buildFenYeList() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: SizedBox(
				height: 25,
				child: ListView.builder(
					scrollDirection: Axis.horizontal,
					itemCount: tapah.fenyes.length,
					itemBuilder: (context, index) {
						var fenye = tapah.fenyes[index];
						bool isSelected = fenyeindex == index;
						return GestureDetector(
							onTap: () => setState(() => fenyeindex = index),
							child: Container(
								padding: EdgeInsets.symmetric(horizontal: 8),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.end,
									children: [
										Text(fenye.title, style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),),
									],
								),
							),
						);
					},
				),
			),
		);
	}
}
