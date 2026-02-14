import 'package:flutter/material.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;
import 'package:frontend/wigets/inputfield.dart' as widget;

class FieldWidget extends StatefulWidget {
	const FieldWidget({super.key});

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> {
	@override
	void initState() {
		super.initState();
		getFieldList();
	}

	void getFieldList() async {
		await tapah.RequestFieldList();
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		List<TableRow> rows = [];
		for (var i = 0;i < tapah.fieldlist.length;i++) {
			var field = tapah.fieldlist[i];
			rows.add(TableRow(
				children: [
					const TableCell(
						child: SizedBox(height: 40,),
					),
					TableCell(
						child: Center(
							child: Text(field.id.toString(),),
						),
					),
					TableCell(
						child: Center(
							child: Text(field.value,),
						),
					),
					TableCell(
						child: Center(
							child: Text(field.sector,),
						),
					),
					TableCell(
						child: Center(
							child: Text(field.star.toString(),),
						),
					),
					TableCell(
						child: Center(
							child: Text(field.content,),
						),
					),
					TableCell(
						child: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								GestureDetector(
									onTap: () async {
										List<String>? result = await widget.InputField.show(context, field: field,);
										if (result == null) return;
										await tapah.RequestEditField(field.id, result[0], result[1], int.parse(result[2]), result[3]);
										await tapah.RequestFieldList();
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
										await tapah.RequestDeleteField(field.id);
										await tapah.RequestFieldList();
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
						child: Container(),
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
									List<String>? result = await widget.InputField.show(context, field: tapah.Field(id: 0, value: "", sector: "", star: 0, content: ""),);
									if (result == null) return;
									await tapah.RequestAddField(result[0], result[1], int.parse(result[2]), result[3]);
									await tapah.RequestFieldList();
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
				title: const Text('学科管理'),
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
							3: FixedColumnWidth(150),
							4: FixedColumnWidth(150),
							5: FixedColumnWidth(150),
							6: FixedColumnWidth(100),
						},
						border: TableBorder.all(color: Colors.black),
						children: rows,
					),
				),
			),
		);
	}
}
