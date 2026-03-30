import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class FieldWidget extends StatefulWidget {
	const FieldWidget({super.key,});

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> with tapah.Callback {
	int selectedIndex = 0;
	List<String> types = [];
	Map<String, List<tapah.Field>> typeFields = {};
	final ScrollController scrollController = ScrollController();
	Map<String, GlobalKey> sectionKeys = {};
	bool isProgramScroll = false;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_field, widget.key!);
		typeFields = {};
		for (var field in tapah.fieldlist) {
			if (field.type.isEmpty) continue;
			typeFields.putIfAbsent(field.type, () => []);
			typeFields[field.type]!.add(field);
		}
		types = typeFields.keys.toList();
		for (var type in types) {
			sectionKeys[type] = GlobalKey();
		}
		scrollController.addListener(onScroll);
	}

	void onScroll() {
		if (isProgramScroll) return;
		for (int i = types.length - 1; i >= 0; i--) {
			final key = sectionKeys[types[i]];
			if (key?.currentContext == null) continue;
			final box = key!.currentContext!.findRenderObject() as RenderBox;
			final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
			if (pos.dy <= 150) {
				if (selectedIndex != i) {
					setState(() { selectedIndex = i; });
				}
				break;
			}
		}
	}

	@override
	void dispose() {
		scrollController.dispose();
		super.dispose();
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			child: Container(
				height: double.infinity,
				decoration: const BoxDecoration(
					color: Colors.white,
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
								Text('专业类别', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
							],
						),
						SizedBox(height: 10),
						Expanded(
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									buildTypeList(),
									Expanded(child: buildFieldGrid()),
								],
							),
						),
					],
				),
			),
		);
	}

	Widget buildTypeList() {
		return Container(
			width: 100,
			color: Colors.white,
			child: ListView.builder(
				itemCount: types.length,
				itemBuilder: (context, index) {
					bool selected = index == selectedIndex;
					return GestureDetector(
						onTap: () {
							setState(() { selectedIndex = index; });
							scrollToType(index);
						},
						child: Container(
							padding: const EdgeInsets.symmetric(vertical: 14),
							decoration: BoxDecoration(
								color: selected ? const Color(0xFFE2EDFF) : Colors.white,
								border: Border(
									left: BorderSide(
										color: selected ? const Color(0xFF4A90D9) : Colors.transparent,
										width: 3,
									),
								),
							),
							child: Center(
								child: Text(
									types[index],
									style: TextStyle(
										fontSize: 14,
										fontWeight: selected ? FontWeight.bold : FontWeight.normal,
										color: selected ? const Color(0xFF4A90D9) : Colors.black87,
									),
								),
							),
						),
					);
				},
			),
		);
	}

	void scrollToType(int index) {
		final key = sectionKeys[types[index]];
		if (key?.currentContext == null) return;
		isProgramScroll = true;
		Scrollable.ensureVisible(
			key!.currentContext!,
			duration: const Duration(milliseconds: 300),
			curve: Curves.easeInOut,
			alignment: 0.0,
		).then((_) {
			isProgramScroll = false;
		});
	}

	Widget buildFieldGrid() {
		if (types.isEmpty) return const SizedBox();
		return Container(
			color: const Color(0xFFF5F5F5),
			child: SingleChildScrollView(
				controller: scrollController,
				padding: const EdgeInsets.all(12),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: types.map((type) {
						List<tapah.Field> fields = typeFields[type] ?? [];
						return Container(
							key: sectionKeys[type],
							margin: const EdgeInsets.only(bottom: 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
									const SizedBox(height: 12),
									Wrap(
										spacing: 10,
										runSpacing: 10,
										children: fields.map((field) {
											return Container(
												padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
												decoration: BoxDecoration(
													color: Colors.white,
													borderRadius: BorderRadius.circular(6),
												),
												child: Text(
													field.value,
													style: const TextStyle(fontSize: 13, color: Colors.black87),
												),
											);
										}).toList(),
									),
								],
							),
						);
					}).toList(),
				),
			),
		);
	}
}
