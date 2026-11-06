import 'package:flutter/material.dart';

import 'package:frontend/tapah/request.dart' as tapah;

class DbtiAppointmentsWidget extends StatefulWidget {
	const DbtiAppointmentsWidget({super.key});

	@override
	State<DbtiAppointmentsWidget> createState() => DbtiAppointmentsState();
}

class DbtiAppointmentsState extends State<DbtiAppointmentsWidget> {
	bool _loading = true;
	String? _error;
	List<Map<String, dynamic>> _rows = [];
	int _total = 0;

	@override
	void initState() {
		super.initState();
		_load();
	}

	Future<void> _load() async {
		setState(() {
			_loading = true;
			_error = null;
		});
		try {
			final data = await tapah.RequestQueryDbtiAppointments(limit: 200, offset: 0);
			final list = data['list'];
			if (list is! List) {
				throw Exception('响应格式错误');
			}
			if (!mounted) return;
			setState(() {
				_rows = list
						.map((e) => Map<String, dynamic>.from((e as Map).cast<String, dynamic>()))
						.toList();
				_total = (data['total'] is int) ? data['total'] as int : _rows.length;
				_loading = false;
			});
		} catch (e) {
			if (!mounted) return;
			setState(() {
				_error = e.toString();
				_loading = false;
			});
		}
	}

	String _diff(dynamic d) {
		if (d is List) {
			return d.map((e) => e.toString()).join('、');
		}
		return d?.toString() ?? '';
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('DBTI 预约列表'),
				actions: [
					IconButton(
						icon: const Icon(Icons.refresh),
						onPressed: _loading ? null : _load,
					),
				],
			),
			body: _loading
					? const Center(child: CircularProgressIndicator())
					: _error != null
							? Center(
									child: Padding(
										padding: const EdgeInsets.all(24),
										child: SelectableText(
											_error!,
											style: const TextStyle(color: Colors.red),
										),
									),
								)
							: _rows.isEmpty
									? const Center(child: Text('暂无记录'))
									: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch,
											children: [
												Padding(
													padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
													child: Text(
														'共 $_total 条（本页 ${_rows.length} 条）',
														style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
													),
												),
												Expanded(
													child: ListView.separated(
														itemCount: _rows.length,
														separatorBuilder: (_, __) => const Divider(height: 1),
														itemBuilder: (context, index) {
															final r = _rows[index];
															final phone = r['phone']?.toString() ?? '';
															final mbti = r['mbtiType']?.toString() ?? '';
															final jobs = r['recommendedJobs']?.toString() ?? '';
															final target = r['targetDirection']?.toString() ?? '';
															final stage = r['currentStage']?.toString() ?? '';
															final diff = _diff(r['difficulties']);
															final time = r['contactTime']?.toString() ?? '';
															final lead = r['leadLevel']?.toString() ?? '';
															final updated = r['updatedAt']?.toString() ?? '';
															return ExpansionTile(
																title: Text(
																	'$phone  ·  $mbti',
																	style: const TextStyle(
																		fontWeight: FontWeight.w600,
																		fontSize: 15,
																	),
																),
																subtitle: Text(
																	'更新 $updated',
																	style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
																),
																children: [
																	Padding(
																		padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
																		child: Align(
																			alignment: Alignment.centerLeft,
																			child: DefaultTextStyle(
																				style: const TextStyle(fontSize: 13, height: 1.45),
																				child: Column(
																					crossAxisAlignment: CrossAxisAlignment.start,
																					children: [
																						Text('推荐岗位：$jobs'),
																						Text('目标方向：$target'),
																						Text('当前阶段：$stage'),
																						Text('当前困难：$diff'),
																						Text('联系时间：$time'),
																						Text('lead：$lead'),
																					],
																				),
																			),
																		),
																	),
																],
															);
														},
													),
												),
											],
										),
		);
	}
}
