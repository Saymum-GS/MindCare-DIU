// lib/features/info/help_faq_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faqs = [
    (
      'Is my identity kept private?',
      'Yes. You are completely anonymous by default. You use a randomly generated pseudonym (like "gentle_heron") - never your real name. Volunteers and psychologists only see this pseudonym.'
    ),
    (
      'What happens if I feel suicidal?',
      'Your safety is our top priority. If you answer PHQ9 Question 9 with anything other than "Not at all", you will be immediately directed to crisis resources. You can also tap the Crisis Help button on the home screen at any time, 24/7, with zero internet required.'
    ),
    (
      'Is this app a substitute for professional therapy?',
      'No. MindCare@DIU is a support platform, not a replacement for professional mental health care. Peer volunteers are trained listeners, not therapists. For ongoing mental health treatment, please book a session with one of our licensed psychologists.'
    ),
    (
      'How do I book a session with a psychologist?',
      'From the home screen, tap "Book a Session". Browse psychologists, select one, choose an available time slot. DIU students book for free. External users will arrange payment with administrators before the session is confirmed.'
    ),
    (
      'I\'m a DIU student. Why do I see a payment screen?',
      'Your DIU student status must be verified by an administrator. Contact mindcare@diu.edu.bd with your DIU student ID. Once verified, all sessions are free.'
    ),
    (
      'What do PHQ9 and GAD7 measure?',
      'PHQ9 (Patient Health Questionnaire-9) screens for depression severity. GAD7 (Generalized Anxiety Disorder-7) screens for anxiety severity. Both are internationally validated, clinically recognised tools used by healthcare professionals worldwide.'
    ),
    (
      'Can I delete my account?',
      'Yes. Go to Settings → Delete Account. This removes your personal data and mood history. Screening records are anonymised and retained for clinical safety purposes.'
    ),
    (
      'How do I report a technical problem?',
      'Email mindcare@diu.edu.bd with a description of the issue and your device model. We typically respond within 48 hours.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.blue50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.blue100),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_outlined,
                    color: AppColors.blue500, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need direct help?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.blue700)),
                        const Text('mindcare@diu.edu.bd',
                            style: TextStyle(
                                color: AppColors.blue500, fontSize: 13)),
                      ]),
                ),
              ],
            ),
          ),
          ..._faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question, answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.gray200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(question,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.gray900)),
        children: [
          Text(answer,
              style: TextStyle(
                  fontSize: 13, color: isDark ? AppColors.gray300 : AppColors.gray700, height: 1.6))
        ],
      ),
    );
  }
}
