import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class InfoWidget extends StatefulWidget {
	const InfoWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<InfoWidget> createState() => InfoState();
}

class InfoState extends State<InfoWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_info, widget.key!);
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Container(
				child: Text("深度解读"),
			),
		);
	}
}
