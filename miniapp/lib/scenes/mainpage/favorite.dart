import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable_text/expandable_text.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/scenes/mainpage/fielddetail.dart' as mainpage;

class FavoriteWidget extends StatefulWidget {
	const FavoriteWidget({super.key});

	@override
	State<FavoriteWidget> createState() => FavoriteState();
}

class FavoriteState extends State<FavoriteWidget> with tapah.Callback {
	bool isLoading = true;
	final ScrollController scrollcontroller1 = ScrollController();
	final ScrollController scrollcontroller2 = ScrollController();
	final GlobalKey scrollViewKey = GlobalKey();
	int activeTab = 0;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_favorite, widget.key!);
		tapah.enterpriselist = [];
		tapah.myfieldlist = [];
		WidgetsBinding.instance.addPostFrameCallback((_) async {
			await tapah.RequestFavorite();
			if (mounted == false) return;
			setState(() {
				isLoading = false;
			});
		});
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		Widget list = const Center(child: CircularProgressIndicator());
		if (isLoading == false) {
			if (activeTab == 0) {
				list = buildEnterpriseList();
			} else {
				list = buildFieldList();
			}
		}
		return tapah.buildMain1(context, [
			const Text('我的关注', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
			const SizedBox(height: 10,),
			buildTabHeader(),
			Expanded(
				child: list,
			),
		]);
	}

	Widget buildTabHeader() {
		return Container(
			height: 54,
			padding: const EdgeInsets.symmetric(horizontal: 6),
			decoration: const BoxDecoration(
				color: Color(0xFFF1F2F4),
				border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2), width: 0.7)),
			),
			child: Row(
				children: [
					Expanded(child: buildTabItem('招聘企业', 0)),
					Expanded(child: buildTabItem('招聘专业', 1)),
				],
			),
		);
	}

	Widget buildTabItem(String text, int index) {
		final active = activeTab == index;
		return GestureDetector(
			onTap: () {
				activeTab = index;
				setState(() {});
			},
			child: Container(
				alignment: Alignment.center,
				decoration: BoxDecoration(
					border: Border(
						bottom: BorderSide(color: active ? const Color(0xFF2D7BFF) : Colors.transparent, width: 2),
					),
				),
				child: Text(
					text,
					style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: active ? const Color(0xFF2D7BFF) : const Color(0xFF444444)),
				),
			),
		);
	}

	Widget buildEnterpriseList() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10.0),
			child: ListView.separated(
				controller: scrollcontroller1,
				physics: const BouncingScrollPhysics(),
				padding: EdgeInsets.zero,
				shrinkWrap: false,
				itemCount: tapah.enterpriselist.length,
				separatorBuilder: (context, index) => const SizedBox(height: 10),
				itemBuilder: (context, index) {
					var enterprise = tapah.enterpriselist[index];
					return GestureDetector(
						onTap: () {
							Navigator.pushNamed(context, '/enterprise/detail', arguments: enterprise);
						},
						child: Container(
							height: 100,
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(8),
							),
							padding: const EdgeInsets.all(10),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.start,
								children: [
									Column(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											enterprise.icon!.isEmpty ? Container(width: 45, height: 45, color: Colors.grey) : Image.network(tapah.parseimage('小图标/${enterprise.icon}.png'), width: 45, height: 45,)
										],
									),
									const SizedBox(width: 10),
									Expanded(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.start,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												AutoSizeText(
													enterprise.name!,
													style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
													minFontSize: 10,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
												),
												const SizedBox(height: 4),
												if (enterprise.tags.isNotEmpty) SingleChildScrollView(
													scrollDirection: Axis.horizontal,
													child: Row(
														children: (enterprise.tags).map<Widget>((t) => Container(
															height: 15,
															margin: const EdgeInsets.only(right: 6),
															padding: const EdgeInsets.symmetric(horizontal: 2),
															decoration: BoxDecoration(
																color: Color(0xFFFEEDDF),
																borderRadius: BorderRadius.circular(4),
															),
															child: Text(t, style: const TextStyle(color: Color(0xFF692E1F), fontSize: 10)),
														)).toList(),
													),
												),
												const SizedBox(height: 4),
												Text("${enterprise.zone!.value} ${enterprise.city!}", style: const TextStyle(fontSize: 10),),
											],
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

	Widget buildFieldList() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10.0),
			child: ListView.separated(
				padding: EdgeInsets.zero,
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemCount: tapah.myfieldlist.length,
				separatorBuilder: (context, index) => const SizedBox(height: 10),
				itemBuilder: (context, index) {
					var field = tapah.myfieldlist[index];
					if (field.id == 1) {
						return Container();
					}
					return GestureDetector(
						onTap: () {
							Navigator.push(
								context,
								MaterialPageRoute(
									builder: (context) => mainpage.FieldDetailWidget(key: GlobalKey(),field: field,),
								),
							);
						},
						child: Container(
							width: double.infinity,
							padding: EdgeInsets.all(10),
							decoration: BoxDecoration(
								border: Border.all(color: Color(0xFF2D7BFF), width: 1),
								borderRadius: BorderRadius.circular(8),
							),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.start,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(field.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),),
									const SizedBox(height: 5,),
									Text("学科门类: ${field.type}", style: TextStyle(fontSize: 11, color: Colors.black),),
									Row(
										mainAxisAlignment: MainAxisAlignment.start,
										children: [
											Text("专业热门度:", style: TextStyle(fontSize: 11, color: Colors.black),),
											const SizedBox(width: 5,),
											...List.generate(
												field.star,
												(_) => Icon(Icons.star, size: 16, color: Colors.orange,),
											),
										],
									),
									ExpandableText(field.content, expandText: '展开', collapseText: '收起', maxLines: 3, linkColor: Colors.blue,),
									//widgets.ExpandableText(field.content, expandText: '展开', collapseText: '收起', maxLines: 3, linkColor: Colors.blue,),
								],
							),
						),
					);
				},
			),
		);
	}
}
