import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;

class KeFuWidget extends StatefulWidget {
	const KeFuWidget({super.key,});

	@override
	State<KeFuWidget> createState() => KeFuState();
}

class KeFuState extends State<KeFuWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.kefu, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			child: Column(
				children: [
					tapah.buildWechatNavBar(context, title: '添加顾问', showBack: true),
					const SizedBox(height: 10,),
					Expanded(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: SingleChildScrollView(
								scrollDirection: Axis.vertical,
								child: Column(
									mainAxisAlignment: MainAxisAlignment.start,
									children: [
										const SizedBox(height: 20,),
										Container(
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(20),
											),
											child: Column(
												children: [
													const SizedBox(height: 20,),
													Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															const SizedBox(width: 20,),
															Image.network(tapah.parseimage('客服/头像.png'),),
															const SizedBox(width: 20,),
															Column(
																mainAxisAlignment: MainAxisAlignment.center,
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	Row(
																		children: [
																			Text('求职家顾问老师', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: new Color(0xFF3D3D3D),),),
																			const SizedBox(width: 8,),
																			Image.network(tapah.parseimage('客服/角标.png')),
																		],
																	),
																	const SizedBox(height: 2,),
																	Text("1V1求职咨询顾问", style: TextStyle(fontSize: 14, color: new Color(0xFF3D3D3D),),),
																	const SizedBox(height: 10,),
																	Row(
																		children: [
																			Image.network(tapah.parseimage('客服/图标.png'),),
																			const SizedBox(width: 4,),
																			Text("专注求职辅导·帮你拿到心仪Offer+同学", style: TextStyle(fontSize: 10, color: new Color(0xFF2D7BFF),),),
																		],
																	),
																],
															),
														],
													),
													const SizedBox(height: 40,),
													GestureDetector(
														onTap: () {
															var option = wxapi.PreviewImageOption();
															option.urls = [tapah.parseimage('客服/二维码.png')];
															wxapi.wx.previewImage(option);
														},
														child: Image.network(tapah.parseimage('客服/二维码.png'),),
													),
													const SizedBox(height: 20,),
													Text('长按识别二维码，添加顾问老师', style: TextStyle(fontSize: 16, color: new Color(0xFF3D3D3D),),),
													const SizedBox(height: 10,),
													Text('获取岗位信息、投递建议与专属资料', style: TextStyle(fontSize: 13, color: new Color(0xFF3D3D3D),),),
													const SizedBox(height: 10,),
													Image.network(tapah.parseimage('客服/底部.png'),),
												],
											),
										),
										const SizedBox(height: 20,),
										Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												GestureDetector(
													behavior: HitTestBehavior.opaque,
													onTap: () {
														var option = wxapi.DownloadFileOption();
														option.url = tapah.parseimage('客服/二维码.png');
														option.success = (res) {
															final tempFilePath = res.$$context$$['tempFilePath'];
															var saveOption = wxapi.SaveImageToPhotosAlbumOption();
															saveOption.filePath = tempFilePath;
															saveOption.success = (result) {
																var toastOption = wxapi.ShowToastOption();
																toastOption.title = "已保存到相册";
																wxapi.wx.showToast(toastOption);
															};
															saveOption.fail = (error) {
																print("保存失败: $error");
															};
															wxapi.wx.saveImageToPhotosAlbum(saveOption);
														};
														wxapi.wx.downloadFile(option);
													},
													child: Container(
														padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
														decoration: BoxDecoration(
															color: Colors.white,
															borderRadius: BorderRadius.circular(12),
														),
														child: Row(
															children: [
																Image.network(tapah.parseimage('客服/保存.png'),),
																const SizedBox(width: 10,),
																Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Text("保存二维码", style: TextStyle(fontSize: 16, color: new Color(0xFF3D3D3D), fontWeight: FontWeight.bold),),
																		const SizedBox(height: 2,),
																		Text("保存到相册，方便查看", style: TextStyle(fontSize: 11, color: new Color(0xFF3D3D3D),),),
																	],
																),
															],
														),
													),
												),
												const SizedBox(width: 20,),
												GestureDetector(
													behavior: HitTestBehavior.opaque,
													onTap: () {
														wxapi.wx.setClipboardData(wxapi.SetClipboardDataOption()..data = "FomaKK");
													},
													child: Container(
														padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
														decoration: BoxDecoration(
															color: Colors.white,
															borderRadius: BorderRadius.circular(12),
														),
														child: Row(
															children: [
																Image.network(tapah.parseimage('客服/复制.png'),),
																const SizedBox(width: 10,),
																Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Text("复制微信号", style: TextStyle(fontSize: 16, color: new Color(0xFF3D3D3D), fontWeight: FontWeight.bold),),
																		const SizedBox(height: 2,),
																		Text("复制后去微信添加", style: TextStyle(fontSize: 11, color: new Color(0xFF3D3D3D),),),
																	],
																),
															],
														),
													),
												),
											],
										),
										const SizedBox(height: 20,),
									],
								),
							),
						),
					),
				],
			),
		);
	}
}

