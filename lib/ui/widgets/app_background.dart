import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkBackgroundStart,
                      AppColors.darkBackgroundMiddle,
                      AppColors.darkBackgroundEnd,
                    ]
                  : [
                      AppColors.lightBackgroundStart,
                      AppColors.lightBackgroundMiddle,
                      AppColors.lightBackgroundEnd,
                    ],
            ),
          ),
        ),
        
        // Bubbles (Static for now, imitating the layout)
        if (isDark) ...[
          _buildBubble(top: 100, left: 50, size: 80, color: AppColors.primaryLight.withOpacity(0.05)),
          _buildBubble(top: 300, right: 30, size: 120, color: AppColors.primaryLight.withOpacity(0.03)),
          _buildBubble(bottom: 150, left: 80, size: 60, color: AppColors.primaryLight.withOpacity(0.04)),
          _buildBubble(bottom: 50, right: 100, size: 90, color: AppColors.primaryLight.withOpacity(0.05)),
        ] else ...[
          _buildBubble(top: 100, left: 50, size: 80, color: Colors.white.withOpacity(0.1)),
          _buildBubble(top: 300, right: 30, size: 120, color: Colors.white.withOpacity(0.1)),
          _buildBubble(bottom: 150, left: 80, size: 60, color: Colors.white.withOpacity(0.1)),
          _buildBubble(bottom: 50, right: 100, size: 90, color: Colors.white.withOpacity(0.1)),
        ],

        // Content
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildBubble({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
