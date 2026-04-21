import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/scenes/mainpage/fielddetail.dart' as mainpage;

class FieldWidget extends StatefulWidget {
	final tapah.Field? field;
	const FieldWidget({super.key, this.field});

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> with tapah.Callback {
	final TextEditingController _searchController = TextEditingController();
	final Map<int, GlobalKey> _itemKeys = {};
	bool _didAutoScroll = false;
	String _searchText = "";

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_field, widget.key!);
		_scheduleAutoScrollIfNeeded();
	}

	@override
	void didUpdateWidget(covariant FieldWidget oldWidget) {
		super.didUpdateWidget(oldWidget);
		if (oldWidget.field?.id != widget.field?.id) {
			_didAutoScroll = false;
			_scheduleAutoScrollIfNeeded();
		}
	}

	@override
	void dispose() {
		_searchController.dispose();
		uninitCallback();
		super.dispose();
	}

	Widget build(BuildContext context) {
		_scheduleAutoScrollIfNeeded();
		return Material(
			child: SingleChildScrollView(
				scrollDirection: Axis.vertical,
				child: Container(
					child: buildInfo(),
				),
			),
		);
	}

	Widget buildInfo() {
		var displayList = tapah.fieldlist.where((e) {
			if (_searchText.isEmpty) return true;
			return e.value.contains(_searchText) || e.type.contains(_searchText);
		}).toList();
		return Padding(
			padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							GestureDetector(
								onTap: () {
									Navigator.pop(context);
								},
								child: Container(
									width: 30,
									height: 30,
									margin: const EdgeInsets.only(left: 10),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(15),
									),
									child: const Icon(Icons.arrow_back, size: 15,),
								),
							),
							const SizedBox(width: 10,),
							Expanded(child: Container(
									padding: EdgeInsets.symmetric(horizontal: 12),
									decoration: BoxDecoration(
										color: Color(0xFFF2F4F8),
										borderRadius: BorderRadius.circular(24),
									),
									child: TextField(
										controller: _searchController,
										decoration: InputDecoration(
											hintText: '搜索你的专业',
											border: InputBorder.none,
											icon: Icon(Icons.search, color: Color(0xFF2D7BFF)),
										),
										onChanged: (value) {
											setState(() {
												_searchText = value.trim();
											});
										},
									),
								),
							),
						],
					),
					const SizedBox(height: 12),
					ListView.separated(
						padding: EdgeInsets.zero,
						shrinkWrap: true,
						physics: const NeverScrollableScrollPhysics(),
						itemCount: displayList.length,
						separatorBuilder: (context, index) => const SizedBox(height: 10),
						itemBuilder: (context, index) {
							var field = displayList[index];
							var itemKey = _itemKeys.putIfAbsent(field.id, () => GlobalKey());
							return GestureDetector(
								key: itemKey,
								onTap: () {
									Navigator.push(
										context,
										MaterialPageRoute(
											builder: (context) => mainpage.FieldDetailWidget(key: GlobalKey(),field: field,),
										),
									);
								},
								child: Container(
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
											Text(field.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),),
											const SizedBox(height: 5,),
											Text("学科门类: ${field.type}", style: TextStyle(fontSize: 11, color: Colors.black),),
											Row(
												mainAxisAlignment: MainAxisAlignment.start,
												children: [
													Text("专业热门度:", style: TextStyle(fontSize: 11, color: Colors.black),),
													const SizedBox(width: 5,),
													...List.generate(
														field.star,
														(_) => Icon(Icons.star, size: 16, color: Colors.orange,),
													),
												],
											),
											widgets.ExpandableText(field.content, expandText: '展开', collapseText: '收起', maxLines: 3, linkColor: Colors.blue,),
										],
									),
								),
							);
						},
					),
				],
			),
		);
	}

	void _scheduleAutoScrollIfNeeded() {
		if (_didAutoScroll || widget.field == null || tapah.fieldlist.isEmpty) return;
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!mounted) return;
			_scrollToSelectedField();
		});
	}

	void _scrollToSelectedField() {
		if (_didAutoScroll || widget.field == null) return;
		final targetContext = _itemKeys[widget.field!.id]?.currentContext;
		if (targetContext == null) {
			_scheduleAutoScrollIfNeeded();
			return;
		}
		_didAutoScroll = true;
		Scrollable.ensureVisible(
			targetContext,
			alignment: 0.0,
			duration: const Duration(milliseconds: 280),
			curve: Curves.easeOutCubic,
		);
	}
}
