import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
	const ExpandableText(
		this.text, {
		super.key,
		this.style,
		this.maxLines = 3,
		this.expandText = '展开',
		this.collapseText = '收起',
		this.linkColor = Colors.blue,
	});

	final String text;
	final TextStyle? style;
	final int maxLines;
	final String expandText;
	final String collapseText;
	final Color linkColor;

	@override
	State<ExpandableText> createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
	bool _expanded = false;
	bool _hasOverflow = false;

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(
			builder: (context, constraints) {
				final textSpan = TextSpan(text: widget.text, style: widget.style);
				final textPainter = TextPainter(
					text: textSpan,
					maxLines: widget.maxLines,
					textDirection: TextDirection.ltr,
				)..layout(maxWidth: constraints.maxWidth);

				_hasOverflow = textPainter.didExceedMaxLines;

				return Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							widget.text,
							style: widget.style,
							maxLines: _expanded ? null : widget.maxLines,
							overflow: _expanded ? null : TextOverflow.ellipsis,
						),
						if (_hasOverflow)
							GestureDetector(
								onTap: () => setState(() => _expanded = !_expanded),
								child: Padding(
									padding: const EdgeInsets.only(top: 4),
									child: Text(
										_expanded ? widget.collapseText : widget.expandText,
										style: TextStyle(color: widget.linkColor, fontSize: widget.style?.fontSize),
									),
								),
							),
					],
				);
			},
		);
	}
}
