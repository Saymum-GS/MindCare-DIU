import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_util.dart';
import 'package:mindcare_diu/l10n/app_localizations.dart';

class ScreeningSelectScreen extends StatelessWidget {
  const ScreeningSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in', style: TextStyle(fontSize: context.rf(17))),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/screening-history'),
            icon: Icon(Icons.history_rounded, size: context.rs(18)),
            label: Text('History', style: TextStyle(fontSize: context.rf(14))),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.all(context.rs(16)),
            children: [
              Text('How are you feeling?',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: context.rf(26),
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: context.rs(8)),
              Text('Select a check-in to assess your current mental wellbeing.',
                  style: TextStyle(
                      fontSize: context.rf(15),
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              SizedBox(height: context.rs(24)),
              _InstrumentCard(
                title: l10n.takePHQ9,
                description: l10n.phq9Description,
                icon: Icons.monitor_heart,
                onTap: () => context.push('/screening/PHQ9'),
              ),
              SizedBox(height: context.rs(16)),
              _InstrumentCard(
                title: l10n.takeGAD7,
                description: l10n.gad7Description,
                icon: Icons.psychology,
                onTap: () => context.push('/screening/GAD7'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _InstrumentCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.rs(20)),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(20)),
        child: Padding(
          padding: EdgeInsets.all(context.rs(20)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.rs(12)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(context.rs(16)),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: context.rs(32)),
              ),
              SizedBox(width: context.rs(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: context.rf(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.rs(4)),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: context.rf(13),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
