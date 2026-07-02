import 'package:flutter/material.dart';

import 'package:frontend/tapah/option.dart' as tapah;

class MainPageWidget extends StatefulWidget {
	const MainPageWidget({super.key});

	@override
	State<MainPageWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPageWidget> {
	bool _authenticated = false;
	bool _optionLoading = true;
	bool _optionLoadFailed = false;
	final TextEditingController _passwordController = TextEditingController();
	String? _errorText;

	@override
	void initState() {
		super.initState();
		_loadOption();
	}

	Future<void> _loadOption() async {
		try {
			await tapah.loadOption();
			if (!mounted) return;
			setState(() {
				_optionLoading = false;
				_optionLoadFailed = tapah.mainpagePassword == null;
			});
		} catch (_) {
			if (!mounted) return;
			setState(() {
				_optionLoading = false;
				_optionLoadFailed = true;
			});
		}
	}

	@override
	void dispose() {
		_passwordController.dispose();
		super.dispose();
	}

	void _submitPassword() {
		if (tapah.mainpagePassword == null) {
			setState(() {
				_errorText = '配置加载失败';
			});
			return;
		}
		if (_passwordController.text == tapah.mainpagePassword) {
			setState(() {
				_authenticated = true;
				_errorText = null;
			});
			return;
		}
		setState(() {
			_errorText = '密码错误';
		});
	}

	Widget _buildPasswordGate() {
		if (_optionLoading) {
			return const Center(child: CircularProgressIndicator());
		}
		return Center(
			child: SizedBox(
				width: 320,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Text(
							'求职家后台',
							style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 32),
						if (_optionLoadFailed)
							const Padding(
								padding: EdgeInsets.only(bottom: 16),
								child: Text(
									'配置加载失败',
									style: TextStyle(color: Colors.red),
								),
							),
						TextField(
							controller: _passwordController,
							obscureText: true,
							enabled: !_optionLoadFailed,
							decoration: InputDecoration(
								labelText: '密码',
								errorText: _errorText,
								border: const OutlineInputBorder(),
							),
							onSubmitted: (_) => _submitPassword(),
						),
						const SizedBox(height: 16),
						SizedBox(
							width: double.infinity,
							child: FilledButton(
								onPressed: _optionLoadFailed ? null : _submitPassword,
								child: const Text('进入'),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildMenu() {
		return Column(
			mainAxisAlignment: MainAxisAlignment.start,
			children: [
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/zone');
							},
							child: const Text("地区列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/level');
							},
							child: const Text("层级列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/sector');
							},
							child: const Text("大类列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/field');
							},
							child: const Text("学科列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/enterprise');
							},
							child: const Text("企业列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/question');
							},
							child: const Text("问题列表", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
				const SizedBox(height: 50,),
				Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						const SizedBox(width: 50,),
						GestureDetector(
							onTap: () {
								Navigator.of(context).pushNamed('/import');
							},
							child: const Text("导入数据", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
						),
					],
				),
			],
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: _authenticated ? _buildMenu() : _buildPasswordGate(),
		);
	}
}
