import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';
import 'package:mpflutter_wechat_editable/mpflutter_wechat_editable.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class ProfileWidget extends StatefulWidget {
	const ProfileWidget({super.key});

	@override
	State<ProfileWidget> createState() => ProfileState();
}

class ProfileState extends State<ProfileWidget> with tapah.Callback {
	final TextEditingController nicknamecontroller = TextEditingController();

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_profile, widget.key!);
	}

	@override
	void dispose() {
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		Widget icon = Icon(Icons.account_circle, size: 80, color: Colors.grey[400],);
		if (tapah.accountinfo != null && tapah.accountinfo!.avatar.isNotEmpty) {
			icon = Image.network(tapah.accountinfo!.avatar, width: 80, height: 80, fit: BoxFit.cover,);
		}

		Widget nickname = Text("未登录", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500));
		Widget id = Text("");
		if (tapah.accountinfo != null) {
			id = Text("ID: ${tapah.accountinfo!.id}", style: TextStyle(fontSize: 13, color: Colors.grey));
			nicknamecontroller.text = tapah.accountinfo!.nickname;
			nickname = SizedBox(
				width: 100,
				height: 30,
				child: MPFlutterTextField(
					controller: nicknamecontroller,
					keyboardType: TextInputType.name,
					showConfirmBar: true,
					onChanged: (text) {
						tapah.accountinfo ??= tapah.AccountInfo();
						if (text.isEmpty) {
							text = "微信名称";
						}
						tapah.accountinfo!.nickname = text;
						nicknamecontroller.text = text;
						tapah.RequestUserInfo();
					},
				),
			);
		}

		Widget login = Container(
			height: 100,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: Colors.white,
			),
			child: Row(
				children: [
					const SizedBox(width: 10,),
					MPFlutter_Wechat_Button(
						openType: "chooseAvatar",
						onChooseAvatar: (result) {
							if (!mounted) return;
							setState(() {
								tapah.accountinfo ??= tapah.AccountInfo();
								tapah.accountinfo!.avatar = result["avatarUrl"];
								tapah.RequestUserInfo();
							});
						},
						child: icon,
					),
					const SizedBox(width: 10,),
					Column(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							nickname,
							const SizedBox(height: 10,),
							id,
						],
					),
					Expanded(child: Container(),),
					Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400],),
					const SizedBox(width: 10,),
				],
			),
		);
		Widget loginbutton = MPFlutter_Wechat_Button(
			openType: "getPhoneNumber",
			onGetPhoneNumber: (result) async {
				await tapah.RequestWxCode(result["code"]);
				if (!mounted) return;
				setState(() {});
			},
			child: login,
		);

		return tapah.buildMain1(context, [
			Center(child: const Text('个人中心', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),),
			const SizedBox(height: 10,),
			Row(
				children: [
					const SizedBox(width: 20,),
					Expanded(
						child: tapah.accountinfo == null ? loginbutton : login,
					),
					const SizedBox(width: 20,),
				],
			),
			const SizedBox(height: 20,),
			Row(
				children: [
					const SizedBox(width: 20,),
					Expanded(
						child: Container(
							height: 100,
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(10),
								color: Colors.white,
							),
							child: Row(
								children: [
									const SizedBox(width: 20,),
									Image.network(tapah.parseimage('客服/关注.png'),),
									const SizedBox(width: 25,),
									GestureDetector(
										behavior: HitTestBehavior.translucent,
										onTap: () {
											if (tapah.accountinfo == null) {
												return;
											}
											tapah.navigator(context, '/mainpage/favorite');
										},
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											crossAxisAlignment: CrossAxisAlignment.start,
											children: const [
												Text('我的关注', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
												const SizedBox(height: 10,),
												Text('查看已关注的公司与专业方向', style: TextStyle(fontSize: 13, color: Colors.grey)),
											],
										),
									),
									Expanded(child: Container(),),
									Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400],),
									const SizedBox(width: 10,),
								],
							),
						),
					),
					const SizedBox(width: 20,),
				],
			),
			const SizedBox(height: 20,),
			Row(
				children: [
					const SizedBox(width: 20,),
					Expanded(
						child: Container(
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(10),
								color: Colors.white,
							),
							child: Column(
								children: [
									const SizedBox(height: 10,),
									//Row(
									//	children: [
									//		const SizedBox(width: 20),
									//		Image.network(tapah.parseimage('客服/浏览记录.png',),),
									//		const SizedBox(width: 10,),
									//		const Text('浏览记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
									//		Expanded(child: Container(),),
									//		Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400],),
									//		const SizedBox(width: 10,),
									//	],
									//),
									//Divider(color: Colors.grey[300], thickness: 1, indent: 20, endIndent: 20,),
									//Row(
									//	children: [
									//		const SizedBox(width: 20),
									//		Image.network(tapah.parseimage('客服/求职资料.png',),),
									//		const SizedBox(width: 10,),
									//		const Text('求职资料', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
									//		Expanded(child: Container(),),
									//		Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400],),
									//		const SizedBox(width: 10,),
									//	],
									//),
									//Divider(color: Colors.grey[300], thickness: 1, indent: 20, endIndent: 20,),
									GestureDetector(
										behavior: HitTestBehavior.translucent,
										onTap: () {
											tapah.KeFu(context);
										},
										child: Row(
											children: [
												const SizedBox(width: 20),
												Image.network(tapah.parseimage('客服/联系客服.png',),),
												const SizedBox(width: 10,),
												const Text('联系客服', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
												Expanded(child: Container(),),
												Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400],),
												const SizedBox(width: 10,),
											],
										),
									),
									const SizedBox(height: 10,),
								],
							),
						),
					),
					const SizedBox(width: 20,),
				],
			),
			const SizedBox(height: 20,),
			Visibility(
				visible: tapah.accountinfo != null,
				child: GestureDetector(
					onTap: () {
						setState(() {
							tapah.accountinfo = null;
						});
					},
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Image.network(tapah.parseimage('客服/退出登录.png',),),
							const SizedBox(width: 10,),
							const Text('退出登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
						],
					),
				),
			),
			const SizedBox(height: 20,),
		]);
	}
}
