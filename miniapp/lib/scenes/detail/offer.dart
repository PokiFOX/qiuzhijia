import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class OfferWidget extends StatefulWidget {
	const OfferWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<OfferWidget> createState() => OfferState();
}

class OfferState extends State<OfferWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_offer, widget.key!);
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
				child: Text("招聘资讯"),
			),
		);
	}
}
