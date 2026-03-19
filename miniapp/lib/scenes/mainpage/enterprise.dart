import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

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
		await tapah.RequestEnterpriseList(zone, sector, level);
		if (mounted == false) return;
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			height: double.infinity,
			decoration: const BoxDecoration(
				color: Color(0xFFE2EDFF),
			),
			child: SingleChildScrollView(
				scrollDirection: Axis.vertical,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 50),
						buildTopRow(),
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
						GestureDetector(
							onTap: () {
								part = 0;
								getEnterpriseList();
							},
							child: Text("央企", style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: part == 0 ? FontWeight.bold : FontWeight.normal),),
						),
						const SizedBox(width: 20),
						GestureDetector(
							onTap: () {
								part = 1;
								getEnterpriseList();
							},
							child: Text("国企", style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: part == 1 ? FontWeight.bold : FontWeight.normal),),
						),
						const SizedBox(width: 20),
						GestureDetector(
							onTap: () {
								part = 2;
								getEnterpriseList();
							},
							child: Text("金融机构", style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: part == 2 ? FontWeight.bold : FontWeight.normal),),
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
								child: Text('更多', style: TextStyle(fontSize: 14)),
							),
						],
					);
				}),
			),
		);
	}

	Widget buildEnterpriseList() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10.0),
			child: ListView.separated(
				padding: EdgeInsets.zero,
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemCount: tapah.enterpriselist.length,
				separatorBuilder: (context, index) => const SizedBox(height: 10),
				itemBuilder: (context, index) {
					var enterprise = tapah.enterpriselist[index];
					return GestureDetector(
						onTap: () {
							Navigator.pushNamed(context, '/enterprise/detail', arguments: enterprise);
						},
						child: Container(
							height: 100,
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
											Icon(Icons.stop, size: 80,),
										],
									),
									const SizedBox(width: 10),
									Expanded(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.start,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												AutoSizeText(
													enterprise.name!,
													style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
													minFontSize: 10,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
												),
												const SizedBox(height: 4),
												SingleChildScrollView(
													scrollDirection: Axis.horizontal,
													child: Row(
														children: (enterprise.tags).map<Widget>((t) => Container(
															height: 15,
															margin: const EdgeInsets.only(right: 6),
															padding: const EdgeInsets.symmetric(horizontal: 2),
															decoration: BoxDecoration(
																color: Color(0xFF82B2F5),
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
					);
				},
			),
		);
	}
}
