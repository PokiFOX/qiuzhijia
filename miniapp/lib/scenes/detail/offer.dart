import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class OfferWidget extends StatefulWidget {
	const OfferWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<OfferWidget> createState() => OfferState();
}

class OfferState extends State<OfferWidget> with tapah.Callback {
	late final List<tapah.Article> articles;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_offer, widget.key!);
		articles = widget.enterprise.article2.where((a) => a.article.trim().isNotEmpty).toList();
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		if (articles.isEmpty) {
			return const Center(child: Text("暂无招聘咨询文章", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}
		return Padding(
			padding: const EdgeInsets.all(10),
			child: Column(
				children: [
					for (int index = 0; index < articles.length; index++) ...[
						if (index > 0) const SizedBox(height: 10),
						MPFlutter_Wechat_Button(
							onTap: (_) {
								tapah.openOfficialAccountArticle(articles[index].article);
							},
							child: Container(
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(8),
								),
								padding: const EdgeInsets.all(10),
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Expanded(
											child: SizedBox(
												height: 80,
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															articles[index].title.isNotEmpty ? articles[index].title : "未知标题",
															style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
															maxLines: 2,
															overflow: TextOverflow.ellipsis,
														),
														const SizedBox(height: 4),
														Expanded(
															child: Text(
																articles[index].description,
																style: TextStyle(fontSize: 12, color: Colors.grey[600]),
																maxLines: 2,
																overflow: TextOverflow.ellipsis,
															),
														),
													],
												),
											),
										),
									],
								),
							),
						),
					],
				],
			),
		);
	}
}
