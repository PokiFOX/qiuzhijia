import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:frontend/tapah/request.dart' as tapah;

class ImportWidget extends StatefulWidget {
	const ImportWidget({super.key});

	@override
	State<ImportWidget> createState() => ImportState();
}

class ImportState extends State<ImportWidget> {
	String resultCode = '';
	String resultStatus = '';

	void _applyResponse(dynamic response) {
		final data = response?.data;
		if (data is! Map) {
			setState(() {
				resultCode = '-1';
				resultStatus = '响应格式错误';
			});
			return;
		}
		setState(() {
			resultCode = data['code']?.toString() ?? '';
			resultStatus = data['status']?.toString() ?? '';
		});
	}

	void _applyError(Object e) {
		setState(() {
			resultCode = '-1';
			resultStatus = e.toString();
		});
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
									try {
										final result = await FilePicker.platform.pickFiles(
											type: FileType.any,
											withData: true,
										);
										if (result == null || result.files.isEmpty) return;
										final file = result.files.single;
										final bytes = file.bytes;
										if (bytes == null || bytes.isEmpty) {
											_applyError(StateError('未能读取文件内容'));
											return;
										}
										final response = await tapah.RequestImport(file.name, bytes);
										_applyResponse(response);
									} catch (e) {
										_applyError(e);
									}
								},
								child: const Text('选择文件'),
							),
							const SizedBox(width: 20),
							ElevatedButton(
								onPressed: () async {
									try {
										final response = await tapah.RequestExport();
										final data = response?.data;
										if (data is! Map || data['code'] != 0) {
											_applyResponse(response);
											return;
										}
										final encoding = data['encoding'] as String? ?? '';
										final filedata = data['filedata'] as String? ?? '';
										if (filedata.isEmpty) {
											setState(() {
												resultCode = '-1';
												resultStatus = 'filedata 为空';
											});
											return;
										}
										final filename = data['filename'] as String? ?? '企业列表.xlsx';
										final Uint8List bytes = encoding == 'base64'
											? base64Decode(filedata)
											: Uint8List.fromList(filedata.codeUnits);
										await tapah.saveExportedExcel(filename, bytes);
										_applyResponse(response);
									} catch (e) {
										_applyError(e);
									}
								},
								child: const Text('导出'),
							),
						],
					),
					const SizedBox(height: 20,),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							Text(resultCode),
							const SizedBox(width: 20),
							Expanded(child: Text(resultStatus)),
						],
					),
					const SizedBox(height: 20,),
				],
			),
		);
	}
}
