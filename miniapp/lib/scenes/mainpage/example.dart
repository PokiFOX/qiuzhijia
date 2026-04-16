import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/scenes/mainpage/casefilter.dart';
import 'package:qiuzhijia/scenes/mainpage/field.dart';

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
		return Material(
			child: Container(
				height: double.infinity,
				decoration: const BoxDecoration(
					color: Color(0xFFE2EDFF),
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 50),
						Row(
							children: [
								GestureDetector(
									onTap: () {
										Navigator.pop(context);
									},
									child: Container(
										width: 50,
										height: 30,
										margin: const EdgeInsets.only(left: 10),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(15),
										),
										child: const Icon(Icons.arrow_back, size: 15,),
									),
								),
								const SizedBox(width: 10),
								Text('过往案例', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
							],
						),
						SizedBox(height: 10),
						buildFilterRow(),
						SizedBox(height: 10),
						Expanded(child: buildExampleList(),),
						SizedBox(height: 10),
					],
				),
			),
		);
	}

	Widget buildFilterRow() {
		return Padding(
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
								Navigator.push(context, MaterialPageRoute(builder: (context) => CaseFilterWidget(key: GlobalKey(), level: level, sector: sector, stag: stag, year: year,)));
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
		);
	}

	Widget buildExampleList() {
		if (isLoading) {
			return const Center(child: CircularProgressIndicator());
		}
		if (tapah.caselist.isEmpty) {
			return const Center(child: Text("暂无成功案例", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}

		return ListView.separated(
			controller: scrollcontroller,
			padding: const EdgeInsets.all(10),
			itemCount: tapah.caselist.length,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
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
										children: c.tags.where((t) => t.trim().isNotEmpty).map((tag) => Container(
											padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
											decoration: BoxDecoration(
												color: const Color(0xFFE8F0FE),
												borderRadius: BorderRadius.circular(4),
											),
											child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF2D7BFF))),
										)).toList(),
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
																	Navigator.push(context, MaterialPageRoute(builder: (context) => FieldWidget(key: GlobalKey(), field: field1!,)));
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
																	Navigator.push(context, MaterialPageRoute(builder: (context) => FieldWidget(key: GlobalKey(), field: field2!,)));
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
																var enterprise = tapah.enterpriselist[i];
																Navigator.pushNamed(context, '/enterprise/detail', arguments: enterprise);
																return;
															}
														}
														var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, 0, null, c.entname ?? '', 1);
														if (enterpriseList.isNotEmpty) {
															Navigator.pushNamed(context, '/enterprise/detail', arguments: enterpriseList[0]);
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
		);
	}
}
