import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class BiShiTiKuWidget extends StatefulWidget {
	const BiShiTiKuWidget({super.key,});

	@override
	State<BiShiTiKuWidget> createState() => BiShiTiKuState();
}

class BiShiTiKuState extends State<BiShiTiKuWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_bishitiku, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return tapah.buildMain1(context, [
			// 顶部标题区（白底文字 + 大图）
			Padding(
				padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: const [
						Text(
							'科学刷题，高效备战',
							textAlign: TextAlign.center,
							style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
						),
						SizedBox(height: 6),
						Text(
							'精选真题 · 高频考点 · 分类练习',
							textAlign: TextAlign.center,
							style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2D7BFF)),
						),
						SizedBox(height: 10),
						Text(
							'帮助你更高效地准备笔试，提升备考方向感与答题效率',
							textAlign: TextAlign.center,
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
						tapah.parseimage('栏目/笔试题库/顶部.png'),
					),
				),
			),
			const SizedBox(height: 28),
			// 刷题模块标题（居中带横线）
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20),
				child: Row(
					children: const [
						Expanded(child: Divider(color: Color(0xFFDDDDDD))),
						Padding(
							padding: EdgeInsets.symmetric(horizontal: 12),
							child: Text('刷题模块', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
									imageName: '栏目/笔试题库/真题精选.png',
									bgColor: const Color(0xFFECF3FD),
									label: '真题精选',
									sub: '贴近真实笔试场景',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/笔试题库/高频考点.png',
									bgColor: const Color(0xFFECF3FD),
									label: '高频考点',
									sub: '结合背景制定求职路径',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/笔试题库/分类练习.png',
									bgColor: const Color(0xFFECF3FD),
									label: '分类练习',
									sub: '按题型系统训练',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/笔试题库/笔试辅导.png',
									bgColor: const Color(0xFFECF3FD),
									label: '笔试辅导',
									sub: '顾问协助规划方向',
								)),
							],
						),
					],
				),
			),
			const SizedBox(height: 16),
			// MPFlutter_Wechat_Button(
			// 	onTap: (_) {
			GestureDetector(
				onTap: () {
					tapah.KeFu(context);
				},
				child: Padding(
				padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
				child: Container(
					width: double.infinity,
					height: 160,
					decoration: BoxDecoration(
						color: const Color(0xFFEFF6FA),
						borderRadius: BorderRadius.circular(18),
					),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Container(
								width: 200,
								height: 46,
								decoration: BoxDecoration(
									color: const Color(0xFF2D7BFF),
									borderRadius: BorderRadius.circular(20),
								),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Image.network(
											tapah.parseimage('栏目/笔试题库/微信.png'),
										),
										const SizedBox(width: 10,),
										Text("立即咨询", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
									],
								),
							),
							const SizedBox(height: 10,),
							const SizedBox(
								width: 270,
								child: Text("点击按钮，即可添加顾问老师企业微信 1v1获取专属题库推荐与备考建议", style: const TextStyle(fontSize: 16, color: Color(0xFF3D3D3D)), textAlign: TextAlign.center,),
							),
						],
					),
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
		], title: '笔试题库');
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
						width: 40,
						height: 40,
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
}

