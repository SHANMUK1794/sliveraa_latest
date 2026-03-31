import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late List<double> _dataPoints;

  @override
  void initState() {
    super.initState();
    _initDataPoints();
  }

  @override
  void didUpdateWidget(PriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGold != widget.isGold) {
      _initDataPoints();
    }
  }

  void _initDataPoints() {
    _dataPoints = [
      0.15, 0.17, 0.19, 0.18, 0.16, 0.17, 0.20, 0.22, 0.21,
      0.22, 0.23, 0.24, 0.27, 0.28, 0.32, 0.34, 0.39, 0.40,
      0.46, 0.48, 0.60, 0.85, 0.90
    ];
    if (widget.isGold) {
      _dataPoints[_dataPoints.length - 1] = 0.82;
    }
  }

  void _handleTouch(Offset localPosition, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    const double rightPadding = 30; // Matches painter's setting
    final chartWidth = size.width - rightPadding;
    
    int pointCount = _dataPoints.length;
    double stepX = chartWidth / (pointCount - 1);
    
    // Find closest data point based on horizontal touch position
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
          dataPoints: _dataPoints,
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
  final List<double> dataPoints;
  final int? touchedIndex;

  _ChartPainter({
    required this.lineColor,
    required this.isGold,
    required this.timeframe,
    required this.dataPoints,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 30;
    const double rightPadding = 30;
    
    final chartWidth = size.width - rightPadding;
    final chartHeight = size.height - bottomPadding;

    _drawGridAndLabels(canvas, chartWidth, chartHeight, size.width, size.height);
    _drawDataLine(canvas, chartWidth, chartHeight);
    
    if (touchedIndex != null) {
      _drawTooltip(canvas, chartWidth, chartHeight);
    }
  }

  void _drawGridAndLabels(Canvas canvas, double w, double h, double totalW, double totalH) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    const int verticalLines = 8;
    for (int i = 0; i < verticalLines; i++) {
      double x = (w / (verticalLines - 1)) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    const int horizontalLines = 7;
    for (int i = 0; i < horizontalLines; i++) {
      double y = (h / (horizontalLines - 1)) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    _drawText(canvas, textPainter, "Feb'18", const Offset(0, 0), dyOffset: h + 8, textAlignRight: false);
    _drawText(canvas, textPainter, "Feb'22", Offset(w / 2, h + 8), alignCenter: true);
    _drawText(canvas, textPainter, "Mar'26", Offset(w, h + 8), textAlignRight: true);

    textPainter.text = TextSpan(
      text: "Price",
      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w600),
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(totalW - 8, h / 2);
    canvas.rotate(-3.14159 / 2); // Rotate -90 degrees
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

  void _drawDataLine(Canvas canvas, double w, double h) {
    final path = Path();
    final fillPath = Path();
    final stepX = w / (dataPoints.length - 1);

    path.moveTo(0, h - (dataPoints[0] * h));
    fillPath.moveTo(0, h);
    fillPath.lineTo(0, h - (dataPoints[0] * h));

    for (int i = 0; i < dataPoints.length - 1; i++) {
        final p0File = dataPoints[i];
        final p1File = dataPoints[i + 1];

        final p0 = Offset(stepX * i, h - (p0File * h));
        final p1 = Offset(stepX * (i + 1), h - (p1File * h));

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

    final endX = w;
    final endY = h - (dataPoints.last * h);

    final haloPaint = Paint()
      ..color = lineColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 10, haloPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
  }

  void _drawTooltip(Canvas canvas, double w, double h) {
    if (touchedIndex == null) return;
    
    final stepX = w / (dataPoints.length - 1);
    final pointX = stepX * touchedIndex!;
    final pointY = h - (dataPoints[touchedIndex!] * h);
    
    // Draw vertical dotted/guideline
    final guidePaint = Paint()
      ..color = lineColor.withOpacity(0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(pointX, 0), Offset(pointX, h), guidePaint);
    
    // Draw dot on the actual point
    final pointDotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(pointX, pointY), 5.5, pointDotPaint);
    canvas.drawCircle(Offset(pointX, pointY), 5.5, borderPaint);

    // Calculate dynamic price based on the point's percentage height
    // So visual and values correlate
    double basePrice = isGold ? 6900.0 : 75.0;
    double volatility = isGold ? 450.0 : 15.0;
    double priceVal = basePrice + (dataPoints[touchedIndex!] * volatility);
    String priceStr = "₹${priceVal.toStringAsFixed(0)}";
    String timeStr = "Oct ${10 + touchedIndex!}"; 
    
    final TextPainter pricePainter = TextPainter(
      text: TextSpan(
        text: priceStr,
        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    pricePainter.layout();
    
    final TextPainter timePainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8)),
      ),
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    
    // Size constraints for the tooltip box
    double tooltipWidth = (pricePainter.width > timePainter.width ? pricePainter.width : timePainter.width) + 24;
    double tooltipHeight = pricePainter.height + timePainter.height + 16;
    
    double boxX = pointX - (tooltipWidth / 2);
    // Keep it within bounds horizontal
    if (boxX < 0) boxX = 0;
    if (boxX + tooltipWidth > w + 20) boxX = (w + 20) - tooltipWidth;
    
    // Keep it above the dot
    double boxY = pointY - tooltipHeight - 12;
    // If it bleeds over top edge, push below the dot
    if (boxY < 0) boxY = pointY + 16;
    
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxX, boxY, tooltipWidth, tooltipHeight),
      const Radius.circular(8)
    );
    
    // Draw shadow manually
    canvas.drawShadow(
      Path()..addRRect(rrect),
      Colors.black,
      4.0, // elevation
      false,
    );
    
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
           oldDelegate.touchedIndex != touchedIndex;
  }
}
