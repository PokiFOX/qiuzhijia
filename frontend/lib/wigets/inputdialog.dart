import 'package:flutter/material.dart';

class InputDialog {
	static Future<String?> show(BuildContext context, {required String title, String defaultText = '',}) async {
		final TextEditingController controller = TextEditingController(text: defaultText);
		return showDialog<String?>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text(title),
					content: TextField(
						controller: controller,
						decoration: const InputDecoration(
							hintText: 'Enter text',
							border: OutlineInputBorder(),
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context, null),
							child: const Text('Cancel'),
						),
						TextButton(
							onPressed: () => Navigator.pop(context, controller.text),
							child: const Text('OK'),
						),
					],
				);
			},
		);
	}
}
