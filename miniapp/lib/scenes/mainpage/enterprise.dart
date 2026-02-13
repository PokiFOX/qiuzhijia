import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class EnterpriseWidget extends StatefulWidget {
	const EnterpriseWidget({super.key});

	@override
	State<EnterpriseWidget> createState() => EnterpriseState();
}

class EnterpriseState extends State<EnterpriseWidget> with tapah.Callback {
	int zone = 0, sector = 0, level = 0, part = 0;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_enterprise, widget.key!);
		getEnterpriseList();
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	Future<void> getEnterpriseList() async {
		List<int> levels = [];
		if (level == 0) {
			for (var e in tapah.levellist) {
				if (part == 0 && e.value.contains("央")) levels.add(e.id);
				if (part == 1 && e.value.contains("国")) levels.add(e.id);
				if (part == 2 && e.value.contains("金")) levels.add(e.id);
			}
		}
		else {
			levels.add(level);
		}
		await tapah.RequestEnterpriseList(zone, sector, levels);
		if (mounted == false) return;
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Container(
				decoration: BoxDecoration(
					color: Colors.grey[200],
					borderRadius: BorderRadius.circular(0),
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 10),
						buildTopRow(),
						SizedBox(height: 10),
						buildFilterRow(),
						SizedBox(height: 10),
						buildEnterpriseList(),
					],
				),
			),
		);
	}

	Widget buildTopRow() {
		return SizedBox(
			height: 50,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20.0),
				child: Row(
					children: [
						Expanded(
							child: GestureDetector(
								onTap: () {
									part = 0;
									getEnterpriseList();
								},
								child: Container(
									alignment: Alignment.center,
									decoration: BoxDecoration(
										color: Colors.blue,
										borderRadius: BorderRadius.circular(4),
									),
									child: const Text('央企', style: TextStyle(color: Colors.white, fontSize: 12)),
								),
							),
						),
						const SizedBox(width: 20),
						Expanded(
							child: GestureDetector(
								onTap: () {
									part = 1;
									getEnterpriseList();
								},
								child: Container(
									alignment: Alignment.center,
									decoration: BoxDecoration(
										color: Colors.green,
										borderRadius: BorderRadius.circular(4),
									),
									child: const Text('国企', style: TextStyle(color: Colors.white, fontSize: 12)),
								),
							),
						),
						const SizedBox(width: 20),
						Expanded(
							child: GestureDetector(
								onTap: () {
									part = 2;
									getEnterpriseList();
								},
								child: Container(
									alignment: Alignment.center,
									decoration: BoxDecoration(
										color: Colors.orange,
										borderRadius: BorderRadius.circular(4),
									),
									child: const Text('金融机构', style: TextStyle(color: Colors.white, fontSize: 12)),
								),
							),
						),
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
						hint: Text(labelText, style: const TextStyle(fontSize: 10)),
						icon: const Icon(Icons.arrow_drop_down, size: 15),
						items: items.map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.value, style: const TextStyle(fontSize: 10)))).toList(),
						onChanged: onChanged,
					),
				),
			);
		}

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20.0),
			child: SizedBox(
				height: 50,
				child: StatefulBuilder(builder: (context, setState) {
					return Row(
						children: [
							SizedBox(
								width: 65,
								child: dropdown(zone, tapah.zonelist, (v) {
									zone = v ?? 0;
									getEnterpriseList();
								}, "地区"),
							),
							const SizedBox(width: 10),
							SizedBox(
								width: 100,
								child: dropdown(level, tapah.levellist.where((e) {
									if (part == 0) return e.value.contains("央");
									if (part == 1) return e.value.contains("国");
									if (part == 2) return e.value.contains("金");
									return true;
								}).toList(), (v) {
									level = v ?? 0;
									getEnterpriseList();
								}, "档次"),
							),
							const SizedBox(width: 10),
							Expanded(
								child: dropdown(sector, tapah.sectorlist, (v) {
									sector = v ?? 0;
									getEnterpriseList();
								}, "行业"),
							),
							const SizedBox(width: 10),
							const SizedBox(
								width: 40,
								child: Text('更多', style: TextStyle(fontSize: 10)),
							),
						],
					);
				}),
			),
		);
	}

	Widget buildEnterpriseList() {
		return ListView.separated(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			itemCount: tapah.enterpriselist.length,
			separatorBuilder: (context, index) => const SizedBox(height: 5),
			itemBuilder: (context, index) {
				var enterprise = tapah.enterpriselist[index];
				return GestureDetector(
					onTap: () {
						Navigator.pushNamed(context, '/enterprise/detail', arguments: enterprise);
					},
					child: Container(
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
												Column(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Icon(Icons.stop, size: 70,),
													],
												),
												const SizedBox(width: 10),
												Expanded(
													child: Column(
														mainAxisAlignment: MainAxisAlignment.start,
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(enterprise.name!),
															const SizedBox(height: 4),
															SingleChildScrollView(
																scrollDirection: Axis.horizontal,
																child: Row(
																	children: (enterprise.tags).map<Widget>((t) => Container(
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
															Text("${enterprise.zone!.value} ${enterprise.city!}", style: const TextStyle(fontSize: 10),),
														],
													),
												),
											],
										),
									),
								),
								const SizedBox(width: 10),
							],
						),
					),
				);
			},
		);
	}
}
