import 'package:flutter/material.dart';

import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart';

import 'package:device_preview/device_preview.dart';

import 'package:qiuzhijia/app.dart';
import 'package:qiuzhijia/tapah/reserved.dart' as tapah;

void main() {
	runApp(DevicePreview(
		enabled: true,
		defaultDevice: tapah.deviceinfo,
		builder: (context) => const MainApp(),
	),);

	if (kIsMPFlutter) {
		try {
			wx.$$context$$;
		}
		catch (e) {
		}
	}
	MainAppDelegate();
}
