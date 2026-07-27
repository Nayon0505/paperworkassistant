import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.showWordmark = true, this.light = false});

  final bool showWordmark;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? AppColors.white : AppColors.navy950;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: light ? AppColors.white : AppColors.navy900,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            Icons.article_outlined,
            size: 22,
            color: light ? AppColors.navy900 : AppColors.white,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: AppSpacing.sm + 2),
          Text(
            'Paperwork',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ],
    );
  }
}
