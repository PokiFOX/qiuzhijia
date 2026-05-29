import 'package:flutter/material.dart';


import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/widgets/marquee_tags.dart' as widgets;
import 'package:qiuzhijia/widgets/marquee_text.dart' as widgets;

class EnterpriseWidget extends StatefulWidget {
	const EnterpriseWidget({super.key});

	@override
	State<EnterpriseWidget> createState() => EnterpriseState();
}

class EnterpriseState extends State<EnterpriseWidget> with tapah.Callback {
	int zone = 0, sector = 0, level = 0, page = 1;
	String search = "";
	final ScrollController scrollcontroller = ScrollController();
	bool isLoading = false, isFinish = false;
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_enterprise, widget.key!);
		tapah.enterpriselist = [];
		getEnterpriseList();

		scrollcontroller.addListener(() async {
			if (scrollcontroller.position.pixels >= scrollcontroller.position.maxScrollExtent * 0.9) {
				if (isFinish) return;
				if (isLoading) return;
				isLoading = true;
				page++;
				isFinish = await tapah.RequestEnterpriseList(zone, sector, level, 0, 0, null, "", page) < 20;
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
		isFinish = await tapah.RequestEnterpriseList(zone, sector, level, 0, 0, null, search, page) < 20;
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
			child: SafeArea(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						SizedBox(height: 30),
						buildTopRow(),
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

	Widget buildTopRow() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceAround,
			children: [
				GestureDetector(
					onTap: () {
						tapah.navigator(context, '/mainpage/filter', arguments: {"enttype": 1, "financial": 0});
					},
					child: Container(
						width: 116,
						height: 56,
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.centerRight,
								end: Alignment.centerLeft,
								colors: [Color(0xFFDA2F35), Color(0xFFFFC1C3)],
							),
							borderRadius: BorderRadius.circular(6),
						),
						child: Center(
							child: Text("国有企业", style: TextStyle(fontSize: 16, color: Colors.white,),),
						),
					),
				),
				GestureDetector(
					onTap: () {
						tapah.navigator(context, '/mainpage/filter', arguments: {"enttype": 2, "financial": 0});
					},
					child: Container(
						width: 116,
						height: 56,
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.centerRight,
								end: Alignment.centerLeft,
								colors: [Color(0xFFFFA600), Color(0xFFFEEFD1)],
							),
							borderRadius: BorderRadius.circular(6),
						),
						child: Center(
							child: Text("中央企业", style: TextStyle(fontSize: 16, color: Colors.white,),),
						),
					),
				),
				GestureDetector(
					onTap: () {
						tapah.navigator(context, '/mainpage/filter', arguments: {"enttype": 0, "financial": 1});
					},
					child: Container(
						width: 116,
						height: 56,
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.centerRight,
								end: Alignment.centerLeft,
								colors: [Color(0xFF4EC67B), Color(0xFFB9FFD3)],
							),
							borderRadius: BorderRadius.circular(6),
						),
						child: Center(
							child: Text("金融机构", style: TextStyle(fontSize: 16, color: Colors.white,),),
						),
					),
				),
			],
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
							SizedBox(
								width: 65,
								child: dropdown(zone, tapah.zonelist, (v) {
									zone = v ?? 0;
									getEnterpriseList();
								}, "地区"),
							),
							SizedBox(
								width: 65,
								child: dropdown(level, tapah.levellist.where((e) {
									return true;
								}).toList(), (v) {
									level = v ?? 0;
									getEnterpriseList();
								}, "档次"),
							),
							SizedBox(
								width: 65,
								child: dropdown(sector, tapah.sectorlist, (v) {
									sector = v ?? 0;
									getEnterpriseList();
								}, "行业"),
							),
							Expanded(
								child: TextField(
									textAlignVertical: TextAlignVertical.center,
									onSubmitted: (v) {
										search = v;
										getEnterpriseList();
									},
									decoration: const InputDecoration(
										contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
										border: InputBorder.none,
										hintText: "搜索企业",
										hintStyle: TextStyle(fontSize: 14),
										suffixIcon: Icon(Icons.search, color: Color(0xFF2D7BFF)),
									),
								),
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
							tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": enterprise.id});
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
											mainAxisAlignment: MainAxisAlignment.center,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												widgets.MarqueeTextWidget(
													text: enterprise.name!,
													style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
													height: 28,
												),
												const SizedBox(height: 4),
												if (enterprise.tags.isNotEmpty) widgets.MarqueeTagsWidget(tags: enterprise.tags.map((tag) => Container(
													height: 15,
													margin: const EdgeInsets.only(right: 6),
													padding: const EdgeInsets.symmetric(horizontal: 8),
													decoration: BoxDecoration(
														color: const Color(0xFFFEEDDF),
														borderRadius: BorderRadius.circular(4),
													),
													child: Text(tag, style: const TextStyle(color: Color(0xFF692E1F), fontSize: 10)),
												)).toList()),
												const SizedBox(height: 8),
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
