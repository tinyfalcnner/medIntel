// lib/widgets/health_news_ticker.dart
//
// A marquee-style health news ticker that fetches headlines periodically
// from a service (LLM / API) and scrolls them continuously.
// - Refreshes every 30 minutes
// - Has fallback headlines when the network fails
// - Accessible (semantics) and responsive
// - Uses a single AnimationController to loop the scroll

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // optional - helpful for timestamps if desired
import '../services/llm_service.dart'; // See notes below
import '../models/headline.dart';

class HealthNewsTicker extends StatefulWidget {
  /// Height of the ticker; you can override to adapt to layout.
  final double height;

  const HealthNewsTicker({Key? key, this.height = 48.0}) : super(key: key);

  @override
  _HealthNewsTickerState createState() => _HealthNewsTickerState();
}

class _HealthNewsTickerState extends State<HealthNewsTicker>
    with SingleTickerProviderStateMixin {
  List<Headline> _headlines = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  late AnimationController _controller;
  double _textWidth = 0;
  double _screenWidth = 0;

  // Poll interval - 30 minutes (in production you may adjust)
  static const Duration _refreshInterval = Duration(minutes: 30);
  // Animation duration - will be calculated dynamically based on content width
  Duration _animationDuration = const Duration(seconds: 60);

  // Fallback headlines (used if network call fails)
  static final List<Headline> _fallback = [
    Headline(headline: "New Study Shows Benefits of Regular Exercise for Mental Health", category: "Research", source: "Health News"),
    Headline(headline: "FDA Approves New Treatment for Diabetes Management", category: "Medicine", source: "Medical Journal"),
    Headline(headline: "Breakthrough in Cancer Immunotherapy Shows Promising Results", category: "Research", source: "Science Daily"),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadHeadlines();
    // schedule periodic refresh
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
      _error = null;
    });

    try {
      // LlmService.getHealthHeadlines should return List<Headline>
      final headlines = await LlmService.getHealthHeadlines();
      if (mounted) {
        setState(() {
          _headlines = (headlines.isNotEmpty) ? headlines : _fallback;
          _isLoading = false;
        });
        // Give the widget tree a tick to measure before starting animation
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
      }
    } catch (err) {
      // On failure, use fallback and keep the error string for logs/UI
      setState(() {
        _headlines = _fallback;
        _isLoading = false;
        _error = err.toString();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }
  }

  void _startAnimation() {
    // Recalculate sizes and animation duration
    if (!mounted) return;

    final text = _buildTickerText();
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _tickerTextStyle()),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // measured total width of concatenated ticker items
    _textWidth = textPainter.width;
    _screenWidth = MediaQuery.of(context).size.width;

    // If content is smaller than screen, slow/fixed scroll (or no scroll)
    const minSpeedPixelsPerSecond = 30.0; // fine-tune for comfortable reading
    final desiredSeconds = (_textWidth + _screenWidth) / minSpeedPixelsPerSecond;
    final computedDuration = Duration(
        milliseconds: (desiredSeconds * 1000).clamp(15000, 180000).toInt());
    _animationDuration = computedDuration;

    // Setup controller to loop
    _controller
      ..duration = _animationDuration
      ..repeat();
  }

  String _buildTickerText() {
    // Build a readable concatenation with separators like "  •  "
    final parts = _headlines.map((h) => "${h.headline}  - ${h.source}").toList();
    // Repeat once so continuous loop is smoother
    return parts.join("     •     ") + "     •     " + parts.join("     •     ");
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
    // Keep ticker accessible and contrast-friendly
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
        child: _isLoading
            ? _loadingContent()
            : _tickerBody(),
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
            child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          ),
          SizedBox(width: 8),
          Text('Loading health news...', style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _tickerBody() {
    final tickerText = _buildTickerText();

    // When the content width is small (content fits), we simply center it.
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

    // Use AnimatedBuilder to translate the text horizontally using controller value
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalScrollWidth = _textWidth / 2; // because we repeated the content
        // The animation value goes 0..1 and we map it to -totalScrollWidth..0
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
                        const Icon(Icons.new_releases, color: Color(0xFF9FD3FF), size: 18),
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
