import 'dart:convert';

import 'package:flutter/services.dart';

const _optionAssetPath = 'assets/option.json';

String? mainpagePassword;

Future<void> loadOption() async {
	final raw = await rootBundle.loadString(_optionAssetPath);
	final json = jsonDecode(raw) as Map<String, dynamic>;
	mainpagePassword = json['password'] as String?;
}
