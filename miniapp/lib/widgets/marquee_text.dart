import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class MarqueeTextWidget extends StatefulWidget {
	final String text;
	final TextStyle? style;
	final double height;
	const MarqueeTextWidget({required this.text, this.style, this.height = 24});
	@override
	State<MarqueeTextWidget> createState() => MarqueeTextState();
}

class MarqueeTextState extends State<MarqueeTextWidget> with SingleTickerProviderStateMixin {
	late final Ticker _ticker;
	final _measureKey = GlobalKey();
	double _offset = 0;
	double _singleWidth = 0;
	double _viewportWidth = 0;
	bool _measured = false;
	bool _needsMarquee = false;
	Duration? _lastElapsed;
	static const double _speed = 60.0;
	static const double _gap = 60.0;

	@override
	void initState() {
		super.initState();
		_ticker = createTicker(_onTick);
		WidgetsBinding.instance.addPostFrameCallback((_) => _afterFirstFrame());
	}

	void _afterFirstFrame() {
		if (!mounted) return;
		final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
		if (box == null) return;
		_singleWidth = box.size.width;
		_measured = true;
		if (_singleWidth > _viewportWidth && _viewportWidth > 0) {
			_needsMarquee = true;
			_offset = _viewportWidth;
			_ticker.start();
		}
		setState(() {});
	}

	void _onTick(Duration elapsed) {
		if (_lastElapsed == null) { _lastElapsed = elapsed; return; }
		final dt = (elapsed - _lastElapsed!).inMicroseconds / 1e6;
		_lastElapsed = elapsed;
		setState(() {
			_offset -= _speed * dt;
			if (_offset <= -(_singleWidth + _gap)) {
				_offset += _singleWidth + _gap;
			}
		});
	}

	@override
	void dispose() {
		_ticker.dispose();
		super.dispose();
	}

	Widget _buildText() => Text(widget.text, style: widget.style, maxLines: 1);

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(builder: (context, constraints) {
			_viewportWidth = constraints.maxWidth;
			return SizedBox(
				height: widget.height,
				child: ClipRect(
					child: Stack(
						children: [
							if (!_measured) Offstage(
								child: OverflowBox(
									maxWidth: double.infinity,
									alignment: Alignment.centerLeft,
									child: Row(key: _measureKey, children: [_buildText()]),
								),
							),
							if (_measured && !_needsMarquee) Align(alignment: Alignment.centerLeft, child: _buildText()),
							if (_measured && _needsMarquee) ...[
								Positioned(left: _offset, top: 0, bottom: 0, child: _buildText()),
							Positioned(left: _offset + _singleWidth + _gap, top: 0, bottom: 0, child: _buildText()),
							],
						],
					),
				),
			);
		});
	}
}
