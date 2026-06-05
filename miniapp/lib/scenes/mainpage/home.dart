import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;
import 'package:mpflutter_wechat_webview/mpflutter_wechat_webview.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/const.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

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
	List<tapah.Article> articles = [];
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
		WidgetsBinding.instance.addPostFrameCallback((_) async {
			await tapah.RequestArticle1();
			articles = tapah.article1;
			metas = {};
			_loadingArticles.clear();
			displayCount = 5;
			if (mounted == false) return;
			setState(() {});
		});
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
		return SafeArea(
			child: Container(
				height: double.infinity,
				child: ListView.separated(
					controller: scrollController,
					padding: const EdgeInsets.symmetric(horizontal: 10),
					itemCount: 5 + (articles.isEmpty ? 1 : displayCount.clamp(0, articles.length)),
					itemBuilder: (context, index) {
						if (index == 0) {
							return buildTopImage();
						}
						if (index == 1 || index == 3) {
							return const SizedBox(height: 20);
						}
						if (index == 2) {
							return buildLanMuList();
						}
						if (index == 4) {
							return buildFenYeList();
						}
						if (articles.isEmpty) {
							return const Center(child: Text("暂无文章", style: TextStyle(fontSize: 16, color: Colors.grey)));
						}
						var article = articles[index - 5];
						if (metas.containsKey(index - 5) == false) {
							loadArticles(index - 5);
						}
						var meta = metas[index - 5];
						return GestureDetector(
							onTap: () {
								MPFlutter_Wechat_WebView.open(article.article, onLoad: (_) {
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
													],
												),
											),
										),
									],
								),
							),
						);
					},
					separatorBuilder: (context, index) {
						if (index >= 3 && articles.isNotEmpty) {
							return const Divider(height: 1, thickness: 1, indent: 15, endIndent: 15);
						}
						return const SizedBox.shrink();
					},
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
					childAspectRatio: 0.85,
				),
				itemCount: tapah.lanmus.length,
				itemBuilder: (context, index) {
					var lanmu = tapah.lanmus[index];
					return GestureDetector(
						onTap: () {
							if (index == 0) {
								tapah.navigator(context, "/mainpage", arguments: {"index": 1});
							}
							if (index == 1) {
								tapah.navigator(context, '/mainpage/field');
							}
							if (index == 3) {
								// if (tapah.accountinfo == null) {
								// 	tapah.navigator(context, '/mainpage/profile');
								// 	return;
								// }
								tapah.navigator(context, '/mainpage/example');
							}
							if (index == 4) {
								// MPFlutter_Wechat_WebView.open(tapah.url_boardcast, onLoad: (_) {
								// 	print("webview loaded");
								// });
								wxapi.NavigateToMiniProgramOption option = wxapi.NavigateToMiniProgramOption();
								option.appId = tapah.url_mpid;
								option.path = "/pages/entry/share?o=store&type=39&id=2";
								option.success = (result) {
									print("navigateToMiniProgram success: $result");
								};
								option.fail = (error) {
									print("navigateToMiniProgram fail: $error");
								};
								wxapi.wx.navigateToMiniProgram(option);
							}
							if (index == 5) {
								tapah.navigator(context, '/lanmu/qiuzhiziliao');
							}
							if (index == 6) {
								tapah.navigator(context, '/lanmu/shixineitui');
							}
							if (index == 7) {
								tapah.navigator(context, '/lanmu/gangweineitui');
							}
							if (index == 8) {
								tapah.navigator(context, '/lanmu/zixunguwen');
							}
							if (index == 9) {
								tapah.navigator(context, '/lanmu/bishitiku');
							}
							if (index == 10) {
								tapah.navigator(context, '/lanmu/mianshijingyan');
							}
							if (index == 11) {
								tapah.navigator(context, '/lanmu/qiuzhifuwu');
							}
						},
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Image.network(tapah.parseimage(lanmu.image), width: 53, height: 53,),
								Text(lanmu.title, style: TextStyle(fontSize: 12)),
							],
						),
					);
				},
			),
		);
	}

	Widget buildFenYeList() {
		//return Padding(
		//	padding: const EdgeInsets.symmetric(horizontal: 10),
		//	child: SizedBox(
		//		height: 25,
		//		child: ListView.builder(
		//			scrollDirection: Axis.horizontal,
		//			itemCount: tapah.fenyes.length,
		//			itemBuilder: (context, index) {
		//				var fenye = tapah.fenyes[index];
		//				bool isSelected = fenyeindex == index;
		//				return GestureDetector(
		//					onTap: () async {
		//						if (index == 1) {
		//							await tapah.RequestArticle1();
		//							articles = tapah.article1;
		//							metas = {};
		//							_loadingArticles.clear();
		//							displayCount = 5;
		//						}
		//						if (index == 2) {
		//							await tapah.RequestArticle2();
		//							articles = tapah.article2;
		//							metas = {};
		//							_loadingArticles.clear();
		//							displayCount = 5;
		//						}
		//						setState(() {
		//							fenyeindex = index;
		//						});
		//					},
		//					child: Container(
		//						padding: EdgeInsets.symmetric(horizontal: 8),
		//						child: Column(
		//							mainAxisAlignment: MainAxisAlignment.end,
		//							children: [
		//								Text(fenye.title, style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),),
		//							],
		//						),
		//					),
		//				);
		//			},
		//		),
		//	),
		//);
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10),
			child: Container(
				height: 25,
				width: double.infinity,
				decoration: BoxDecoration(
					color: Colors.blue,
				),
				child: Center(
					child: Text("求职解析", style: TextStyle(fontSize: 13, color: Colors.white),),
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
			var meta = await tapah.RequestArticleMeta(articles[index].article.trim());
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
}
