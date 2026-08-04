// lib/features/info/about_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue400, AppColors.blue700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            Text('MindCare',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28, color: isDark ? Colors.white : AppColors.gray900)),
            Text('@DIU',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.blue500,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Version 1.0.0',
                style: TextStyle(color: AppColors.gray500, fontSize: 13)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.gray200),
              ),
              child: Text(
                'MindCare@DIU is a mental health support platform built for Daffodil International University. '
                'It provides anonymous wellbeing screenings, peer volunteer chat, professional psychologist '
                'booking, and 24/7 crisis resources - all free for DIU students.',
                style: TextStyle(
                    fontSize: 14, color: isDark ? AppColors.gray300 : AppColors.gray700, height: 1.7),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const _AboutRow(
                icon: Icons.school_outlined,
                label: 'Daffodil International University'),
            const _AboutRow(
                icon: Icons.location_on_outlined, label: 'Dhaka, Bangladesh'),
            const _AboutRow(
                icon: Icons.email_outlined, label: 'mindcare@diu.edu.bd'),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.push('/privacy'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Privacy Policy'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/help'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Help & FAQ'),
            ),
            const SizedBox(height: 32),
            const Text('Built with ❤️ for student wellbeing',
                style: TextStyle(color: AppColors.gray500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AboutRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: AppColors.gray600, fontSize: 13)),
      ]),
    );
  }
}
