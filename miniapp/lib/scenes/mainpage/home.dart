import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_webview/mpflutter_wechat_webview.dart';
import 'package:qiuzhijia/scenes/lanmu/bishitiku.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/scenes/mainpage/field.dart';
import 'package:qiuzhijia/scenes/mainpage/example.dart';
import 'package:qiuzhijia/scenes/lanmu/qiuzhiziliao.dart';
import 'package:qiuzhijia/scenes/lanmu/shixineitui.dart';
import 'package:qiuzhijia/scenes/lanmu/gangweineitui.dart';
import 'package:qiuzhijia/scenes/lanmu/qiuzhifuwu.dart';
import 'package:qiuzhijia/scenes/lanmu/mianshijingyan.dart';
import 'package:qiuzhijia/scenes/lanmu/zixunguwen.dart';

class HomeWidget extends StatefulWidget {
	const HomeWidget({super.key});

	@override
	State<HomeWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> with tapah.Callback {
	int topimageindex = 0, lanmuindex = 0, fenyeindex = 0;
	late PageController topimagecontroller;
	late Timer topimagetimer;
	late ScrollController scrollController;
	List<String> articles = [];
	Map<int, tapah.ArticleMeta> metas = {};
	int displayCount = 5;
	bool isLoadingMore = false;
	final Set<int> _loadingArticles = {};

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_home, widget.key!);
		topimagecontroller = PageController();
		scrollController = ScrollController();
		scrollController.addListener(_onScroll);
		startTopImagePlay();
	}

	@override
	void dispose() {
		topimagetimer.cancel();
		topimagecontroller.dispose();
		scrollController.dispose();
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
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					const SizedBox(height: 10),
					buildTopImage(),
					const SizedBox(height: 10),
					buildLanMuList(),
					const SizedBox(height: 10),
					buildFenYeList(),
					const SizedBox(height: 10),
					Expanded(child: buildWebsites()),
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

	Widget buildTopImage() {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: AspectRatio(
				aspectRatio: 16 / 9,
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
								return ClipRRect(
									borderRadius: BorderRadius.circular(8),
									child: Image.network(tapah.parseimage(tapah.imageurls[index]), fit: BoxFit.cover, width: double.infinity,),
								);
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
				padding: EdgeInsets.zero,
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
							if (index == 4) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => ZiXunGuWenWidget(key: GlobalKey(),)));
							}
							if (index == 5) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => QiuZhiZiLiaoWidget(key: GlobalKey(),)));
							}
							if (index == 6) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => ShiXiNeiTuiWidget(key: GlobalKey(),)));
							}
							if (index == 7) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => GangWeiNeiTuiWidget(key: GlobalKey(),)));
							}
							if (index == 8) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => BiShiTiKuWidget(key: GlobalKey(),)));
							}
							if (index == 9) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => MianShiJingYanWidget(key: GlobalKey(),)));
							}
							if (index == 10) {
								Navigator.push(context, MaterialPageRoute(builder: (context) => QiuZhiFuWuWidget(key: GlobalKey(),)));
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
							onTap: () async {
								if (index == 1) {
									await tapah.RequestArticle1();
									articles = tapah.article1;
									metas = {};
									_loadingArticles.clear();
									displayCount = 5;
								}
								if (index == 2) {
									await tapah.RequestArticle2();
									articles = tapah.article2;
									metas = {};
									_loadingArticles.clear();
									displayCount = 5;
								}
								setState(() {
									fenyeindex = index;
								});
							},
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

	void _onScroll() {
		if (isLoadingMore) return;
		if (displayCount >= articles.length) return;
		if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
			setState(() {
				isLoadingMore = true;
				displayCount = (displayCount + 5).clamp(0, articles.length);
				isLoadingMore = false;
			});
		}
	}

	Future<void> loadArticles(int index) async {
		if (_loadingArticles.contains(index)) return;
		_loadingArticles.add(index);
		try {
			var meta = await tapah.RequestArticleMeta(articles[index].trim());
			if (_loadingArticles.contains(index) == false) return;
			if (mounted) {
				setState(() {
					metas[index] = meta;
				});
			}
		} finally {
			_loadingArticles.remove(index);
		}
	}

	Widget buildWebsites() {
		if (articles.isEmpty) {
			return const Center(child: Text("暂无文章", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}
		final int count = displayCount.clamp(0, articles.length);
		final bool hasMore = displayCount < articles.length;
		return ListView.separated(
			controller: scrollController,
			padding: const EdgeInsets.all(10),
			itemCount: hasMore ? count + 1 : count,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
			itemBuilder: (context, index) {
				if (hasMore && index == count) {
					return const Padding(
						padding: EdgeInsets.symmetric(vertical: 12),
						child: Center(child: Text("上拉加载更多", style: TextStyle(fontSize: 13, color: Colors.grey))),
					);
				}
				var article = articles[index];
				if (metas.containsKey(index) == false) {
					loadArticles(index);
				}
				var meta = metas[index];
				return GestureDetector(
					onTap: () {
						MPFlutter_Wechat_WebView.open(article, onLoad: (_) {
							print("webview loaded");
						});
					},
					child: Container(
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(8),
						),
						padding: const EdgeInsets.all(10),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								ClipRRect(
									borderRadius: BorderRadius.circular(6),
									child: meta != null && meta.image.isNotEmpty ? Image.network(
										meta.image,
										width: 100,
										height: 80,
										fit: BoxFit.cover,
										errorBuilder: (context, error, stackTrace) => Container(
											width: 100,
											height: 80,
											color: Colors.grey[200],
											child: const Icon(Icons.article, size: 36, color: Colors.grey),
										),
									) : Container(
										width: 100,
										height: 80,
										color: Colors.grey[200],
										child: const Icon(Icons.article, size: 36, color: Colors.grey),
									),
								),
								const SizedBox(width: 10),
								Expanded(
									child: SizedBox(
										height: 80,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													meta != null && meta.title.isNotEmpty ? meta.title : "未知标题",
													style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
													maxLines: 2,
													overflow: TextOverflow.ellipsis,
												),
												const SizedBox(height: 4),
												Expanded(
													child: Text(
														meta != null && meta.description.isNotEmpty ? meta.description : "",
														style: TextStyle(fontSize: 12, color: Colors.grey[600]),
														maxLines: 2,
														overflow: TextOverflow.ellipsis,
													),
												),
												Align(
													alignment: Alignment.bottomRight,
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															Icon(Icons.visibility, size: 14, color: Colors.grey[400]),
															const SizedBox(width: 2),
															Text(
																"${meta != null ? meta.clicks : 0}",
																style: TextStyle(fontSize: 12, color: Colors.grey[400]),
															),
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
			},
		);
	}
}
