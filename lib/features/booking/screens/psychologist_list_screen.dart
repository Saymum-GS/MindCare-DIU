import '../providers/booking_providers.dart';
import '../../../shared/models/booking_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class PsychologistListScreen extends ConsumerWidget {
  const PsychologistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final psychologistsAsync = ref.watch(verifiedPsychologistsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('Professionals',
            style: TextStyle(fontSize: context.rf(17), fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: context.rs(24)),
          onPressed: () => context.pop(),
        ),
      ),
      body: psychologistsAsync.when(
        loading: () => Center(child: AppLoadingState(itemCount: 4, height: context.rs(100))),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(fontSize: context.rf(14)))),
        data: (profiles) {
          if (profiles.isEmpty) {
            return const AppEmptyState(
              icon: Icons.psychology_outlined,
              title: 'No professionals available',
              message: 'Please check back later.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.builder(
                padding:
                    EdgeInsets.symmetric(horizontal: context.rs(20), vertical: context.rs(16)),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return _PsychologistCard(
                    profile: profile,
                    onTap: () => context.push('/psychologists/${profile.uid}',
                        extra: profile),
                    isDark: isDark,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PsychologistCard extends StatelessWidget {
  final PsychologistProfile profile;
  final VoidCallback onTap;
  final bool isDark;

  const _PsychologistCard({
    required this.profile,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.rs(16)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(context.rs(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(20)),
          child: Padding(
            padding: EdgeInsets.all(context.rs(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.rs(72),
                  height: context.rs(72),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.gray100,
                    borderRadius: BorderRadius.circular(context.rs(20)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.rs(20)),
                    child: _buildAvatarImage(profile.photoBase64Thumb),
                  ),
                ),
                SizedBox(width: context.rs(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: TextStyle(
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.title ?? 'Psychologist',
                        style: TextStyle(
                          fontSize: context.rf(14),
                          color: AppColors.blue500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.rs(12)),
                      Wrap(
                        spacing: context.rs(8),
                        runSpacing: context.rs(6),
                        children: profile.specialties.take(3).map((s) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.rs(10), vertical: context.rs(5)),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface2
                                  : AppColors.gray50,
                              borderRadius: BorderRadius.circular(context.rs(12)),
                              border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorderSoft
                                      : AppColors.gray200),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                  fontSize: context.rf(11),
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: isDark ? AppColors.gray600 : AppColors.gray400,
                    size: context.rs(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover);
    }
    try {
      return Image.memory(base64Decode(base64), fit: BoxFit.cover);
    } catch (_) {
      return Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover);
    }
  }
}
