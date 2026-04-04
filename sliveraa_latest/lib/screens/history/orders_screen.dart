import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import 'delivery_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await AppState().fetchDeliveries();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = AppState().deliveries;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Orders',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBrownGold),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadOrders();
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrownGold))
        : orders.isEmpty 
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Request physical delivery of your gold or\nsilver to see them here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(DeliveryRequest order) {
    bool isGold = order.metalType == 'GOLD';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // For now, take to the tracking screen
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const DeliveryTrackingScreen())
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM, yyyy').format(order.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGold ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isGold ? Icons.stars_rounded : Icons.toll_rounded,
                        color: isGold ? const Color(0xFFD97706) : const Color(0xFF4B5563),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.weight}g Physical ${isGold ? "Gold" : "Silver"}',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.trackingId != null ? 'Tracking: ${order.trackingId}' : 'Processing in vault',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return const Color(0xFFF59E0B);
      case 'SHIPPED': return const Color(0xFF3B82F6);
      case 'DELIVERED': return const Color(0xFF10B981);
      case 'CANCELLED': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }
}
