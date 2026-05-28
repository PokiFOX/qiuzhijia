import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;

class ExampleWidget extends StatefulWidget {
	const ExampleWidget({super.key,});

	@override
	State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> with tapah.Callback {
	int level = 0, sector = 0, stag = 0, year = 0, page = 1;
	int expandindex = -1;
	final ScrollController scrollcontroller = ScrollController();
	bool isLoading = false, isFinish = false;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_example, widget.key!);
		addCallback(tapah.EventType.mainpage_example_casefilter, (selections) {
			page = 1;
			stag = selections[0];
			year = selections[1];
			level = selections[2];
			sector = selections[3];
			setState(() {});
		});
		loadCases();
		scrollcontroller.addListener(() async {
			if (scrollcontroller.position.pixels >= scrollcontroller.position.maxScrollExtent * 0.9) {
				if (isFinish) return;
				if (isLoading) return;
				isLoading = true;
				page++;
				isFinish = await tapah.RequestCaseList(0, level, sector, 0, stag, year, page) < 20;
				isLoading = false;
				setState(() {});
			}
		});
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	Future<void> loadCases() async {
		page = 1;
		tapah.caselist = [];
		isFinish = await tapah.RequestCaseList(0, level, sector, 0, stag, year, page) < 20;
		if (mounted == false) return; 
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return tapah.buildMain1(context, [
			Center(child: Text('过往案例', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
			SizedBox(height: 10),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 10.0),
				child: Row(
					children: [
						Expanded(
							child: Container(
								height: 50,
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(10),
								),
								padding: const EdgeInsets.symmetric(horizontal: 12),
								child: Row(
									children: [
										Icon(Icons.search, size: 18, color: Colors.grey[400]),
										const SizedBox(width: 6),
										Expanded(
											child: TextField(
												style: const TextStyle(fontSize: 14),
												decoration: InputDecoration(
													hintText: '搜索企业/岗位/专业',
													hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
													border: InputBorder.none,
													isCollapsed: true,
													contentPadding: EdgeInsets.zero,
												),
											),
										),
									],
								),
							),
						),
						const SizedBox(width: 10,),
						Container(
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(10),
							),
							width: 100,
							height: 50,
							child: GestureDetector(
								onTap: () {
									tapah.navigator(context, '/mainpage/casefilter', arguments: {"stag": stag, "year": year, "level": level, "sector": sector,});
								},
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text("筛选", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
										const Icon(Icons.arrow_drop_down, size: 15),
									],
								),
							),
						),
					],
				),
			),
			SizedBox(height: 10),
			buildExampleList(),
		]);
	}

	Widget buildExampleList() {
		if (isLoading) {
			return const Center(child: CircularProgressIndicator());
		}
		if (tapah.caselist.isEmpty) {
			return const Center(child: Text("暂无成功案例", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}

		return Padding(
			padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
			child: ListView.separated(
				controller: scrollcontroller,
				padding: EdgeInsets.zero,
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				separatorBuilder: (context, index) => const SizedBox(height: 10),
				itemCount: tapah.caselist.length,
				itemBuilder: (context, index) {
					var c = tapah.caselist[index];
					String tag = '';
					if (c.stag1 == 1 || c.stag2 == 1) {
						tag = "985";
					} else if (c.stag1 == 2 || c.stag2 == 2) {
						tag = "211";
					} else if (c.stag1 == 3 || c.stag2 == 3) {
						tag = "普通";
					} else {
						tag = "海外";
					}
					tapah.Field? field1, field2;
					for (var f in tapah.fieldlist) {
						if (f.value == c.field1) {
							field1 = f;
						}
						if (f.value == c.field2) {
							field2 = f;
						}
					}
					return Container(
						width: double.infinity,
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(8),
						),
						padding: const EdgeInsets.all(10),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.start,
									children: [
										Text(
											c.student ?? "",
											style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D7BFF),)
										),
										const SizedBox(width: 5,),
										Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													c.entname ?? "",
													style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
												),
												Text(
													c.name,
													style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
												),
											],
										),
									],
								),
								const SizedBox(height: 5,),
								Row(
									children: [
										Wrap(
											spacing: 5,
											runSpacing: 3,
									children: c.tags.where((t) => t.trim().isNotEmpty).toList().asMap().entries.map((entry) {
										const tagColors = [
											[Color(0xFFE8F0FE), Color(0xFF2D7BFF)], // 蓝
											[Color(0xFFFEEDDF), Color(0xFF692E1F)], // 金
											[Color(0xFFF3EEFF), Color(0xFF6B21A8)], // 紫
										];
										final bg = tagColors[entry.key % 3][0];
										final fg = tagColors[entry.key % 3][1];
										return Container(
											padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
											decoration: BoxDecoration(
												color: bg,
												borderRadius: BorderRadius.circular(4),
											),
											child: Text(entry.value, style: TextStyle(fontSize: 11, color: fg)),
										);
									}).toList(),
										),
										Expanded(child: Container(),),
										GestureDetector(
											onTap: () {
												setState(() {
													if (expandindex == index) {
														expandindex = -1;
													} else {
														expandindex = index;
													}
												});
											},
											child: Text(expandindex == index ? "收起" : "展开", style: const TextStyle(fontSize: 12, color: Colors.blue),),
										),
									],
								),
								if (expandindex == index) ...[
									const Divider(height: 16, thickness: 0.5),
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Container(
												margin: const EdgeInsets.only(bottom: 6),
												padding: const EdgeInsets.only(left: 8),
												decoration: const BoxDecoration(
													border: Border(left: BorderSide(color: Color(0xFF2D7BFF), width: 3)),
												),
												child: const Text(
													"基础信息",
													style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
												),
											),
											Row(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text("· 学生姓名    	${c.student ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																Text("· 学校层次    	$tag", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																Text("· 本科院校    	${c.school1 ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																GestureDetector(
																	onTap: () {
																		tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field1!.id});
																	},
																	child: Row(
																		children: [
																			Text("· 本科专业    	", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																			Text("${c.field1 ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF2D7BFF))),
																		],
																	),
																),
															],
														),
													),
													const SizedBox(width: 8),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text("· 硕士院校    	${c.school2 ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																GestureDetector(
																	onTap: () {
																		tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field2!.id});
																	},
																	child: Row(
																		children: [
																			Text("· 硕士专业    	", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
																			Text("${c.field2 ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF2D7BFF))),
																		],
																	),
																),
																const SizedBox(height: 2),
																const Text("· 主要实习", style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
																if (c.detail != null && c.detail!.trim().isNotEmpty)
																	widgets.ExpandableText(
																		c.detail!,
																		style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
																		maxLines: 2,
																		expandText: '展开',
																		collapseText: '收起',
																	),
															],
														),
													),
												],
											),
											const SizedBox(height: 10),
											Container(
												margin: const EdgeInsets.only(bottom: 6),
												padding: const EdgeInsets.only(left: 8),
												decoration: const BoxDecoration(
													border: Border(left: BorderSide(color: Color(0xFF2D7BFF), width: 3)),
												),
												child: const Text(
													"求职结果",
													style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
												),
											),
											Text("· 录取岗位    	${c.name}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
											Text("· 所在部门    	${c.dep ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
											Row(
												children: [
													Text("· 去向单位    	", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
													GestureDetector(
														onTap: () async {
															for (var i = 0;i < tapah.enterpriselist.length;i++) {
																if (tapah.enterpriselist[i].name == c.entname) {
																	tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": tapah.enterpriselist[i].id});
																	return;
																}
															}
															var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, 0, null, c.entname ?? '', 1);
															if (enterpriseList.isNotEmpty) {
																tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": enterpriseList[0].id});
															}
														},
														child: Text("${c.entname ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF2D7BFF)),),
													),
												],
											),
										],
									),
								],
							],
						),
					);
				},
			),
		);
	}
}
