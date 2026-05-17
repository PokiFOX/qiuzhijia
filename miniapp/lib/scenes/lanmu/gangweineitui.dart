import 'package:flutter/material.dart';

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class GangWeiNeiTuiWidget extends StatefulWidget {
	const GangWeiNeiTuiWidget({super.key,});

	@override
	State<GangWeiNeiTuiWidget> createState() => GangWeiNeiTuiState();
}

class GangWeiNeiTuiState extends State<GangWeiNeiTuiWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_gangweineitui, widget.key!);
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
									const Text('岗位内推', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
									Image.network(
										tapah.parseimage('栏目/岗位内推/顶部.png'),
									),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												_sectionTitle('服务内容'),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/岗位内推/校招岗位.png',
															bgColor: const Color(0xFFC8DBFC),
															label: '校招岗位',
															sub: '应届/秋招/春招',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/岗位内推/社招岗位.png',
															bgColor: const Color(0xFFDED8FD),
															label: '社招岗位',
															sub: '社会招聘/转岗方向',
														)),
													],
												),
												const SizedBox(height: 12),
												Row(
													children: [
														Expanded(child: _typeCard(
															imageName: '栏目/岗位内推/管培项目.png',
															bgColor: const Color(0xFFFCE5D2),
															label: '管培项目',
															sub: '管培生/储备干部方向',
														)),
														const SizedBox(width: 12),
														Expanded(child: _typeCard(
															imageName: '栏目/岗位内推/定向推荐.png',
															bgColor: const Color(0xFFD4F0E9),
															label: '定向推荐',
															sub: '结合背景精准匹配',
														)),
													],
												),
												const SizedBox(height: 24),
												_sectionTitle('推荐优势'),
												const SizedBox(height: 12),
												_contentCard(
													imageName: '栏目/岗位内推/精准岗位筛选.png',
													title: '精准岗位筛选',
													bullets: [
														'结合学历、专业、经历与意向城市匹配岗位',
														'帮助缩小投递范围，提高投递效率',
													],
												),
												const SizedBox(height: 12),
												_contentCard(
													imageName: '栏目/岗位内推/投递支持服务.png',
													title: '投递支持服务',
													bullets: [
														'简历优化、网申提醒、笔试面试节奏建议',
														'从岗位推荐到投递跟进形成完整闭环',
													],
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
												tapah.parseimage('栏目/岗位内推/底部.png'),
											),
										),
									),
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

	Widget _contentCard({
		required String imageName,
		required String title,
		required List<String> bullets,
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
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Image.network(
						tapah.parseimage(imageName),
					),
					const SizedBox(width: 14),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
								const SizedBox(height: 8),
								...bullets.map((b) => Padding(
									padding: const EdgeInsets.only(bottom: 4),
									child: Text('· $b', style: const TextStyle(fontSize: 10, color: Color(0xFF555555), height: 1.5)),
								)),
							],
						),
					),
				],
			),
		);
	}
}

