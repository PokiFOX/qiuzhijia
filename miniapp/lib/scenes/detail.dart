import 'dart:async';
import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;

import 'package:qiuzhijia/scenes/detail/brief.dart' as scenes;
import 'package:qiuzhijia/scenes/detail/sector.dart' as scenes;
import 'package:qiuzhijia/scenes/detail/info.dart' as scenes;
import 'package:qiuzhijia/scenes/detail/offer.dart' as scenes;
import 'package:qiuzhijia/scenes/detail/example.dart' as scenes;

class DetailWidget extends StatefulWidget {
	const DetailWidget({super.key});

	@override
	State<DetailWidget> createState() => DetailState();
}

class DetailState extends State<DetailWidget> with tapah.Callback {
	late tapah.Enterprise enterprise;
	bool initialized = false;
	int fenyeindex = 0;
	int topimageindex = 0;
	late PageController topimagecontroller;
	late Timer topimagetimer;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.detail, widget.key!);
		topimagecontroller = PageController();
		startTopImagePlay();
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is tapah.Enterprise) {
			enterprise = args;
			initialized = true;
		}
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

	void openUrl(String? url) {
		if (url == null || url.isEmpty) {
			BotToast.showText(text: '暂无链接');
			return;
		}
		wxapi.wx.setClipboardData(wxapi.SetClipboardDataOption()..data = url);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: SingleChildScrollView(
					scrollDirection: Axis.vertical,
					child: Container(
						decoration: const BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.topCenter, 
								end: Alignment.bottomCenter,
								colors: [
									Color(0xFF7EAEFF),
									Color(0xFFFFFFFF),
								],
							),
						),
						child: Column(
							children: [
								const SizedBox(height: 10),
								buildTopImage(),
								const SizedBox(height: 10),
								buildInfoView(),
								const SizedBox(height: 10),
							],
						),
					),
				),
			),
			bottomNavigationBar: Container(
				height: 60,
				decoration: BoxDecoration(
					color: Colors.white,
					border: Border(top: BorderSide(color: Colors.grey.shade200)),
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						InkWell(
							onTap: () {
								openUrl(enterprise.website1);
							},
							child: Row(
								children: [
									Image.network(tapah.parseimage('企业详情/首页.png'), fit: BoxFit.contain, width: 28, height: 28,),
									Text("首页", style: TextStyle(color: Colors.black, fontSize: 10),),
								],
							),
						),
						const SizedBox(width: 20,),
						InkWell(
							onTap: () {
							},
							child: Row(
								children: [
									Image.network(tapah.parseimage('企业详情/关注.png'), fit: BoxFit.contain, width: 28, height: 28,),
									Text("关注", style: TextStyle(color: Colors.black, fontSize: 10),),
								],
							),
						),
						const SizedBox(width: 20,),
						GestureDetector(
							onTap: () {
							},
							child: Container(
								width: 100,
								height: 30,
								decoration: BoxDecoration(
									color: Color(0xFF82B2F5),
									borderRadius: BorderRadius.circular(15),
								),
								child: Center(
									child: Text("在线咨询", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),
								),
							),
						),
						const SizedBox(width: 20,),
						GestureDetector(
							onTap: () {
							},
							child: Container(
								width: 100,
								height: 30,
								decoration: BoxDecoration(
									color: Color(0xFFFFC300),
									borderRadius: BorderRadius.circular(15),
								),
								child: Center(
									child: Text("电话咨询", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),
								),
							),
						),
					],
				),
			),
		);
	}


	void startTopImagePlay() {
		topimagetimer = Timer.periodic(Duration(seconds: tapah.topimageduration), (timer) {
			int nextIndex = (topimageindex + 1) % enterprise.images.length;
			topimagecontroller.animateToPage(
				nextIndex,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeInOut,
			);
		});
	}


	Widget buildTopImage() {
		Widget topimage = Container();
		if (initialized  && enterprise.images.length > 0) {
			topimage = Image.network(tapah.parseimage('大图标/${enterprise.images[topimageindex]}.png',), fit: BoxFit.contain,);
		}
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: ConstrainedBox(
				constraints: BoxConstraints(maxHeight: 214),
				child: Stack(
					children: [
						PageView.builder(
							controller: topimagecontroller,
							itemCount: enterprise.images.length,
							onPageChanged: (index) {
								setState(() {
									topimageindex = index;
								});
							},
							itemBuilder: (context, index) {
								return topimage;
							},
						),
						Column(
							mainAxisAlignment: MainAxisAlignment.start,
							children: [
								const SizedBox(height: 20),
								Row(
									mainAxisAlignment: MainAxisAlignment.start,
									children: [
										const SizedBox(width: 10),
										IconButton(
											icon: const Icon(Icons.arrow_back, color: Colors.white,),
											onPressed: () {
												Navigator.pop(context);
											},
										),
									],
								),
							],
						),
					],
				),
			),
		);
	}

	Widget buildInfoView() {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(8),
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					const SizedBox(height: 10,),
					SizedBox(
						height: 25,
						child: ListView.builder(
							scrollDirection: Axis.horizontal,
							itemCount: tapah.entfenyes.length,
							itemBuilder: (context, index) {
								return GestureDetector(
									onTap: () => setState(() => fenyeindex = index),
									child: Container(
										padding: EdgeInsets.symmetric(horizontal: 8),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.end,
											children: [
												Text(tapah.entfenyes[index], style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: fenyeindex == index ? FontWeight.bold : FontWeight.normal),),
											],
										),
									),
								);
							},
						),
					),
					const SizedBox(height: 10,),
					IndexedStack(
						index: fenyeindex,
						children: [
							scenes.BriefWidget(key: tapah.keyDTBrief, enterprise: enterprise),
							scenes.SectorWidget(key: tapah.keyDTSector, enterprise: enterprise),
							scenes.InfoWidget(key: tapah.keyDTInfo, enterprise: enterprise),
							scenes.OfferWidget(key: tapah.keyDTOffer, enterprise: enterprise),
							scenes.ExampleWidget(key: tapah.keyDTExample, enterprise: enterprise),
						],
					),
				],
			),
		);
	}
}
