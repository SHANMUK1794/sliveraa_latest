import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../utils/extensions.dart';

class RewardsScreen extends StatefulWidget {
  final bool hideBackButton;

  const RewardsScreen({super.key, this.hideBackButton = false});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _wheelLabels = [
    '10%',
    'GOLD',
    '25',
    'FREE',
    '10%',
    '100',
    '5%',
    '50',
  ];

  late final AnimationController _controller;
  late Animation<double> _animation;

  double _rotation = 0.0;
  bool _isSpinning = false;
  String _wonItem = '';

  String _getWinMessage(String item) {
    if (item.contains('%')) {
      return 'You won a $item discount coupon!';
    } else if (item == 'FREE') {
      return 'You won a FREE Mystery Box!';
    } else if (item == 'GOLD') {
      return 'You won 1mg of 24K GOLD!';
    } else if (item.isNotEmpty) {
      return 'You won $item Aura Coins!';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    _animation = AlwaysStoppedAnimation(_rotation);

    _controller.addListener(() {
      setState(() {
        _rotation = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _claimRewardAndShowDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;

    final targetIndex = math.Random().nextInt(_wheelLabels.length);
    final segmentAngle = (2 * math.pi) / _wheelLabels.length;
    final normalizedStart = _rotation % (2 * math.pi);
    final targetAngle = -(targetIndex * segmentAngle) - (segmentAngle / 2);
    final totalRotation = normalizedStart + (2 * math.pi * 6) + targetAngle;

    setState(() {
      _isSpinning = true;
      _wonItem = _wheelLabels[targetIndex];
    });

    _animation = Tween<double>(
      begin: normalizedStart,
      end: totalRotation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    await _controller.forward(from: 0);
  }

  Future<void> _claimRewardAndShowDialog() async {
    try {
      final response = await ApiService().claimSpinReward(_wonItem);
      if (response.data['success'] == true) {
        // Refresh profile to get updated points/gold
        final profileResponse = await ApiService().getUserProfile();
        if (profileResponse.data != null) {
          AppState().updateFromMap(profileResponse.data);
        }
      }
    } catch (e) {
      debugPrint('Error claiming spin reward: $e');
    }
    
    if (mounted) {
      _showWinDialog();
    }
  }

  void _showInfoMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showWinDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4E6D6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFB38252),
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Congratulations!',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF181818),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getWinMessage(_wonItem),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7B7B7B),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2AF86),
                    foregroundColor: const Color(0xFF241A12),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'AWESOME!',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 58,
        leadingWidth: widget.hideBackButton ? 0 : 44,
        leading: widget.hideBackButton
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 6),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ),
        title: Text(
          'Rewards',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF191919),
          ),
        ),
        centerTitle: true,
        actions: [
          _buildPointsPill(),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            _buildBalanceCard(),
            const SizedBox(height: 18),
            _buildSpinAndWinSection(),
            const SizedBox(height: 16),
            _buildSpendRewardsSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7ECDF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            size: 12,
            color: Color(0xFFD1AE86),
          ),
          const SizedBox(width: 4),
          Text(
            AppState().auraPoints.toLocaleString(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD1AE86),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4B287),
            Color(0xFFC7A277),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCAA77F).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -6,
            child: Opacity(
              opacity: 0.14,
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL AURA COINS',
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5C442C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppState().auraPoints.toLocaleString(),
                    style: GoogleFonts.manrope(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF171717),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'pts',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF171717),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tier: Gold Member',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6A4F34),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _showInfoMessage('Reward history will be available here.'),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2217),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 24),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'HISTORY',
                      style: GoogleFonts.manrope(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
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

  Widget _buildSpinAndWinSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wheelSize = math.min(300.0, width * 0.83);
        final contentLeft = width * 0.53;
        final pointerSize = 19.0;

        return SizedBox(
          height: wheelSize + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -(wheelSize * 0.52),
                top: 0,
                child: Transform.rotate(
                  angle: _rotation,
                  child: SizedBox(
                    width: wheelSize,
                    height: wheelSize,
                    child: CustomPaint(
                      painter: _WheelPainter(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: contentLeft - 18,
                top: (wheelSize / 2) - (pointerSize / 2),
                child: Container(
                  width: pointerSize,
                  height: pointerSize,
                  transform: Matrix4.rotationZ(math.pi / 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3AF86),
                    border: Border.all(
                      color: const Color(0xFF5B4328),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: contentLeft + 8,
                right: 18,
                top: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY\nSPIN &\nWIN',
                      style: GoogleFonts.manrope(
                        fontSize: width < 360 ? 19 : 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF181818),
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 92,
                      child: Text(
                        'Try your luck to\nwin pure gold\ncoins!',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC7A98C),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSpinning ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3AF86),
                        foregroundColor: const Color(0xFF2D2116),
                        disabledBackgroundColor: const Color(0xFFE3D3BF),
                        disabledForegroundColor: const Color(0xFF8A735A),
                        minimumSize: const Size(78, 56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        elevation: 0,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        _isSpinning ? 'SPINNING' : 'SPIN\nNOW',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: _isSpinning ? 10 : 14,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Spend Your Rewards',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF181818),
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    _showInfoMessage('More rewards will appear here soon.'),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD6B58D),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _RewardItem(
                title: '1g 24K Gold Coin',
                points: '5,000',
                retail: 'Retail: \$60.00',
                isExclusive: true,
                tone: _RewardTone.gold,
                onRedeem: () =>
                    _showInfoMessage('1g 24K Gold Coin redeem flow coming soon.'),
              ),
              _RewardItem(
                title: '10g Silver Bar',
                points: '2,500',
                retail: 'Retail: \$43.00',
                isExclusive: false,
                tone: _RewardTone.silver,
                onRedeem: () =>
                    _showInfoMessage('10g Silver Bar redeem flow coming soon.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String title;
  final String points;
  final String retail;
  final bool isExclusive;
  final _RewardTone tone;
  final VoidCallback onRedeem;

  const _RewardItem({
    required this.title,
    required this.points,
    required this.retail,
    required this.isExclusive,
    required this.tone,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF081116),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _CoinArtwork(tone: tone),
              ),
              if (isExclusive)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5C66A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EXCLUSIVE',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF171717),
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191919),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            points,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFD7A46F),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            retail,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFC3C3C3),
              decoration: TextDecoration.lineThrough,
              decorationColor: const Color(0xFFC3C3C3),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onRedeem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3AF86),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'REDEEM',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  static const _colors = [
    Color(0xFF312815),
    Color(0xFFFFFFFF),
    Color(0xFF5B4E25),
    Color(0xFF2A2412),
    Color(0xFF40351A),
    Color(0xFF4E4220),
    Color(0xFF312915),
    Color(0xFF5C5128),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * math.pi) / _RewardsScreenState._wheelLabels.length;

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = const Color(0xFFD2AF86);

    for (var i = 0; i < _RewardsScreenState._wheelLabels.length; i++) {
      final startAngle = (-math.pi / 2) + (i * segmentAngle);
      fillPaint.color = _colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        fillPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: _RewardsScreenState._wheelLabels[i],
          style: GoogleFonts.manrope(
            fontSize: _RewardsScreenState._wheelLabels[i].length <= 2 ? 15 : 13,
            fontWeight: FontWeight.w900,
            color: _colors[i] == Colors.white
                ? const Color(0xFFD0A97D)
                : const Color(0xFFD4B075),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelAngle = startAngle + (segmentAngle / 2);
      final labelRadius = radius * 0.61;

      canvas.save();
      canvas.translate(
        center.dx + (labelRadius * math.cos(labelAngle)),
        center.dy + (labelRadius * math.sin(labelAngle)),
      );
      canvas.rotate(labelAngle + (math.pi / 2));
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    canvas.drawCircle(center, radius - 3.5, strokePaint);

    final hubFill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1D160E);
    final hubStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFD2AF86);

    canvas.drawCircle(center, 20, hubFill);
    canvas.drawCircle(center, 14, hubStroke);
    canvas.drawCircle(center, 5.5, Paint()..color = const Color(0xFFD2AF86));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _RewardTone {
  gold,
  silver,
}

class _CoinArtwork extends StatelessWidget {
  final _RewardTone tone;

  const _CoinArtwork({required this.tone});

  @override
  Widget build(BuildContext context) {
    final isGold = tone == _RewardTone.gold;

    final outerColors = isGold
        ? [
            const Color(0xFFF7D97B),
            const Color(0xFFC18C2C),
            const Color(0xFFF0C85A),
          ]
        : [
            const Color(0xFFF3F6F8),
            const Color(0xFFACB5BA),
            const Color(0xFFDDE4E8),
          ];

    final innerColors = isGold
        ? [
            const Color(0xFF6F5117),
            const Color(0xFFE0BA51),
          ]
        : [
            const Color(0xFF929DA3),
            const Color(0xFFE9EEF1),
          ];

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: outerColors),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: innerColors,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isGold
                    ? const Color(0xFFF4DA8B)
                    : const Color(0xFFD5DDE1),
                width: 1.4,
              ),
            ),
          ),
          Text(
            'S',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: isGold
                  ? const Color(0xFFF9E6A7)
                  : const Color(0xFFF7FAFB),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
