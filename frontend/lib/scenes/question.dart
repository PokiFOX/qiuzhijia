import 'package:flutter/material.dart';

import 'package:pluto_grid/pluto_grid.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;
import 'package:frontend/tapah/request.dart' as tapah;

class QuestionWidget extends StatefulWidget {
	const QuestionWidget({super.key});

	@override
	State<QuestionWidget> createState() => QuestionState();
}

class QuestionState extends State<QuestionWidget> {
	PlutoGridStateManager? stateManager;
	late List<PlutoColumn> columns = [];

	@override
	void initState() {
		super.initState();
		columns = [
			PlutoColumn(
				title: 'ID',
				field: 'id',
				type: PlutoColumnType.text(),
				enableEditingMode: false,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '智能体',
				field: 'agent',
				type: PlutoColumnType.select(['resume', 'joblevel']),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '问题内容',
				field: 'question',
				type: PlutoColumnType.text(),
				enableEditingMode: true,
				enableColumnDrag: false,
			),
			PlutoColumn(
				title: '操作',
				field: 'operation',
				type: PlutoColumnType.text(),
				enableEditingMode: false,
				enableColumnDrag: false,
				renderer: (renderercontext) {
					final id = renderercontext.row.cells['id']!.value;
					if (id == null || id.toString().isEmpty) {
						return GestureDetector(
							onTap: () async {
								final agent = renderercontext.row.cells['agent']!.value?.toString() ?? '';
								final question = renderercontext.row.cells['question']!.value?.toString() ?? '';
								if (agent.isEmpty || question.isEmpty) return;
								await tapah.RequestAddQuestion(agent, question);
								await getQuestionList();
								setState(() {});
							},
							child: const Text("添加", style: TextStyle(color: Colors.green, decoration: TextDecoration.underline,),),
						);
					}
					final item = tapah.questionlist.firstWhere(
						(element) => element.id == id,
						orElse: () => tapah.Question(id: 0, agent: '', question: ''),
					);
					if (item.id == 0) return const SizedBox.shrink();
					return GestureDetector(
						onTap: () async {
							if (await showAdaptiveDialog<bool>(
								context: context,
								builder: (BuildContext context) => AlertDialog.adaptive(
									title: const Text('确认操作'),
									content: const Text('你确定要执行此操作吗？此过程不可逆。'),
									actions: <Widget>[
										TextButton(
											onPressed: () => Navigator.pop(context, false),
											child: const Text('取消', style: TextStyle(color: Colors.grey)),
										),
										TextButton(
											onPressed: () => Navigator.pop(context, true),
											child: const Text('确认', style: TextStyle(color: Colors.red)),
										),
									],
								),
							) != true) return;
							await tapah.RequestDeleteQuestion(item.id);
							await getQuestionList();
							setState(() {});
						},
						child: const Text("删除", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline,),),
					);
				},
			),
		];
		getQuestionList();
	}

	Future<void> getQuestionList() async {
		await tapah.RequestQuestionListAll();
		if (stateManager != null) {
			stateManager!.removeAllRows();
			stateManager!.appendRows(buildRows());
		} else {
			setState(() {});
		}
	}

	List<PlutoRow> buildRows() {
		List<PlutoRow> rows = tapah.questionlist.map((item) => PlutoRow(
			cells: {
				'id': PlutoCell(value: item.id),
				'agent': PlutoCell(value: item.agent),
				'question': PlutoCell(value: item.question),
				'operation': PlutoCell(value: ""),
			},
		)).toList();
		rows.add(PlutoRow(
			cells: {
				'id': PlutoCell(value: ""),
				'agent': PlutoCell(value: "resume"),
				'question': PlutoCell(value: ""),
				'operation': PlutoCell(value: ""),
			},
		));
		return rows;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('问题列表'),
			),
			body: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20,),
				child: PlutoGrid(
					columns: columns,
					rows: buildRows(),
					onChanged: (PlutoGridOnChangedEvent event) async {
						if (event.row.cells['id']!.value == null || event.row.cells['id']!.value == '') return;
						final item = tapah.questionlist.firstWhere((element) => element.id == event.row.cells['id']!.value);
						item.agent = event.row.cells['agent']!.value.toString();
						item.question = event.row.cells['question']!.value.toString();
						await tapah.RequestEditQuestion(item);
						await getQuestionList();
						setState(() {});
					},
					onLoaded: (PlutoGridOnLoadedEvent event) {
						stateManager = event.stateManager;
					},
				),
			),
		);
	}
}
