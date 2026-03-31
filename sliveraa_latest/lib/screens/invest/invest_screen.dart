import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/price_provider.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import 'invest_amount_screen.dart';

class InvestScreen extends StatefulWidget {
  final bool isGold;
  const InvestScreen({super.key, required this.isGold});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  late bool isGoldSelected;
  String selectedTimeframe = '1D';

  @override
  void initState() {
    super.initState();
    isGoldSelected = widget.isGold;
  }

  @override
  Widget build(BuildContext context) {
    final priceProvider = Provider.of<PriceProvider>(context);
    final currentPrice = isGoldSelected ? priceProvider.goldPrice : priceProvider.silverPrice;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isGoldSelected ? 'Gold 24K' : 'Silver 24K',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF111827)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGoldSilverToggle(),
            const SizedBox(height: 40),
            _buildPriceSection(currentPrice),
            const SizedBox(height: 32),
            _buildTimeframeSelector(),
            _buildChartSection(),
            const SizedBox(height: 32),
            _buildPriceAlertCard(),
            const SizedBox(height: 16),
            _buildPromoCard(),
            const SizedBox(height: 120), // Bottom padding
          ],
        ),
      ),
      bottomSheet: _buildBottomActionButton(),
    );
  }

  Widget _buildGoldSilverToggle() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              'GOLD', 
              isGoldSelected, 
              const Color(0xFFCE9966),
              () => setState(() => isGoldSelected = true),
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              'SILVER', 
              !isGoldSelected, 
              const Color(0xFF94A3B8),
              () => setState(() => isGoldSelected = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(double price) {
    return Column(
      children: [
        Text(
          '₹${formatRupee(price)}',
          style: GoogleFonts.manrope(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.north_east_rounded, color: Color(0xFF15803D), size: 14),
              const SizedBox(width: 4),
              Text(
                '+1.2% (₹74.15) Today',
                style: GoogleFonts.inter(
                  color: const Color(0xFF15803D),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final frames = ['1D', '1W', '1M', '1Y', 'ALL'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: frames.map((f) {
          bool isSelected = selectedTimeframe == f;
          return GestureDetector(
            onTap: () => setState(() => selectedTimeframe = f),
            child: Column(
              children: [
                Text(
                  f,
                  style: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFFCE9966) : const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2,
                  width: 24,
                  color: isSelected ? const Color(0xFFCE9966) : Colors.transparent,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: CustomPaint(
        painter: _MarketChartPainter(isGold: isGoldSelected),
      ),
    );
  }

  Widget _buildPriceAlertCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFB45309), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isGoldSelected ? 'Gold' : 'Silver'} Price Alert',
                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                Text(
                  'Get timely alerts when prices drop',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: const Color(0xFFCE9966),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1), // Grey base matching image
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.8,
              child: Icon(Icons.eco_rounded, size: 140, color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'LUMINA',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF475569),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'NEXT-GENERATION WEALTH MANAGEMENT',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569).withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    final activeColor = isGoldSelected ? const Color(0xFFEAB308) : const Color(0xFF94A3B8);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InvestAmountScreen(isGold: isGoldSelected)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            isGoldSelected ? 'BUY GOLD' : 'BUY SILVER',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  final bool isGold;
  _MarketChartPainter({required this.isGold});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isGold ? const Color(0xFFCE9966) : const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();
    
    // Complex Bezier curve matching image
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.15, size.height * 0.7,
      size.width * 0.25, size.height * 0.4,
      size.width * 0.35, size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.45, size.height * 0.8,
      size.width * 0.55, size.height * 0.5,
      size.width * 0.65, size.height * 0.7,
    );
    path.cubicTo(
      size.width * 0.75, size.height * 0.9,
      size.width * 0.85, size.height * 0.1,
      size.width, size.height * 0.5,
    );

    // Create fill path
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        (isGold ? const Color(0xFFCE9966) : const Color(0xFF94A3B8)).withValues(alpha: 0.2),
        Colors.transparent,
      ],
    );
    canvas.drawPath(fillPath, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Draw main line
    canvas.drawPath(path, paint);

    // Draw vertical bars (volatility/indicators)
    final barPaint = Paint()..strokeWidth = 3..style = PaintingStyle.stroke;
    final bars = [
      {'x': 0.15, 'h': 20.0, 'up': true},
      {'x': 0.22, 'h': 25.0, 'up': false},
      {'x': 0.32, 'h': 35.0, 'up': true},
      {'x': 0.42, 'h': 20.0, 'up': true},
      {'x': 0.52, 'h': 30.0, 'up': false},
      {'x': 0.62, 'h': 40.0, 'up': true},
      {'x': 0.72, 'h': 25.0, 'up': true},
      {'x': 0.82, 'h': 45.0, 'up': true},
    ];

    for (var bar in bars) {
      final x = size.width * (bar['x'] as double);
      final h = bar['h'] as double;
      final up = bar['up'] as bool;
      
      barPaint.color = up ? const Color(0xFFBBE5BE).withValues(alpha: 0.8) : const Color(0xFFFECACA).withValues(alpha: 0.8);
      
      final yOffset = up ? -h : h; // Randomish logic for placement near line
      // For now just draw some vertical lines
      canvas.drawLine(Offset(x, 150), Offset(x, 150 + yOffset), barPaint);
    }
    
    // Draw dotted line
    final dashPaint = Paint()
      ..color = const Color(0xFFB45309).withValues(alpha: 0.4)
      ..strokeWidth = 1;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width * 0.7, startY), Offset(size.width * 0.7, startY + 5), dashPaint);
      startY += 10;
    }

    // Time labels
    const labels = ['09:00 AM', '12:00 PM', '03:00 PM', '06:00 PM', '09:00 PM'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length; i++) {
       textPainter.text = TextSpan(
         text: labels[i], 
         style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)
       );
       textPainter.layout();
       textPainter.paint(canvas, Offset((size.width / 5) * i + 10, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
