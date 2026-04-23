import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfdropcheckoutcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../invest/payment_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final String paymentSessionId;
  final String environment;
  final bool isGold;
  final double grams;

  const PaymentScreen({
    super.key, 
    required this.amount,
    required this.orderId,
    required this.paymentSessionId,
    required this.environment,
    required this.isGold,
    required this.grams,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var cfPaymentGatewayService = CFPaymentGatewayService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  void _startPayment() {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(widget.environment == 'PRODUCTION' ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX)
          .setOrderId(widget.orderId)
          .setPaymentSessionId(widget.paymentSessionId)
          .build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor(widget.isGold ? "#CAA779" : "#1E293B")
          .setPrimaryFont("Inter")
          .setPrimaryTextColor("#FFFFFF")
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session!)
          .setTheme(theme!)
          .setComponent(CFDropCheckoutComponentBuilder().build())
          .build();

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      debugPrint("Cashfree initialization error: ${e.message}");
      _showError(e.message ?? 'Failed to open payment gateway');
    } catch (e) {
      debugPrint("Cashfree error: $e");
      _showError('Unexpected error occurred');
    }
  }

  void verifyPayment(String orderId) async {
    setState(() => _isProcessing = true);
    try {
      // Verify payment status on backend
      final verifyResponse = await ApiService().verifyPayment({
        'orderId': orderId,
      });

      if (verifyResponse.data['success'] == true) {
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
        throw Exception(verifyResponse.data['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      _showError('Verification Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    setState(() => _isProcessing = false);
    
    String message = errorResponse.getMessage() ?? 'Payment could not be completed.';

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isProcessing ? const CircularProgressIndicator(color: AppColors.primaryBrownGold) : Icon(Icons.payment_rounded, size: 60, color: AppColors.primaryBrownGold),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
