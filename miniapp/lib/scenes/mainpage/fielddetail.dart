import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as fn;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;

class FieldDetailWidget extends StatefulWidget {
	final tapah.Field field;
	const FieldDetailWidget({super.key, required this.field});

	@override
	State<FieldDetailWidget> createState() => FieldDetailState();
}

class FieldDetailState extends State<FieldDetailWidget> with tapah.Callback {
	List<tapah.Enterprise> enterprise = [];
	List<tapah.Case> cases = [];
	bool isLoading = true;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_fielddetail, widget.key!);
		loadEnterprise();
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	void loadEnterprise() async {
		setState(() {
			isLoading = true;
			enterprise = [];
			cases = [];
		});
		var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, widget.field.id, null, "", 1);
		var caseList = await tapah.RequestCase(0, 0, 0, widget.field.id, 0, 0, 1);
		if (!mounted) return;
		setState(() {
			enterprise = enterpriseList;
			cases = caseList;
			isLoading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF1F2F4),
			body: Column(
				children: [
					_buildHeader(),
					Expanded(
						child: isLoading
							? const Center(child: CircularProgressIndicator())
							: SingleChildScrollView(
								padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										_buildFieldInfoCard(),
										const SizedBox(height: 12),
										_buildEnterpriseSection(),
										const SizedBox(height: 12),
										_buildCaseSection(),
									],
								),
							),
					),
				],
			),
		);
	}

	Widget _buildHeader() {
		return Container(
			height: 68,
			padding: const EdgeInsets.symmetric(horizontal: 8),
			decoration: const BoxDecoration(
				color: Color(0xFFF1F2F4),
				border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2), width: 0.7)),
			),
			child: Row(
				children: [
					IconButton(
						onPressed: () => Navigator.pop(context),
						icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF333333)),
					),
					const Expanded(
						child: Center(
							child: Text(
								'专业详情',
								style: TextStyle(fontSize: 34 / 2, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
							),
						),
					),
					const SizedBox(width: 48),
				],
			),
		);
	}

	Widget _buildFieldInfoCard() {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
			decoration: BoxDecoration(
				color: const Color(0xFFDDE5F4),
				borderRadius: BorderRadius.circular(14),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						widget.field.value,
						style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D7BFF)),
					),
					const SizedBox(height: 4),
					Text('学科门类: ${widget.field.type}', style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
					const SizedBox(height: 4),
					Row(
						children: [
							const Text('专业热门度: ', style: TextStyle(fontSize: 13, color: Color(0xFF333333))),
							...List.generate(
								widget.field.star.clamp(0, 8),
								(_) => const Padding(
									padding: EdgeInsets.only(right: 2),
									child: Icon(Icons.star, size: 17, color: Color(0xFFF6C44D)),
								),
							),
						],
					),
					const SizedBox(height: 6),
					widgets.ExpandableText(
						widget.field.content,
						maxLines: 2,
						style: const TextStyle(fontSize: 11, color: Color(0xFF555555), height: 1.4),
						expandText: '展开',
						collapseText: '收起',
						linkColor: const Color(0xFF2D7BFF),
					),
				],
			),
		);
	}

	Widget _buildSectionTitle(String title) {
		return Row(
			children: [
				Container(
					width: 4,
					height: 20,
					decoration: BoxDecoration(
						color: const Color(0xFF2D7BFF),
						borderRadius: BorderRadius.circular(2),
					),
				),
				const SizedBox(width: 8),
				Text(title, style: const TextStyle(fontSize: 34 / 2, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
			],
		);
	}

	Widget _buildEnterpriseSection() {
		final list = enterprise.take(3).toList();
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					_buildSectionTitle('热招企业'),
					const SizedBox(height: 10),
					if (list.isEmpty)
						const Padding(
							padding: EdgeInsets.symmetric(vertical: 12),
							child: Text('暂无相关企业', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
						),
					...list.map((ent) => _buildEnterpriseCard(ent)),
				],
			),
		);
	}

	Widget _buildEnterpriseCard(tapah.Enterprise ent) {
		return GestureDetector(
			onTap: () {
				Navigator.pushNamed(context, '/enterprise/detail', arguments: ent);
			},
			child: Container(
				margin: const EdgeInsets.only(bottom: 8),
				padding: const EdgeInsets.all(10),
				decoration: BoxDecoration(
					color: const Color(0xFFF7F8FA),
					borderRadius: BorderRadius.circular(12),
					border: Border.all(color: const Color(0xFFE2E2E2), width: 0.8),
				),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						Container(
							width: 58,
							height: 58,
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(8),
								border: Border.all(color: const Color(0xFFE3E3E3), width: 0.6),
							),
							child: Center(
								child: ent.icon == null || ent.icon!.isEmpty
									? const Icon(Icons.business, color: Color(0xFFB4B4B4), size: 28)
									: Image.network(fn.parseimage('小图标/${ent.icon}.png'), width: 44, height: 44),
							),
						),
						const SizedBox(width: 10),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										ent.name ?? '--',
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
									),
									const SizedBox(height: 5),
									SingleChildScrollView(
										scrollDirection: Axis.horizontal,
										child: Row(
											children: (ent.tags.where((t) => t.trim().isNotEmpty).take(2)).map((tag) {
												return Container(
													margin: const EdgeInsets.only(right: 8),
													padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
													decoration: BoxDecoration(
														color: const Color(0xFFCFE0F7),
														borderRadius: BorderRadius.circular(2),
													),
													child: Text(tag, style: const TextStyle(fontSize: 10, color: Color(0xFF4E79B3))),
												);
											}).toList(),
										),
									),
									const SizedBox(height: 5),
									Text('${ent.zone?.value ?? '--'} ${ent.city ?? '--'}', style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
								],
							),
						),
						const SizedBox(width: 8),
						Column(
							children: [
								GestureDetector(
									onTap: () {
										Navigator.pushNamed(context, '/enterprise/detail', arguments: ent);
									},
									child: Text('查看企业详情 >', style: const TextStyle(fontSize: 11, color: Color(0xFF2D7BFF))),
								),
							],
						),
					],
				),
			),
		);
	}

	Widget _buildCaseSection() {
		final list = cases.take(3).toList();
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					_buildSectionTitle('成功案例'),
					const SizedBox(height: 10),
					if (list.isEmpty)
						const Padding(
							padding: EdgeInsets.symmetric(vertical: 12),
							child: Text('暂无相关案例', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
						),
					...list.map((c) => _buildCaseCard(c)),
				],
			),
		);
	}

	Widget _buildCaseCard(tapah.Case c) {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(8),
			),
			padding: const EdgeInsets.all(10),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Text(
								c.student ?? "",
								style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D7BFF),)
							),
							const SizedBox(width: 5,),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										c.entname ?? "",
										style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
									),
									Text(
										c.name,
										style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
									),
								],
							),
						],
					),
					const SizedBox(height: 5,),
					Row(
						children: [
							Wrap(
								spacing: 5,
								runSpacing: 3,
								children: c.tags.where((t) => t.trim().isNotEmpty).map((tag) => Container(
									padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
									decoration: BoxDecoration(
										color: const Color(0xFFE8F0FE),
										borderRadius: BorderRadius.circular(4),
									),
									child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF2D7BFF))),
								)).toList(),
							),
						],
					),
				],
			),
		);
	}
}
