import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/tapah/option.dart' as tapah;

class DetailWidget extends StatefulWidget {
	const DetailWidget({super.key});

	@override
	State<DetailWidget> createState() => DetailState();
}

class DetailState extends State<DetailWidget> with tapah.Callback {
	late tapah.Enterprise enterprise;
	int fenyeindex = 0;
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.detail, widget.key!);
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		final args = ModalRoute.of(context)?.settings.arguments;
		if (args != null && args is tapah.Enterprise) {
			enterprise = args;
		}
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: SingleChildScrollView(
					scrollDirection: Axis.vertical,
					child: Container(
						child: Column(
							children: [
								buildTopImage(),
								const SizedBox(height: 10),
								buildInfoSection(),
							],
						),
					),
				),
			),
		);
	}

	Widget buildTopImage() {
		return Stack(
			children: [
				ConstrainedBox(
					constraints: BoxConstraints(maxHeight: 200),
					child: Image.network(tapah.parseimage('儿童底图.png',), fit: BoxFit.contain,),
				),
				Column(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(height: 20),
						Row(
							mainAxisAlignment: MainAxisAlignment.start,
							children: [
								const SizedBox(width: 10),
								IconButton(
									icon: const Icon(Icons.arrow_back, color: Colors.white,),
									onPressed: () {
										Navigator.pop(context);
									},
								),
							],
						),
					],
				),
			],
		);
	}

	Widget buildInfoSection() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.start,
			children: [
				const SizedBox(width: 10),
				Expanded(
					child: GestureDetector(
						onTap: () => setState(() => fenyeindex = 0),
						child: Container(
							height: 40,
							decoration: BoxDecoration(
								color: fenyeindex == 0 ? Colors.grey[400] : Colors.transparent,
								borderRadius: BorderRadius.circular(0),
							),
							child: Center(
								child: Text(tapah.entfenyes[0], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: fenyeindex == 0 ? FontWeight.bold : FontWeight.normal,),),
							),
						),
					),
				),
				const SizedBox(width: 10),
				Expanded(
					child: GestureDetector(
						onTap: () => setState(() => fenyeindex = 1),
						child: Container(
							height: 40,
							decoration: BoxDecoration(
								color: fenyeindex == 1 ? Colors.grey[400] : Colors.transparent,
								borderRadius: BorderRadius.circular(0),
							),
							child: Center(
								child: Text(tapah.entfenyes[1], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: fenyeindex == 1 ? FontWeight.bold : FontWeight.normal,),),
							),
						),
					),
				),
				const SizedBox(width: 10),
				Expanded(
					child: GestureDetector(
						onTap: () => setState(() => fenyeindex = 2),
						child: Container(
							height: 40,
							decoration: BoxDecoration(
								color: fenyeindex == 2 ? Colors.grey[400] : Colors.transparent,
								borderRadius: BorderRadius.circular(0),
							),
							child: Center(
								child: Text(tapah.entfenyes[2], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: fenyeindex == 2 ? FontWeight.bold : FontWeight.normal,),),
							),
						),
					),
				),
				const SizedBox(width: 10),
				Expanded(
					child: GestureDetector(
						onTap: () => setState(() => fenyeindex = 3),
						child: Container(
							height: 40,
							decoration: BoxDecoration(
								color: fenyeindex == 3 ? Colors.grey[400] : Colors.transparent,
								borderRadius: BorderRadius.circular(0),
							),
							child: Center(
								child: Text(tapah.entfenyes[3], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: fenyeindex == 3 ? FontWeight.bold : FontWeight.normal,),),
							),
						),
					),
				),
				const SizedBox(width: 10),
				Expanded(
					child: GestureDetector(
						onTap: () => setState(() => fenyeindex = 4),
						child: Container(
							height: 40,
							decoration: BoxDecoration(
								color: fenyeindex == 4 ? Colors.grey[400] : Colors.transparent,
								borderRadius: BorderRadius.circular(0),
							),
							child: Center(
								child: Text(tapah.entfenyes[4], style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: fenyeindex == 4 ? FontWeight.bold : FontWeight.normal,),),
							),
						),
					),
				),
				const SizedBox(width: 10),
			],
		);
	}
}
