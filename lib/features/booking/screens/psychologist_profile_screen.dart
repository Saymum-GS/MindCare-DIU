import '../../../shared/models/booking_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class PsychologistProfileScreen extends StatelessWidget {
  final PsychologistProfile profile;

  const PsychologistProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.gray100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildAvatarImage(profile.photoBase64Thumb),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.displayName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26,
                          color: isDark ? Colors.white : AppColors.gray900,
                          height: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    profile.title ?? 'Psychologist',
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.blue500,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.gray200),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.bio ?? 'No bio provided.',
                      style: TextStyle(
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                          height: 1.6,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    // Professional Credentials
                    _CredentialRow(
                        icon: Icons.history_edu_rounded,
                        label: 'Experience',
                        value: '${profile.experienceYears ?? 0} Years',
                        isDark: isDark),
                    _CredentialRow(
                        icon: Icons.school_outlined,
                        label: 'Education',
                        value: profile.education ?? 'Verified Professional',
                        isDark: isDark),
                    _CredentialRow(
                        icon: Icons.verified_user_outlined,
                        label: 'License',
                        value: profile.licenseNumber ?? 'MC-VERIFIED',
                        isDark: isDark),
                    _CredentialRow(
                        icon: Icons.translate_rounded,
                        label: 'Languages',
                        value: profile.consultationLanguages.join(', '),
                        isDark: isDark),
                    if (profile.officeLocation != null && profile.officeLocation!.isNotEmpty)
                      _CredentialRow(
                          icon: Icons.location_on_outlined,
                          label: 'DIU Office',
                          value: profile.officeLocation!,
                          isDark: isDark),
                    if (profile.consultingHours != null && profile.consultingHours!.isNotEmpty)
                      _CredentialRow(
                          icon: Icons.access_time_rounded,
                          label: 'Schedule',
                          value: profile.consultingHours!,
                          isDark: isDark),
                    const SizedBox(height: 28),
                    Text(
                      'Specialties & Approaches',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: {
                        ...profile.specialties,
                        ...profile.therapeuticApproaches,
                      }.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface2
                                : AppColors.blue50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorderSoft
                                    : AppColors.blue100),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.gray200
                                    : AppColors.blue700,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.blue600,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => context.push(
              '/psychologists/${profile.uid}/slots',
              extra: profile),
          icon: const Icon(Icons.calendar_month_rounded),
          label: const Text('Book a Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return Icon(Icons.person, size: 48, color: AppColors.gray400);
    }
    try {
      return Image.memory(base64Decode(base64), fit: BoxFit.cover);
    } catch (_) {
      return Icon(Icons.person, size: 48, color: AppColors.gray400);
    }
  }
}

class _CredentialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _CredentialRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 20, color: isDark ? AppColors.gray400 : AppColors.gray500),
          const SizedBox(width: 12),
          Text('$label:',
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.gray900,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
