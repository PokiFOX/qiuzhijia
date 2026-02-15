import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:frontend/tapah/request.dart' as tapah;

class ImportWidget extends StatefulWidget {
	const ImportWidget({super.key});

	@override
	State<ImportWidget> createState() => ImportState();
}

class ImportState extends State<ImportWidget> {
	dynamic response;

	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('导入表格'),
			),
			body: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					const SizedBox(height: 20,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50),
							ElevatedButton(
								onPressed: () async {
									FilePickerResult? result = await FilePicker.platform.pickFiles(
										type: FileType.any,
										withData: true,
									);
									if (result == null) return;
									var file = result.files.single;
									response = await tapah.RequestImport(file.name, file.bytes);
									setState(() {});
								},
								child: const Text('选择文件'),
							),
						],
					),
					const SizedBox(height: 20,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Text(response != null ? response.data['code'].toString() : ''),
							const SizedBox(width: 20),
							Text(response != null ? response.data['status'] : ''),
						],
					),
					const SizedBox(height: 20,),
				],
			),
		);
	}
}
