import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtil.getGridCount(context, base: 2),
        mainAxisSpacing: context.rs(12),
        crossAxisSpacing: context.rs(12),
        childAspectRatio: 1.4,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionCard(
          title: 'Peer Support',
          subtitle: 'Talk anonymously',
          icon: Icons.chat_bubble_rounded,
          iconColor: isDark ? AppColors.sage500 : AppColors.sage600,
          onTap: () => context.go('/chat-request'),
        ),
        _ActionCard(
          title: 'Wellbeing',
          subtitle: 'Daily check-in',
          icon: Icons.monitor_heart_rounded,
          iconColor: isDark ? AppColors.red400 : AppColors.red500,
          onTap: () => context.go('/screening'),
        ),
        _ActionCard(
          title: 'Professionals',
          subtitle: 'Clinical sessions',
          icon: Icons.psychology_rounded,
          iconColor: isDark ? AppColors.blue400 : AppColors.blue600,
          onTap: () => context.push('/psychologists'),
        ),
        _ActionCard(
          title: 'Mood Tracker',
          subtitle: 'Log your day',
          icon: Icons.mood_rounded,
          iconColor: isDark ? AppColors.blue400 : AppColors.blue500,
          onTap: () => context.push('/mood'),
        ),
        _ActionCard(
          title: 'Resources',
          subtitle: 'Articles & Tips',
          icon: Icons.library_books_rounded,
          iconColor: isDark ? AppColors.amber500 : AppColors.amber600,
          onTap: () => context.go('/content'),
        ),
        _ActionCard(
          title: 'Bookings',
          subtitle: 'Join sessions',
          icon: Icons.calendar_month_rounded,
          iconColor: isDark ? AppColors.blue400 : AppColors.blue500,
          onTap: () => context.push('/bookings'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.05),
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
            padding: EdgeInsets.all(context.rs(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.rs(8)),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.rs(10)),
                      ),
                      child: Icon(icon, color: iconColor, size: context.rs(22)),
                    ),
                    Icon(Icons.arrow_outward_rounded, 
                      size: context.rs(16), 
                      color: isDark ? AppColors.gray600 : AppColors.gray300),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: context.rf(15),
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.gray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: context.rf(12),
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
