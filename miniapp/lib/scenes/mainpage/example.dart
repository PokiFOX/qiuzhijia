import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/wigets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/scenes/mainpage/casefilter.dart';

class ExampleWidget extends StatefulWidget {
	const ExampleWidget({super.key,});

	@override
	State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> with tapah.Callback {
	int zone = 0, sector = 0, stag = 0, year = 0, page = 1;
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
			setState(() {});
		});
		loadCases();
		scrollcontroller.addListener(() async {
			if (scrollcontroller.position.pixels >= scrollcontroller.position.maxScrollExtent * 0.9) {
				if (isFinish) return;
				if (isLoading) return;
				isLoading = true;
				page++;
				isFinish = await tapah.RequestCaseList(0, zone, sector, stag, year, page) < 20;
				isLoading = false;
				setState(() {});
			}
		});
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	Future<void> loadCases() async {
		page = 1;
		tapah.caselist = [];
		isFinish = await tapah.RequestCaseList(0, zone, sector, stag, year, page) < 20;
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
		Widget dropdown(int value, List items, ValueChanged<int?> onChanged, String labelText) {
			bool hasValue = items.any((e) => e.id == value);
			return Container(
				height: 20,
				padding: const EdgeInsets.symmetric(horizontal: 8),
				child: DropdownButtonHideUnderline(
					child: DropdownButton<int>(
						isExpanded: true,
						value: hasValue && value != 0 ? value : null,
						hint: Text(labelText, style: const TextStyle(fontSize: 14)),
						icon: const Icon(Icons.arrow_drop_down, size: 15),
						items: items.map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.value, style: const TextStyle(fontSize: 14)))).toList(),
						onChanged: onChanged,
					),
				),
			);
		}

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10.0),
			child: Container(
				decoration: BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.circular(10),
				),
				height: 50,
				child: StatefulBuilder(builder: (context, setState) {
					return Row(
						mainAxisAlignment: MainAxisAlignment.spaceAround,
						children: [
							SizedBox(
								width: 65,
								child: dropdown(zone, tapah.zonelist, (v) {
									zone = v ?? 0;
									loadCases();
								}, "地区"),
							),
							SizedBox(
								width: 65,
								child: dropdown(sector, tapah.sectorlist, (v) {
									sector = v ?? 0;
									loadCases();
								}, "学科"),
							),
							SizedBox(
								width: 100,
								child: GestureDetector(
									onTap: () {
										Navigator.push(context, MaterialPageRoute(builder: (context) => CaseFilterWidget(key: GlobalKey(), zone: zone, stag: stag, sector: sector, year: year,)));
									},
									child: Row(
										children: [
											Text("背景", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
											const Icon(Icons.arrow_drop_down, size: 15),
										],
									),
								),
							),
						],
					);
				}),
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

		return ListView.separated(
			controller: scrollcontroller,
			padding: const EdgeInsets.all(10),
			itemCount: tapah.caselist.length,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
			itemBuilder: (context, index) {
				var c = tapah.caselist[index];
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
								children: [
									c.enticon!.isEmpty ? Container(width: 45, height: 45, color: Colors.grey) : Image.network(tapah.parseimage('小图标/${c.enticon}.png'), width: 45, height: 45,),
									const SizedBox(width: 10),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													c.entname ?? "",
													style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
												),
												const SizedBox(height: 4),
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
											],
										),
									),
								],
							),
							const Divider(height: 16, thickness: 0.5),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									infoRow("学生姓名", c.student),
									infoRow("本科院校", c.school1),
									infoRow("本科专业", c.field1),
									infoRow("硕士院校", c.school2),
									infoRow("硕士专业", c.field2),
									if (c.detail != null && c.detail!.trim().isNotEmpty) ...[
										const SizedBox(height: 6),
										Text("主要经历", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
										const SizedBox(height: 4),
										widgets.ExpandableText(
											c.detail!,
											style: const TextStyle(fontSize: 13, color: Colors.black),
											expandText: '展开',
											collapseText: '收起',
											maxLines: 3,
											linkColor: Colors.blue,
										),
									],
								],
							),
						],
					),
				);
			},
		);
	}
}
