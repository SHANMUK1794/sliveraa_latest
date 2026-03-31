import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/price_data.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import 'delivery_summary_screen.dart';

class DeliveryScreen extends StatefulWidget {
  final bool isGoldInitial;
  const DeliveryScreen({super.key, this.isGoldInitial = true});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late bool isGold;
  final TextEditingController _gramsController = TextEditingController();
  bool payWithVault = true;

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  double get vaultBalance => isGold ? AppState().goldGrams : AppState().silverGrams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Physical Delivery',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('SELECT METAL TYPE'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMetalTypeCard('Gold', Icons.stars_rounded, true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetalTypeCard('Silver', Icons.toll_rounded, false)),
                  ],
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionLabel('QUANTITY TO DELIVER'),
                    Text(
                      'VIEW DENOMINATIONS',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBrownGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gramsController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: GoogleFonts.manrope(
                            color: const Color(0xFFE5E7EB),
                            fontWeight: FontWeight.w900,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Text(
                      'grams',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 48, color: Color(0xFFF3F4F6)),
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 10),
                    Text(
                      'Available in Vault: ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${vaultBalance.toStringAsFixed(2)} g',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                _buildSectionLabel('SETTLEMENT METHOD'),
                const SizedBox(height: 16),
                _buildSettlementCard(
                  'Deduct from Vault',
                  'Use your existing gold savings',
                  Icons.eco_rounded,
                  payWithVault,
                  () => setState(() => payWithVault = true),
                ),
                const SizedBox(height: 12),
                _buildSettlementCard(
                  'Pay with NetBanking/UPI',
                  'Buy and deliver in one go',
                  Icons.account_balance_rounded,
                  !payWithVault,
                  () => setState(() => payWithVault = false),
                ),
                const SizedBox(height: 40),
                _buildProceedButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMetalTypeCard(String label, IconData icon, bool gold) {
    bool active = isGold == gold;
    return GestureDetector(
      onTap: () => setState(() => isGold = gold),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: active ? Colors.white : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? AppColors.primaryBrownGold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (active)
              Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.check_circle_rounded, color: AppColors.primaryBrownGold, size: 20),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFF9F5F1) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: active ? AppColors.primaryBrownGold : const Color(0xFF9CA3AF),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: active ? const Color(0xFF111827) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementCard(String title, String subtitle, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryBrownGold.withValues(alpha: 0.1) : Colors.transparent,
            width: 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF111827), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.primaryBrownGold, size: 24)
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [AppColors.accentBrownGold, AppColors.primaryBrownGold],
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
        onPressed: () {
          double requestedGrams = double.tryParse(_gramsController.text) ?? 0;
          if (requestedGrams <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter quantity')));
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliverySummaryScreen(
                isGold: isGold,
                requestedGrams: requestedGrams,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Address',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

}
