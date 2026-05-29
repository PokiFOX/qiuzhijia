import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;

class FieldListWidget extends StatefulWidget {
	const FieldListWidget({super.key});

	@override
	State<FieldListWidget> createState() => FieldListState();
}

class FieldListState extends State<FieldListWidget> {
	final Map<String, List<tapah.Field>> fieldmap = {};
	late List<String> typeKeys;
	final Set<int> _selectedIds = {};
	int _activeTypeIndex = 0;
	final Map<String, GlobalKey> _sectionKeys = {};

	@override
	void initState() {
		super.initState();
		for (var field in tapah.fieldlist) {
			if (field.id == 1) continue;
			fieldmap.putIfAbsent(field.type, () => []).add(field);
		}
		typeKeys = fieldmap.keys.toList();
		for (var key in typeKeys) {
			_sectionKeys[key] = GlobalKey();
		}
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is Map<String, dynamic>) {
			for (var id in args["fields"].split(',')) {
				if (id.isEmpty) continue;
				_selectedIds.add(int.parse(id));
			}
		}
		setState(() {});
	}

	void _scrollToSection(String type) {
		final ctx = _sectionKeys[type]?.currentContext;
		if (ctx == null) return;
		Scrollable.ensureVisible(
			ctx,
			alignment: 0.0,
			duration: const Duration(milliseconds: 300),
			curve: Curves.easeOutCubic,
		);
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
									// 左侧：学科门类列表
									SizedBox(
										width: 88,
										child: ListView.builder(
											itemCount: typeKeys.length,
											itemBuilder: (context, index) {
												final isActive = index == _activeTypeIndex;
												return GestureDetector(
													onTap: () {
														setState(() => _activeTypeIndex = index);
														_scrollToSection(typeKeys[index]);
													},
													child: Container(
														width: double.infinity,
														padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
														color: isActive ? Colors.white : const Color(0xFFF5F5F5),
														child: Text(
															typeKeys[index],
															style: TextStyle(
																fontSize: 14,
																fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
																color: isActive ? const Color(0xFF2D7BFF) : Colors.black87,
															),
														),
													),
												);
											},
										),
									),
									// 右侧：所有专业（分组展示，可多选）
									Expanded(
										child: SingleChildScrollView(
											padding: const EdgeInsets.all(12),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: typeKeys.map((type) {
													return Column(
														key: _sectionKeys[type],
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																type,
																style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
															),
															const SizedBox(height: 8),
															Wrap(
																spacing: 8,
																runSpacing: 8,
																children: fieldmap[type]!.map((field) {
																	final isSelected = _selectedIds.contains(field.id);
																	return GestureDetector(
																		onTap: () {
																			setState(() {
																				if (isSelected) {
																					_selectedIds.remove(field.id);
																				} else {
																					_selectedIds.add(field.id);
																				}
																			});
																		},
																		child: Container(
																			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
																			decoration: BoxDecoration(
																				color: isSelected ? const Color(0xFF2D7BFF) : const Color(0xFFF2F4F8),
																				borderRadius: BorderRadius.circular(16),
																			),
																			child: Text(
																				field.value,
																				style: TextStyle(
																					fontSize: 13,
																					color: isSelected ? Colors.white : Colors.black87,
																				),
																			),
																		),
																	);
																}).toList(),
															),
															const SizedBox(height: 16),
														],
													);
												}).toList(),
											),
										),
									),
								],
							),
						),
						// 底部按钮
						Container(
							padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
							decoration: const BoxDecoration(
								border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
							),
							child: Row(
								children: [
									Expanded(
										child: OutlinedButton(
											onPressed: () {
												setState(() => _selectedIds.clear());
											},
											child: const Text("重置"),
										),
									),
									const SizedBox(width: 12),
									Expanded(
										flex: 2,
										child: ElevatedButton(
											style: ElevatedButton.styleFrom(
												backgroundColor: const Color(0xFF2D7BFF),
											),
											onPressed: () {
												final result = tapah.fieldlist
													.where((f) => _selectedIds.contains(f.id))
													.toList();
												Navigator.pop(context, result);
											},
											child: const Text("确定", style: TextStyle(color: Colors.white)),
										),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}
