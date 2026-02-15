import 'package:flutter/material.dart';

import 'package:pluto_grid/pluto_grid.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;

class ZoneWidget extends StatefulWidget {
	const ZoneWidget({super.key});

	@override
	State<ZoneWidget> createState() => ZoneState();
}

class ZoneState extends State<ZoneWidget> {
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
				title: '地区名称',
				field: 'value',
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
					var zone = tapah.zonelist.firstWhere((element) => element.id == renderercontext.row.cells['id']!.value, orElse: () => tapah.Zone(id: 0, value: ""));
					if (zone.id == 0) {
						return GestureDetector(
							onTap: () async {
								var result = renderercontext.row.cells['value']!.value;
								if (result == null || result.toString().isEmpty) return;
								await tapah.RequestAddZone(result);
								await getZoneList();
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
							await tapah.RequestDeleteZone(zone.id);
							await getZoneList();
							setState(() {});
						},
						child: const Text("删除", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline,),),
					);
				},
			),
		];
		getZoneList();
	}

	Future<void> getZoneList() async {
		await tapah.RequestZoneList();
		if (stateManager != null) {
			stateManager!.removeAllRows();
			stateManager!.appendRows(buildRows());
		}
		else {
			setState(() {});
		}
	}

	List<PlutoRow> buildRows() {
		List<PlutoRow> rows = tapah.zonelist.map((zone) => PlutoRow(
			cells: {
				'id': PlutoCell(value: zone.id),
				'value': PlutoCell(value: zone.value),
				'operation': PlutoCell(value: ""),
			},
		)).toList();
		rows.add(PlutoRow(
			cells: {
				'id': PlutoCell(value: ""),
				'value': PlutoCell(value: ""),
				'operation': PlutoCell(value: ""),
			},
		));
		return rows;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('地区管理'),
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
											var zone = tapah.zonelist.firstWhere((element) => element.id == event.row.cells['id']!.value);
											zone.value = event.row.cells['value']!.value;
											await tapah.RequestEditZone(zone);
											await getZoneList();
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
