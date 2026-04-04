import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import 'home_screen.dart';

import '../invest/payment_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final bool isGold;
  final double grams;

  const PaymentScreen({
    super.key, 
    required this.amount,
    required this.orderId,
    required this.isGold,
    required this.grams,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Start payment process immediately after screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  void _startPayment() {
    final state = context.read<AppState>();
    var options = {
      'key': 'rzp_test_MOCK_KEY', // Triggers Mock Mode in backend
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'Silvra',
      'order_id': widget.orderId, // Real order ID from backend
      'description': 'Purchase of ${widget.grams.toStringAsFixed(3)}gm ${widget.isGold ? 'Gold' : 'Silver'}',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': state.userPhone,
        'email': state.userEmail,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    try {
      // Verify signature on backend
      final verifyResponse = await ApiService().verifyPayment({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });

      if (verifyResponse.data['success'] == true) {
        // Refresh profile to show new balance
        await context.read<AppState>().refreshStatus();
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(
                isSuccess: true,
                amount: widget.amount,
              ),
            ),
          );
        }
      } else {
        throw Exception(verifyResponse.data['message'] ?? 'Signature verification failed');
      }
    } catch (e) {
      _showError('Verification Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    
    String message = 'Payment could not be completed.';
    
    // Responsibility: Explaining WHY it failed
    if (response.code == 2) { // 2 is typically the code for Cancelled
      message = 'Payment was cancelled. You can try again whenever you are ready.';
    } else if (response.code == 0) { // 0 is typically for Network Error
      message = 'Connection issue. Please check your internet and try again.';
    } else if (response.message != null && response.message!.isNotEmpty) {
      message = response.message!;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentStatusScreen(
          isSuccess: false,
          amount: widget.amount,
          errorMessage: message,
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _showError(String message) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentStatusScreen(
            isSuccess: false,
            amount: widget.amount,
            errorMessage: message,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isProcessing ? _buildProcessingIcon() : _buildIdleIcon(),
            const SizedBox(height: 48),
            Text(
              _isProcessing ? 'Verifying Payment...' : 'Opening Secure Checkout...',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please do not close the app during the transaction.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildAmountPill(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryBrownGold.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.payment_rounded, size: 40, color: AppColors.primaryBrownGold),
    );
  }

  Widget _buildAmountPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL PAYABLE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildProcessingIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrownGold.withOpacity(0.2)),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrownGold),
          ),
        ),
        const Icon(Icons.security_rounded, size: 40, color: Color(0xFF1E293B)),
      ],
    );
  }
}
