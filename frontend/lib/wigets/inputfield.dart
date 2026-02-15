import 'package:flutter/material.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;

class InputFieldWidget extends StatefulWidget {
	final List<tapah.Field> fields;
	const InputFieldWidget({super.key, required this.fields});

	@override
	State<InputFieldWidget> createState() => InputFieldState();
}

class InputFieldState extends State<InputFieldWidget> {
	List<int> selected = [];

	@override
	void initState() {
		super.initState();
		selected = widget.fields.map((e) => e.id).toList();
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Text("选择学科"),
			content: SingleChildScrollView(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: tapah.fieldlist.map((e) => CheckboxListTile(
						title: Text(e.value),
						value: selected.contains(e.id),
						onChanged: (bool? value) {
							if (value == true) {
								selected.add(e.id);
							}
							else {
								selected.remove(e.id);
							}
							setState(() {});
						},
					)).toList(),
				),
			),
			actions: [
				TextButton(
					onPressed: () {
						Navigator.pop(context, null);
					},
					child: const Text('Cancel'),
				),
				TextButton(
					onPressed: () {
						List<tapah.Field> fields = [];
						for (var id in selected) {
							var field = tapah.fieldlist.firstWhere((element) => element.id == id, orElse: () => tapah.Field(id: id, value: "", sector: "", star: 0, content: ""));
							if (field.id == 0) continue;
							fields.add(field);
						}
						Navigator.pop(context, fields);
					},
					child: const Text('OK'),
				),
			],
		);
	}
}

Future<List<tapah.Field>?> showInputFieldDialog(BuildContext context, List<tapah.Field> fields) async {
	var result = await showDialog<List<tapah.Field>>(
		context: context,
		builder: (BuildContext context) {
			return InputFieldWidget(fields: fields);
		},
	);
	if (result != null) {
		return result;
	}
	else {
		return null;
	}
}
