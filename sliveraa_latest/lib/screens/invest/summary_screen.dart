import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/extensions.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../home/payment_screen.dart';

class SummaryScreen extends StatefulWidget {
  final bool isGold;
  final double amount;
  final double grams;

  const SummaryScreen({
    super.key, 
    required this.isGold, 
    required this.amount, 
    required this.grams
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isLoading = false;

  Future<void> _initiateOrder() async {
    setState(() => _isLoading = true);
    try {
      final state = context.read<AppState>();
      final response = await ApiService().createOrder(
        widget.amount, // Total amount (Inclusive of 3% GST)
        widget.isGold ? 'GOLD' : 'SILVER',
        widget.grams,
        state.userId,
      );

      if (mounted) {
        if (response.data['success'] == true) {
          final orderId = response.data['orderId'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentScreen(
              amount: widget.amount,
              orderId: orderId,
              isGold: widget.isGold,
              grams: widget.grams,
            )),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Failed to create order')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inclusive GST Logic: widget.amount is the TOTAL paid by user
    double total = widget.amount;
    double baseValue = total / 1.03;
    double gst = total - baseValue;
    String metal = widget.isGold ? 'gold' : 'silver';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Summary',
          style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              color: widget.isGold ? const Color(0xFFF5EDE3) : const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${(baseValue/widget.grams).toStringAsFixed(2)}/gm (Excl. 3% GST)',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrownGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Live price',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildRow('${metal.characters.first.toUpperCase() + metal.substring(1)} quantity', '${widget.grams.toStringAsFixed(widget.isGold ? 3 : 1)}gm'),
                  const SizedBox(height: 24),
                  _buildRow('${metal.characters.first.toUpperCase() + metal.substring(1)} value', '₹${baseValue.toLocaleString()}'),
                  const SizedBox(height: 24),
                  _buildRow('GST (3%)', '₹${gst.toLocaleString()}'),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 2),
                  const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total payable amount',
                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${total.toLocaleString()}',
                              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _initiateOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Next',
                      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
          ),
        ),
      ],
    );
  }
}
