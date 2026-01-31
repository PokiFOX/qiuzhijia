import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart';

import 'package:qiuzhijia/app.dart';

void main() {
	runMPApp(const MainApp());

	if (kIsMPFlutter) {
		try {
			wx.$$context$$;
		}
		catch (e) {
		}
	}
	MainAppDelegate();
}
