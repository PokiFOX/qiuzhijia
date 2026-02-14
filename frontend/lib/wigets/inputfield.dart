import 'package:flutter/material.dart';

import 'package:frontend/tapah/class.dart' as tapah;

class InputField {
	static Future<List<String>?> show(BuildContext context, {required tapah.Field field,}) async {
		final TextEditingController controller1 = TextEditingController(text: field.value);
		final TextEditingController controller2 = TextEditingController(text: field.sector);
		final TextEditingController controller3 = TextEditingController(text: field.star.toString());
		final TextEditingController controller4 = TextEditingController(text: field.content);
		return showDialog<List<String>?>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("编辑学科"),
					content: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									const Text("学科名称:"),
									const SizedBox(width: 20,),
									Expanded(
										child: TextField(
											controller: controller1,
											decoration: const InputDecoration(
												hintText: 'Enter text',
												border: OutlineInputBorder(),
											),
										),
									),
								],
							),
							const SizedBox(height: 20,),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									const Text("所属行业:"),
									const SizedBox(width: 20,),
									Expanded(
										child: TextField(
											controller: controller2,
											decoration: const InputDecoration(
												hintText: 'Enter text',
												border: OutlineInputBorder(),
											),
										),
									),
								],
							),
							const SizedBox(height: 20,),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									const Text("星级:"),
									const SizedBox(width: 20,),
									Expanded(
										child: TextField(
											controller: controller3,
											decoration: const InputDecoration(
												hintText: 'Enter text',
												border: OutlineInputBorder(),
											),
										),
									),
								],
							),
							const SizedBox(height: 20,),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									const Text("备注:"),
									const SizedBox(width: 20,),
									Expanded(
										child: TextField(
											controller: controller4,
											decoration: const InputDecoration(
												hintText: 'Enter text',
												border: OutlineInputBorder(),
											),
										),
									),
								],
							),
						],
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
								List<String> result = [controller1.text, controller2.text, controller3.text, controller4.text];
								Navigator.pop(context, result);
							},
							child: const Text('OK'),
						),
					],
				);
			},
		);
	}
}
