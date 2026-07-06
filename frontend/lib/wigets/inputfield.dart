import 'package:flutter/material.dart';

import 'package:frontend/tapah/class.dart' as tapah;
import 'package:frontend/tapah/data.dart' as tapah;

List<String> _mappingTokens(tapah.Field field) {
	return field.mapping.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

class InputFieldWidget extends StatefulWidget {
	final String? mapping;
	const InputFieldWidget({super.key, required this.mapping});

	@override
	State<InputFieldWidget> createState() => InputFieldState();
}

class InputFieldState extends State<InputFieldWidget> {
	Set<String> selected = {};

	@override
	void initState() {
		super.initState();
		selected = (widget.mapping ?? '')
			.split(',')
			.map((e) => e.trim())
			.where((e) => e.isNotEmpty)
			.toSet();
	}

	@override
	Widget build(BuildContext context) {
		final children = <Widget>[];
		for (final field in tapah.fieldlist) {
			final tokens = _mappingTokens(field);
			if (tokens.isEmpty) continue;
			children.add(Padding(
				padding: const EdgeInsets.only(top: 8, bottom: 4),
				child: Text(field.value, style: const TextStyle(fontWeight: FontWeight.bold)),
			));
			for (final token in tokens) {
				children.add(CheckboxListTile(
					title: Text(token),
					value: selected.contains(token),
					onChanged: (bool? value) {
						if (value == true) {
							selected.add(token);
						} else {
							selected.remove(token);
						}
						setState(() {});
					},
				));
			}
		}
		return AlertDialog(
			title: const Text("选择学科"),
			content: SingleChildScrollView(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: children,
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
						Navigator.pop(context, selected.join(','));
					},
					child: const Text('OK'),
				),
			],
		);
	}
}

Future<String?> showInputFieldDialog(BuildContext context, String? mapping) async {
	return showDialog<String>(
		context: context,
		builder: (BuildContext context) {
			return InputFieldWidget(mapping: mapping);
		},
	);
}
