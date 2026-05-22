import 'package:flutter/material.dart';

class NewsThemeExtension extends ThemeExtension<NewsThemeExtension> {
  final Color brandPrimary;
  final Color brandAccent;
  final Color offlineBannerColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final double cardRadius;
  final double cardElevation;

  const NewsThemeExtension({
    required this.brandPrimary,
    required this.brandAccent,
    required this.offlineBannerColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    required this.cardRadius,
    required this.cardElevation,
  });


  @override
  NewsThemeExtension lerp(NewsThemeExtension? other, double t) {
    if (other is! NewsThemeExtension) return this;
    return NewsThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      offlineBannerColor:
      Color.lerp(offlineBannerColor, other.offlineBannerColor, t)!,
      shimmerBaseColor:
      Color.lerp(shimmerBaseColor, other.shimmerBaseColor, t)!,
      shimmerHighlightColor:
      Color.lerp(shimmerHighlightColor, other.shimmerHighlightColor, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t)!,
    );
  }

  @override
  NewsThemeExtension copyWith({
    Color? brandPrimary,
    Color? brandAccent,
    Color? offlineBannerColor,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    double? cardRadius,
    double? cardElevation,
  }) {
    return NewsThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      offlineBannerColor: offlineBannerColor ?? this.offlineBannerColor,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
      shimmerHighlightColor ?? this.shimmerHighlightColor,
      cardRadius: cardRadius ?? this.cardRadius,
      cardElevation: cardElevation ?? this.cardElevation,
    );
  }

  static const light = NewsThemeExtension(
    brandPrimary: Color(0xFF1A73E8),
    brandAccent: Color(0xFF34A853),
    offlineBannerColor: Color(0xFFEA4335),
    shimmerBaseColor: Color(0xFFE0E0E0),
    shimmerHighlightColor: Color(0xFFF5F5F5),
    cardRadius: 12.0,
    cardElevation: 2.0,
  );

  static const dark = NewsThemeExtension(
    brandPrimary: Color(0xFF82B1FF),
    brandAccent: Color(0xFF69F0AE),
    offlineBannerColor: Color(0xFFCF6679),
    shimmerBaseColor: Color(0xFF2A2A2A),
    shimmerHighlightColor: Color(0xFF3A3A3A),
    cardRadius: 12.0,
    cardElevation: 4.0,
  );
}

double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}