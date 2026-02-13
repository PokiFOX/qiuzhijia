import 'package:flutter/material.dart';

import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;
import 'package:frontend/wigets/inputdialog.dart' as widget;

class LevelWidget extends StatefulWidget {
	const LevelWidget({super.key});

	@override
	State<LevelWidget> createState() => LevelState();
}

class LevelState extends State<LevelWidget> {
	@override
	void initState() {
		super.initState();
		getLevelList();
	}

	void getLevelList() async {
		await tapah.RequestLevelList();
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		List<TableRow> rows = [];
		for (var i = 0;i < tapah.levellist.length;i++) {
			var level = tapah.levellist[i];
			rows.add(TableRow(
				children: [
					const TableCell(
						child: SizedBox(height: 40,),
					),
					TableCell(
						child: Center(
							child: Text(level.id.toString(),),
						),
					),
					TableCell(
						child: Center(
							child: Text(level.value,),
						),
					),
					TableCell(
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								GestureDetector(
									onTap: () async {
										String? result = await widget.InputDialog.show(context, title: "编辑层级", defaultText: level.value,);
										if (result == null) return;
										await tapah.RequestEditLevel(level.id, result);
										await tapah.RequestLevelList();
										setState(() {});
									},
									child: const Text("编辑", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
								),
								const SizedBox(width: 20,),
								GestureDetector(
									onTap: ()  async {
										if (await showAdaptiveDialog<bool>(
											context: context,
											builder: (BuildContext context) => AlertDialog.adaptive(
												title: const Text('确认操作'),
												content: const Text('你确定要执行此操作吗？此过程不可逆。'),
												actions: <Widget>[
													TextButton(
														onPressed: () => Navigator.pop(context, false),
														child: const Text('取消', style: TextStyle(color: Colors.grey)),
													),
													TextButton(
														onPressed: () => Navigator.pop(context, true),
														child: const Text('确认', style: TextStyle(color: Colors.red)),
													),
												],
											),
										) != true) return;
										await tapah.RequestDeleteLevel(level.id);
										await tapah.RequestLevelList();
										setState(() {});
									},
									child: const Text("删除", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline,),),
								),
							],
						),
					),
				],
			));
		}
		rows.add(TableRow(
			children: [
					const TableCell(
						child: SizedBox(height: 40,),
					),
					TableCell(
						child: Container(),
					),
					TableCell(
						child: Container(),
					),
					TableCell(
						child: Center(
							child: GestureDetector(
								onTap: () async {
									String? result = await widget.InputDialog.show(context, title: "添加层级", defaultText: "",);
									if (result == null) return;
									await tapah.RequestAddLevel(result);
									await tapah.RequestLevelList();
									setState(() {});
								},
								child: const Text("添加", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
							),
						),
					),
			],
		));
		return Scaffold(
			appBar: AppBar(
				title: const Text('层级管理'),
			),
			body: SingleChildScrollView(
				child:  Padding(
					padding: const EdgeInsets.all(50),
					child: Table(
						defaultVerticalAlignment: TableCellVerticalAlignment.middle,
						columnWidths: const {
							0: FixedColumnWidth(0),
							1: FixedColumnWidth(50),
							2: FixedColumnWidth(200),
							3: FixedColumnWidth(100),
						},
						border: TableBorder.all(color: Colors.black),
						children: rows,
					),
				),
			),
		);
	}
}
