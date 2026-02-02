import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class SectorWidget extends StatefulWidget {
	const SectorWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<SectorWidget> createState() => SectorState();
}

class SectorState extends State<SectorWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_sector, widget.key!);
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
				],
			),
		);
	}
}
