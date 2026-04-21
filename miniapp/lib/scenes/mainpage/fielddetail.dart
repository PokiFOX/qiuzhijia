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
	int _enterprisePage = 0;
	int _casePage = 0;
	final ScrollController _scrollController = ScrollController();
	final GlobalKey _scrollViewKey = GlobalKey();
	final GlobalKey _detailSectionKey = GlobalKey();
	final GlobalKey _enterpriseSectionKey = GlobalKey();
	final GlobalKey _caseSectionKey = GlobalKey();
	int _activeTab = 0;
	bool _isTabScrolling = false;
	int expandindex = -1;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_fielddetail, widget.key!);
		_scrollController.addListener(_onScroll);
		loadEnterprise();
	}

	@override
	void dispose() {
		_scrollController.removeListener(_onScroll);
		_scrollController.dispose();
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
			_enterprisePage = 0;
			_casePage = 0;
			isLoading = false;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF1F2F4),
			body: Column(
				children: [
					SizedBox(height: 30),
					_buildTabHeader(),
					Expanded(
						child: isLoading
							? const Center(child: CircularProgressIndicator())
							: SingleChildScrollView(
								key: _scrollViewKey,
								controller: _scrollController,
								padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Container(key: _detailSectionKey, child: _buildFieldInfoCard()),
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

	Widget _buildTabHeader() {
		return Container(
			height: 54,
			padding: const EdgeInsets.symmetric(horizontal: 6),
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
					Expanded(
						child: Row(
							children: [
								Expanded(child: _buildTabItem('专业详情', 0)),
								Expanded(child: _buildTabItem('招聘企业', 1)),
								Expanded(child: _buildTabItem('成功案例', 2)),
							],
						),
					),
					const SizedBox(width: 8),
				],
			),
		);
	}

	Widget _buildTabItem(String text, int index) {
		final active = _activeTab == index;
		return GestureDetector(
			onTap: () => _scrollToSection(index),
			child: Container(
				alignment: Alignment.center,
				decoration: BoxDecoration(
					border: Border(
						bottom: BorderSide(color: active ? const Color(0xFF2D7BFF) : Colors.transparent, width: 2),
					),
				),
				child: Text(
					text,
					style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: active ? const Color(0xFF2D7BFF) : const Color(0xFF444444)),
				),
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
		const pageSize = 3;
		final pageCount = enterprise.isEmpty ? 0 : ((enterprise.length + pageSize - 1) ~/ pageSize);
		final currentPage = pageCount == 0 ? 0 : _enterprisePage.clamp(0, pageCount - 1);
		final start = currentPage * pageSize;
		final end = pageCount == 0 ? 0 : (start + pageSize > enterprise.length ? enterprise.length : start + pageSize);
		final list = pageCount == 0 ? <tapah.Enterprise>[] : enterprise.sublist(start, end);
		return Container(
			key: _enterpriseSectionKey,
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: GestureDetector(
				behavior: HitTestBehavior.opaque,
				onHorizontalDragEnd: (details) {
					if (pageCount <= 1) return;
					final velocity = details.primaryVelocity ?? 0;
					if (velocity > 100 && currentPage < pageCount - 1) {
						setState(() => _enterprisePage = currentPage + 1);
					} else if (velocity < -100 && currentPage > 0) {
						setState(() => _enterprisePage = currentPage - 1);
					}
				},
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Expanded(child: _buildSectionTitle('热招企业')),
								if (pageCount > 1)
									Text('${currentPage + 1}/$pageCount  左右滑动', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
							],
						),
						const SizedBox(height: 10),
						if (list.isEmpty)
							const Padding(
								padding: EdgeInsets.symmetric(vertical: 12),
								child: Text('暂无相关企业', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
							),
						...list.map((ent) => _buildEnterpriseCard(ent)),
					],
				),
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
		const pageSize = 3;
		final pageCount = cases.isEmpty ? 0 : ((cases.length + pageSize - 1) ~/ pageSize);
		final currentPage = pageCount == 0 ? 0 : _casePage.clamp(0, pageCount - 1);
		final start = currentPage * pageSize;
		final end = pageCount == 0 ? 0 : (start + pageSize > cases.length ? cases.length : start + pageSize);
		final list = pageCount == 0 ? <tapah.Case>[] : cases.sublist(start, end);
		return Container(
			key: _caseSectionKey,
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: GestureDetector(
				behavior: HitTestBehavior.opaque,
				onHorizontalDragEnd: (details) {
					if (pageCount <= 1) return;
					final velocity = details.primaryVelocity ?? 0;
					if (velocity > 100 && currentPage < pageCount - 1) {
						setState(() => _casePage = currentPage + 1);
					} else if (velocity < -100 && currentPage > 0) {
						setState(() => _casePage = currentPage - 1);
					}
				},
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Expanded(child: _buildSectionTitle('成功案例')),
								if (pageCount > 1)
									Text('${currentPage + 1}/$pageCount  左右滑动', style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
							],
						),
						const SizedBox(height: 10),
						if (list.isEmpty)
							const Padding(
								padding: EdgeInsets.symmetric(vertical: 12),
								child: Text('暂无相关案例', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
							),
						...list.map((c) => _buildCaseCard(c)),
					],
				),
			),
		);
	}

	Widget _buildCaseCard(tapah.Case c) {
		Widget infoRow(String label, String? value) {
			if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
			return Padding(
				padding: const EdgeInsets.symmetric(vertical: 2),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						SizedBox(
							width: 70,
							child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
						),
						Expanded(
							child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
						),
					],
				),
			);
		}

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
							Expanded(child: Container(),),
							GestureDetector(
								onTap: () {
									setState(() {
										if (expandindex == c.id) {
											expandindex = -1;
										} else {
											expandindex = c.id;
										}
									});
								},
								child: Text(expandindex == c.id ? "收起" : "展开", style: const TextStyle(fontSize: 12, color: Colors.blue),),
							),
						],
					),
					if (expandindex == c.id) ...[
						const Divider(height: 16, thickness: 0.5),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								infoRow("本科院校", c.school1),
								infoRow("本科专业", c.field1),
								infoRow("硕士院校", c.school2),
								infoRow("硕士专业", c.field2),
								if (c.detail != null && c.detail!.trim().isNotEmpty) ...[
									const SizedBox(height: 6),
									Text("主要经历", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
									const SizedBox(height: 4),
									widgets.ExpandableText(
										c.detail!,
										style: const TextStyle(fontSize: 13, color: Colors.black),
										expandText: '展开',
										collapseText: '收起',
										maxLines: 3,
										linkColor: Colors.blue,
									),
								],
							],
						),
					],
				],
			),
		);
	}

	void _onScroll() {
		if (_isTabScrolling || !_scrollController.hasClients) return;
		final enterpriseTop = _getSectionOffset(_enterpriseSectionKey);
		final caseTop = _getSectionOffset(_caseSectionKey);
		final current = _scrollController.offset + 40;
		int nextTab = 0;
		if (current >= caseTop) {
			nextTab = 2;
		} else if (current >= enterpriseTop) {
			nextTab = 1;
		}
		if (_activeTab != nextTab) {
			setState(() {
				_activeTab = nextTab;
			});
		}
	}

	void _scrollToSection(int index) {
		if (!_scrollController.hasClients) return;
		final key = index == 0 ? _detailSectionKey : (index == 1 ? _enterpriseSectionKey : _caseSectionKey);
		final target = _getSectionOffset(key).clamp(0.0, _scrollController.position.maxScrollExtent);
		setState(() {
			_activeTab = index;
		});
		_isTabScrolling = true;
		_scrollController
			.animateTo(
				target,
				duration: const Duration(milliseconds: 280),
				curve: Curves.easeOutCubic,
			)
			.whenComplete(() {
				_isTabScrolling = false;
			});
	}

	double _getSectionOffset(GlobalKey key) {
		if (!_scrollController.hasClients) return 0;
		final scrollContext = _scrollViewKey.currentContext;
		final targetContext = key.currentContext;
		if (scrollContext == null || targetContext == null) return _scrollController.offset;
		final scrollBox = scrollContext.findRenderObject() as RenderBox?;
		final targetBox = targetContext.findRenderObject() as RenderBox?;
		if (scrollBox == null || targetBox == null) return _scrollController.offset;
		final dy = targetBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;
		return _scrollController.offset + dy;
	}
}
