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
import 'package:qiuzhijia/scenes/detail/field.dart' as scenes;
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
	late ScrollController scrollcontroller;
	final List<GlobalKey> sectionKeys = List.generate(5, (_) => GlobalKey());
	final GlobalKey tabbarkey = GlobalKey();
	bool isscrollingtosection = false;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.detail, widget.key!);
		topimagecontroller = PageController();
		scrollcontroller = ScrollController()..addListener(onScroll);
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is tapah.Enterprise) {
			enterprise = args;
			initialized = true;
			if (enterprise.images.isNotEmpty) {
				startTopImagePlay();
			}
		}
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	void dispose() {
		if (enterprise.images.isNotEmpty) {
			topimagetimer.cancel();
		}
		topimagecontroller.dispose();
		scrollcontroller.dispose();
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
				child: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topCenter, 
							end: Alignment.bottomCenter,
							colors: [
								Color(0xFF7EAEFF),
								Color(0xFFFFFFFF),
							],
							stops: [0.0, 0.3],
						),
					),
					child: CustomScrollView(
						controller: scrollcontroller,
						slivers: [
							const SliverToBoxAdapter(child: SizedBox(height: 10)),
							SliverToBoxAdapter(child: buildTopImage()),
							const SliverToBoxAdapter(child: SizedBox(height: 10)),
							SliverPersistentHeader(
								pinned: true,
								delegate: TabBarDelegate(
									child: Container(
										key: tabbarkey,
										decoration: BoxDecoration(
											color: Colors.white,
											border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
										),
										child: buildTabBar(),
									),
								),
							),
							SliverToBoxAdapter(child: buildSections()),
							const SliverToBoxAdapter(child: SizedBox(height: 10)),
						],
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
		if (initialized == false || enterprise.images.isEmpty) {
			return Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
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
			);
		}
		return ConstrainedBox(
			constraints: BoxConstraints(maxHeight: 200, minHeight: 200,),
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
							return Image.network(tapah.parseimage('大图标/${enterprise.images[topimageindex]}.png',), fit: BoxFit.cover,);
						},
					),
					Column(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
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
		);
	}

	void onScroll() {
		if (isscrollingtosection) return;
		final tabBarContext = tabbarkey.currentContext;
		if (tabBarContext == null) return;
		final tabBarBox = tabBarContext.findRenderObject() as RenderBox;
		final tabBarBottom = tabBarBox.localToGlobal(Offset.zero).dy + tabBarBox.size.height;
		for (int i = sectionKeys.length - 1; i >= 0; i--) {
			final keyContext = sectionKeys[i].currentContext;
			if (keyContext != null) {
				final renderBox = keyContext.findRenderObject() as RenderBox;
				final position = renderBox.localToGlobal(Offset.zero);
				if (position.dy <= tabBarBottom + 20) {
					if (fenyeindex != i) {
						setState(() => fenyeindex = i);
					}
					return;
				}
			}
		}
	}

	void scrollToSection(int index) async {
		isscrollingtosection = true;
		setState(() => fenyeindex = index);
		final keyContext = sectionKeys[index].currentContext;
		if (keyContext != null) {
			await Scrollable.ensureVisible(
				keyContext,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeInOut,
				alignment: 0.0,
			);
		}
		isscrollingtosection = false;
	}

	Widget buildTabBar() {
		return SizedBox(
			height: 35,
			child: ListView.builder(
				scrollDirection: Axis.horizontal,
				itemCount: tapah.entfenyes.length,
				itemBuilder: (context, index) {
					return GestureDetector(
						onTap: () => scrollToSection(index),
						child: Container(
							padding: EdgeInsets.symmetric(horizontal: 8),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text(tapah.entfenyes[index], style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: fenyeindex == index ? FontWeight.bold : FontWeight.normal),),
									const SizedBox(height: 2),
									Container(
										height: 2,
										width: 20,
										color: fenyeindex == index ? Color(0xFF2D7BFF) : Colors.transparent,
									),
								],
							),
						),
					);
				},
			),
		);
	}

	Widget buildSections() {
		if (!initialized) return const SizedBox.shrink();
		final sections = <Widget>[
			scenes.BriefWidget(key: tapah.keyDTBrief, enterprise: enterprise),
			scenes.FieldWidget(key: tapah.keyDTField, enterprise: enterprise),
			scenes.InfoWidget(key: tapah.keyDTInfo, enterprise: enterprise),
			scenes.OfferWidget(key: tapah.keyDTOffer, enterprise: enterprise),
			scenes.ExampleWidget(key: tapah.keyDTExample, enterprise: enterprise),
		];
		List<Widget> children = [];
		for (int i = 0; i < sections.length; i++) {
			if (i > 0) {
				children.add(Divider(height: 20, thickness: 8, color: Colors.grey.shade100));
			}
			children.add(Container(
				key: sectionKeys[i],
				padding: const EdgeInsets.symmetric(vertical: 10),
				child: sections[i],
			));
		}
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
			),
			child: Column(children: children),
		);
	}
}

class TabBarDelegate extends SliverPersistentHeaderDelegate {
	final Widget child;
	TabBarDelegate({required this.child});

	@override
	Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
		return child;
	}

	@override
	double get maxExtent => 35;

	@override
	double get minExtent => 35;

	@override
	bool shouldRebuild(covariant TabBarDelegate oldDelegate) => true;
}
