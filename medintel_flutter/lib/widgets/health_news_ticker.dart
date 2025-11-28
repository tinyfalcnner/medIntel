import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/llm_service.dart';
import '../models/headline.dart';

class HealthNewsTicker extends StatefulWidget {
  final double height;
  final String? userId;

  const HealthNewsTicker({
    super.key,
    this.height = 48.0,
    this.userId,
  });

  @override
  State<HealthNewsTicker> createState() => _HealthNewsTickerState();
}

class _HealthNewsTickerState extends State<HealthNewsTicker>
    with SingleTickerProviderStateMixin {
  List<Headline> _headlines = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  late AnimationController _controller;
  double _textWidth = 0;
  double _screenWidth = 0;

  static const Duration _refreshInterval = Duration(minutes: 30);
  Duration _animationDuration = const Duration(seconds: 60);

  static final List<Headline> _fallback = [
    Headline(
      headline: "New Study Shows Benefits of Regular Exercise for Mental Health",
      category: "Research",
      source: "Health News",
    ),
    Headline(
      headline: "FDA Approves New Treatment for Diabetes Management",
      category: "Medicine",
      source: "Medical Journal",
    ),
    Headline(
      headline: "Breakthrough in Cancer Immunotherapy Shows Promising Results",
      category: "Research",
      source: "Science Daily",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadHeadlines();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _loadHeadlines());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHeadlines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // No userId named parameter here → fixes undefined_named_parameter
      final headlines = await LlmService.getHealthHeadlines();
      if (!mounted) return;
      setState(() {
        _headlines = headlines.isNotEmpty ? headlines : _fallback;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _headlines = _fallback;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }
  }

  void _startAnimation() {
    if (!mounted) return;

    final text = _buildTickerText();
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _tickerTextStyle()),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    _textWidth = textPainter.width;
    _screenWidth = MediaQuery.of(context).size.width;

    const minSpeedPixelsPerSecond = 30.0;
    final desiredSeconds = (_textWidth + _screenWidth) / minSpeedPixelsPerSecond;
    final computedDuration = Duration(
      milliseconds: (desiredSeconds * 1000).clamp(15000, 180000).toInt(),
    );
    _animationDuration = computedDuration;

    _controller
      ..duration = _animationDuration
      ..repeat();
  }

  String _buildTickerText() {
    final parts = _headlines.map((h) => "${h.headline} - ${h.source}").toList();
    final joined = parts.join("   •   ");
    return "$joined   •   $joined";
  }

  TextStyle _tickerTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Live health news ticker',
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF006644)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border(top: BorderSide(color: Color(0xFF0B5B8A), width: 1)),
        ),
        child: _isLoading ? _loadingContent() : _tickerBody(),
      ),
    );
  }

  Widget _loadingContent() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Loading health news...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _tickerBody() {
    final tickerText = _buildTickerText();
    if (_textWidth <= _screenWidth) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.new_releases, color: Color(0xFF9FD3FF), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tickerText,
                style: _tickerTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalScrollWidth = _textWidth / 2;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animationValue = _controller.value;
            final dx = -animationValue * totalScrollWidth;
            return ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.new_releases,
                            color: Color(0xFF9FD3FF), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(dx, 0),
                            child: Text(
                              tickerText,
                              style: _tickerTextStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
