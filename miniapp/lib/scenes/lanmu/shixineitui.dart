import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class ShiXiNeiTuiWidget extends StatefulWidget {
	const ShiXiNeiTuiWidget({super.key,});

	@override
	State<ShiXiNeiTuiWidget> createState() => ShiXiNeiTuiState();
}

class ShiXiNeiTuiState extends State<ShiXiNeiTuiWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_shixineitui, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return tapah.buildMain1(context, [
			Center(child: const Text('实习内推', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),),
			// 顶部横幅
			Image.network(
				tapah.parseimage('栏目/实习内推/顶部.png'),
			),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// 服务内容
						_sectionTitle('服务内容'),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/实习内推/央国企实习.png',
									bgColor: const Color(0xFFC8DBFC),
									label: '央国企实习',
									sub: '国资平台/央企子公司',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/实习内推/金融机构实习.png',
									bgColor: const Color(0xFFDED8FD),
									label: '金融机构实习',
									sub: '银行/券商/保险/金科',
								)),
							],
						),
						const SizedBox(height: 12),
						Row(
							children: [
								Expanded(child: _typeCard(
									imageName: '栏目/实习内推/岗位匹配.png',
									bgColor: const Color(0xFFFCE5D2),
									label: '岗位匹配',
									sub: '结合背景推荐合适岗位',
								)),
								const SizedBox(width: 12),
								Expanded(child: _typeCard(
									imageName: '栏目/实习内推/投递辅导.png',
									bgColor: const Color(0xFFD4F0E9),
									label: '投递辅导',
									sub: '网申/笔试/面试建议',
								)),
							],
						),
						const SizedBox(height: 24),
						// 内推说明
						_sectionTitle('内推说明'),
						const SizedBox(height: 12),
						// 适合人群
						Container(
							padding: const EdgeInsets.all(14),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(12),
								boxShadow: [
									BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
								],
							),
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									Image.network(
										tapah.parseimage('栏目/实习内推/适合人群.png'),
									),
									const SizedBox(width: 14),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: const [
												Text('适合人群', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
												SizedBox(height: 8),
												Text('· 在校大学生/研一研二学生', style: TextStyle(fontSize: 10, height: 1.8)),
												Text('· 希望进入央国企/金融机构实习的同学', style: TextStyle(fontSize: 10, height: 1.8)),
												Text('· 希望获得高质量内推与专业辅导的同学', style: TextStyle(fontSize: 10, height: 1.8)),
											],
										),
									),
								],
							),
						),
						const SizedBox(height: 12),
						// 内推服务流程
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
									const Text('内推服务流程', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
									const SizedBox(height: 14),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceAround,
										children: [
											_flowStep('栏目/实习内推/流程-咨询评估.png', '咨询评估', const Color(0xFFC8DBFC),),
											const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),
											_flowStep('栏目/实习内推/流程-岗位匹配.png', '岗位匹配', const Color(0xFFFCE5D2),),
											const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),
											_flowStep('栏目/实习内推/流程-投递辅导.png', '投递辅导', const Color(0xFFD4F0E9),),
											const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCCCCCC)),
											_flowStep('栏目/实习内推/流程-跟进反馈.png', '跟进反馈', const Color(0xFFDED8FD),),
										],
									),
								],
							),
						),
					],
				),
			),
			// 底部
			Center(
				// child: MPFlutter_Wechat_Button(
				// 	onTap: (_) {
				child: GestureDetector(
					onTap: () {
						tapah.KeFu(context);
					},
					child: Image.network(
						tapah.parseimage('栏目/实习内推/底部.png'),
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
								Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
								const SizedBox(height: 4),
								Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF888888)), maxLines: 2),
							],
						),
					),
				],
			),
		);
	}

	Widget _flowStep(String imageName, String label, Color bgColor) {
		return Column(
			children: [
				Container(
					width: 40,
					height: 40,
					decoration: BoxDecoration(
						color: bgColor,
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

