import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../invest/payment_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final bool isGold;
  final double grams;
  final String? method; // Pre-selected method (card, upi, netbanking)

  const PaymentScreen({
    super.key, 
    required this.amount,
    required this.orderId,
    required this.isGold,
    required this.grams,
    this.method,
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
        'contact': _formatPhone(state.userPhone),
        'email': state.userEmail,
        if (widget.method != null) 'method': widget.method,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': widget.isGold ? '#CAA779' : '#1E293B',
      },
      'modal': {
        'confirm_close': true,
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
        if (mounted) {
          await context.read<AppState>().refreshStatus();
        }
        
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
    
    // Using official Razorpay error constants for better reliability
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      message = 'Payment was cancelled. You can try again whenever you are ready.';
    } else if (response.code == Razorpay.NETWORK_ERROR) {
      message = 'Connection issue. Please check your internet and try again.';
    } else if (response.code == Razorpay.INVALID_OPTIONS) {
      message = 'Technical error: Invalid payment options. Please contact support.';
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

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) return '+91$clean';
    if (!phone.startsWith('+')) return '+$clean';
    return phone;
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
        color: AppColors.primaryBrownGold.withValues(alpha: 0.1),
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
    return const _SecureHandshakeAnimation();
  }
}

class _SecureHandshakeAnimation extends StatefulWidget {
  const _SecureHandshakeAnimation();

  @override
  State<_SecureHandshakeAnimation> createState() => _SecureHandshakeAnimationState();
}

class _SecureHandshakeAnimationState extends State<_SecureHandshakeAnimation> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  int _iconIndex = 0;

  final List<IconData> _methodIcons = [
    Icons.credit_card_rounded,
    Icons.account_balance_rounded,
    Icons.qr_code_2_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() {
      int newIndex = ((_rotateController.value * _methodIcons.length) % _methodIcons.length).floor();
      if (newIndex != _iconIndex) {
        setState(() => _iconIndex = newIndex);
      }
    })..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsating Rings
        ...List.generate(2, (index) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              double val = (_pulseController.value + (index * 0.5)) % 1.0;
              return Container(
                width: 140 * val + 60,
                height: 140 * val + 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBrownGold.withValues(alpha: 0.3 * (1 - val)),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }),
        
        // Central Shield & Rotating Method Icons
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBrownGold.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 10,
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinning outer ring
              RotationTransition(
                turns: _rotateController,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBrownGold.withValues(alpha: 0.1),
                      width: 4,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 36,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBrownGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dynamic Icon Transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                },
                child: Icon(
                  _methodIcons[_iconIndex],
                  key: ValueKey(_iconIndex),
                  size: 36,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        // Shield badge in the corner
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
