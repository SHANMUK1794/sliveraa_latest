import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SILVRA',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD4B184),
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE6D5B8), // Gold emblem background
              ),
              child: Center(
                child: Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primaryBrownGold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #SLV-9827410',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track Delivery',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildJourneyDetails(),
                const SizedBox(height: 24),
                _buildLogisticsCard(),
                const SizedBox(height: 24),
                _buildContactButton(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Out for Delivery',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFC8A97E), // Soft brown
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arriving Today',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
              Text(
                '66%',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBrownGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.66,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFD4B184), AppColors.primaryBrownGold],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Your precious metal shipment is currently with our last-mile delivery partner and will reach you by 6:00 PM.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journey Details',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTimelineNode(
            title: 'Order Confirmed',
            subtitle: 'Oct 24, 10:30 AM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineNode(
            title: 'Packed',
            subtitle: 'Oct 24, 02:15 PM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineNode(
            title: 'Shipped',
            subtitle: 'Oct 25, 09:00 AM',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineNode(
            title: 'Out for Delivery',
            subtitle: 'Expected by 6:00 PM',
            isCompleted: false, // Treating as "current" state
            isActive: true,
            isLast: false,
          ),
          _buildTimelineNode(
            title: 'Delivered',
            subtitle: 'Pending arrival',
            isCompleted: false,
            isActive: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? const Color(0xFF0D9488) // Teal
                      : isActive 
                          ? const Color(0xFFFDE6C8) // Pale Orange
                          : const Color(0xFFF3F4F6), // Grey
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : isActive
                          ? Icon(Icons.location_on, color: AppColors.primaryBrownGold, size: 16)
                          : const Icon(Icons.inventory_2_outlined, color: Color(0xFF9CA3AF), size: 16),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xFFE5E7EB) : const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24), // Spacing between items
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 6), // Better vertical alignment with circle
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isCompleted || isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primaryBrownGold : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined, color: Color(0xFF111827), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sequel Logistics',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'SLV9827410',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy_rounded, color: Color(0xFFD4B184), size: 14),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.phone_outlined, color: Color(0xFF6B7280), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryBrownGold, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(
          'CONTACT SUPPORT',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBrownGold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('Home', Icons.home_filled, true),
          _navItem('Market', Icons.auto_graph_rounded, false),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBrownGold.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBrownGold.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBrownGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          _navItem('Rewards', Icons.emoji_events_rounded, false),
          _navItem('History', Icons.history_rounded, false),
        ],
      ),
    );
  }

  Widget _navItem(String label, IconData icon, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? AppColors.primaryBrownGold : const Color(0xFFD1D5DB), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            color: active ? AppColors.primaryBrownGold : const Color(0xFFD1D5DB),
          ),
        ),
      ],
    );
  }
}
