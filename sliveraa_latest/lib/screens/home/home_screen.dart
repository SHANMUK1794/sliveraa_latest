import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/price_provider.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../utils/price_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_bottom_navbar.dart';

import 'price_trends_screen.dart';
import 'notifications_screen.dart';
import '../invest/invest_screen.dart';
import '../invest/summary_screen.dart';
import '../invest/wealth_calculator.dart';
import '../invest/savings_plan_screen.dart';
import '../rewards/rewards_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../portfolio/withdraw_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/referral_screen.dart';
import '../support/concierge_support_screen.dart';
import '../profile/support_screen.dart';
import '../delivery/delivery_screen.dart';
import '../history/history_screen.dart';
import '../../core/api_service.dart';

// Format helper since formatRupee was from an unknown import in the original file.
String formatRupee(double amount) {
  return NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(amount);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isGoldSelected = true;
  double get goldBalance => AppState().goldGrams;
  double get silverBalance => AppState().silverGrams;
  String selectedAmount = '₹2,000';
  
  bool showGoldPrice = true;
  late Timer _priceTimer;

  @override
  void initState() {
    super.initState();
    _startPriceTimer();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final profileResponse = await ApiService().getUserProfile();
      AppState().updateFromMap({'user': profileResponse.data});
      
      final txResponse = await ApiService().getTransactions();
      AppState().updateTransactions(txResponse.data);
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
    }
  }

  void _startPriceTimer() {
    _priceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          showGoldPrice = !showGoldPrice;
        });
      }
    });
  }

  @override
  void dispose() {
    _priceTimer.cancel();
    super.dispose();
  }

  Future<void> _checkKycAndNavigate(Widget screen) async {
    final status = context.read<AppState>().kycStatus;
    if (status == "VERIFIED") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } else {
      _showKycRequiredDialog(screen);
    }
  }

  void _showKycRequiredDialog(Widget targetScreen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF5EDE3), shape: BoxShape.circle),
              child: Icon(Icons.verified_user_outlined, color: AppColors.primaryBrownGold, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'KYC Required',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Compliance verification is mandatory for investing, withdrawing, or requesting physical delivery.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const KycScreen()));
                  _fetchInitialData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Verify Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Later',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for status changes to update UI instantly
    context.watch<AppState>();
    
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Prevents app from closing
        }
        return true; // Allows app to close if on Home tab
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: _buildCurrentTabContent(),
        bottomNavigationBar: CustomBottomNavbar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const PriceTrendsScreen(hideBackButton: true);
      case 2:
        return PortfolioScreen(
          goldBalance: goldBalance, 
          silverBalance: silverBalance,
          hideBottomNav: true,
        );
      case 3:
        return const RewardsScreen(hideBackButton: true);
      case 4:
        return const HistoryScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    double topPadding = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: topPadding + 16),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWelcomeSection(),
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildQuickSave(),
          _buildQuickActions(),
          _buildSavingPlans(),
          _buildReferralBanner(),
          _buildRecommendedSection(),
          _buildSupportBanner(),
          _buildPartnersFooter(),
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final priceProvider = Provider.of<PriceProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8A27B), Color(0xFFD2B494)],
                ),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ),
          
          // Centered Dynamic Pill
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _PulsatingDot(),
                        const SizedBox(width: 8),
                        Container(
                          height: 16,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              final isEnteringGold = (child.key as ValueKey<bool>).value;
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: isEnteringGold ? const Offset(0.0, -1.0) : const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: Text(
                              showGoldPrice 
                                ? '₹${formatRupee(priceProvider.goldPrice)}/gm' 
                                : '₹${formatRupee(priceProvider.silverPrice)}/gm',
                              key: ValueKey<bool>(showGoldPrice),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF111827),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icons Right
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFFC8A27B), size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConciergeSupportScreen())),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFFC8A27B), size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hey ',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  AppState().userName.isNotEmpty ? '${AppState().userName}!' : 'Venu!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.primaryBrownGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Let's Start Saving",
            style: GoogleFonts.manrope(
              color: const Color(0xFF111827),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Build your gold wealth consistently',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final priceProvider = Provider.of<PriceProvider>(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBrownGold, AppColors.secondaryBrownGold], 
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryBrownGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Toggle Buttons
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildToggleButton('Gold', isGoldSelected, () => setState(() => isGoldSelected = true)),
                    _buildToggleButton('Silver', !isGoldSelected, () => setState(() => isGoldSelected = false)),
                  ],
                ),
              ),
              // Percentage Pill removed per user request
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Balance',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${formatRupee(isGoldSelected ? (goldBalance * priceProvider.goldPrice) : (silverBalance * priceProvider.silverPrice))}',
                style: GoogleFonts.manrope(
                  color: Colors.white, 
                  fontSize: 34, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _checkKycAndNavigate(WithdrawScreen(isGoldInitial: isGoldSelected)),
                  child: _buildCardButton(
                    'Withdraw', 
                    Colors.white.withOpacity(0.2), 
                    Colors.white, 
                    Icons.add, // User's image looks like a plus
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _checkKycAndNavigate(SavingsPlanScreen(isGoldInitial: isGoldSelected)),
                  child: _buildCardButton(
                    'Start Saving', 
                    Colors.white, 
                    const Color(0xFFB08C65), 
                    Icons.pie_chart_outline_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFFA6845B) : Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(String label, Color bg, Color text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: text),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: text, 
              fontSize: 14, 
              fontWeight: FontWeight.w700
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSave() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'QUICK SAVE',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8), 
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 1.2
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 20, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swipe to Save in ${isGoldSelected ? 'gold' : 'silver'}',
                style: GoogleFonts.manrope(
                  fontSize: 16, 
                  fontWeight: FontWeight.w800, 
                  color: const Color(0xFF111827)
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Instantly move money to your secure vault!',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8), 
                  fontSize: 12,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 24),
              _buildSwipeSlider(),
              const SizedBox(height: 24),
              Row(
                children: ['₹500', '₹1,000', '₹2,000', '₹5,000'].map((e) {
                  bool isSelected = e == selectedAmount;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedAmount = e),
                      child: Container(
                        margin: EdgeInsets.only(right: e == '₹5,000' ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFC8A27B) : const Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          e,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSwipeSlider() {
    double swipeWidth = MediaQuery.of(context).size.width - 88; 
    return Container(
      height: 52,
      width: swipeWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Slide to Invest $selectedAmount',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8), 
                fontSize: 13, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          // Removed the lock icon purely for UX, as it now triggers a popup on swipe
          Positioned(
            left: 4,
            top: 4,
            bottom: 4,
            child: Draggable(
              axis: Axis.horizontal,
              onDragEnd: (details) async {
                if (details.offset.dx > swipeWidth * 0.6) {
                  final appState = context.read<AppState>();
                  if (appState.kycStatus == "VERIFIED") {
                    double amountValue = double.parse(selectedAmount.replaceAll('₹', '').replaceAll(',', ''));
                    double netAmount = amountValue / 1.03;
                    double price = isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SummaryScreen(
                        isGold: isGoldSelected, 
                        amount: amountValue, 
                        grams: netAmount / price,
                      )),
                    );
                  } else {
                    _showKycRequiredDialog(SummaryScreen(
                      isGold: isGoldSelected, 
                      amount: 0, // Placeholder as KYC is needed first
                      grams: 0,
                    ));
                  }
                }
              },
              feedback: _buildSwipeHandle(),
              childWhenDragging: Opacity(opacity: 0.5, child: _buildSwipeHandle()),
              child: _buildSwipeHandle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHandle() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFC6A17A),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 20),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8), 
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionItem(
                Icons.monetization_on, // Or a custom gold coin
                'Buy Gold', 
                const Color(0xFFFDE68A), 
                Colors.white,
                () => _checkKycAndNavigate(const PriceTrendsScreen(initialIsGold: true)),
                solidIconBg: true,
                bgOverride: const Color(0xFFFBBF24)
              ),
              _buildActionItem(
                Icons.monetization_on, 
                'Buy Silver', 
                const Color(0xFFE2E8F0), 
                Colors.white,
                () => _checkKycAndNavigate(const PriceTrendsScreen(initialIsGold: false)),
                solidIconBg: true,
                bgOverride: const Color(0xFF94A3B8)
              ),
              _buildActionItem(
                Icons.calculate_outlined, 
                'Calculator', 
                const Color(0xFFF1F5F9), 
                const Color(0xFF94A3B8),
                () => _checkKycAndNavigate(const WealthCalculator()),
              ),
              _buildActionItem(
                Icons.local_shipping_outlined, 
                'Delivery', 
                const Color(0xFFF1F5F9), 
                const Color(0xFF94A3B8),
                () => _checkKycAndNavigate(const DeliveryScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap, {bool solidIconBg = false, Color? bgOverride}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4)
                )
              ],
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: solidIconBg ? bgOverride : bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label, 
            style: GoogleFonts.inter(
              fontSize: 11, 
              fontWeight: FontWeight.w700, 
              color: const Color(0xFF111827)
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSavingPlans() {
    final plans = [
      {'title': 'Save Daily', 'subtitle': 'Starts from just ₹10/day', 'icon': Icons.calendar_today_rounded, 'color': const Color(0xFFB57BF4), 'freq': 'Daily'},
      {'title': 'Save Weekly', 'subtitle': 'Starts from just ₹50/week', 'icon': Icons.event_available_rounded, 'color': const Color(0xFF4ADE80), 'freq': 'Weekly'},
      {'title': 'Save Monthly', 'subtitle': 'Starts from just ₹100/month', 'icon': Icons.pie_chart_rounded, 'color': const Color(0xFFE5B55A), 'freq': 'Monthly'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Gold ', style: GoogleFonts.manrope(color: const Color(0xFFC8A27B), fontSize: 20, fontWeight: FontWeight.w800)),
              Text('Saving Plans', style: GoogleFonts.manrope(color: const Color(0xFF111827), fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...plans.map((e) => _buildPlanItem(
                e['title'] as String,
                e['subtitle'] as String,
                e['icon'] as IconData,
                e['color'] as Color,
                () {
                  _checkKycAndNavigate(SavingsPlanScreen(isGoldInitial: true, initialFrequency: e['freq'] as String));
                },
              )),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String title, String subtitle, IconData icon, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.manrope(
                      fontSize: 16, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.white
                    )
                  ),
                  Text(
                    subtitle, 
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE8E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Grow Together with\n',
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827), height: 1.3),
                ),
                TextSpan(
                  text: 'Silvra',
                  style: GoogleFonts.manrope(color: const Color(0xFFC8A27B), fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Turn your connections into gold. Invite\nfriends and build wealth side by side.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B), 
                fontSize: 12, 
                height: 1.5,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _checkKycAndNavigate(const ReferralScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFC4A076),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start Referring, Start Earning',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recommended for you', 
            style: GoogleFonts.manrope(
              fontSize: 16, 
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827)
            )
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 290,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            children: [
              _buildNewsCard('Top 5 Tech Stocks to Watch in Q3 2024', 'Understand how the latest AI developments are shaping the market...', 'ARTICLE'),
              _buildNewsCard('New Sustainability Trends in Gold Mining', 'Invest in the future with green energy portfolio insights...', 'INVESTMENT'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String desc, String tag) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: tag == 'ARTICLE' 
                  ? const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1618409019667-c107590aa511?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                    )
                  : null,
            ),
            child: Center(
              child: tag == 'ARTICLE' ? Text(
                'INSIGHT', 
                style: GoogleFonts.manrope(
                  color: Colors.white, 
                  fontSize: 24, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                )
              ) : const SizedBox(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tag == 'ARTICLE' ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7), 
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag, 
                    style: GoogleFonts.inter(
                      color: tag == 'ARTICLE' ? const Color(0xFFD97706) : const Color(0xFF16A34A), 
                      fontSize: 9, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5
                    )
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title, 
                  maxLines: 2,
                  style: GoogleFonts.manrope(
                    fontSize: 14, 
                    fontWeight: FontWeight.w800, 
                    height: 1.3,
                    color: const Color(0xFF111827)
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  desc, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8), 
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConciergeSupportScreen())),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF6EFEB), 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFB08C65), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support', 
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    "Need help? We're online", 
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8), 
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EFEB), 
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '11AM - 8PM', 
                style: GoogleFonts.inter(
                  color: const Color(0xFFB08C65), 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800
                )
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPartnerLogo('AUGMONT', 'Gold Partner'),
              _buildPartnerLogo('SEQUEL', 'Logistics Partner'),
              _buildPartnerLogo('RAZORPAY', 'Payments'),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6EFEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, size: 16, color: Color(0xFFB08C65)),
              ),
              const SizedBox(height: 8),
              Text(
                '100% Secure', 
                style: GoogleFonts.inter(
                  color: const Color(0xFF111827), 
                  fontSize: 11, 
                  fontWeight: FontWeight.w800
                )
              ),
              Text(
                'Safe & Trusted', 
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8), 
                  fontSize: 10, 
                  fontWeight: FontWeight.w500
                )
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8A27B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Save in ',
                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: 'Gold. ',
                        style: GoogleFonts.inter(color: const Color(0xFFC8A27B), fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: 'Grow with Confidence.',
                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ]
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String name, String sub) {
    return Column(
      children: [
        Text(
          name, 
          style: GoogleFonts.inter(
            fontSize: 8, 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFF94A3B8),
            letterSpacing: 1
          )
        ),
        Text(
          sub, 
          style: GoogleFonts.inter(
            fontSize: 7, 
            color: const Color(0xFFCBD5E1),
            fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}

class _PulsatingDot extends StatefulWidget {
  const _PulsatingDot();

  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }@override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for KYC status changes to instantly update Home Screen buttons
    context.watch<AppState>();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5 * (1 - _controller.value)),
                blurRadius: 10 * _controller.value,
                spreadRadius: 5 * _controller.value,
              )
            ],
          ),
        );
      },
    );
  }
}
