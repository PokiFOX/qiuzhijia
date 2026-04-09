import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class CaseFilterWidget extends StatefulWidget {
	final int zone, sector, stag, year;
	const CaseFilterWidget({super.key, required this.zone, required this.sector, required this.stag, required this.year,});

	@override
	State<CaseFilterWidget> createState() => CaseFilterState();
}

class CaseFilterState extends State<CaseFilterWidget> with tapah.Callback {
	int selectedCategory = 0;
	List<int> selections = [0, 0,];

	final ScrollController rightScrollController = ScrollController();
	final List<GlobalKey> sectionKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
	bool isProgramScroll = false;

	final List<String> categories = ['院校层次', '目前状态'];
	List<List<String>> get options => [
		['985院校', '211院校', '普通本科', '海外本科'],
		['应届生', '已毕业'],
	];

	@override
	void initState() {
		super.initState();
		selections[0] = widget.stag;
		selections[1] = widget.year;
		initCallback(tapah.SceneID.mp_casefilter, widget.key!);
		rightScrollController.addListener(onScroll);
	}

	@override
	void dispose() {
		rightScrollController.dispose();
		super.dispose();
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	void onScroll() {
		if (isProgramScroll) return;
		for (int i = categories.length - 1; i >= 0; i--) {
			final key = sectionKeys[i];
			if (key.currentContext == null) continue;
			final box = key.currentContext!.findRenderObject() as RenderBox;
			final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
			if (pos.dy <= 100) {
				if (selectedCategory != i) {
					setState(() { selectedCategory = i; });
				}
				break;
			}
		}
	}

	Future<void> scrollToSection(int index) async {
		final key = sectionKeys[index];
		if (key.currentContext == null) return;
		isProgramScroll = true;
		setState(() { selectedCategory = index; });
		await Scrollable.ensureVisible(
			key.currentContext!,
			duration: const Duration(milliseconds: 300),
			curve: Curves.easeInOut,
		);
		await Future.delayed(const Duration(milliseconds: 350));
		isProgramScroll = false;
	}

	void reset() {
		setState(() {
			selections = [0, 0, 0];
		});
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			child: SafeArea(
				child: Column(
					children: [
						Expanded(
							child: Row(
								children: [
									buildLeftPanel(),
									buildRightPanel(),
								],
							),
						),
						buildBottomBar(),
					],
				),
			),
		);
	}

	Widget buildLeftPanel() {
		return Container(
			width: 90,
			color: const Color(0xFFF5F5F5),
			child: ListView.builder(
				physics: const NeverScrollableScrollPhysics(),
				itemCount: categories.length,
				itemBuilder: (context, index) {
					final selected = selectedCategory == index;
					return GestureDetector(
						onTap: () => scrollToSection(index),
						child: Container(
							height: 56,
							decoration: BoxDecoration(
								color: selected ? Colors.white : const Color(0xFFF5F5F5),
								border: selected
									? const Border(left: BorderSide(color: Color(0xFF4A90E2), width: 3))
									: null,
							),
							alignment: Alignment.center,
							child: Text(
								categories[index],
								style: TextStyle(
									fontSize: 14,
									fontWeight: selected ? FontWeight.bold : FontWeight.normal,
									color: selected ? const Color(0xFF4A90E2) : Colors.black87,
								),
							),
						),
					);
				},
			),
		);
	}

	Widget buildRightPanel() {
		return Expanded(
			child: ListView.builder(
				controller: rightScrollController,
				padding: const EdgeInsets.all(12),
				itemCount: categories.length,
				itemBuilder: (context, index) => buildSection(index),
			),
		);
	}

	Widget buildSection(int index) {
		return Container(
			key: sectionKeys[index],
			margin: const EdgeInsets.only(bottom: 16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						categories[index],
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
					),
					const SizedBox(height: 10),
					if (options[index].isEmpty)
						const SizedBox(height: 10)
					else
						Wrap(
							spacing: 8,
							runSpacing: 8,
							children: options[index].asMap().entries.map((entry) {
								final i = entry.key;
								final opt = entry.value;
								final selected = selections[index] == i + 1;
								return GestureDetector(
									onTap: () {
										setState(() {
											selections[index] = selected ? 0 : i + 1;
										});
									},
									child: Container(
										padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
										decoration: BoxDecoration(
											color: selected ? const Color(0xFF4A90E2) : const Color(0xFFF0F0F0),
											borderRadius: BorderRadius.circular(6),
										),
										child: Text(
											opt,
											style: TextStyle(
												fontSize: 14,
												color: selected ? Colors.white : Colors.black87,
											),
										),
									),
								);
							}).toList(),
						),
				],
			),
		);
	}

	Widget buildBottomBar() {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
			decoration: const BoxDecoration(
				color: Colors.white,
				border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
			),
			child: Row(
				children: [
					Expanded(
						flex: 2,
						child: GestureDetector(
							onTap: reset,
							child: Container(
								height: 44,
								decoration: BoxDecoration(
									color: Colors.white,
									border: Border.all(color: const Color(0xFFDDDDDD)),
									borderRadius: BorderRadius.circular(22),
								),
								alignment: Alignment.center,
								child: const Text('重置', style: TextStyle(fontSize: 16)),
							),
						),
					),
					const SizedBox(width: 12),
					Expanded(
						flex: 5,
						child: GestureDetector(
							onTap: () async {
								tapah.caselist = [];
								await tapah.RequestCaseList(0, widget.zone, widget.sector, selections[0], selections[1], 1);
								tapah.EventManager().call(tapah.SceneID.mp_example, tapah.EventType.mainpage_example_casefilter, [selections[0], selections[1]]);
								Navigator.pop(context);
							},
							child: Container(
								height: 44,
								decoration: BoxDecoration(
									color: const Color(0xFF4A90E2),
									borderRadius: BorderRadius.circular(22),
								),
								alignment: Alignment.center,
								child: const Text('确定', style: TextStyle(fontSize: 16, color: Colors.white)),
							),
						),
					),
				],
			),
		);
	}
}
