import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_webview/mpflutter_wechat_webview.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class OfferWidget extends StatefulWidget {
	const OfferWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<OfferWidget> createState() => OfferState();
}

class OfferState extends State<OfferWidget> with tapah.Callback {
	List<tapah.ArticleMeta> articles = [];
	bool isLoading = true;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_offer, widget.key!);
		loadArticles();
	}

	Future<void> loadArticles() async {
		List<tapah.ArticleMeta> result = [];
		for (var url in widget.enterprise.article2) {
			if (url.trim().isEmpty) continue;
			var meta = await tapah.RequestArticleMeta(url.trim());
			result.add(meta);
		}
		if (mounted) {
			setState(() {
				articles = result;
				isLoading = false;
			});
		}
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		if (isLoading) {
			return const Center(child: CircularProgressIndicator());
		}
		if (articles.isEmpty) {
			return const Center(child: Text("暂无招聘咨询文章", style: TextStyle(fontSize: 16, color: Colors.grey)));
		}
		return ListView.separated(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			padding: const EdgeInsets.all(10),
			itemCount: articles.length,
			separatorBuilder: (context, index) => const SizedBox(height: 10),
			itemBuilder: (context, index) {
				var article = articles[index];
				return GestureDetector(
					onTap: () {
						MPFlutter_Wechat_WebView.open(widget.enterprise.article2[index], onLoad: (_) {
							print("webview loaded");
						});
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
								ClipRRect(
									borderRadius: BorderRadius.circular(6),
									child: article.image.isNotEmpty ? Image.network(
										article.image,
										width: 100,
										height: 80,
										fit: BoxFit.cover,
										errorBuilder: (context, error, stackTrace) => Container(
											width: 100,
											height: 80,
											color: Colors.grey[200],
											child: const Icon(Icons.article, size: 36, color: Colors.grey),
										),
									) : Container(
										width: 100,
										height: 80,
										color: Colors.grey[200],
										child: const Icon(Icons.article, size: 36, color: Colors.grey),
									),
								),
								const SizedBox(width: 10),
								Expanded(
									child: SizedBox(
										height: 80,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													article.title.isNotEmpty ? article.title : "未知标题",
													style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
													maxLines: 2,
													overflow: TextOverflow.ellipsis,
												),
												const SizedBox(height: 4),
												Expanded(
													child: Text(
														article.description.isNotEmpty ? article.description : "",
														style: TextStyle(fontSize: 12, color: Colors.grey[600]),
														maxLines: 2,
														overflow: TextOverflow.ellipsis,
													),
												),
												Align(
													alignment: Alignment.bottomRight,
													child: Row(
														mainAxisSize: MainAxisSize.min,
														children: [
															Icon(Icons.visibility, size: 14, color: Colors.grey[400]),
															const SizedBox(width: 2),
															Text(
																"${article.clicks}",
																style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
					),
				);
			},
		);
	}
}
