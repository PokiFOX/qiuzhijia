import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class ExampleWidget extends StatefulWidget {
	const ExampleWidget({super.key, required this.enterprise});
	final tapah.Enterprise enterprise;

	@override
	State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.dt_example, widget.key!);
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
				child: Text("成功案例"),
			),
		);
	}
}
