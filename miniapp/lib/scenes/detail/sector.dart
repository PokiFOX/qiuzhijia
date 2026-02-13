import 'package:flutter/material.dart';

import 'package:expandable_text/expandable_text.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class SectorWidget extends StatefulWidget {
	const SectorWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<SectorWidget> createState() => SectorState();
}

class SectorState extends State<SectorWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_sector, widget.key!);
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
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
			padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
			child: Column(
				children: widget.enterprise.fields.map<Widget>((f) => Container(
					width: double.infinity,
					margin: EdgeInsets.only(bottom: 6),
					padding: EdgeInsets.all(10),
					decoration: BoxDecoration(
						color: Colors.grey[200],
						borderRadius: BorderRadius.circular(8),
					),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.start,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(f.value, style: TextStyle(fontSize: 14,),),
							const SizedBox(height: 5,),
							Container(
								decoration: BoxDecoration(
									color: Colors.white,
								),
								child: Padding(
									padding: EdgeInsets.all(5),
									child: Row(
										children: [
											Expanded(
												child: Column(
													mainAxisAlignment: MainAxisAlignment.start,
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text("学科门类: ${f.sector}"),
														Row(
															mainAxisAlignment: MainAxisAlignment.start,
															children: [
																Text("专业热门度:"),
																const SizedBox(width: 5,),
																...List.generate(f.star, (_) => Icon(Icons.star, size: 16,)),
															],
														),
														ExpandableText(
															"专业介绍: ${f.content}",
															expandText: '展开',
															collapseText: '收起',
															maxLines: 3,
															linkColor: Colors.blue,
														),
													],
												),
											),
										],
									),
								),
							),
						],
					),
				)).toList(),
			),
		);
	}
}
