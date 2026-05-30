import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class ExampleWidget extends StatefulWidget {
	const ExampleWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> with tapah.Callback {
	List<tapah.Case> cases = [];
	bool isLoading = true;
	int expandindex = -1;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_example, widget.key!);
		loadCases();
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	Future<void> loadCases() async {
		tapah.caselist = [];
		await tapah.RequestCaseList(widget.enterprise.id, 0, 0, 0, 0, 0, 0, 1);
		if (mounted) {
			setState(() {
				cases = List.from(tapah.caselist);
				isLoading = false;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		if (isLoading) {
			return const Center(child: CircularProgressIndicator());
		}
		if (cases.isEmpty) {
			return const Center(child: Text("暂无成功案例", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}

		Widget infoRow(String label, String? value) {
			if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
			return Padding(
				padding: const EdgeInsets.symmetric(vertical: 2),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						SizedBox(
							width: 70,
							child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
						),
						Expanded(
							child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
						),
					],
				),
			);
		}

		Widget child = ListView.separated(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			padding: const EdgeInsets.all(10),
			itemCount: cases.length,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
			itemBuilder: (context, index) {
				var c = cases[index];
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
										Table(
											columnWidths: const {
												0: IntrinsicColumnWidth(),
												1: FlexColumnWidth(1),
											},
											defaultVerticalAlignment: TableCellVerticalAlignment.top,
											children: [
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 学生姓名", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													Text(c.student ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科院校", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													Text(c.school1 ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科层次", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													Text(tapah.stagStr(c.stag1), style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科专业", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													GestureDetector(
														onTap: c.field1 != null ? () { tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field1!.id}); } : null,
														child: Text(c.field1 ?? '--', style: TextStyle(fontSize: 12, color: c.field1 != null ? const Color(0xFF2D7BFF) : const Color(0xFF555555))),
													),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士院校", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													Text(c.school2 ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士层次", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													Text(tapah.stagStr(c.stag2), style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士专业", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													GestureDetector(
														onTap: c.field2 != null ? () { tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field2!.id}); } : null,
														child: Text(c.field2 ?? '--', style: TextStyle(fontSize: 12, color: c.field2 != null ? const Color(0xFF2D7BFF) : const Color(0xFF555555))),
													),
												]),
												TableRow(children: [
													Padding(padding: const EdgeInsets.only(right: 8), child: const Text("· 主要实习", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
													c.detail != null && c.detail!.trim().isNotEmpty
														? Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: c.detail!.split(',').map((s) => Text(
																s.trim(),
																style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
															)).toList(),
														)
														: const SizedBox(),
												]),
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
										Row(
											children: [
												Text("· 去向单位    	", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
												// GestureDetector(
												// 	onTap: () async {
												// 		for (var i = 0;i < tapah.enterpriselist.length;i++) {
												// 			if (tapah.enterpriselist[i].name == c.entname) {
												// 				tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": tapah.enterpriselist[i].id});
												// 				return;
												// 			}
												// 		}
												// 		var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, 0, null, c.entname ?? '', 1);
												// 		if (enterpriseList.isNotEmpty) {
												// 			tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": enterpriseList[0].id});
												// 		}
												// 	},
												// 	child: Text("${c.entname ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF2D7BFF)),),
												// ),
												Text("${c.entname ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),),
											],
										),
										Text("· 所在部门    	${c.dep ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										Text("· 录取岗位    	${c.name}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
									],
								),
							],
						],
					),
				);
			},
		);
		if (tapah.accountinfo == null) {
			return Stack(
				children: [
					child,
					Positioned.fill(
						child: MPFlutter_Wechat_Button(
							openType: "getPhoneNumber",
							onGetPhoneNumber: (result) async {
								await tapah.RequestWxCode(result["code"]);
								if (!mounted) return;
								setState(() {});
							},
							child: ClipRect(
								child: BackdropFilter(
									filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
									child: Container(
										color: Colors.black.withOpacity(0.12),
										alignment: Alignment.center,
										child: const Text(
											'请先登录后查看',
											style: TextStyle(
												color: Colors.white,
												fontSize: 16,
												fontWeight: FontWeight.w600,
											),
										),
									),
								),
							),
						),
					),
				],
			);
		}
		return child;
	}
}
