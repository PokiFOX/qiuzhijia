import 'package:flutter/material.dart';

class CopyWidget extends StatefulWidget {
	const CopyWidget(
		this.url, {
		super.key,
		this.onLater,
		this.onConsult,
	});

	final String url;
	final VoidCallback? onLater;
	final VoidCallback? onConsult;

	@override
	State<CopyWidget> createState() => CopyState();
}

class CopyState extends State<CopyWidget> {
	@override
	Widget build(BuildContext context) {
		return Center(
			child: Material(
				color: Colors.transparent,
				child: Container(
					width: 280,
					height: 373,
					padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
					decoration: BoxDecoration(
						color: const Color(0xFFF3F3F3),
						borderRadius: BorderRadius.circular(32),
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Container(
								width: 68,
								height: 68,
								decoration: const BoxDecoration(
									shape: BoxShape.circle,
									color: Color(0xFFD5E5D8),
								),
								child: const Icon(
									Icons.check,
									size: 68,
									color: Color(0xFF34BE7B),
								),
							),
							const SizedBox(height: 14),
							const Text(
								'链接已复制',
								style: TextStyle(
									fontSize: 22,
									fontWeight: FontWeight.bold,
									color: Color(0xFF3D3D3D),
								),
							),
							Container(
								width: double.infinity,
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
								child: const Text(
									'立即咨询顾问老师，获取岗位信息，投递建议和专属资料吧！',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 14,
										color: Color(0xFF3D3D3D),
									),
								),
							),
							Image.asset(
								'assets/images/copy.png',
								fit: BoxFit.contain,
								height: 72,
							),
							const SizedBox(height: 20),
							Row(
								children: [
									Expanded(
										child: _buildButton(
											label: '稍后查看',
											backgroundColor: const Color(0xFFF0F0F0),
											textColor: const Color(0xFF333333),
											onTap: () {
												if (widget.onLater != null) {
													widget.onLater!.call();
												} else {
													Navigator.of(context).maybePop();
												}
											},
										),
									),
									const SizedBox(width: 16),
									Expanded(
										child: _buildButton(
											label: '立即咨询',
											backgroundColor: const Color(0xFF2F74F7),
											textColor: Colors.white,
											onTap: () {
												if (widget.onConsult != null) {
													widget.onConsult!.call();
												}
											},
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}

	Widget _buildButton({
		required String label,
		required Color backgroundColor,
		required Color textColor,
		required VoidCallback onTap,
	}) {
		return SizedBox(
			height: 40,
			child: DecoratedBox(
				decoration: BoxDecoration(
					color: backgroundColor,
					borderRadius: BorderRadius.circular(18),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.12),
							blurRadius: 6,
							offset: const Offset(0, 2),
						),
					],
				),
				child: TextButton(
					onPressed: onTap,
					style: TextButton.styleFrom(
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
					),
					child: Text(
						label,
						style: TextStyle(
							fontSize: 16,
							color: textColor,
						),
					),
				),
			),
		);
	}
}
