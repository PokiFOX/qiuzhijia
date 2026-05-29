import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;
import 'package:qiuzhijia/widgets/copy.dart' as widgets;
import 'package:qiuzhijia/widgets/marquee_tags.dart' as widgets;
import 'package:qiuzhijia/scenes/kefu.dart';

class BriefWidget extends StatefulWidget {
	const BriefWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<BriefWidget> createState() => BriefState();
}

class BriefState extends State<BriefWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_brief, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				buildTitle(),
				const SizedBox(height: 10,),
				Padding(
					padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
					child: widgets.ExpandableText(
						widget.enterprise.brief ?? '',
						style: TextStyle(fontSize: 15, color: Colors.black,),
						expandText: '展开',
						collapseText: '收起',
						maxLines: 4,
						linkColor: Colors.blue,
					),
				),
				const SizedBox(height: 10,),
				buildInfo(),
				const SizedBox(height: 10,),
			],
		);
	}

	Widget buildTitle() {
		return Padding(
			padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
			child: Row(
				children: [
					Expanded(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.start,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(widget.enterprise.name!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
								const SizedBox(height: 10),
								if (widget.enterprise.tags.isNotEmpty) widgets.MarqueeTagsWidget(tags: widget.enterprise.tags.map((tag) => Container(
									height: 15,
									margin: const EdgeInsets.only(right: 6),
									padding: const EdgeInsets.symmetric(horizontal: 8),
									decoration: BoxDecoration(
										color: const Color(0xFFFEEDDF),
										borderRadius: BorderRadius.circular(4),
									),
									child: Text(tag, style: const TextStyle(color: Color(0xFF692E1F), fontSize: 10)),
								)).toList()),
								const SizedBox(height: 10),
								Row(
									mainAxisAlignment: MainAxisAlignment.start,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Container(
											margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1,),
											decoration: BoxDecoration(
												color: Colors.grey[200],
												borderRadius: BorderRadius.circular(4),
											),
											child: Text("${widget.enterprise.zone!.value}", style: const TextStyle(fontSize: 9, color: Colors.black,),),
										),
										const SizedBox(width: 10,),
										Container(
											margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1,),
											decoration: BoxDecoration(
												color: Colors.grey[200],
												borderRadius: BorderRadius.circular(4),
											),
											child: Text("${widget.enterprise.city!}", style: const TextStyle(fontSize: 9, color: Colors.black,),),
										),
									],
								),
							],
						),
					),
					const SizedBox(width: 10,),
					Image.network(tapah.parseimage('小图标/${widget.enterprise.icon}.png'), width: 60, height: 60,),
				],
			),
		);
	}

	Widget buildInfo() {
		TableRow buildRow(String title, String info, String action, Function? onclick) {
			return TableRow(
				children: [
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,), textAlign: TextAlign.end,),
					),
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: Padding(
							padding: const EdgeInsets.all(6.0),
							child: Text(info, style: TextStyle(fontSize: 14, color: action == "" ? Colors.black : Colors.blue),),
						),
					),
					TableCell(
						verticalAlignment: TableCellVerticalAlignment.middle,
						child: 
						GestureDetector(
							onTap: onclick as void Function()?,
							child: Text(action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: action == "" ? Colors.black : Colors.blue),),
						),
					),
				],
			);
		}

		return Padding(
			padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
			child: Table(
				columnWidths: const {
					0: FixedColumnWidth(70),
					1: FlexColumnWidth(1),
					2: FixedColumnWidth(70),
				},
				children: [
					buildRow("全称:", widget.enterprise.name ?? '', "", null),
					buildRow("简称:", '', "", null),
					buildRow("上级单位:", widget.enterprise.upper ?? '', "", null),
					buildRow("行业类别:", widget.enterprise.sector?.value ?? '', "", null),
					buildRow("公司层级:", widget.enterprise.level?.value ?? '', "", null),
					buildRow("公司官网:", widget.enterprise.website1 ?? '', "点击复制", () {
						if (widget.enterprise.website1 != null) {
							showDialog(
								context: context,
								builder: (_) => widgets.CopyWidget(
									widget.enterprise.website1!,
									onLater: () => Navigator.of(context).pop(),
									onConsult: () {
										Navigator.of(context).pop();
										Navigator.of(context).push(MaterialPageRoute(builder: (_) => KeFuWidget(key: GlobalKey(),)));
									},
								),
							);
							wxapi.wx.setClipboardData(wxapi.SetClipboardDataOption()..data = widget.enterprise.website1!);
						}
					}),
					buildRow("招聘官网:", widget.enterprise.website2 ?? '', "点击复制", () {
						if (widget.enterprise.website2 != null) {
							showDialog(
								context: context,
								builder: (_) => widgets.CopyWidget(
									widget.enterprise.website2!,
									onLater: () => Navigator.of(context).pop(),
									onConsult: () {
										Navigator.of(context).pop();
										Navigator.of(context).push(MaterialPageRoute(builder: (_) => KeFuWidget(key: GlobalKey(),)));
									},
								),
							);
							wxapi.wx.setClipboardData(wxapi.SetClipboardDataOption()..data = widget.enterprise.website2!);
						}
					}),
				],
			),
		);
	}
}
