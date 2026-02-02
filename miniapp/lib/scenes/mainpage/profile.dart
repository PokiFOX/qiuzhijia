import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;

class ProfileWidget extends StatefulWidget {
	const ProfileWidget({super.key});

	@override
	State<ProfileWidget> createState() => ProfileState();
}

class ProfileState extends State<ProfileWidget> with tapah.Callback {
	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.mp_profile, widget.key!);
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
