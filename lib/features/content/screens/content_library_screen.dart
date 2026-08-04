import 'package:mindcare_diu/core/theme/app_colors.dart';
// lib/features/content/screens/content_library_screen.dart
import '../data/content_repository.dart';
import '../../../shared/models/content_model.dart';
import 'package:flutter/material.dart';

import '../widgets/content_article_card.dart';
import '../widgets/content_video_card.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  final ContentRepository _repository = ContentRepository();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Care Resources'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<ContentItem>>(
        stream: _repository.watchPublishedContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoadingState());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading content: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          final filtered = _filter == 'all'
              ? items
              : items.where((i) => i.type.name == _filter).toList();

          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.library_books_outlined,
              title: 'No resources available',
              message: 'Self-care articles, videos, and workshops will appear here once published.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 160),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset('assets/images/self_care_hero.png',
                              fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(children: [
                      for (final f in ['all', 'article', 'video', 'audio', 'workshops'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f == 'all'
                                ? 'All'
                                : (f == 'workshops' ? '📅 Workshops' : f[0].toUpperCase() + f.substring(1))),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                            selectedColor: AppColors.blue100,
                            checkmarkColor: AppColors.blue500,
                            labelStyle: TextStyle(
                              color: _filter == f
                                  ? AppColors.blue500
                                  : (isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700),
                              fontWeight: _filter == f
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                    ]),
                  ),
                  Expanded(
                    child: _filter == 'workshops'
                        ? _buildWorkshopsList(isDark)
                        : (filtered.isEmpty
                            ? const AppEmptyState(
                                icon: Icons.filter_list_off_rounded,
                                title: 'No resources available yet',
                                message: 'Try selecting a different category.',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  if (item.type == ContentType.video) {
                                    return ContentVideoCard(item: item);
                                  }
                                  return ContentArticleCard(item: item);
                                },
                              )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkshopsList(bool isDark) {
    final workshops = [
      {
        'title': 'Overcoming Midterm Exam Anxiety & Burnout',
        'date': 'July 15, 2026 • 3:00 PM - 4:30 PM',
        'location': 'DIU Counseling Center (DSC Auditorium 2)',
        'speaker': 'Dr. Sharmin Akter, Lead Counseling Psychologist',
      },
      {
        'title': 'Mindfulness & Grounding Techniques Workshop',
        'date': 'July 22, 2026 • 2:00 PM - 3:30 PM',
        'location': 'Online Google Meet / DSC Campus Room 302',
        'speaker': 'DIU Mental Health Peer Counselors Team',
      },
      {
        'title': 'Building Healthy Relationships & Boundaries',
        'date': 'August 5, 2026 • 4:00 PM - 5:00 PM',
        'location': 'DIU Student Affairs Hall',
        'speaker': 'Prof. A. Rahman, Clinical Psychologist',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: workshops.length,
      itemBuilder: (context, index) {
        final w = workshops[index];
        return _WorkshopCard(
          title: w['title']!,
          date: w['date']!,
          location: w['location']!,
          speaker: w['speaker']!,
          isDark: isDark,
        );
      },
    );
  }
}

class _WorkshopCard extends StatefulWidget {
  final String title, date, location, speaker;
  final bool isDark;
  const _WorkshopCard({required this.title, required this.date, required this.location, required this.speaker, required this.isDark});

  @override
  State<_WorkshopCard> createState() => _WorkshopCardState();
}

class _WorkshopCardState extends State<_WorkshopCard> {
  bool _registered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.isDark ? AppColors.darkBorder : AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('FREE WORKSHOP', style: TextStyle(color: AppColors.blue500, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.blue500),
              const SizedBox(width: 6),
              Text(widget.date, style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.gray300 : AppColors.gray700)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.sage600),
              const SizedBox(width: 6),
              Expanded(child: Text(widget.location, style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.gray300 : AppColors.gray700))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.amber600),
              const SizedBox(width: 6),
              Expanded(child: Text('By: ${widget.speaker}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: widget.isDark ? AppColors.gray400 : AppColors.gray600))),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _registered ? AppColors.sage600 : AppColors.blue500,
              ),
              onPressed: () {
                setState(() => _registered = !_registered);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_registered ? 'Registered for workshop! Check your email/app notifications.' : 'Registration cancelled.'),
                  backgroundColor: _registered ? AppColors.sage600 : AppColors.gray700,
                ));
              },
              icon: Icon(_registered ? Icons.check_circle_rounded : Icons.app_registration_rounded, size: 18),
              label: Text(_registered ? 'Registered (Tap to Cancel)' : 'Register Seat Now'),
            ),
          ),
        ],
      ),
    );
  }
}
