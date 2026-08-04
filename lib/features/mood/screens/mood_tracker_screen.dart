import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mood_repository.dart';
import '../widgets/mood_emoji_picker.dart';
import '../widgets/mood_trend_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_loading_state.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final MoodRepository _repository = MoodRepository();
  final TextEditingController _noteController = TextEditingController();
  int? _selectedScore;
  bool _isSaving = false;

  static const _moodNames = {
    5: 'great',
    4: 'good',
    3: 'okay',
    2: 'low',
    1: 'difficult'
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<Color> get _currentGradient {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_selectedScore) {
      case 5:
        return [
          const Color(0xFFFFD54F),
          const Color(0xFFFF8F00)
        ]; // Great (Amber)
      case 4:
        return [
          const Color(0xFF81C784),
          const Color(0xFF2E7D32)
        ]; // Good (Green)
      case 3:
        return [
          const Color(0xFF64B5F6),
          const Color(0xFF1565C0)
        ]; // Okay (Blue)
      case 2:
        return [
          const Color(0xFF7986CB),
          const Color(0xFF283593)
        ]; // Low (Indigo)
      case 1:
        return [
          const Color(0xFFBA68C8),
          const Color(0xFF6A1B9A)
        ]; // Difficult (Purple)
      default:
        return isDark
            ? [Colors.black, AppColors.gray500]
            : [Colors.white, const Color(0xFFF3F4F6)];
    }
  }

  Future<void> _saveMood() async {
    if (_selectedScore == null) return;
    setState(() => _isSaving = true);

    try {
      final note = _noteController.text.trim();
      final moodName = _moodNames[_selectedScore!] ?? 'okay';
      await _repository.logMood(moodName, _selectedScore!,
          note: note.isEmpty ? null : note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully!')),
        );
        setState(() {
          _selectedScore = null;
          _noteController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Mood History',
            onPressed: () => context.push('/mood/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic ambient color layer
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _currentGradient,
                ),
              ),
            ),
          ),
          // Frosted glass blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          // Content
          ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'How are you feeling today?',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              MoodEmojiPicker(
                selectedScore: _selectedScore,
                onSelected: (score) => setState(() => _selectedScore = score),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                maxLength: AppConstants.maxMoodNoteLength,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a note about your day (optional)...',
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    _selectedScore == null || _isSaving ? null : _saveMood,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Mood',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 48),
              const Text(
                '30-Day Trend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<MoodEntry>>(
                stream: _repository.watchRecentMoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: AppLoadingState(itemCount: 1, height: 200));
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final entries = snapshot.data ?? [];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: MoodTrendChart(entries: entries),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
