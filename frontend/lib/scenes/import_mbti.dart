import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:frontend/tapah/request.dart' as tapah;

class ImportMbtiWidget extends StatefulWidget {
	const ImportMbtiWidget({super.key});

	@override
	State<ImportMbtiWidget> createState() => ImportMbtiState();
}

class ImportMbtiState extends State<ImportMbtiWidget> {
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
				title: const Text('MBTI 配置'),
			),
			body: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const SizedBox(height: 20),
					const Padding(
						padding: EdgeInsets.symmetric(horizontal: 50),
						child: Text(
							'上传 MBTI.xlsx（问题 / 结果 / 岗位），保存后立即生效，无需重启服务。',
						),
					),
					const SizedBox(height: 20),
					Row(
						mainAxisAlignment: MainAxisAlignment.start,
						children: [
							const SizedBox(width: 50),
							ElevatedButton(
								onPressed: () async {
									try {
										final result = await FilePicker.platform.pickFiles(
											type: FileType.custom,
											allowedExtensions: ['xlsx'],
											withData: true,
										);
										if (result == null || result.files.isEmpty) return;
										final file = result.files.single;
										final bytes = file.bytes;
										if (bytes == null || bytes.isEmpty) {
											_applyError(StateError('未能读取文件内容'));
											return;
										}
										final response = await tapah.RequestImportMbti(file.name, bytes);
										_applyResponse(response);
									} catch (e) {
										_applyError(e);
									}
								},
								child: const Text('上传 MBTI.xlsx'),
							),
							const SizedBox(width: 20),
							ElevatedButton(
								onPressed: () async {
									try {
										final response = await tapah.RequestExportMbti();
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
										final filename = data['filename'] as String? ?? 'MBTI.xlsx';
										final Uint8List bytes = encoding == 'base64'
											? base64Decode(filedata)
											: Uint8List.fromList(filedata.codeUnits);
										await tapah.saveExportedExcel(filename, bytes);
										_applyResponse(response);
									} catch (e) {
										_applyError(e);
									}
								},
								child: const Text('下载 MBTI.xlsx'),
							),
						],
					),
					const SizedBox(height: 20),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 50),
						child: Row(
							children: [
								Text(resultCode),
								const SizedBox(width: 20),
								Expanded(child: Text(resultStatus)),
							],
						),
					),
				],
			),
		);
	}
}
