import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:mpflutter_wechat_webview/mpflutter_wechat_webview.dart';

class MarkdownBubbleText extends StatelessWidget {
	const MarkdownBubbleText({
		super.key,
		required this.detail,
		this.baseStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
	});

	final String detail;
	final TextStyle baseStyle;

	static const _linkColor = Color(0xFF3774FD);
	static const _codeBg = Color(0xFFF5F7FB);

	MarkdownStyleSheet _buildStyleSheet() {
		return MarkdownStyleSheet(
			p: baseStyle,
			h1: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
			h2: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
			h3: baseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
			h4: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
			h5: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
			h6: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
			strong: baseStyle.copyWith(fontWeight: FontWeight.w600),
			em: baseStyle.copyWith(fontStyle: FontStyle.italic),
			a: baseStyle.copyWith(color: _linkColor, decoration: TextDecoration.underline),
			code: baseStyle.copyWith(
				fontFamily: 'monospace',
				fontSize: 14,
				backgroundColor: _codeBg,
			),
			codeblockDecoration: BoxDecoration(
				color: _codeBg,
				borderRadius: BorderRadius.circular(6),
			),
			codeblockPadding: const EdgeInsets.all(10),
			blockquote: baseStyle.copyWith(color: const Color(0xFF666666)),
			blockquoteDecoration: BoxDecoration(
				border: Border(left: BorderSide(color: _linkColor.withOpacity(0.4), width: 3)),
			),
			blockquotePadding: const EdgeInsets.only(left: 12),
			listBullet: baseStyle,
			listIndent: 20,
			blockSpacing: 8,
			horizontalRuleDecoration: BoxDecoration(
				border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
			),
			tableHead: baseStyle.copyWith(fontWeight: FontWeight.w600),
			tableBody: baseStyle,
			tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
		);
	}

	@override
	Widget build(BuildContext context) {
		final normalized = detail.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
		return MarkdownBody(
			data: normalized,
			shrinkWrap: true,
			softLineBreak: true,
			styleSheet: _buildStyleSheet(),
			onTapLink: (text, href, title) {
				if (href != null && href.isNotEmpty) {
					MPFlutter_Wechat_WebView.open(href, onLoad: (_) {});
				}
			},
		);
	}
}
