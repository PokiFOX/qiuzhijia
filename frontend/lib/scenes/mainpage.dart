import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

import 'package:qiuzhijia/scenes/home.dart' as scenes;
import 'package:qiuzhijia/scenes/enterprise.dart' as scenes;
import 'package:qiuzhijia/scenes/offer.dart' as scenes;
import 'package:qiuzhijia/scenes/service.dart' as scenes;
import 'package:qiuzhijia/scenes/profile.dart' as scenes;

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
				child: IndexedStack(
					index: currentindex,
					children: [
						activated[0] ? scenes.HomeWidget(key: tapah.keyHome,) : Container(),
						activated[1] ? scenes.EnterpriseWidget(key: tapah.keyEnterprise,) : Container(),
						activated[2] ? scenes.OfferWidget(key: tapah.keyOffer,) : Container(),
						activated[3] ? scenes.ServiceWidget(key: tapah.keyService,) : Container(),
						activated[4] ? scenes.ProfileWidget(key: tapah.keyProfile,) : Container(),
					],
				),
			),
			bottomNavigationBar: Container(
				height: 60,
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
									Icon(Icons.home, color: activated[0] ? Colors.blue : Colors.black),
									const SizedBox(height: 22),
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
									Icon(Icons.school, color: activated[1] ? Colors.blue : Colors.black),
									Text("招聘企业", style: TextStyle(fontSize: 12, color: Colors.black,),),
									const SizedBox(height: 5),
								],
							),
						),
						InkWell(
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
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									Icon(Icons.local_offer, size: 35, color: activated[2] ? Colors.blue : Colors.black,),
									Text("Offer", style: TextStyle(fontSize: 12, color: Colors.black,),),
									const SizedBox(height: 5),
								],
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
									currentindex = 3;
								});
							},
							child: Column(
								mainAxisAlignment: MainAxisAlignment.end,
								children: [
									Icon(Icons.room_service, color: activated[3] ? Colors.blue : Colors.black,),
									Text("服务", style: TextStyle(fontSize: 12, color: Colors.black,),),
									const SizedBox(height: 5),
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
									Icon(Icons.center_focus_strong, color: activated[4] ? Colors.blue : Colors.black,),
									Text("关于我们", style: TextStyle(fontSize: 12, color: Colors.black,),),
									const SizedBox(height: 5),
								],
							),
						),
					],
				),
			),
		);
	}
}
