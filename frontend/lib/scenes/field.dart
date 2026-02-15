import 'package:flutter/material.dart';

import 'package:pluto_grid/pluto_grid.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;

class FieldWidget extends StatefulWidget {
	const FieldWidget({super.key});

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> {
	PlutoGridStateManager? stateManager;
	late List<PlutoColumn> columns = [];

	@override
	void initState() {
		super.initState();
		columns = [
			PlutoColumn(
				title: 'ID',
				field: 'id',
				type: PlutoColumnType.text(),
				enableEditingMode: false,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '学科名称',
				field: 'value',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '学科门类',
				field: 'sector',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '专业热门度',
				field: 'star',
				type: PlutoColumnType.number(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '专业介绍 ',
				field: 'content',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '操作',
				field: 'operation',
				type: PlutoColumnType.text(),
				enableEditingMode: false,
				enableColumnDrag: false,
				renderer: (renderercontext) {
					var field = tapah.fieldlist.firstWhere((element) => element.id == renderercontext.row.cells['id']!.value, orElse: () => tapah.Field(id: 0, value: "", sector: "", star: 0, content: ""));
					if (field.id == 0) {
						return GestureDetector(
							onTap: () async {
								var field = renderercontext.row.cells['value']!.value;
								var sector = renderercontext.row.cells['sector']!.value;
								var star = renderercontext.row.cells['star']!.value;
								var content = renderercontext.row.cells['content']!.value;
								if (field == null || field.toString().isEmpty) return;
								await tapah.RequestAddField(field, sector ?? "", star ?? 0, content ?? "");
								await getFieldList();
								setState(() {});
							},
							child: const Text("添加", style: TextStyle(color: Colors.green, decoration: TextDecoration.underline,),),
						);
					}
					return GestureDetector(
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
							await getFieldList();
							setState(() {});
						},
						child: const Text("删除", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline,),),
					);
				},
			),
		];
		getFieldList();
	}

	Future<void> getFieldList() async {
		await tapah.RequestFieldList();
		if (stateManager != null) {
			stateManager!.removeAllRows();
			stateManager!.appendRows(buildRows());
		}
		else {
			setState(() {});
		}
	}

	List<PlutoRow> buildRows() {
		List<PlutoRow> rows = tapah.fieldlist.map((field) => PlutoRow(
			cells: {
				'id': PlutoCell(value: field.id),
				'value': PlutoCell(value: field.value),
				'sector': PlutoCell(value: field.sector),
				'star': PlutoCell(value: field.star),
				'content': PlutoCell(value: field.content),
				'operation': PlutoCell(value: ""),
			},
		)).toList();
		rows.add(PlutoRow(
			cells: {
				'id': PlutoCell(value: ""),
				'value': PlutoCell(value: ""),
				'sector': PlutoCell(value: ""),
				'star': PlutoCell(value: 0),
				'content': PlutoCell(value: ""),
				'operation': PlutoCell(value: ""),
			},
		));
		return rows;
	}


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('学科管理'),
			),
			body: Column(
				children: [
					const SizedBox(height: 20,),
					Expanded(
						child: Row(
							children: [
								const SizedBox(width: 50,),
								Expanded(
									child: PlutoGrid(
										columns: columns,
										rows: buildRows(),
										onChanged: (PlutoGridOnChangedEvent event) async {
											if (event.row.cells['id']!.value == null || event.row.cells['id']!.value == '') return;
											var field = tapah.fieldlist.firstWhere((element) => element.id == event.row.cells['id']!.value);
											field.value = event.row.cells['value']!.value;
											field.sector = event.row.cells['sector']!.value;
											field.star = event.row.cells['star']!.value;
											field.content = event.row.cells['content']!.value;
											await tapah.RequestEditField(field);
											await getFieldList();
											setState(() {});
										},
										onLoaded: (PlutoGridOnLoadedEvent event) {
											stateManager = event.stateManager;
										},
									)
								),
								const SizedBox(width: 50,),
							],
						),
					),
					const SizedBox(height: 20,),
				],
			),
		);
	}
}
