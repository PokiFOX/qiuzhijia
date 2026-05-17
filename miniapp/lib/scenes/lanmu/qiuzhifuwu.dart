import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class QiuZhiFuWuWidget extends StatefulWidget {
	const QiuZhiFuWuWidget({super.key,});

	@override
	State<QiuZhiFuWuWidget> createState() => QiuZhiFuWuState();
}

class QiuZhiFuWuState extends State<QiuZhiFuWuWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_qiuzhifuwu, widget.key!);
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
									const Text('求职服务', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
													'一站式求职规划，陪你高效上岸',
													style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
												),
												SizedBox(height: 8),
												Text(
													'求职规划 · 简历优化 · 笔面试辅导',
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
												tapah.parseimage('栏目/求职服务/顶部.png'),
												width: double.infinity,
												fit: BoxFit.fitWidth,
											),
										),
									),
									const SizedBox(height: 24),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												// 服务内容
												_sectionTitle('服务内容'),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/求职服务/求职定位.png',
															bgColor: const Color(0xFFECF3FD),
															label: '求职定位',
															sub: '结合背景匹配方向',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/求职服务/简历优化.png',
															bgColor: const Color(0xFFDED8FD),
															label: '简历优化',
															sub: '突出经理与岗位优势',
														)),
													],
												),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/求职服务/投递规划.png',
															bgColor: const Color(0xFFD4F0E9),
															label: '投递规划',
															sub: '筛选岗位与企业机会',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/求职服务/笔面辅助.png',
															bgColor: const Color(0xFFFDEEE4),
															label: '笔面辅导',
															sub: '提升笔试与面试表现',
														)),
													],
												),
												const SizedBox(height: 24),
												// 适合哪些同学
												_sectionTitle('适合哪些同学'),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _targetCard(
															imageName: '栏目/求职服务/不知道投什么.png',
															title: '不知道投什么',
															sub: '明确岗位与行业方向',
														)),
														const SizedBox(width: 10),
														Expanded(child: _targetCard(
															imageName: '栏目/求职服务/简历没有亮点.png',
															title: '简历没有亮点',
															sub: '优化简历表达重点',
														)),
														const SizedBox(width: 10),
														Expanded(child: _targetCard(
															imageName: '栏目/求职服务/面试准备不足.png',
															title: '面试准备不足',
															sub: '补足答题思路与表达',
														)),
													],
												),
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
												tapah.parseimage('栏目/求职服务/底部.png'),
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

	Widget _sectionTitle(String text) {
		return Row(
			children: [
				Container(
					width: 4,
					height: 18,
					decoration: BoxDecoration(
						color: const Color(0xFF2D7BFF),
						borderRadius: BorderRadius.circular(2),
					),
				),
				const SizedBox(width: 8),
				Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
			],
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
					Image.network(
						tapah.parseimage(imageName),
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
			padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
				],
			),
			child: Row(
				children: [
					const SizedBox(width: 5,),
					Image.network(
						tapah.parseimage(imageName),
					),
					const SizedBox(width: 8),
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const SizedBox(height: 8),
							Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
							const SizedBox(height: 4),
							Text(sub, style: const TextStyle(fontSize: 8, color: Color(0xFF888888)), textAlign: TextAlign.center, maxLines: 2),
						],
					),
				],
			),
		);
	}
}

