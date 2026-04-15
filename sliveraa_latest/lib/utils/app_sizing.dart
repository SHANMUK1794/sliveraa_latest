import 'package:flutter/material.dart';

/// Responsive sizing helper for Silvra.
/// Scales values relative to a 390×844 design baseline (iPhone 14 / Pixel 7).
/// Works across Android and iOS — small phones, large phones, and tablets.
class AppSizing {
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  final double _screenWidth;
  final double _screenHeight;
  final double _pixelRatio;

  AppSizing._(this._screenWidth, this._screenHeight, this._pixelRatio);

  factory AppSizing.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AppSizing._(mq.size.width, mq.size.height, mq.devicePixelRatio);
  }

  /// Scale a width value designed for 390px wide screen
  double w(double value) => value * (_screenWidth / _designWidth);

  /// Scale a height value designed for 844px tall screen
  double h(double value) => value * (_screenHeight / _designHeight);

  /// Scale a font/icon size (uses width ratio, capped for readability)
  double sp(double value) {
    final ratio = _screenWidth / _designWidth;
    // Cap scale at 1.3x to prevent overly huge text on tablets
    return value * ratio.clamp(0.75, 1.3);
  }

  /// Responsive padding — adapts horizontal padding to screen width
  double get horizontalPadding => w(24).clamp(16.0, 40.0);

  /// Screen dimensions
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  /// Whether the screen is a small phone (< 360dp wide, e.g. Galaxy A series)
  bool get isSmallPhone => _screenWidth < 360;

  /// Whether the screen is a tablet (> 600dp wide)
  bool get isTablet => _screenWidth > 600;

  /// Adaptive font size — smaller on small phones, caps on tablets
  double adaptiveFontSize(double base) {
    if (isSmallPhone) return (base * 0.88).clamp(10.0, base);
    if (isTablet) return (base * 1.1).clamp(base, base * 1.3);
    return base;
  }
}
