import 'dart:async';
import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;

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
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	void dispose() {
		topimagetimer.cancel();
		topimagecontroller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					buildHeader(),
					SizedBox(height: 10),
					buildTopImage(),
					SizedBox(height: 10),
					buildLanMuList(),
					SizedBox(height: 10),
					buildFenYeList(),
					SizedBox(height: 10),
				],
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

	Widget buildHeader() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.start,
			children: [
				SizedBox(width: 20),
				Icon(Icons.home, color: Colors.blue),
				SizedBox(width: 10),
				SizedBox(
					width: 200,
					child: TextField(
						decoration: InputDecoration(
							prefixIcon: Icon(Icons.search, color: Colors.grey),
							hintText: '雅思口语AI评测',
							hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(8),
								borderSide: BorderSide.none,
							),
							filled: true,
							fillColor: Colors.grey[200],
							contentPadding: EdgeInsets.symmetric(vertical: 12),
						),
					),
				),
			],
		);
	}

	Widget buildTopImage() {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: ConstrainedBox(
				constraints: BoxConstraints(maxHeight: 200),
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
		return Column(
			children: [
				GestureDetector(
					onHorizontalDragEnd: (details) {
						setState(() {
							if (details.primaryVelocity! > 0) {
								if (lanmuindex < (tapah.lanmus.length / 10).ceil() - 1) lanmuindex++;
							} else if (details.primaryVelocity! < 0) {
								if (lanmuindex > 0) lanmuindex--;
							}
						});
					},
					child: SizedBox(
						height: 180,
						child: PageView.builder(
							itemCount: (tapah.lanmus.length / 10).ceil(),
							onPageChanged: (index) {
								setState(() {
									lanmuindex = index;
								});
							},
							itemBuilder: (context, pageIndex) {
								int startIndex = lanmuindex * 10;
								int endIndex = (startIndex + 10).clamp(0, tapah.lanmus.length);
								List lanmuPage = tapah.lanmus.sublist(startIndex, endIndex);
								return GridView.builder(
									physics: const NeverScrollableScrollPhysics(),
									gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: 5,
										mainAxisSpacing: 10,
										crossAxisSpacing: 10,
										childAspectRatio: 0.8,
									),
									itemCount: lanmuPage.length,
									padding: const EdgeInsets.symmetric(horizontal: 20),
									itemBuilder: (context, index) {
										var lanmu = lanmuPage[index];
										return GestureDetector(
											onTap: () {
											},
											child: Column(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													Image.network(tapah.parseimage(lanmu.image), width: 40, height: 40, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text(
														lanmu.title,
														style: const TextStyle(fontSize: 12),
														overflow: TextOverflow.ellipsis,
													),
												],
											),
										);
									},
								);
							},
						),
					),
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: List.generate((tapah.lanmus.length / 10).ceil(), (index) {
						return Container(
							margin: const EdgeInsets.symmetric(horizontal: 4),
							width: 20,
							height: 3,
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(2),
								color: lanmuindex == index ? Colors.blue : Colors.grey[300],
							),
						);
					}),
				),
			],
		);
	}

	Widget buildFenYeList() {
		return Container(
			height: 60, 
			child: ListView.builder(
				scrollDirection: Axis.horizontal,
				itemCount: tapah.fenyes.length,
				itemBuilder: (context, index) {
					bool isSelected = fenyeindex == index;
					return GestureDetector(
						onTap: () => setState(() => fenyeindex = index),
						child: Container(
							padding: EdgeInsets.symmetric(horizontal: 15),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text(tapah.fenyes[index], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,),),
									Opacity(
										opacity: isSelected ? 1.0 : 0.0,
										child: Padding(
											padding: const EdgeInsets.only(top: .0, left: 25),
											child: Image.asset('assets/images/select.png', width: 20, height: 10, fit: BoxFit.contain,),
										),
									),
								],
							),
						),
					);
				},
			),
		);
	}
}
