import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class ServiceWidget extends StatefulWidget {
	const ServiceWidget({super.key});

	@override
	State<ServiceWidget> createState() => ServiceState();
}

class ServiceState extends State<ServiceWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_service, widget.key!);
	}

	@override
	void deactivate() {
		uninitCallback();
		super.deactivate();
	}

	@override
	Widget build(BuildContext context) {
		return Container(
		);
	}
}
