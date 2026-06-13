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
		return tapah.buildMain1(context, [
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
						// 核心服务
						_sectionTitle('核心服务'),
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
									imageName: '栏目/求职服务/笔面辅导.png',
									bgColor: const Color(0xFFFDEEE4),
									label: '笔面辅导',
									sub: '提升笔试与面试表现',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/首席导师团队.png',
									bgColor: const Color(0xFFD4F0E9),
									label: '首席导师团队',
									sub: '顶尖行业导师',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/实习内推.png',
									bgColor: const Color(0xFFFDEEE4),
									label: '实习内推',
									sub: '定向内推实习',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/24h贴心陪伴.png',
									bgColor: const Color(0xFFD4F0E9),
									label: '24h贴心陪伴',
									sub: '专属辅导组',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/能力提升工作坊.png',
									bgColor: const Color(0xFFFDEEE4),
									label: '能力提升工作坊',
									sub: '助力能力提升',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/其他增值服务.png',
									bgColor: const Color(0xFFD4F0E9),
									label: '其他增值服务',
									sub: '行业资料持续更新',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/求职服务/专属社群支持.png',
									bgColor: const Color(0xFFFDEEE4),
									label: '专属社群支持',
									sub: '消息及时同步',
								)),
							],
						),
						const SizedBox(height: 24),
						Container(
							padding: const EdgeInsets.all(14),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(12),
								boxShadow: [
									BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
								],
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_sectionTitle('服务流程'),
									const SizedBox(height: 12),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceAround,
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											_flowStep('栏目/求职服务/需求沟通.png', '需求沟通',),
											SizedBox(
												height: 40,
												child: Center(child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),),
											),
											_flowStep('栏目/求职服务/策略制定.png', '策略制定',),
											SizedBox(
												height: 40,
												child: Center(child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),),
											),
											_flowStep('栏目/求职服务/技能提升.png', '技能提升',),
											SizedBox(
												height: 40,
												child: Center(child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),),
											),
											_flowStep('栏目/求职服务/信息推荐.png', '信息推荐',),
											SizedBox(
												height: 40,
												child: Center(child: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),),
											),
											_flowStep('栏目/求职服务/面试上岸.png', '面试上岸',),
										],
									),
								],
							),
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
		], title: '求职服务');
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

	Widget _flowStep(String imageName, String label) {
		return Column(
			children: [
				Container(
					width: 40,
					height: 40,
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(26),
					),
					child: Padding(
						padding: const EdgeInsets.all(10),
						child: Image.network(
							tapah.parseimage(imageName),
						),
					),
				),
				const SizedBox(height: 6),
				Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
			],
		);
	}
}

