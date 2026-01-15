import 'package:flutter/material.dart';

/// Breakpoints untuk responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// Extension untuk BuildContext untuk memudahkan pengecekan responsive
extension ResponsiveExtension on BuildContext {
  /// Lebar layar saat ini
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Tinggi layar saat ini
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Apakah layar mobile (< 600px)
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Apakah layar tablet (600px - 1024px)
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Apakah layar desktop (>= 1024px)
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Apakah layar mobile atau tablet
  bool get isMobileOrTablet => screenWidth < Breakpoints.tablet;

  /// Apakah dalam mode landscape
  bool get isLandscape => screenWidth > screenHeight;

  /// Apakah layar memiliki tinggi terbatas (landscape mobile)
  /// Biasanya terjadi saat handphone dalam mode landscape
  bool get isCompactHeight => screenHeight < 500;

  /// Apakah mobile dalam landscape mode (perlu layout khusus)
  bool get isMobileLandscape => isLandscape && screenHeight < 500;

  // =============================================
  // LANDSCAPE SCALING FACTORS
  // Scale down sizes when in compact landscape mode
  // =============================================

  /// Scale factor for general layout (padding, margins, spacing)
  /// Returns 0.75 in compact landscape, 1.0 otherwise
  double get landscapeScale => isCompactHeight ? 0.75 : 1.0;

  /// Scale factor for fonts - slightly less aggressive
  /// Returns 0.85 in compact landscape, 1.0 otherwise
  double get fontScale => isCompactHeight ? 0.85 : 1.0;

  /// Scale factor for icons and small components
  /// Returns 0.8 in compact landscape, 1.0 otherwise
  double get iconScale => isCompactHeight ? 0.8 : 1.0;

  /// Get scaled padding value
  double scaledPadding(double base) => base * landscapeScale;

  /// Get scaled font size
  double scaledFontSize(double base) => base * fontScale;

  /// Get scaled icon size
  double scaledIconSize(double base) => base * iconScale;

  /// Get responsive padding based on device
  EdgeInsets get responsivePadding =>
      EdgeInsets.all(isCompactHeight ? 8.0 : (isMobile ? 12.0 : 16.0));

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding => EdgeInsets.symmetric(
    horizontal: isCompactHeight ? 8.0 : (isMobile ? 12.0 : 16.0),
  );
}

/// Widget builder untuk responsive layout
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet)
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Breakpoints.mobile;
        final isTablet =
            constraints.maxWidth >= Breakpoints.mobile &&
            constraints.maxWidth < Breakpoints.tablet;
        return builder(context, isMobile, isTablet);
      },
    );
  }
}

/// Widget yang menampilkan konten berbeda berdasarkan ukuran layar
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mobile) {
          return mobile;
        } else if (constraints.maxWidth < Breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}
