import 'package:flutter/material.dart';

import 'theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64, this.iconSize = 34});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(size * 0.3125),
        boxShadow: const [AppShadows.brandMark],
      ),
      child: Icon(
        Icons.shield_outlined,
        color: Colors.white,
        size: iconSize,
        strokeWidth: 1.8,
      ),
    );
  }
}