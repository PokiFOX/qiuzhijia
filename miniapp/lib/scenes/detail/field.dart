import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/scenes/mainpage/field.dart' as mainpage;

class FieldWidget extends StatefulWidget {
	const FieldWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<FieldWidget> createState() => FieldState();
}

class FieldState extends State<FieldWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_field, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Container(
				child: buildInfo(),
			),
		);
	}

	Widget buildInfo() {
		return Padding(
			padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
			child: ListView.separated(
				padding: EdgeInsets.zero,
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemCount: widget.enterprise.fields.length,
				separatorBuilder: (context, index) => const SizedBox(height: 10),
				itemBuilder: (context, index) {
					var field = widget.enterprise.fields[index];
					return GestureDetector(
						onTap: () {
							Navigator.push(context, MaterialPageRoute(builder: (context) => mainpage.FieldWidget(key: GlobalKey(), field: field,)));
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
				},
			),
		);
	}
}
