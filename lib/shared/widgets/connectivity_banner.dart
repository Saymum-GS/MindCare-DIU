import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          StreamBuilder<List<ConnectivityResult>>(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final results = snapshot.data!;
              final isOffline = results.contains(ConnectivityResult.none) &&
                  results.length == 1;

              if (!isOffline) return const SizedBox.shrink();

              return Positioned(
                top:
                    0, // Wait, since it's above Scaffold, we might want it under SafeArea. Let's rely on SafeArea or put it at the very top.
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      color: AppColors.red500,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'You are offline. Changes will be saved locally.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
