import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../support/concierge_support_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "Unknown";
    try {
      final dt = DateTime.parse(dateStr.toString());
      return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }

  String _formatOnlyTime(dynamic dateStr) {
    if (dateStr == null) return "Unknown";
    try {
      final dt = DateTime.parse(dateStr.toString());
      return DateFormat("hh:mm a").format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuy = transaction['type'] == 'BUY';
    final String assetType = transaction['assetType'] ?? 'GOLD';
    double amount = transaction['amount'] ?? 0.0;
    
    // Derived dummy data for display purposes
    String orderId = 'SILV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    String paymentMethod = 'Google Pay UPI';
    
    double simulatedPricePerGram = assetType == 'GOLD' ? 7600.0 : 90.0;
    double quantity = amount / simulatedPricePerGram;
    double baseAmount = amount;
    double gst = baseAmount * 0.03;
    double totalAmount = baseAmount + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B6B4D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction Details',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildTopCard(assetType, transaction['type'] ?? 'BUY', amount, transaction['createdAt']),
            const SizedBox(height: 16),
            _buildOrderInformationCard(orderId, paymentMethod, quantity, simulatedPricePerGram, baseAmount, gst, totalAmount),
            const SizedBox(height: 16),
            _buildTimelineCard(transaction['createdAt']),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(String assetType, String type, double amount, dynamic createdAt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EFE9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF8B6B4D),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${type.toUpperCase()} $assetType',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(amount)}',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(createdAt),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3EFE9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B6B4D),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Success',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8B6B4D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInformationCard(String orderId, String paymentMethod, double quantity, double pricePerGram, double baseAmount, double gst, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Slight gray matching the screenshot
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Order ID', orderId, isCopy: true),
          const SizedBox(height: 16),
          _buildInfoRow('Payment method', paymentMethod, isBoldValue: true),
          const SizedBox(height: 16),
          _buildInfoRow('Quantity', '${quantity.toStringAsFixed(4)} g', isBoldValue: true),
          const SizedBox(height: 16),
          _buildInfoRow('Price per gram', '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(pricePerGram)}', isBoldValue: true),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: const Color(0xFFE2E8F0).withOpacity(0.5), height: 1),
          ),
          
          _buildInfoRow('Base Amount', '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(baseAmount)}', isBoldValue: true),
          const SizedBox(height: 12),
          _buildInfoRow('GST (3%)', '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(gst)}', isBoldValue: true),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: const Color(0xFFE2E8F0).withOpacity(0.5), height: 1),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                ),
              ),
              Text(
                '₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(totalAmount)}',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF8B6B4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopy = false, bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            if (isCopy) ...[
              const SizedBox(width: 6),
              const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF8B6B4D)),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineCard(dynamic createdAt) {
    String timeStr = _formatOnlyTime(createdAt);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineItem('Initiated', timeStr, isLast: false),
          _buildTimelineItem('Processing', timeStr, isLast: false),
          _buildTimelineItem('Completed', timeStr, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFD2B48C),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 38,
                color: const Color(0xFFD2B48C),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // To allow gradient to fill
              elevation: 4,
              shadowColor: const Color(0xFFDEB887).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5BE95), Color(0xFFF1D1AE)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Download Invoice',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConciergeSupportScreen()),
            );
          },
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(
            'Need Help?',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8B6B4D),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              'Secure transaction powered by SILVRAS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
