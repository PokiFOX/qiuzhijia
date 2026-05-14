import 'package:flutter/material.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

import 'package:qiuzhijia/tapah/reserved.dart';
import 'package:qiuzhijia/scenes/kefu.dart';

String parseimage(String name) {
	return '$urlheader/images/$name';
}

String parseurl(String url) {
	return 'http://$backendHost:$backendPort/$url';
}

void KeFu(BuildContext context) {
	Navigator.push(context, MaterialPageRoute(builder: (context) => KeFuWidget(key: GlobalKey(),)));
	//var option = wxapi.OpenCustomerServiceChatOption();
	//option.corpId = "ww9c9c584173a105cc";
	//var extInfo = wxapi.ExtInfoOption();
	//extInfo.url = 'https://work.weixin.qq.com/kfid/kfcb5ad5f141ba2d45d';
	//option.extInfo = extInfo;
	//option.success = (result) {
	//	print("打开在线咨询成功:" + result.toString());
	//};
	//option.fail = (error) {
	//	try {
	//		final errMsg = error.$$context$$['errMsg'];
	//		print("打开在线咨询失败详情: $errMsg");
	//	} catch (e) {
	//		print("解析错误对象失败: $error");
	//	}
	//};
	//wxapi.wx.openCustomerServiceChat(option);
}