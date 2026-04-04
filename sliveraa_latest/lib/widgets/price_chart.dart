import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api_service.dart';
import 'package:intl/intl.dart';

class PriceChart extends StatefulWidget {
  final bool isGold;
  final String timeframe;
  final Color lineColor;

  const PriceChart({
    super.key,
    required this.isGold,
    required this.timeframe,
    required this.lineColor,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  int? _touchedIndex;
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void didUpdateWidget(PriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGold != widget.isGold || oldWidget.timeframe != widget.timeframe) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final metal = widget.isGold ? 'GOLD' : 'SILVER';
      final response = await ApiService().getPriceHistory(metal, widget.timeframe);
      
      if (response.statusCode == 200) {
        final List<dynamic> history = response.data['history'] ?? [];
        if (mounted) {
          setState(() {
            _historyData = history.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load chart data';
        });
      }
    }
  }

  void _handleTouch(Offset localPosition, BuildContext context) {
    if (_historyData.isEmpty) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    const double rightPadding = 30;
    final chartWidth = size.width - rightPadding;
    
    int pointCount = _historyData.length;
    if (pointCount < 2) return;
    
    double stepX = chartWidth / (pointCount - 1);
    int closestIndex = (localPosition.dx / stepX).round();
    
    if (closestIndex >= 0 && closestIndex < pointCount) {
      if (_touchedIndex != closestIndex) {
        setState(() {
          _touchedIndex = closestIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4A017)));
    }

    if (_errorMessage != null || _historyData.isEmpty) {
      return Center(
        child: Text(
          _errorMessage ?? 'No data available',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    return GestureDetector(
      onPanDown: (details) => _handleTouch(details.localPosition, context),
      onPanUpdate: (details) => _handleTouch(details.localPosition, context),
      onPanEnd: (_) => setState(() => _touchedIndex = null),
      onPanCancel: () => setState(() => _touchedIndex = null),
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: _ChartPainter(
          lineColor: widget.lineColor,
          isGold: widget.isGold,
          timeframe: widget.timeframe,
          historyData: _historyData,
          touchedIndex: _touchedIndex,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color lineColor;
  final bool isGold;
  final String timeframe;
  final List<Map<String, dynamic>> historyData;
  final int? touchedIndex;

  _ChartPainter({
    required this.lineColor,
    required this.isGold,
    required this.timeframe,
    required this.historyData,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historyData.isEmpty) return;

    const double bottomPadding = 30;
    const double rightPadding = 30;
    
    final chartWidth = size.width - rightPadding;
    final chartHeight = size.height - bottomPadding;

    // Find Min/Max for Scaling
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    
    for (var point in historyData) {
      double price = (point['price'] as num).toDouble();
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }

    // Add some padding to min/max
    double range = maxPrice - minPrice;
    if (range == 0) range = 1.0;
    minPrice -= range * 0.1;
    maxPrice += range * 0.1;
    range = maxPrice - minPrice;

    _drawGridAndLabels(canvas, chartWidth, chartHeight, size.width, size.height);
    _drawDataLine(canvas, chartWidth, chartHeight, minPrice, range);
    
    if (touchedIndex != null) {
      _drawTooltip(canvas, chartWidth, chartHeight, minPrice, range);
    }
  }

  void _drawGridAndLabels(Canvas canvas, double w, double h, double totalW, double totalH) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    const int verticalLines = 6;
    for (int i = 0; i < verticalLines; i++) {
      double x = (w / (verticalLines - 1)) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    const int horizontalLines = 5;
    for (int i = 0; i < horizontalLines; i++) {
      double y = (h / (horizontalLines - 1)) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Dynamic Date Labels
    if (historyData.isNotEmpty) {
      final firstDate = DateTime.parse(historyData.first['date']);
      final middleDate = DateTime.parse(historyData[historyData.length ~/ 2]['date']);
      final lastDate = DateTime.parse(historyData.last['date']);

      DateFormat df = DateFormat('MMM yy');
      if (timeframe == '1M' || timeframe == '3M') df = DateFormat('dd MMM');

      _drawText(canvas, textPainter, df.format(firstDate), const Offset(0, 0), dyOffset: h + 8, textAlignRight: false);
      _drawText(canvas, textPainter, df.format(middleDate), Offset(w / 2, h + 8), alignCenter: true);
      _drawText(canvas, textPainter, df.format(lastDate), Offset(w, h + 8), textAlignRight: true);
    }

    textPainter.text = TextSpan(
      text: "Price",
      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w600),
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(totalW - 8, h / 2);
    canvas.rotate(-3.14159 / 2);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  void _drawText(Canvas canvas, TextPainter tp, String text, Offset pos, {double dyOffset = 0, bool alignCenter = false, bool textAlignRight = false}) {
    tp.text = TextSpan(
      text: text,
      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
    );
    tp.layout();
    
    double dx = pos.dx;
    if (alignCenter) dx -= tp.width / 2;
    if (textAlignRight) dx -= tp.width;

    double dy = dyOffset > 0 ? dyOffset : pos.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawDataLine(Canvas canvas, double w, double h, double minP, double range) {
    if (historyData.length < 2) return;
    
    final path = Path();
    final fillPath = Path();
    final stepX = w / (historyData.length - 1);

    double getNormalizedY(double price) {
      return h - (((price - minP) / range) * h);
    }

    double firstY = getNormalizedY((historyData[0]['price'] as num).toDouble());
    path.moveTo(0, firstY);
    fillPath.moveTo(0, h);
    fillPath.lineTo(0, firstY);

    for (int i = 0; i < historyData.length - 1; i++) {
        final p0Price = (historyData[i]['price'] as num).toDouble();
        final p1Price = (historyData[i + 1]['price'] as num).toDouble();

        final p0 = Offset(stepX * i, getNormalizedY(p0Price));
        final p1 = Offset(stepX * (i + 1), getNormalizedY(p1Price));

        final midX = (p0.dx + p1.dx) / 2;
        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(w, h);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withOpacity(0.15),
        lineColor.withOpacity(0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTRB(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // End Dot
    final lastPrice = (historyData.last['price'] as num).toDouble();
    final endX = w;
    final endY = getNormalizedY(lastPrice);

    final haloPaint = Paint()
      ..color = lineColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 10, haloPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
  }

  void _drawTooltip(Canvas canvas, double w, double h, double minP, double range) {
    if (touchedIndex == null || touchedIndex! >= historyData.length) return;
    
    final pointData = historyData[touchedIndex!];
    final double priceVal = (pointData['price'] as num).toDouble();
    final DateTime date = DateTime.parse(pointData['date']);
    
    final stepX = w / (historyData.length - 1);
    final pointX = stepX * touchedIndex!;
    final pointY = h - (((priceVal - minP) / range) * h);
    
    final guidePaint = Paint()
      ..color = lineColor.withOpacity(0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(pointX, 0), Offset(pointX, h), guidePaint);
    
    final pointDotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(pointX, pointY), 5.5, pointDotPaint);
    canvas.drawCircle(Offset(pointX, pointY), 5.5, borderPaint);

    String priceStr = "₹${priceVal.toStringAsFixed(2)}";
    String timeStr = DateFormat('dd MMM yyyy').format(date);
    
    final TextPainter pricePainter = TextPainter(
      text: TextSpan(
        text: priceStr,
        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    pricePainter.layout();
    
    final TextPainter timePainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8)),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    timePainter.layout();
    
    double tooltipWidth = (pricePainter.width > timePainter.width ? pricePainter.width : timePainter.width) + 24;
    double tooltipHeight = pricePainter.height + timePainter.height + 16;
    
    double boxX = pointX - (tooltipWidth / 2);
    if (boxX < 0) boxX = 0;
    if (boxX + tooltipWidth > w + 20) boxX = (w + 20) - tooltipWidth;
    
    double boxY = pointY - tooltipHeight - 12;
    if (boxY < 0) boxY = pointY + 16;
    
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, boxY, tooltipWidth, tooltipHeight),
      const Radius.circular(8)
    );
    
    canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 4.0, false);
    final Paint boxPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(rrect, boxPaint);
    
    pricePainter.paint(canvas, Offset(boxX + 12, boxY + 8));
    timePainter.paint(canvas, Offset(boxX + 12, boxY + 8 + pricePainter.height + 2));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.isGold != isGold ||
           oldDelegate.timeframe != timeframe ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.touchedIndex != touchedIndex ||
           oldDelegate.historyData != historyData;
  }
}
