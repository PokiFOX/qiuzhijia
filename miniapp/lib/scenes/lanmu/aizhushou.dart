import 'package:flutter/material.dart';

import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wxapi;

// import 'package:mpflutter_wechat_button/mpflutter_wechat_button.dart';

import 'package:qiuzhijia/tapah/class.dart' as tapah;
import 'package:qiuzhijia/tapah/data.dart' as tapah;
import 'package:qiuzhijia/tapah/enum.dart' as tapah;
import 'package:qiuzhijia/tapah/function.dart' as tapah;
import 'package:qiuzhijia/widgets/markdown_bubble.dart' as widgets;
import 'package:qiuzhijia/tapah/request.dart' as tapah;

class AIZhuShouWidget extends StatefulWidget {
	const AIZhuShouWidget({super.key,});

	@override
	State<AIZhuShouWidget> createState() => AIZhuShouState();
}

class AIZhuShouState extends State<AIZhuShouWidget> with tapah.Callback {
	static const _agents = {
		"resume": "简历助手",
		"joblevel": "岗位分析",
	};
	List<String> questions = [
		"我是27届学生，目前还没有明确求职方向，适合先做求职规划吗？",
		"我的简历比较空，没有相关实习经历，还可以做简历精修吗？",
		"全程辅导具体包括哪些服务？适合什么时候开始准备？",
		"全程辅导具体包括哪些服务？适合什么时候开始准备？",
	];
	List<tapah.ChatItem> chatlist = [];
	final TextEditingController messageController = TextEditingController();
	final ScrollController _scrollController = ScrollController();
	bool _sending = false;
	bool _inCooldown = false;
	String _selectedAgent = "resume";

	bool get _canSend => !_sending && !_inCooldown;

	@override
	void initState() {
		super.initState();
		initCallback(tapah.SceneID.lm_aizhushou, widget.key!);
		_initChat();
	}

	Future<void> _initChat() async {
		if (tapah.accountinfo == null) return;
		try {
			final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
			if (tapah.chataiToken == null || (tapah.chataiTokenExpiresAt != null && now >= tapah.chataiTokenExpiresAt!)) {
				await tapah.RequestChatAIAuth();
			}
			final history = await tapah.RequestAIChatHistory(agent: _selectedAgent);
			if (!mounted) return;
			setState(() {
				chatlist = history;
			});
			_scrollToBottom();
		} catch (e) {
			if (!mounted) return;
			print('init chat failed: $e');
		}
	}

