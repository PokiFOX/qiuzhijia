import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:expandable_text/expandable_text.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class BriefWidget extends StatefulWidget {
	const BriefWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<BriefWidget> createState() => BriefState();
}

class BriefState extends State<BriefWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_brief, widget.key!);
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					buildTitle(),
					const SizedBox(height: 5,),
					Padding(
						padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
						child: ExpandableText(
							widget.enterprise.brief ?? '',
							expandText: '展开',
							collapseText: '收起',
							maxLines: 3,
							linkColor: Colors.blue,
						),
					),
					const SizedBox(height: 10,),
					buildInfo(),
					const SizedBox(height: 10,),
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							SizedBox(width: 10,),
							Text("招聘专业", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,),),
							Expanded(child: Container(),),
							Icon(Icons.search, size: 16,),
							SizedBox(width: 10,),
						],
					),
					const SizedBox(height: 10,),
					buildSector(),
				],
			),
		);
	}

	Widget buildTitle() {
		return Container(
			height: 90,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					const SizedBox(width: 10),
					Expanded(
						child: Container(
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(8),
							),
							padding: const EdgeInsets.all(10),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.start,
								children: [
									Expanded(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.start,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(widget.enterprise.name!),
												const SizedBox(height: 4),
												SingleChildScrollView(
													scrollDirection: Axis.horizontal,
													child: Row(
														children: (widget.enterprise.tags).map<Widget>((t) => Container(
															margin: const EdgeInsets.only(right: 6),
															padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
															decoration: BoxDecoration(
																color: Colors.blue,
																borderRadius: BorderRadius.circular(4),
															),
															child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10)),
														)).toList(),
													),
												),
												const SizedBox(height: 4),
												Text("${widget.enterprise.zone!.value} ${widget.enterprise.city!}", style: const TextStyle(fontSize: 10),),
											],
										),
									),
									const SizedBox(width: 10),
									Column(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											Icon(Icons.stop, size: 70,),
										],
									),
								],
							),
						),
					),
					const SizedBox(width: 10),
				],
			),
		);
	}

	Widget buildInfo() {
		TableRow buildRow(String title, String info, String action, Function? onclick) {
			return TableRow(
				children: [
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,),),
					),
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: Padding(
							padding: const EdgeInsets.all(6.0),
							child: Text(info, style: TextStyle(fontSize: 12, color: action == "" ? Colors.black : Colors.blue),),
						),
					),
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: Text(action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: action == "" ? Colors.black : Colors.blue),),
					),
				],
			);
		}

		return Padding(
			padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
			child: Table(
				columnWidths: const {
					0: FixedColumnWidth(70),
					1: FlexColumnWidth(1),
					2: FixedColumnWidth(50),
				},
				children: [
					buildRow("全称:", widget.enterprise.name ?? '', "", null),
					buildRow("简称:", '', "", null),
					buildRow("上级单位:", widget.enterprise.upper ?? '', "", null),
					buildRow("行业类别:", widget.enterprise.sector?.value ?? '', "", null),
					buildRow("公司层级:", widget.enterprise.level?.value ?? '', "", null),
					buildRow("公司官网:", widget.enterprise.website1 ?? '', "点击复制", () {
						if (widget.enterprise.website2 != null) {
							Clipboard.setData(ClipboardData(text: widget.enterprise.website2!));
						}
					}),
					buildRow("招聘官网:", widget.enterprise.website2 ?? '', "点击复制", () {
						if (widget.enterprise.website2 != null) {
							Clipboard.setData(ClipboardData(text: widget.enterprise.website2!));
						}
					}),
				],
			),
		);
	}

	Widget buildSector() {
		return Padding(
			padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
			child: Column(
				children: widget.enterprise.fields.map<Widget>((f) => Container(
					width: double.infinity,
					margin: EdgeInsets.only(bottom: 6),
					padding: EdgeInsets.all(10),
					decoration: BoxDecoration(
						color: Colors.grey[200],
						borderRadius: BorderRadius.circular(8),
					),
					child: Text(f.value, style: TextStyle(fontSize: 12,),),
				)).toList(),
			),
		);
	}
}
