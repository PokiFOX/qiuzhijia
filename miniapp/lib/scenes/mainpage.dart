import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

import 'package:qiuzhijia/scenes/mainpage/home.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/enterprise.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/offer.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/service.dart' as scenes;
import 'package:qiuzhijia/scenes/mainpage/profile.dart' as scenes;

class MainPageWidget extends StatefulWidget {
	const MainPageWidget({super.key});

	@override
	State<MainPageWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPageWidget> with tapah.Callback {
	int currentindex = 0;
	List<bool> activated = [true, false, false, false, false];

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mainpage, widget.key!);
		addCallback(tapah.EventType.mainpage_activate, (index) {
			setState(() {
				activated[0] = index == 0;
				activated[1] = index == 1;
				activated[2] = index == 2;
				activated[3] = index == 3;
				activated[4] = index == 4;
				currentindex = index;
			});
		});
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SizedBox.expand(
				child: Stack(
					children: [
						Padding(
							padding: const EdgeInsets.only(bottom: 80), 
							child: IndexedStack(
								index: currentindex,
								children: [
									activated[0] ? scenes.HomeWidget(key: tapah.keyMPHome) : const SizedBox.shrink(),
									activated[1] ? scenes.EnterpriseWidget(key: tapah.keyMPEntprise) : const SizedBox.shrink(),
									activated[2] ? scenes.OfferWidget(key: tapah.keyMPOffer) : const SizedBox.shrink(),
									activated[3] ? scenes.ServiceWidget(key: tapah.keyMPService) : const SizedBox.shrink(),
									activated[4] ? scenes.ProfileWidget(key: tapah.keyMPProfile) : const SizedBox.shrink(),
								],
							),
						),
						Positioned(
							left: 0,
							right: 0,
							bottom: 0,
							child: Container(
								height: 80,
								decoration: BoxDecoration(
									image: DecorationImage(
										image: NetworkImage(tapah.parseimage("底部按钮/底部按钮底板.png")),
										fit: BoxFit.fitWidth,
									),
								),
								padding: EdgeInsets.symmetric(horizontal: 10),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceAround,
									crossAxisAlignment: CrossAxisAlignment.end,
									children: [
										GestureDetector(
											onTap: () {
												setState(() {
													activated[0] = true;
													activated[1] = false;
													activated[2] = false;
													activated[3] = false;
													activated[4] = false;
													currentindex = 0;
												});
											},
											child: Column(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													Image.network(tapah.parseimage(activated[0] ? "底部按钮/首页-选中.png" : "底部按钮/首页-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text("首页", style: TextStyle(fontSize: 10, color: Colors.black,),),
												],
											),
										),
										GestureDetector(
											onTap: () {
												setState(() {
													activated[0] = false;
													activated[1] = true;
													activated[2] = false;
													activated[3] = false;
													activated[4] = false;
												});
												currentindex = 1;
											},
											child: Column(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													Image.network(tapah.parseimage(activated[1] ? "底部按钮/招聘企业-选中.png" : "底部按钮/招聘企业-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text("招聘企业", style: TextStyle(fontSize: 10, color: Colors.black,),),
												],
											),
										),
										GestureDetector(
											onTap: () {
												setState(() {
													activated[0] = false;
													activated[1] = false;
													activated[2] = true;
													activated[3] = false;
													activated[4] = false;
													currentindex = 2;
												});
											},
											child: Column(
												mainAxisSize: MainAxisSize.min,
												children: [
													Image.network(tapah.parseimage(activated[2] ? "底部按钮/offer-选中.png" : "底部按钮/offer-普通.png"), width: 60, height: 60, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text("OFFER", style: TextStyle(fontSize: 10, color: Colors.black)),
												],
											),
										),
										GestureDetector(
											onTap: () {
												setState(() {
													activated[0] = false;
													activated[1] = false;
													activated[2] = false;
													activated[3] = true;
													activated[4] = false;
													currentindex = 3;
												});
											},
											child: Column(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													Image.network(tapah.parseimage(activated[3] ? "底部按钮/服务-选中.png" : "底部按钮/服务-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text("服务", style: TextStyle(fontSize: 10, color: Colors.black,),),
												],
											),
										),
										GestureDetector(
											onTap: () {
												setState(() {
													activated[0] = false;
													activated[1] = false;
													activated[2] = false;
													activated[3] = false;
													activated[4] = true;
													currentindex = 4;
												});
											},
											child: Column(
												mainAxisAlignment: MainAxisAlignment.end,
												children: [
													Image.network(tapah.parseimage(activated[4] ? "底部按钮/个人中心-选中.png" : "底部按钮/个人中心-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
													const SizedBox(height: 5),
													Text("个人中心", style: TextStyle(fontSize: 10, color: Colors.black,),),
												],
											),
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