	void _scrollToBottom() {
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!mounted || !_scrollController.hasClients) return;
			_scrollController.animateTo(
				_scrollController.position.maxScrollExtent,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeOut,
			);
		});
	}

	Future<void> sendMessage([String? text]) async {
		final content = (text ?? messageController.text).trim();
		if (content.isEmpty || !_canSend) return;
		if (tapah.accountinfo == null) {
			var toastOption = wxapi.ShowToastOption();
			toastOption.title = '请先登录';
			wxapi.wx.showToast(toastOption);
			return;
		}
		final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
		setState(() {
			_sending = true;
			chatlist.add(tapah.ChatItem(isuser: true, detail: content, timestamp: ts));
			if (text == null) messageController.clear();
		});
		_scrollToBottom();
		try {
			if (tapah.chataiToken == null || tapah.chataiToken!.isEmpty) {
				await tapah.RequestChatAIAuth();
			}
			final reply = await tapah.RequestChatAIChat(content, agent: _selectedAgent);
			if (!mounted) return;
			setState(() {
				chatlist.add(tapah.ChatItem(isuser: false, detail: reply, timestamp: ts));
				_sending = false;
				_inCooldown = true;
			});
			_scrollToBottom();
			Future.delayed(const Duration(seconds: 10), () {
				if (!mounted) return;
				setState(() {
					_inCooldown = false;
				});
			});
		} catch (e) {
			if (!mounted) return;
			setState(() {
				_sending = false;
			});
			print('send message failed: $e');
			var toastOption = wxapi.ShowToastOption();
			toastOption.title = '发送失败';
			wxapi.wx.showToast(toastOption);
		}
	}

	Future<void> _onAgentChanged(String? agent) async {
		if (agent == null || agent == _selectedAgent || !_canSend) return;
		setState(() {
			_selectedAgent = agent;
			chatlist = [];
		});
		if (tapah.accountinfo == null) return;
		try {
			final history = await tapah.RequestAIChatHistory(agent: agent);
			if (!mounted) return;
			setState(() {
				chatlist = history;
			});
			_scrollToBottom();
		} catch (e) {
			if (!mounted) return;
			print('load agent history failed: $e');
		}
	}

	Widget buildAgentDropdown() {
		final textStyle = TextStyle(fontSize: 12, color: Color(0xFF3D3D3D));
		return Container(
			height: 40,
			padding: const EdgeInsets.symmetric(horizontal: 6),
			decoration: BoxDecoration(
				color: Color(0xFFF5F7FB),
				borderRadius: BorderRadius.circular(18),
				border: Border.all(color: Color(0xFFEDF0F4)),
			),
			child: DropdownButtonHideUnderline(
				child: DropdownButton<String>(
					value: _selectedAgent,
					isExpanded: true,
					icon: Icon(Icons.arrow_drop_down, size: 18, color: _canSend ? Color(0xFF3774FD) : Color(0xFFAAC4FE)),
					selectedItemBuilder: (context) {
						return _agents.entries.map((e) {
							final label = e.value.length > 4 ? e.value.substring(0, 4) : e.value;
							return Align(
								alignment: Alignment.centerLeft,
								child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
							);
						}).toList();
					},
					items: _agents.entries.map((e) {
						return DropdownMenuItem<String>(
							value: e.key,
							child: Text(e.value, style: textStyle),
						);
					}).toList(),
					onChanged: _canSend ? _onAgentChanged : null,
				),
			),
		);
	}

	@override
	void dispose() {
		_scrollController.dispose();
		uninitCallback();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return tapah.buildMain1(context, [
			Center(child: const Text('求职家智能咨询', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),),
			Center(child: const Text('智能客服在线，帮你快速了解服务内容', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF979797))),),
			const SizedBox(height: 24),
			Center(child: Image.network(tapah.parseimage('栏目/AI助手/机器人头像.png'),),),
			const SizedBox(height: 24),
			Center(child: const Text('你好，我是求职家智能ai助手👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1D2129))),),
			const SizedBox(height: 24),
			Center(child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 50),
				child:  const Text('我可以帮你解答课程服务、简历精修、模拟面试、秋招计划、岗位内推等内容。也可以为你提供求职建议。', style: TextStyle(fontSize: 16, color: Color(0xFF979797))),),
			),
			const SizedBox(height: 24),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 30),
				child: Container(
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(12),
					),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							const SizedBox(height: 10),
							Row(
								children: [
									const SizedBox(width: 10),
									Image.network(tapah.parseimage('栏目/AI助手/灯泡.png'),),
									const SizedBox(width: 10),
									const Text('猜你想问', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1D2129))),
								],
							),
							const SizedBox(height: 10),
							...questions.map((q) {
								return Padding(
									padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
									child: GestureDetector(
										onTap: _canSend ? () => sendMessage(q) : null,
										child: Opacity(
											opacity: _canSend ? 1 : 0.5,
											child: Container(
												width: double.infinity,
												decoration: BoxDecoration(
													color: Color(0xFFECF3FD),
													border: Border.all(color: Color(0xFFD1DFFD)),
													borderRadius: BorderRadius.circular(10),
												),
												child: Padding(
													padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
													child: Text(q, style: TextStyle(fontSize: 16, color: Color(0xFF3774FD)), softWrap: true),
												),
											),
										),
									),
								);
							},).toList(),
							const SizedBox(height: 10),
						],
					),
				),
			),
			buildChatList(),
			if (_sending) Padding(
				padding: const EdgeInsets.symmetric(horizontal: 30),
				child: Align(
					alignment: Alignment.centerLeft,
					child: Padding(
						padding: const EdgeInsets.only(bottom: 10),
						child: Text('正在输入...', style: TextStyle(fontSize: 14, color: Color(0xFFC9CDD4))),
					),
				),
			),
			const SizedBox(height: 24),
			Container(
				decoration: BoxDecoration(
					color: Color(0xFFF8F9FC),
					border: Border.all(color: Color(0xFFEDF0F4)),
				),
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 10),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text('没解决问题？联系人工顾问为你提供更专业的解答', style: TextStyle(fontSize: 13, color: Color(0xFF3D3D3D))),
							const SizedBox(width: 10),
							GestureDetector(
								onTap: () => tapah.KeFu(context),
								child: Container(
									padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
									decoration: BoxDecoration(
										color:  Colors.white,
										borderRadius: BorderRadius.circular(15),
										border: Border.all(color: Color(0xFF2D7BFF)),
									),
									child: Text('转人工', style: TextStyle(fontSize: 14, color: Color(0xFF2D7BFF))),
								),
							),
						],
					),
				),
			),
			const SizedBox(height: 10),
			Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					const SizedBox(width: 20),
					SizedBox(
						width: 72,
						child: buildAgentDropdown(),
					),
					const SizedBox(width: 8),
					Expanded(
						child: TextField(
							controller: messageController,
							enabled: _canSend,
							decoration: InputDecoration(
								fillColor: Color(0xFFF5F7FB),
								hintText: '请输入你想咨询的问题',
								hintStyle: TextStyle(fontSize: 14, color: Color(0xFF3D3D3D)),
								border: OutlineInputBorder(
									borderSide: BorderSide(color: Color(0xFFEDF0F4)),
									borderRadius: BorderRadius.circular(18),
								),
								enabledBorder: OutlineInputBorder(
									borderSide: BorderSide(color: Color(0xFFEDF0F4)),
									borderRadius: BorderRadius.circular(18),
								),
								focusedBorder: OutlineInputBorder(
									borderSide: BorderSide(color: Color(0xFF3774FD)),
									borderRadius: BorderRadius.circular(18),
								),
							),
						),
					),
					const SizedBox(width: 20),
					GestureDetector(
						onTap: _canSend ? sendMessage : null,
						child: Container(
							height: 40,
							padding: const EdgeInsets.symmetric(horizontal: 15),
							decoration: BoxDecoration(
								color: _canSend ? Color(0xFF3774FD) : Color(0xFFAAC4FE),
								borderRadius: BorderRadius.circular(18),
							),
							child: Center(child: Text('发送', style: TextStyle(fontSize: 14, color: Colors.white))),
						),
					),
					const SizedBox(width: 20),
				],
			),
		], scrollController: _scrollController);
	}

	Widget buildChatList() {
		if (chatlist.isEmpty) return const SizedBox.shrink();
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 30),
			child: Column(
				children: [
					const SizedBox(height: 24),
					...chatlist.asMap().entries.expand((entry) {
						final widgets = <Widget>[];
						if (entry.key == 0 || chatlist[entry.key].timestamp - chatlist[entry.key - 1].timestamp > 300) {
							final dt = DateTime.fromMillisecondsSinceEpoch(entry.value.timestamp * 1000);
							final now = DateTime.now();
							final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
							String timestr = '';
							if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
								timestr = time;
							} else {
								timestr = '${dt.month}月${dt.day}日 $time';
							}
							widgets.add(Center(
								child: Padding(
									padding: const EdgeInsets.symmetric(vertical: 12),
									child: Text(
										timestr,
										style: TextStyle(
											fontSize: 14,
											fontWeight: FontWeight.w400,
											color: Color(0xFFC9CDD4),
										),
									),
								),
							));
						}
						widgets.add(buildMessageBubble(entry.value));
						return widgets;
					}),
					const SizedBox(height: 24),
				],
			),
		);
	}

	Widget buildChatAvatar(bool isUser) {
		const size = 36.0;
		if (isUser) {
			if (tapah.accountinfo != null && tapah.accountinfo!.avatar.isNotEmpty) {
				return ClipRRect(
					borderRadius: BorderRadius.circular(size / 2),
					child: Image.network(tapah.accountinfo!.avatar, width: size, height: size, fit: BoxFit.cover),
				);
			}
			return Icon(Icons.account_circle, size: size, color: Colors.grey[400]);
		}
		return ClipRRect(
			borderRadius: BorderRadius.circular(size / 2),
			child: Image.network(tapah.parseimage('栏目/AI助手/机器人头像.png'), width: size, height: size, fit: BoxFit.cover),
		);
	}

	Widget buildBubbleText(String detail, TextStyle style) {
		final normalized = detail.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
		final lines = normalized.split('\n');
		if (lines.length == 1) {
			return Text(lines[0], style: style, softWrap: true);
		}
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			mainAxisSize: MainAxisSize.min,
			children: [
				for (var i = 0; i < lines.length; i++)
					Padding(
						padding: EdgeInsets.only(top: i > 0 ? 4 : 0),
						child: Text(lines[i].isEmpty ? ' ' : lines[i], style: style, softWrap: true),
					),
			],
		);
	}

	Widget buildMessageBubble(tapah.ChatItem item) {
		const avatarGap = 8.0;
		final isUser = item.isuser;
		final textStyle = TextStyle(
			fontSize: 16,
			fontWeight: FontWeight.w400,
			color: isUser ? Colors.white : Colors.black,
		);
		final bubble = Container(
			width: double.infinity,
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
			decoration: BoxDecoration(
				color: isUser ? const Color(0xFF3774FD) : Colors.white,
				borderRadius: BorderRadius.circular(12),
			),
			child: isUser
				? buildBubbleText(item.detail, textStyle)
				: widgets.MarkdownBubbleText(detail: item.detail, baseStyle: textStyle),
		);
		return Padding(
			padding: const EdgeInsets.only(bottom: 10),
			child: Column(
				crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
				children: [
					buildChatAvatar(isUser),
					SizedBox(height: avatarGap),
					bubble,
				],
			),
		);
	}
}

