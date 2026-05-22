import 'package:flutter/material.dart';

class AnimatedNewsTicker extends StatefulWidget {
  final List<String> headlines;
  final Duration scrollDuration;
  final double fontSize;

  const AnimatedNewsTicker({
    super.key,
    required this.headlines,
    this.scrollDuration = const Duration(seconds: 30),
    this.fontSize = 13.0,
  });

  @override
  State<AnimatedNewsTicker> createState() => _AnimatedNewsTickerState();
}

class _AnimatedNewsTickerState extends State<AnimatedNewsTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scrollAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    );

    _scrollAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headlines.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.primaryContainer;
    final textColor = theme.colorScheme.onPrimaryContainer;

    // Join all headlines with a separator
    final tickerText = widget.headlines
        .map((h) => '  •  $h')
        .join('          '); // 10 spaces between headlines

    return Container(
      height: 36,
      color: bgColor,
      child: Row(
        children: [
          // "LIVE" badge on the left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: theme.colorScheme.primary,
            height: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'LIVE',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          // The scrolling ticker area
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _scrollAnim,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _TickerPainter(
                      text: tickerText,
                      progress: _scrollAnim.value,
                      textColor: textColor,
                      fontSize: widget.fontSize,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  final String text;
  final double progress;
  final Color textColor;
  final double fontSize;

  _TickerPainter({
    required this.text,
    required this.progress,
    required this.textColor,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final totalWidth = textPainter.width;
    final dx = size.width + totalWidth - (progress * (size.width + totalWidth));

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    textPainter.paint(
      canvas,
      Offset(dx - totalWidth, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_TickerPainter old) =>
      old.progress != progress || old.text != text;
}