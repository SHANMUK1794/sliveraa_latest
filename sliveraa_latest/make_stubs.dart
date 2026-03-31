import 'dart:io';

void main() {
  final stubs = {
    'lib/widgets/custom_bottom_navbar.dart': '''
import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Trends'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Portfolio'),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
''',
    'lib/widgets/price_chart.dart': '''
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('PriceChart Stub'));
  }
}
''',
    'lib/screens/invest/invest_screen.dart': '''
import 'package:flutter/material.dart';

class InvestScreen extends StatelessWidget {
  final bool isGold;
  const InvestScreen({super.key, required this.isGold});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Invest')), body: const Center(child: Text('Invest Stub')));
  }
}
''',
    'lib/screens/invest/summary_screen.dart': '''
import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final bool isGold;
  final double amount;
  final double grams;
  const SummaryScreen({super.key, required this.isGold, required this.amount, required this.grams});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Summary')), body: const Center(child: Text('Summary Stub')));
  }
}
''',
    'lib/screens/invest/wealth_calculator.dart': '''
import 'package:flutter/material.dart';

class WealthCalculator extends StatelessWidget {
  const WealthCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Calculator')), body: const Center(child: Text('Calculator Stub')));
  }
}
''',
    'lib/screens/invest/savings_plan_screen.dart': '''
import 'package:flutter/material.dart';

class SavingsPlanScreen extends StatelessWidget {
  final bool isGoldInitial;
  final String initialFrequency;
  const SavingsPlanScreen({super.key, required this.isGoldInitial, required this.initialFrequency});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Savings Plan')), body: const Center(child: Text('Savings Plan Stub')));
  }
}
''',
    'lib/screens/rewards/rewards_screen.dart': '''
import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  final bool hideBackButton;
  const RewardsScreen({super.key, this.hideBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: hideBackButton ? null : AppBar(title: const Text('Rewards')), body: const Center(child: Text('Rewards Stub')));
  }
}
''',
    'lib/screens/portfolio/portfolio_screen.dart': '''
import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  final double goldBalance;
  final double silverBalance;
  final bool hideBottomNav;
  const PortfolioScreen({super.key, required this.goldBalance, required this.silverBalance, this.hideBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: hideBottomNav ? null : AppBar(title: const Text('Portfolio')), body: const Center(child: Text('Portfolio Stub')));
  }
}
''',
    'lib/screens/portfolio/withdraw_screen.dart': '''
import 'package:flutter/material.dart';

class WithdrawScreen extends StatelessWidget {
  final bool isGoldInitial;
  const WithdrawScreen({super.key, required this.isGoldInitial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Withdraw')), body: const Center(child: Text('Withdraw Stub')));
  }
}
''',
    'lib/screens/profile/profile_screen.dart': '''
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: Text('Profile Stub')));
  }
}
''',
    'lib/screens/profile/kyc_screen.dart': '''
import 'package:flutter/material.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('KYC')), body: const Center(child: Text('KYC Stub')));
  }
}
''',
    'lib/screens/profile/referral_screen.dart': '''
import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Referrals')), body: const Center(child: Text('Referrals Stub')));
  }
}
''',
    'lib/screens/profile/support_screen.dart': '''
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Support')), body: const Center(child: Text('Support Stub')));
  }
}
''',
    'lib/screens/delivery/delivery_screen.dart': '''
import 'package:flutter/material.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Delivery')), body: const Center(child: Text('Delivery Stub')));
  }
}
''',
  };

  for (final entry in stubs.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
    print('Created \${entry.key}');
  }
}
