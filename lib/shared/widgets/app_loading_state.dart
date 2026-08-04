import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class AppLoadingState extends StatelessWidget {
  final int itemCount;
  final double height;
  final double width;

  const AppLoadingState({
    super.key,
    this.itemCount = 3,
    this.height = 80,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: isDark ? AppColors.darkSurface2 : AppColors.gray200,
            highlightColor: isDark ? AppColors.darkSurface3 : AppColors.gray100,
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
