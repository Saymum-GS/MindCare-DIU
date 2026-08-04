// lib/features/info/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text('Effective: January 2026',
              style: TextStyle(color: AppColors.gray500, fontSize: 13)),
          const SizedBox(height: 24),
          _Section(
              '1. Information We Collect',
              'When you use MindCare@DIU anonymously, we collect only:\n\n'
                  '• A randomly generated pseudonym (e.g. "gentle_heron")\n'
                  '• Your wellbeing questionnaire answers (PHQ9, GAD7)\n'
                  '• Mood check-in entries\n'
                  '• Chat messages, stored under your pseudonym\n'
                  '• Device FCM token for push notifications\n\n'
                  'We do not collect your real name, email, phone number, location, or device identifier unless you choose to link an email account.'),
          _Section(
              '2. How We Use Your Information',
              'Your information is used solely to:\n\n'
                  '• Connect you with peer volunteers and psychologists\n'
                  '• Track your wellbeing over time (visible only to you)\n'
                  '• Alert our clinical team when your safety may be at risk\n'
                  '• Maintain a mandatory audit trail for clinical accountability'),
          _Section(
              '3. Who Can See Your Data',
              '• Volunteers: Your pseudonym and chat messages during an active session only\n'
                  '• Psychologists: Your screening results and session notes\n'
                  '• Administrators: Anonymised safety data only\n\n'
                  'No one outside MindCare@DIU has access to your data. We do not sell or share data with advertisers.'),
          _Section(
              '4. Data Retention',
              'Mood entries can be deleted when you delete your account.\n\n'
                  'Screening records and crisis records are retained in anonymised form for clinical and legal purposes, even after account deletion.\n\n'
                  'Chat messages are anonymised (your pseudonym replaced with "[deleted user]") upon account deletion.'),
          _Section(
              '5. Your Rights',
              '• Delete your account at any time from Settings\n'
                  '• Request a copy of your data by contacting mindcare@diu.edu.bd\n'
                  '• Opt out of push notifications at any time in your device settings'),
          _Section(
              '6. Contact',
              'If you have questions about this policy:\n'
                  'Email: mindcare@diu.edu.bd\n'
                  'Daffodil International University\n'
                  'Dhaka, Bangladesh'),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.gray900)),
        const SizedBox(height: 8),
        Text(body,
            style: TextStyle(
                fontSize: 14, color: isDark ? AppColors.gray300 : AppColors.gray700, height: 1.7)),
      ]),
    );
  }
}
