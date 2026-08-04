import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? photoBase64;
  final String name;
  final double radius;
  final bool showOnlineIndicator;
  final bool isOnline;

  const AppAvatar({
    super.key,
    this.photoBase64,
    required this.name,
    this.radius = 24.0,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(photoBase64!));
      } catch (_) {
        image = const AssetImage('assets/images/default_avatar.png');
      }
    } else {
      image = const AssetImage('assets/images/default_avatar.png');
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.blue100,
          backgroundImage: image,
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.sage600 : AppColors.gray400,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
