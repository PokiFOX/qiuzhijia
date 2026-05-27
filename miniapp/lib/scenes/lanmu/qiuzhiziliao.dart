import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class QiuZhiZiLiaoWidget extends StatefulWidget {
	const QiuZhiZiLiaoWidget({super.key,});

	@override
	State<QiuZhiZiLiaoWidget> createState() => QiuZhiZiLiaoState();
}

class QiuZhiZiLiaoState extends State<QiuZhiZiLiaoWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_qiuzhiziliao, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return tapah.buildMain1(context, [
			SizedBox(
				height: 44,
				child: Center(child: Text('求职资料', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),),
			),
			Image.network(
				tapah.parseimage('栏目/求职资料/顶部.png'),
			),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_sectionTitle('资料类型'),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/求职资料/简历模板.png',
									bgColor: const Color(0xFFC8DBFC),
									label: '简历模板',
									sub: '精选模板&优化技巧',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/求职资料/面试资料.png',
									bgColor: const Color(0xFFDED8FD),
									label: '面试资料',
									sub: '高频题库&回答思路',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/求职资料/岗位指南.png',
									bgColor: const Color(0xFFFCE5D2),
									label: '岗位指南',
									sub: '岗位解析&能力要求',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/求职资料/求职规划.png',
									bgColor: const Color(0xFFD4F0E9),
									label: '求职规划',
									sub: '校招流程&时间安排',
								)),
							],
						),
						const SizedBox(height: 24),
						_sectionTitle('重点内容'),
						const SizedBox(height: 12),
						_contentCard('栏目/求职资料/应届生简历模板.png',
							bgColor: const Color(0xFFDDE9FC),
							title: '应届生简历模板合集',
							desc: '适合无实习/少项目经历同学，提供多行业简历模板，\n快速套用提升简历通过率',
						),
						const SizedBox(height: 12),
						_contentCard('栏目/求职资料/春招秋招冲刺资料包.png',
							bgColor: const Color(0xFFFCE5D2),
							title: '春招秋招冲刺资料包',
							desc: '涵盖校招流程、时间规划、笔面试技巧，祝你高效备战春招秋招，先人一步拿offer',
						),
					],
				),
			),
			Center(
				// child: MPFlutter_Wechat_Button(
				// 	onTap: (_) {
				child: GestureDetector(
					onTap: () {
						tapah.KeFu(context);
					},
					child: Image.network(
						tapah.parseimage('栏目/求职资料/底部.png'),
					),
				),
			),
		]);
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
				Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
					Container(
						width: 43,
						height: 43,
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
								Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF888888)), maxLines: 2),
							],
						),
					),
				],
			),
		);
	}

	Widget _contentCard(String imageName, {required Color bgColor, required String title, required String desc}) {
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
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: 52,
						height: 48,
						decoration: BoxDecoration(
							color: bgColor,
							borderRadius: BorderRadius.circular(12),
						),
						child: Image.network(
							tapah.parseimage(imageName),
						),
					),
					const SizedBox(width: 12),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
								const SizedBox(height: 6),
								Text(desc, style: const TextStyle(fontSize: 10, color: Color(0xFF666666), height: 1.5)),
							],
						),
					),
				],
			),
		);
	}
}
