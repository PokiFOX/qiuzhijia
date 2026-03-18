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
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Column(
					children: [
						IndexedStack(
							index: currentindex,
							children: [
								activated[0] ? scenes.HomeWidget(key: tapah.keyMPHome,) : Container(),
								activated[1] ? scenes.EnterpriseWidget(key: tapah.keyMPEntprise,) : Container(),
								activated[2] ? scenes.OfferWidget(key: tapah.keyMPOffer,) : Container(),
								activated[3] ? scenes.ServiceWidget(key: tapah.keyMPService,) : Container(),
								activated[4] ? scenes.ProfileWidget(key: tapah.keyMPProfile,) : Container(),
							],
						),
					],
				),
			),
			bottomNavigationBar: Container(
				height: 80,
				decoration: BoxDecoration(
					color: Colors.white,
					border: Border(top: BorderSide(color: Colors.grey.shade200)),
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceAround,
					children: [
						InkWell(
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
									const SizedBox(height: 10,),
									Image.network(tapah.parseimage(activated[0] ? "首页-选中.png" : "首页-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
									const SizedBox(height: 5),
									Text("首页", style: TextStyle(fontSize: 14, color: Colors.black,),),
									const SizedBox(height: 10,),
								],
							),
						),
						InkWell(
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
									const SizedBox(height: 10,),
									Image.network(tapah.parseimage(activated[1] ? "招聘企业-选中.png" : "招聘企业-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
									const SizedBox(height: 5),
									Text("招聘企业", style: TextStyle(fontSize: 14, color: Colors.black,),),
									const SizedBox(height: 10,),
								],
							),
						),
						Transform.translate(
							offset: const Offset(0, -25),
							child: InkWell(
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
										const SizedBox(height: 10),
										Image.network(tapah.parseimage(activated[2] ? "offer-选中.png" : "offer-普通.png"), width: 60, height: 60, fit: BoxFit.contain,),
										const SizedBox(height: 5),
										Text("Offer", style: TextStyle(fontSize: 14, color: Colors.black)),
										const SizedBox(height: 10),
									],
								),
							),
						),
						InkWell(
							onTap: () {
								setState(() {
									activated[0] = false;
									activated[1] = false;
									activated[2] = false;
									activated[3] = true;
									activated[4] = false;
									currentindex = 4;
								});
							},
							child: Column(
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									const SizedBox(height: 10,),
									Image.network(tapah.parseimage(activated[3] ? "服务-选中.png" : "服务-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
									const SizedBox(height: 5),
									Text("服务", style: TextStyle(fontSize: 14, color: Colors.black,),),
									const SizedBox(height: 10,),
								],
							),
						),
						InkWell(
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
									const SizedBox(height: 10,),
									Image.network(tapah.parseimage(activated[4] ? "个人中心-选中.png" : "个人中心-普通.png"), width: 30, height: 30, fit: BoxFit.contain,),
									const SizedBox(height: 5),
									Text("个人中心", style: TextStyle(fontSize: 14, color: Colors.black,),),
									const SizedBox(height: 10,),
								],
							),
						),
					],
				),
			),
		);
	}
}
