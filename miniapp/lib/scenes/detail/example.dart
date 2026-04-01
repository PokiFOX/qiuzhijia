import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/wigets/expandable_text.dart' as widgets;

class ExampleWidget extends StatefulWidget {
	const ExampleWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> with tapah.Callback {
	List<tapah.Case> cases = [];
	bool isLoading = true;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_example, widget.key!);
		loadCases();
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	Future<void> loadCases() async {
		tapah.caselist = [];
		await tapah.RequestCaseList(widget.enterprise.id, 1);
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

		return ListView.separated(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			padding: const EdgeInsets.all(10),
			itemCount: cases.length,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
			itemBuilder: (context, index) {
				var c = cases[index];
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
