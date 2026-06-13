import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;
import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;
import 'package:qiuzhijia/widgets/expandable_text.dart' as widgets;

class FieldDetailWidget extends StatefulWidget {
	const FieldDetailWidget({super.key});

	@override
	State<FieldDetailWidget> createState() => FieldDetailState();
}

class FieldDetailState extends State<FieldDetailWidget> with tapah.Callback {
	tapah.Field? field;
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
	double _enterpriseDragAccum = 0.0;
	double _caseDragAccum = 0.0;
	int _enterpriseServerPage = 1;
	int _caseServerPage = 1;
	bool _isLoadingMoreEnterprise = false;
	bool _isLoadingMoreCase = false;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_fielddetail, widget.key!);
		_scrollController.addListener(_onScroll);
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is Map<String, dynamic>) {
			final fieldId = args["field"];
			if (fieldId != null && fieldId is int) {
				for (var f in tapah.fieldlist) {
					if (f.id == fieldId) {
						field = f;
						break;
					}
				}
			}
		}
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
		var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, field!.id, null, "", 1);
		var caseList = await tapah.RequestCase(0, 0, 0, field!.id, 0, 0, 0, 1);
		if (!mounted) return;
		setState(() {
			enterprise = enterpriseList;
			cases = caseList;
			_enterprisePage = 0;
			_casePage = 0;
			_enterpriseServerPage = 1;
			_caseServerPage = 1;
			isLoading = false;
		});
	}

	void _loadMoreEnterprise() async {
		if (_isLoadingMoreEnterprise) return;
		_isLoadingMoreEnterprise = true;
		final nextPage = _enterpriseServerPage + 1;
		var more = await tapah.RequestEnterprise(0, 0, 0, 0, field!.id, null, "", nextPage);
		if (!mounted) return;
		setState(() {
			_isLoadingMoreEnterprise = false;
			if (more.isNotEmpty) {
				enterprise.addAll(more);
				_enterpriseServerPage = nextPage;
				_enterprisePage = _enterprisePage + 1;
			}
		});
	}

	void _loadMoreCase() async {
		if (_isLoadingMoreCase) return;
		_isLoadingMoreCase = true;
		final nextPage = _caseServerPage + 1;
		var more = await tapah.RequestCase(0, 0, 0, field!.id, 0, 0, 0, nextPage);
		if (!mounted) return;
		setState(() {
			_isLoadingMoreCase = false;
			if (more.isNotEmpty) {
				cases.addAll(more);
				_caseServerPage = nextPage;
				_casePage = _casePage + 1;
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		bool fav = false;
		for (var item in tapah.accountinfo?.field ?? {}) {
			if (item == field?.id) {
				fav = true;
				break;
			}
		}
		final bottomBar = Container(
			height: 60,
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border(top: BorderSide(color: Colors.grey.shade200)),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					InkWell(
						onTap: () {
							tapah.navigator(context, '/mainpage');
						},
						child: Row(
							children: [
								Image.network(tapah.parseimage('企业详情/首页.png'), fit: BoxFit.contain, width: 28, height: 28,),
								Text("首页", style: TextStyle(color: Colors.black, fontSize: 10),),
							],
						),
					),
					const SizedBox(width: 20,),
					tapah.accountinfo == null ? MPFlutter_Wechat_Button(
						openType: "getPhoneNumber",
						onGetPhoneNumber: (result) async {
							await tapah.RequestWxCode(result["code"]);
							if (!mounted) return;
							setState(() {});
						},
						child: Row(
							children: [
								Image.network(tapah.parseimage(fav ? '企业详情/已收藏.png' : '企业详情/关注.png'), fit: BoxFit.contain, width: 28, height: 28,),
								Text(fav ? "已收藏" : "关注", style: TextStyle(color: Colors.black, fontSize: 10),),
							],
						),
					): InkWell(
						onTap: () {
							if (field == null) return;
							if (tapah.accountinfo!.field.contains(field!.id)) {
								tapah.accountinfo!.field.remove(field!.id);
							}
							else {
								tapah.accountinfo!.field.add(field!.id);
							}
							tapah.RequestUserInfo();
							setState(() {});
						},
						child: Row(
							children: [
								Image.network(tapah.parseimage(fav ? '企业详情/已收藏.png' : '企业详情/关注.png'), fit: BoxFit.contain, width: 28, height: 28,),
								Text(fav ? "已收藏" : "关注", style: TextStyle(color: Colors.black, fontSize: 10),),
							],
						),
					),
					const SizedBox(width: 20,),
					GestureDetector(
						onTap: () {
							tapah.KeFu(context);
						},
						child: Container(
							width: 100,
							height: 30,
							decoration: BoxDecoration(
								color: Color(0xFF82B2F5),
								borderRadius: BorderRadius.circular(15),
							),
							child: Center(
								child: Text("在线咨询", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),
							),
						),
					),
					const SizedBox(width: 20,),
					GestureDetector(
						onTap: () {
							wxapi.wx.makePhoneCall(wxapi.MakePhoneCallOption()..phoneNumber = '051281660895');
						},
						child: Container(
							width: 100,
							height: 30,
							decoration: BoxDecoration(
								color: Color(0xFFFFC300),
								borderRadius: BorderRadius.circular(15),
							),
							child: Center(
								child: Text("电话咨询", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),
							),
						),
					),
				],
			),
		);
		return tapah.wrapSwipePop(context, Scaffold(
			backgroundColor: const Color(0xFFF1F2F4),
			body: Column(
				children: [
					tapah.buildWechatNavBar(context, showBack: true),
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
			bottomNavigationBar: bottomBar,
		));
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
					Expanded(child: _buildTabItem('专业详情', 0)),
					Expanded(child: _buildTabItem('招聘企业', 1)),
					Expanded(child: _buildTabItem('成功案例', 2)),
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
						field?.value ?? "",
						style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D7BFF)),
					),
					const SizedBox(height: 4),
					Text('学科门类: ${field?.type ?? ""}', style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
					const SizedBox(height: 4),
					Row(
						children: [
							const Text('专业热门度: ', style: TextStyle(fontSize: 13, color: Color(0xFF333333))),
							...List.generate(
								field?.star.clamp(0, 8) ?? 0,
								(_) => const Padding(
									padding: EdgeInsets.only(right: 2),
									child: Icon(Icons.star, size: 17, color: Color(0xFFF6C44D)),
								),
							),
						],
					),
					const SizedBox(height: 6),
					widgets.ExpandableText(
						field?.content ?? "",
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
		if (enterprise.isEmpty) {
			return Container();
		}
		return Container(
			key: _enterpriseSectionKey,
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Expanded(child: _buildSectionTitle('热招企业')),
						],
					),
					const SizedBox(height: 10),
					SizedBox(
						height: 300,
						child: NotificationListener<ScrollNotification>(
							onNotification: (notification) {
								if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 24) {
									_loadMoreEnterprise();
								}
								return false;
							},
							child: SingleChildScrollView(
								child: Column(
									children: [
										...enterprise.map((ent) => _buildEnterpriseCard(ent)),
									],
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildEnterpriseCard(tapah.Enterprise ent) {
		return Container(
			margin: const EdgeInsets.only(bottom: 8),
			padding: const EdgeInsets.all(10),
			decoration: BoxDecoration(
				color: const Color(0xFFF7F8FA),
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: const Color(0xFFE2E2E2), width: 0.8),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.center,
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
								: Image.network(tapah.parseimage('小图标/${ent.icon}.png'), width: 44, height: 44),
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
													color: const Color(0xFFFEEDDF),
													borderRadius: BorderRadius.circular(2),
												),
												child: Text(tag, style: const TextStyle(fontSize: 10, color: Color(0xFF692E1F))),
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
									tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": ent.id});
								},
								child: Text('查看企业详情 >', style: const TextStyle(fontSize: 11, color: Color(0xFF2D7BFF))),
							),
						],
					),
				],
			),
		);
	}

	Widget _buildEnterpriseScrollbar(int currentPage, int pageCount) {
		const trackHeight = 258.0;
		final thumbHeight = trackHeight / pageCount;
		final thumbTop = currentPage * thumbHeight;
		return GestureDetector(
			behavior: HitTestBehavior.translucent,
			onTapDown: (details) {
				final rawPage = (details.localPosition.dy / trackHeight * pageCount).floor();
				if (rawPage >= pageCount) {
					_loadMoreEnterprise();
				} else {
					final tappedPage = rawPage.clamp(0, pageCount - 1);
					if (tappedPage == pageCount - 1 && _enterprisePage == pageCount - 1) {
						_loadMoreEnterprise();
					} else {
						setState(() => _enterprisePage = tappedPage);
					}
				}
			},
			child: SizedBox(
				width: 20,
				height: trackHeight,
				child: Center(
					child: SizedBox(
						width: 4,
						height: trackHeight,
						child: Stack(
							children: [
								Container(
									width: 4,
									height: trackHeight,
									decoration: BoxDecoration(
										color: const Color(0xFFE0E0E0),
										borderRadius: BorderRadius.circular(2),
									),
								),
								Positioned(
									top: thumbTop,
									child: Container(
										width: 4,
										height: thumbHeight,
										decoration: BoxDecoration(
											color: const Color(0xFF2D7BFF),
											borderRadius: BorderRadius.circular(2),
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _buildCaseSection() {
		if (cases.isEmpty) {
			return Container();
		}
		return Container(
			key: _caseSectionKey,
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Expanded(child: _buildSectionTitle('成功案例')),
						],
					),
					const SizedBox(height: 10),
					SizedBox(
						height: 250,
						child: NotificationListener<ScrollNotification>(
							onNotification: (notification) {
								if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 24) {
									_loadMoreCase();
								}
								return false;
							},
							child: SingleChildScrollView(
								child: Column(
									children: [
										...cases.map((c) => _buildCaseCard(c)),
									],
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildCaseScrollbar(int currentPage, int pageCount) {
		const margin = 20.0;
		// Positioned 父级给了有限高度，LayoutBuilder 可以正常拿到 maxHeight
		return LayoutBuilder(
			builder: (context, constraints) {
				final available = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
				final trackHeight = (available - margin * 2).clamp(20.0, double.infinity);
				final thumbHeight = (trackHeight / pageCount).clamp(8.0, trackHeight);
				final thumbTop = pageCount <= 1
						? 0.0
						: (currentPage * (trackHeight / pageCount)).clamp(0.0, trackHeight - thumbHeight);
				return GestureDetector(
					behavior: HitTestBehavior.translucent,
					onTapDown: (details) {
						final dy = details.localPosition.dy - margin;
						if (dy < 0) return;
						final rawPage = (dy / trackHeight * pageCount).floor();
						if (rawPage >= pageCount) {
							_loadMoreCase();
						} else {
							final tappedPage = rawPage.clamp(0, pageCount - 1);
							if (tappedPage >= pageCount - 1 && _casePage >= pageCount - 1) {
								_loadMoreCase();
							} else {
								setState(() => _casePage = tappedPage);
							}
						}
					},
					child: SizedBox(
						width: 26,
						height: available,
						child: Stack(
							children: [
								Positioned(
									top: margin,
									left: 11,
									child: Container(
										width: 4,
										height: trackHeight,
										decoration: BoxDecoration(
											color: const Color(0xFFE0E0E0),
											borderRadius: BorderRadius.circular(2),
										),
									),
								),
								Positioned(
									top: margin + thumbTop,
									left: 11,
									child: Container(
										width: 4,
										height: thumbHeight,
										decoration: BoxDecoration(
											color: const Color(0xFF2D7BFF),
											borderRadius: BorderRadius.circular(2),
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

	Widget _buildCaseCard(tapah.Case c) {
		tapah.Field? field1, field2;
		for (var f in tapah.fieldlist) {
			if (f.value == c.field1) {
				field1 = f;
			}
			if (f.value == c.field2) {
				field2 = f;
			}
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
								children: c.tags.where((t) => t.trim().isNotEmpty).toList().asMap().entries.map((entry) {
									const tagColors = [
										[Color(0xFFE8F0FE), Color(0xFF2D7BFF)], // 蓝
										[Color(0xFFFEEDDF), Color(0xFF692E1F)], // 金
										[Color(0xFFF3EEFF), Color(0xFF6B21A8)], // 紫
									];
									final bg = tagColors[entry.key % 3][0];
									final fg = tagColors[entry.key % 3][1];
									return Container(
										padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
										decoration: BoxDecoration(
											color: bg,
											borderRadius: BorderRadius.circular(4),
										),
										child: Text(entry.value, style: TextStyle(fontSize: 11, color: fg)),
									);
								}).toList(),
							),
							Expanded(child: Container(),),
							GestureDetector(
								onTap: () {
									setState(() {
										if (expandindex == cases.indexOf(c)) {
											expandindex = -1;
										} else {
											expandindex = cases.indexOf(c);
										}
									});
								},
								child: Text(expandindex == cases.indexOf(c) ? "收起" : "展开", style: const TextStyle(fontSize: 12, color: Colors.blue),),
							),
						],
					),
					if (expandindex == cases.indexOf(c)) ...[
						const Divider(height: 16, thickness: 0.5),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Container(
									margin: const EdgeInsets.only(bottom: 6),
									padding: const EdgeInsets.only(left: 8),
									decoration: const BoxDecoration(
										border: Border(left: BorderSide(color: Color(0xFF2D7BFF), width: 3)),
									),
									child: const Text(
										"基础信息",
										style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
									),
								),
								Table(
									columnWidths: const {
										0: IntrinsicColumnWidth(),
										1: FlexColumnWidth(1),
									},
									defaultVerticalAlignment: TableCellVerticalAlignment.top,
									children: [
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 学生姓名", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											Text(c.student ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科院校", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											Text(c.school1 ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科层次", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											Text(tapah.stagStr(c.stag1), style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 本科专业", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											GestureDetector(
												onTap: field1 != null ? () { tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field1!.id}); } : null,
												child: Text(c.field1 ?? '--', style: TextStyle(fontSize: 12, color: field1 != null ? const Color(0xFF2D7BFF) : const Color(0xFF555555))),
											),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士院校", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											Text(c.school2 ?? '--', style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士层次", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											Text(tapah.stagStr(c.stag2), style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8, bottom: 3), child: const Text("· 硕士专业", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											GestureDetector(
												onTap: field2 != null ? () { tapah.navigator(context, '/mainpage/fielddetail', arguments: {"field": field2!.id}); } : null,
												child: Text(c.field2 ?? '--', style: TextStyle(fontSize: 12, color: field2 != null ? const Color(0xFF2D7BFF) : const Color(0xFF555555))),
											),
										]),
										TableRow(children: [
											Padding(padding: const EdgeInsets.only(right: 8), child: const Text("· 主要实习", style: TextStyle(fontSize: 12, color: Color(0xFF555555)))),
											c.detail != null && c.detail!.trim().isNotEmpty
												? Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: c.detail!.split(',').map((s) => Text(
														s.trim(),
														style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
													)).toList(),
												)
												: const SizedBox(),
										]),
									],
								),
								const SizedBox(height: 10),
								Container(
									margin: const EdgeInsets.only(bottom: 6),
									padding: const EdgeInsets.only(left: 8),
									decoration: const BoxDecoration(
										border: Border(left: BorderSide(color: Color(0xFF2D7BFF), width: 3)),
									),
									child: const Text(
										"求职结果",
										style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
									),
								),
								Row(
									children: [
										Text("· 去向单位    	", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
										GestureDetector(
											onTap: () async {
												for (var i = 0;i < tapah.enterpriselist.length;i++) {
													if (tapah.enterpriselist[i].name == c.entname) {
														tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": tapah.enterpriselist[i].id});
														return;
													}
												}
												var enterpriseList = await tapah.RequestEnterprise(0, 0, 0, 0, 0, null, c.entname ?? '', 1);
												if (enterpriseList.isNotEmpty) {
													tapah.navigator(context, '/enterprise/detail', arguments: {"enterprise": enterpriseList[0].id});
												}
											},
											child: Text("${c.entname ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF2D7BFF)),),
										),
									],
								),
								Text("· 所在部门    	${c.dep ?? '--'}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
								Text("· 录取岗位    	${c.name}", style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
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
