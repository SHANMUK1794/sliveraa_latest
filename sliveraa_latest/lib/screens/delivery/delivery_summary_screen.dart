import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'add_delivery_address_screen.dart';

class DeliverySummaryScreen extends StatefulWidget {
  final bool isGold;
  final double requestedGrams;

  const DeliverySummaryScreen({
    super.key,
    required this.isGold,
    required this.requestedGrams,
  });

  @override
  State<DeliverySummaryScreen> createState() => _DeliverySummaryScreenState();
}

class _DeliverySummaryScreenState extends State<DeliverySummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isGold ? 'Gold Delivery' : 'Silver Delivery',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIdentityCard(),
                const SizedBox(height: 32),
                _buildSectionLabel('DELIVERY ADDRESS'),
                const SizedBox(height: 16),
                _buildAddressCard(),
                const SizedBox(height: 16),
                _buildAddAddressButton(),
                const SizedBox(height: 48),
                _buildSectionLabel(widget.isGold ? 'GOLD DELIVERY DETAILS' : 'SILVER DELIVERY DETAILS'),
                const SizedBox(height: 16),
                _buildDeliveryDetailsCard(),
                const SizedBox(height: 32),
                _buildPromoCard(),
                const SizedBox(height: 48),
                _buildConfirmButton(),
                const SizedBox(height: 48),
              ],
            ),
          ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBrownGold, width: 2),
              color: const Color(0xFFF9F5F1),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Icon(Icons.contact_mail_rounded, color: AppColors.primaryBrownGold, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rahul Sharma',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppColors.primaryBrownGold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'VERIFIED INVESTOR',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBrownGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rahul Sharma',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Flat 203, Sunshine Residency, Road\nNo. 12, Banjara Hills, Hyderabad,\nTelangana 500034',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF4B5563)),
                    const SizedBox(width: 6),
                    Text(
                      '+91 9876543210',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDeliveryAddressScreen(isEditing: true)));
            },
            icon: Icon(Icons.edit_outlined, color: AppColors.primaryBrownGold, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            alignment: Alignment.topRight,
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDeliveryAddressScreen(isEditing: false)));
      },
      child: Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBrownGold, size: 20),
          const SizedBox(width: 8),
          Text(
            'Add New Address',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBrownGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard() {
    String displayGrams = widget.requestedGrams > 0 ? widget.requestedGrams.toStringAsFixed(2) : "10";
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow('${widget.isGold ? 'Gold' : 'Silver'} Amount', '$displayGrams Grams', false),
                const SizedBox(height: 24),
                _buildDetailRow('Estimated Delivery', '3 – 5 Business Days', false),
                const SizedBox(height: 24),
                _buildDetailRow('Delivery Charge', 'FREE', true),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEDFDF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Color(0xFF22C55E), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFF22C55E), size: 14),
                const SizedBox(width: 8),
                Text(
                  'INSURED & SECURE ${widget.isGold ? "GOLD" : "SILVER"} DELIVERY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isHighlight ? const Color(0xFF22C55E) : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF382A20), // Dark brown
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIMITED OFFER',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBrownGold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Free insured delivery on ${widget.isGold ? "gold" : "silver"} above\n₹5,000',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.primaryBrownGold, const Color(0xFFD4B184)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrownGold.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _showSuccessDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CONFIRM DELIVERY',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Confirmed!',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your physical ${widget.isGold ? 'gold' : 'silver'} order is being processed for minting and dispatch.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop to delivery screen
                  Navigator.pop(context); // Pop to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
