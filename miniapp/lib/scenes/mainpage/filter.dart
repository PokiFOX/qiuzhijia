import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class FilterWidget extends StatefulWidget {
	final int enttype;
	final bool financial;
	const FilterWidget({super.key, required this.enttype, required this.financial});

	@override
	State<FilterWidget> createState() => FilterState();
}

class FilterState extends State<FilterWidget> with tapah.Callback {
	int zone = 0, page = 1;
	final ScrollController scrollcontroller = ScrollController();
	bool isLoading = false, isFinish = false;
	TextEditingController searchcontroller = TextEditingController();

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_filter, widget.key!);
		tapah.enterpriselist = [];
		getEnterpriseList();

		scrollcontroller.addListener(() async {
			if (scrollcontroller.position.pixels >= scrollcontroller.position.maxScrollExtent * 0.9) {
				if (isFinish) return;
				if (isLoading) return;
				isLoading = true;
				page++;
				isFinish = await tapah.RequestEnterpriseList(zone, 0, 0, widget.enttype, 0, widget.financial, searchcontroller.text, page) < 20;
				isLoading = false;
				setState(() {});
			}
		});
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	Future<void> getEnterpriseList() async {
		page = 1;
		tapah.enterpriselist = [];
		isFinish = await tapah.RequestEnterpriseList(zone, 0, 0, widget.enttype, 0, widget.financial, searchcontroller.text, page) < 20;
		if (mounted == false) return;
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		String rowname = "企业列表";
		if (widget.enttype == 1) rowname = "国有企业";
		if (widget.enttype == 2) rowname = "中央企业";
		if (widget.enttype == 0 && widget.financial) rowname = "金融企业";
		return Material(
			child: Container(
				height: double.infinity,
				decoration: const BoxDecoration(
					color: Color(0xFFE2EDFF),
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 50),
						Row(
							children: [
								GestureDetector(
									onTap: () {
										Navigator.pop(context);
									},
									child: Container(
										width: 50,
										height: 30,
										margin: const EdgeInsets.only(left: 10),
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(15),
										),
										child: const Icon(Icons.arrow_back, size: 15,),
									),
								),
								const SizedBox(width: 10),
								Text(rowname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
							],
						),
						SizedBox(height: 10),
						buildFilterRow(),
						SizedBox(height: 10),
						Expanded(child: buildEnterpriseList(),),
						SizedBox(height: 10),
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
						mainAxisAlignment: MainAxisAlignment.spaceAround,
						children: [
							Expanded(
								child: TextField(
									controller: searchcontroller,
									textAlignVertical: TextAlignVertical.center,
									decoration: InputDecoration(
										hintText: '请输入企业名称',
										prefixIcon: Icon(Icons.search, color: Colors.grey),
										border: InputBorder.none,
									),
									onSubmitted: (value) {
										getEnterpriseList();
										FocusScope.of(context).unfocus();
									},
								),
							),
							const SizedBox(width: 10,),
							SizedBox(
								width: 65,
								child: dropdown(zone, tapah.zonelist, (v) {
									zone = v ?? 0;
									getEnterpriseList();
								}, "地区"),
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
				controller: scrollcontroller,
				physics: const BouncingScrollPhysics(),
				padding: EdgeInsets.zero,
				shrinkWrap: false,
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
											enterprise.icon!.isEmpty ? Container(width: 45, height: 45, color: Colors.grey) : Image.network(tapah.parseimage('小图标/${enterprise.icon}.png'), width: 45, height: 45,)
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
												if (enterprise.tags.isNotEmpty) SingleChildScrollView(
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
