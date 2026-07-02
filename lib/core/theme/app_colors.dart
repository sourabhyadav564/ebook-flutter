import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary   = Color(0xFFC8955A);   // Warm amber — bookshelf wood
  static const secondary = Color(0xFF8B5E3C);   // Deep wood brown
  static const accent    = Color(0xFFE8C49A);   // Parchment highlight

  // Dark theme surfaces
  static const bgDark      = Color(0xFF1A1210);  // Near-black warm
  static const surfaceDark = Color(0xFF2A1F1A);  // Dark wood panel
  static const cardDark    = Color(0xFF3D2B22);  // Shelf card surface

  // Text
  static const textPrimary   = Color(0xFFF5ECD7); // Warm white
  static const textSecondary = Color(0xFFB09070); // Muted parchment

  // Status
  static const success = Color(0xFF4CAF82);
  static const error   = Color(0xFFE05C5C);
  static const warning = Color(0xFFE8A343);

  // File type badges
  static const pdfBadge  = Color(0xFFE05C5C);
  static const epubBadge = Color(0xFF4C8AE0);
}
