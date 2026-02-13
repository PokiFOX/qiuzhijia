import 'package:flutter/material.dart';

import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;
import 'package:frontend/wigets/inputdialog.dart' as widget;

class ZoneWidget extends StatefulWidget {
	const ZoneWidget({super.key});

	@override
	State<ZoneWidget> createState() => ZoneState();
}

class ZoneState extends State<ZoneWidget> {
	@override
	void initState() {
		super.initState();
		getZoneList();
	}

	void getZoneList() async {
		await tapah.RequestZoneList();
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		List<TableRow> rows = [];
		for (var i = 0;i < tapah.zonelist.length;i++) {
			var zone = tapah.zonelist[i];
			rows.add(TableRow(
				children: [
					const TableCell(
						child: SizedBox(height: 40,),
					),
					TableCell(
						child: Center(
							child: Text(zone.id.toString(),),
						),
					),
					TableCell(
						child: Center(
							child: Text(zone.value,),
						),
					),
					TableCell(
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								GestureDetector(
									onTap: () async {
										String? result = await widget.InputDialog.show(context, title: "编辑地区", defaultText: zone.value,);
										if (result == null) return;
										await tapah.RequestEditZone(zone.id, result);
										await tapah.RequestZoneList();
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
										await tapah.RequestDeleteZone(zone.id);
										await tapah.RequestZoneList();
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
									String? result = await widget.InputDialog.show(context, title: "添加地区", defaultText: "",);
									if (result == null) return;
									await tapah.RequestAddZone(result);
									await tapah.RequestZoneList();
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
				title: const Text('地区管理'),
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
