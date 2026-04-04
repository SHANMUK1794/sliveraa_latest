import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../core/api_service.dart';
import 'add_delivery_address_screen.dart';

class DeliverySummaryScreen extends StatefulWidget {
  final bool isGold;
  final double requestedGrams;
  final bool payWithVault;

  const DeliverySummaryScreen({
    super.key,
    required this.isGold,
    required this.requestedGrams,
    required this.payWithVault,
  });

  @override
  State<DeliverySummaryScreen> createState() => _DeliverySummaryScreenState();
}

class _DeliverySummaryScreenState extends State<DeliverySummaryScreen> {
  late Razorpay _razorpay;
  int _selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double get metalPrice => PriceData.getPrice(widget.isGold);
  double get metalValue => widget.requestedGrams * metalPrice;
  double get makingCharges => widget.isGold ? (widget.requestedGrams * 149) : (widget.requestedGrams * 12);
  double get deliveryFee => metalValue > 5000 ? 0 : 100;
  
  double get totalPayable {
    if (widget.payWithVault) {
      return makingCharges + deliveryFee;
    } else {
      return metalValue + makingCharges + deliveryFee;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _finalizeOrder(response.paymentId ?? "MOCK_PAY_ID");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _startPayment() {
    var options = {
      'key': 'rzp_test_MOCK_KEY', // MOCK Key for testing
      'amount': (totalPayable * 100).toInt(),
      'name': 'Silvra Investments',
      'description': '${widget.requestedGrams}g ${widget.isGold ? "Gold" : "Silver"} Delivery',
      'prefill': {
        'contact': AppState().currentUser['phone'] ?? '',
        'email': AppState().currentUser['email'] ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _finalizeOrder(String paymentId) async {
    try {
      final address = AppState().addresses.isNotEmpty 
          ? AppState().addresses[_selectedAddressIndex] 
          : "Default Address";

      final response = await ApiService().createDeliveryRequest({
        'metalType': widget.isGold ? 'GOLD' : 'SILVER',
        'weight': widget.requestedGrams,
        'paymentId': paymentId,
        'payWithVault': widget.payWithVault,
        'address': address,
        'amount': totalPayable,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
        // Update local balance
        if (widget.payWithVault) {
          if (widget.isGold) {
            AppState().goldGrams -= widget.requestedGrams;
          } else {
            AppState().silverGrams -= widget.requestedGrams;
          }
          AppState().notifyListeners();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating order: $e')),
      );
    }
  }

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
            if (AppState().addresses.isEmpty)
              _buildNoAddressState()
            else
              _buildAddressList(),
            const SizedBox(height: 16),
            _buildAddAddressButton(),
            const SizedBox(height: 48),
            _buildSectionLabel('PAYMENT SUMMARY'),
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

  Widget _buildNoAddressState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded, color: Color(0xFF94A3B8), size: 40),
            const SizedBox(height: 12),
            Text(
              'No delivery address added',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return Column(
      children: AppState().addresses.asMap().entries.map((entry) {
        int idx = entry.key;
        String addr = entry.value;
        bool isSelected = _selectedAddressIndex == idx;
        return GestureDetector(
          onTap: () => setState(() => _selectedAddressIndex = idx),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryBrownGold : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    addr,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
                child: Icon(Icons.person_pin_circle_rounded, color: AppColors.primaryBrownGold, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppState().userName.isNotEmpty ? AppState().userName : 'Rahul Sharma',
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

  Widget _buildAddAddressButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDeliveryAddressScreen(isEditing: false)));
        setState(() {});
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
                _buildDetailRow('Metal Weight', '${widget.requestedGrams} Grams', false),
                const SizedBox(height: 16),
                if (!widget.payWithVault)
                  _buildDetailRow('Metal Market Value', '₹${metalValue.toLocaleString()}', false),
                _buildDetailRow('Making Charges', '₹${makingCharges.toLocaleString()}', false),
                _buildDetailRow('Insured Delivery', deliveryFee == 0 ? 'FREE' : '₹${deliveryFee.toLocaleString()}', deliveryFee == 0),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFF3F4F6)),
                ),
                _buildDetailRow('Total Payable', '₹${totalPayable.toLocaleString()}', false, isTotal: true),
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

  Widget _buildDetailRow(String label, String value, bool isHighlight, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 15 : 14,
            color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
            color: isHighlight ? const Color(0xFF22C55E) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FREE DELIVERY THRESHOLD',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBrownGold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Free delivery on gold/silver above ₹5,000 value.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    bool canConfirm = AppState().addresses.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: canConfirm 
            ? [AppColors.primaryBrownGold, const Color(0xFFD4B184)]
            : [const Color(0xFF94A3B8), const Color(0xFF64748B)],
        ),
        boxShadow: canConfirm ? [
          BoxShadow(
            color: AppColors.primaryBrownGold.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: canConfirm ? _startPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'PAY ₹${totalPayable.toLocaleString()} & CONFIRM',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your physical ${widget.isGold ? 'gold' : 'silver'} order is confirmed and will be dispatched within 48 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Summary
                  Navigator.pop(context); // Delivery
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Track My Order', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
