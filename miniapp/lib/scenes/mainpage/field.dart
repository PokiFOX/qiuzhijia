import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/scenes/mainpage/fielddetail.dart';

class FieldWidget extends StatefulWidget {
	final tapah.Field? field;
	const FieldWidget({super.key, this.field});

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> with tapah.Callback {
	int selectedIndex = 0;
	List<String> types = [];
	Map<String, List<tapah.Field>> typeFields = {};
	final ScrollController scrollController = ScrollController();
	Map<String, GlobalKey> sectionKeys = {};
	Map<int, GlobalKey> fieldKeys = {};
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
			fieldKeys.putIfAbsent(field.id, () => GlobalKey());
		}
		types = typeFields.keys.toList();
		for (var type in types) {
			sectionKeys[type] = GlobalKey();
		}
		scrollController.addListener(onScroll);
		WidgetsBinding.instance.addPostFrameCallback((_) {
			scrollToInitialField();
		});
	}

	void scrollToInitialField() {
		final target = widget.field;
		if (target == null || types.isEmpty) return;

		final typeIndex = types.indexOf(target.type);
		if (typeIndex >= 0 && selectedIndex != typeIndex) {
			setState(() {
				selectedIndex = typeIndex;
			});
		}

		final key = fieldKeys[target.id];
		if (key?.currentContext != null) {
			isProgramScroll = true;
			Scrollable.ensureVisible(
				key!.currentContext!,
				duration: const Duration(milliseconds: 320),
				curve: Curves.easeInOut,
				alignment: 0.08,
			).then((_) {
				isProgramScroll = false;
			});
			return;
		}

		if (typeIndex >= 0) {
			scrollToType(typeIndex);
			WidgetsBinding.instance.addPostFrameCallback((_) {
				if (!mounted) return;
				final retryKey = fieldKeys[target.id];
				if (retryKey?.currentContext == null) return;
				isProgramScroll = true;
				Scrollable.ensureVisible(
					retryKey!.currentContext!,
					duration: const Duration(milliseconds: 320),
					curve: Curves.easeInOut,
					alignment: 0.08,
				).then((_) {
					isProgramScroll = false;
				});
			});
		}
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
		uninitCallback();
		super.dispose();
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
											return GestureDetector(
												onTap: () {
													Navigator.push(context, MaterialPageRoute(builder: (context) => FieldDetailWidget(field: field, key: GlobalKey(),)));
												},
												child: Container(
													key: fieldKeys[field.id],
													width: double.infinity,
													padding: EdgeInsets.all(10),
													decoration: BoxDecoration(
														border: Border.all(color: Color(0xFF2D7BFF), width: 1),
														borderRadius: BorderRadius.circular(8),
													),
													child: Column(
														mainAxisAlignment: MainAxisAlignment.start,
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(field.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, ),),
															const SizedBox(height: 5,),
															Text("学科门类: ${field.type}", style: TextStyle(fontSize: 11, color: Colors.black),),
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Text("专业热门度:", style: TextStyle(fontSize: 11, color: Colors.black),),
																	const SizedBox(width: 5,),
																	...List.generate(field.star, (_) => Icon(Icons.star, size: 16, color: Colors.orange,)),
																],
															),
															widgets.ExpandableText(
																field.content,
																expandText: '展开',
																collapseText: '收起',
																maxLines: 3,
																linkColor: Colors.blue,
															),
														],
													),
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
