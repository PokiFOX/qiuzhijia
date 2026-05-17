import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class MianShiJingYanWidget extends StatefulWidget {
	const MianShiJingYanWidget({super.key,});

	@override
	State<MianShiJingYanWidget> createState() => MianShiJingYanState();
}

class MianShiJingYanState extends State<MianShiJingYanWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_mianshijingyan, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			child: Column(
				children: [
					SafeArea(
						bottom: false,
						child: SizedBox(
							height: 44,
							child: Stack(
								alignment: Alignment.center,
								children: [
									const Text('面试经验', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
									Align(
										alignment: Alignment.centerLeft,
										child: GestureDetector(
											onTap: () => Navigator.pop(context),
											child: const Padding(
												padding: EdgeInsets.symmetric(horizontal: 16),
												child: Icon(Icons.chevron_left, size: 28, color: Colors.black87),
											),
										),
									),
								],
							),
						),
					),
					Expanded(
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									// 顶部文字区
									Padding(
										padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: const [
												Text(
													'掌握面试流程，提前准备上岸',
													style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
												),
												SizedBox(height: 8),
												Text(
													'覆盖面试礼仪、常见题型、答题策略与不同轮次面试技巧',
													style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
												),
												SizedBox(height: 16),
											],
										),
									),
									// 顶部大图
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										child: ClipRRect(
											borderRadius: BorderRadius.circular(12),
											child: Image.network(
												tapah.parseimage('栏目/面试经验/顶部.png'),
											),
										),
									),
									const SizedBox(height: 24),
									// 面试备考模块标题（居中带横线）
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 20),
										child: Row(
											children: const [
												Expanded(child: Divider(color: Color(0xFFDDDDDD))),
												Padding(
													padding: EdgeInsets.symmetric(horizontal: 12),
													child: Text('面试备考模块', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
												),
												Expanded(child: Divider(color: Color(0xFFDDDDDD))),
											],
										),
									),
									const SizedBox(height: 16),
									// 四宫格
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										child: Column(
											children: [
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/面试经验/面试礼仪.png',
															bgColor: const Color(0xFFECF3FD),
															label: '面试礼仪',
															sub: '着装禁忌与行为规范',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/面试经验/高频题型.png',
															bgColor: const Color(0xFFECF3FD),
															label: '高频题型',
															sub: '自我介绍与动机问题',
														)),
													],
												),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/面试经验/面试形式.png',
															bgColor: const Color(0xFFECF3FD),
															label: '面试形式',
															sub: '半结构化与无领导小组',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/面试经验/轮次辅导.png',
															bgColor: const Color(0xFFECF3FD),
															label: '轮次辅导',
															sub: 'HR面试与领导面试',
														)),
													],
												),
											],
										),
									),
									const SizedBox(height: 24),
									// 适合哪些需求
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 20),
										child: Row(
											children: const [
												Expanded(child: Divider(color: Color(0xFFDDDDDD))),
												Padding(
													padding: EdgeInsets.symmetric(horizontal: 12),
													child: Text('适合哪些需求', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
												),
												Expanded(child: Divider(color: Color(0xFFDDDDDD))),
											],
										),
									),
									const SizedBox(height: 12),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										child: Row(
											children: [
												Expanded(child: _targetCard(
													imageName: '栏目/面试经验/面试突击.png',
													title: '面试前突击',
													sub: '快速掌握注意事项',
												)),
												const SizedBox(width: 10),
												Expanded(child: _targetCard(
													imageName: '栏目/面试经验/回答没思路.png',
													title: '回答没思路',
													sub: '学习结构化表达',
												)),
												const SizedBox(width: 10),
												Expanded(child: _targetCard(
													imageName: '栏目/面试经验/多轮面试准备.png',
													title: '多轮面试准备',
													sub: '匹配不同面试场景',
												)),
											],
										),
									),
									const SizedBox(height: 24),
									// 底部咨询大图
									Center(
										// child: MPFlutter_Wechat_Button(
										// 	onTap: (_) {
										child: GestureDetector(
											onTap: () {
												tapah.KeFu(context);
											},
											child: Image.network(
												tapah.parseimage('栏目/面试经验/底部.png'),
											),
										),
									),
									const SizedBox(height: 16),
									// 底部徽标
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											Image.network(
												tapah.parseimage("栏目/笔试题库/标记.png"),
											),
											const SizedBox(width: 6),
											const Text('已为数千名学员提供专业咨询服务', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
										],
									),
									const SizedBox(height: 20),
								],
							),
						),
					),
				],
			),
		);
	}

	Widget _typeCard({
		required String imageName,
		required Color bgColor,
		required String label,
		required String sub,
	}) {
		return Container(
			padding: const EdgeInsets.all(14),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
				],
			),
			child: Row(
				children: [
					Container(
						width: 48,
						height: 48,
						decoration: BoxDecoration(
							color: bgColor,
							borderRadius: BorderRadius.circular(12),
						),
						child: Padding(
							padding: const EdgeInsets.all(8),
							child: Image.network(
								tapah.parseimage(imageName),
							),
						),
					),
					const SizedBox(width: 10),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
								const SizedBox(height: 4),
								Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF888888)), maxLines: 2),
							],
						),
					),
				],
			),
		);
	}

	Widget _targetCard({
		required String imageName,
		required String title,
		required String sub,
	}) {
		return Container(
			padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
				],
			),
			child: Column(
				children: [
					Image.network(
						tapah.parseimage(imageName),
					),
					const SizedBox(height: 8),
					Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
					const SizedBox(height: 4),
					Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF888888)), textAlign: TextAlign.center, maxLines: 2),
				],
			),
		);
	}
}

