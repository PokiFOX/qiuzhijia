import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class MarqueeTagsWidget extends StatefulWidget {
	final List<Widget> tags;
	const MarqueeTagsWidget({required this.tags});
	@override
	State<MarqueeTagsWidget> createState() => MarqueeTagsState();
}

class MarqueeTagsState extends State<MarqueeTagsWidget> with SingleTickerProviderStateMixin {
	late final Ticker _ticker;
	final _measureKey = GlobalKey();
	double _offset = 0;
	double _singleWidth = 0;
	double _viewportWidth = 0;
	bool _measured = false;
	bool _needsMarquee = false;
	Duration? _lastElapsed;
	static const double _speed = 50.0;

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
			if (_offset <= -_singleWidth) {
				_offset += _singleWidth;
			}
		});
	}

	@override
	void dispose() {
		_ticker.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(builder: (context, constraints) {
			_viewportWidth = constraints.maxWidth;
			return SizedBox(
				height: 15,
				child: ClipRect(
					child: Stack(
						children: [
							if (!_measured) Offstage(
								child: OverflowBox(
									maxWidth: double.infinity,
									alignment: Alignment.centerLeft,
									child: Row(key: _measureKey, children: widget.tags),
								),
							),
							if (_measured && !_needsMarquee) Row(children: widget.tags),
							if (_measured && _needsMarquee) ...[
								Positioned(left: _offset, top: 0, child: Row(children: widget.tags)),
								Positioned(left: _offset + _singleWidth, top: 0, child: Row(children: widget.tags)),
							],
						],
					),
				),
			);
		});
	}
}
