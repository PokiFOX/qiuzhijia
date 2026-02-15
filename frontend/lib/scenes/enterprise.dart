import 'package:flutter/material.dart';

import 'package:pluto_grid/pluto_grid.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;
import 'package:frontend/wigets/inputfield.dart' as widgets;

class EnterpriseWidget extends StatefulWidget {
	const EnterpriseWidget({super.key});

	@override
	State<EnterpriseWidget> createState() => EnterpriseState();
}

class EnterpriseState extends State<EnterpriseWidget> {
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
				title: '公司名称',
				field: 'value',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '省',
				field: 'zone',
				type: PlutoColumnType.select(tapah.zonelist.map((e) => e.value).toList()),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '市',
				field: 'city',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '简称',
				field: 'shortname',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '简介',
				field: 'brief',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '上级单位',
				field: 'upper',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '大类',
				field: 'sector',
				type: PlutoColumnType.select(tapah.sectorlist.map((e) => e.value).toList()),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '层级',
				field: 'level',
				type: PlutoColumnType.select(tapah.levellist.map((e) => e.value).toList()),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '招聘学科',
				field: 'field',
				type: PlutoColumnType.select(tapah.fieldlist.map((e) => e.value).toList()),
				enableEditingMode: true,
				enableColumnDrag: false,
				renderer: (renderercontext) {
					var fields = renderercontext.row.cells['field']!.value.toString().split(',').where((element) => element.isNotEmpty).toList();
					return GestureDetector(
						onTap: () async {
							var enterprise = tapah.enterpriselist.firstWhere((element) => element.id == renderercontext.row.cells['id']!.value);
							List<tapah.Field>? fields = await widgets.showInputFieldDialog(context, enterprise.fields);
							if (fields == null) return;
							enterprise.fields = fields;
							await tapah.RequestEditEnterprise(enterprise);
							await getEnterpriseList();
							setState(() {});
						},
						child: Text(fields.join(', '), style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
					);
				},
			),
			PlutoColumn(
				title: '标签',
				field: 'tag',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '官网',
				field: 'website1',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '校招官网',
				field: 'website2',
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
					var zone = tapah.enterpriselist.firstWhere((element) => element.id == renderercontext.row.cells['id']!.value, orElse: () => tapah.Enterprise(id: 0,));
					if (zone.id == 0) {
						return GestureDetector(
							onTap: () async {
								var result = renderercontext.row.cells['value']!.value;
								if (result == null || result.toString().isEmpty) return;
								await tapah.RequestAddEnterprise(result);
								await getEnterpriseList();
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
							await tapah.RequestDeleteEnterprise(zone.id);
							await getEnterpriseList();
							setState(() {});
						},
						child: const Text("删除", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline,),),
					);
				},
			),
		];
		getEnterpriseList();
	}

	Future<void> getEnterpriseList() async {
		await tapah.RequestZoneList();
		await tapah.RequestSectorList();
		await tapah.RequestLevelList();
		await tapah.RequestFieldList();
		await tapah.RequestEnterpriseList();
		if (stateManager != null) {
			stateManager!.removeAllRows();
			stateManager!.appendRows(buildRows());
		}
		else {
			setState(() {});
		}
	}

	List<PlutoRow> buildRows() {
		List<PlutoRow> rows = tapah.enterpriselist.map((enterprise) => PlutoRow(
			cells: {
				'id': PlutoCell(value: enterprise.id),
				'value': PlutoCell(value: enterprise.name),
				'zone': PlutoCell(value: enterprise.zone?.value ?? ""),
				'city': PlutoCell(value: enterprise.city ?? ""),
				'shortname': PlutoCell(value: enterprise.shortname ?? ""),
				'brief': PlutoCell(value: enterprise.brief ?? ""),
				'upper': PlutoCell(value: enterprise.upper ?? ""),
				'sector': PlutoCell(value: enterprise.sector?.value ?? ""),
				'level': PlutoCell(value: enterprise.level?.value ?? ""),
				'field': PlutoCell(value: enterprise.fields.map((e) => e.value).join(',')),
				'tag': PlutoCell(value: enterprise.tags.join(',')),
				'website1': PlutoCell(value: enterprise.website1 ?? ""),
				'website2': PlutoCell(value: enterprise.website2 ?? ""),
				'operation': PlutoCell(value: ""),
			},
		)).toList();
		rows.add(PlutoRow(
			cells: {
				'id': PlutoCell(value: ""),
				'value': PlutoCell(value: ""),
				'zone': PlutoCell(value: ""),
				'city': PlutoCell(value: ""),
				'shortname': PlutoCell(value: ""),
				'brief': PlutoCell(value: ""),
				'upper': PlutoCell(value: ""),
				'sector': PlutoCell(value: ""),
				'level': PlutoCell(value: ""),
				'field': PlutoCell(value: ""),
				'tag': PlutoCell(value: ""),
				'website1': PlutoCell(value: ""),
				'website2': PlutoCell(value: ""),
				'operation': PlutoCell(value: ""),
			},
		));
		return rows;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('企业管理'),
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
											var enterprise = tapah.enterpriselist.firstWhere((element) => element.id == event.row.cells['id']!.value);
											enterprise.name = event.row.cells['value']!.value;
											await tapah.RequestEditEnterprise(enterprise);
											await getEnterpriseList();
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
