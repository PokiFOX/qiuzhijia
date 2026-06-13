import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class CaseFilterWidget extends StatefulWidget {
	const CaseFilterWidget({super.key});

	@override
	State<CaseFilterWidget> createState() => CaseFilterState();
}

class CaseFilterState extends State<CaseFilterWidget> with tapah.Callback {
	int selectedCategory = 0;
	List<int> selections = [0, 0, 0, 0, 0];

	final ScrollController rightScrollController = ScrollController();
	final List<GlobalKey> sectionKeys = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
	bool isProgramScroll = false;

	final List<String> categories = ['本科层次', '硕士层次', '目前状态', '单位层次', '单位类别'];
	List<List<String>> get options => [
		['不限', 'C9', '985', '211', '双非', '海外Top10', '海外Top50', '海外Top100', '其他海外院校'],
		['不限', 'C9', '985', '211', '双非', '海外Top10', '海外Top50', '海外Top100', '其他海外院校'],
		['不限', '应届生', '已毕业'],
		tapah.levellist.map((e) => e.value).toList(),
		tapah.sectorlist.map((e) => e.value).toList(),
	];

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_casefilter, widget.key!);
		rightScrollController.addListener(onScroll);
	}

	@override
	void dispose() {
		rightScrollController.dispose();
		uninitCallback();
		super.dispose();
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is Map<String, dynamic>) {
			selections[0] = args['stag1'] ?? 0;
			selections[1] = args['stag2'] ?? 0;
			selections[2] = args['year'] ?? 0;
			selections[3] = args['level'] ?? 0;
			selections[4] = args['sector'] ?? 0;
		}
		setState(() {});
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
			selections = [0, 0, 0, 0, 0];
		});
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			child: Column(
				children: [
					tapah.buildWechatNavBar(context, showBack: true),
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
								final selected = selections[index] == i;
								return GestureDetector(
									onTap: () {
										setState(() {
											selections[index] = selected ? 0 : i;
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
								await tapah.RequestCaseList(0, selections[3], selections[4], 0, selections[0], selections[1], selections[2], 1);
								tapah.EventManager().call(tapah.SceneID.mp_example, tapah.EventType.mainpage_example_casefilter, [selections[0], selections[1], selections[2], selections[3], selections[4]]);
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
