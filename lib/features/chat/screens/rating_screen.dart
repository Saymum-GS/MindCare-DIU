import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/constants/firestore_paths.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import '../../../shared/models/chat_session_model.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const RatingScreen({super.key, required this.sessionId});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}
class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a rating', style: TextStyle(fontSize: context.rf(13)))));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.chatSessions)
          .doc(widget.sessionId)
          .update({
        'rating': _rating,
        'ratingNote': _noteController.text.trim(),
      });
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e', style: TextStyle(fontSize: context.rf(13)))));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Feedback', style: TextStyle(fontSize: context.rf(17))),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.rs(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSurface(
                  padding: EdgeInsets.all(context.rs(24)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: context.rs(48),
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: context.rs(16)),
                      StreamBuilder<ChatSession>(
                        stream: ref.watch(chatRepositoryProvider).watchSession(widget.sessionId),
                        builder: (context, snapshot) {
                          final channel = snapshot.data?.channel ?? 'volunteer';
                          final isPsychologist = channel == 'psychologist';
                          return Text(
                            isPsychologist
                                ? 'Thank you for attending your clinical consultation'
                                : 'Thank you for connecting with a peer listener',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: context.rf(24),
                                color: theme.colorScheme.onSurface),
                            textAlign: TextAlign.center,
                          );
                        }
                      ),
                      SizedBox(height: context.rs(8)),
                      Text(
                        'Your feedback helps us improve the support experience for everyone.',
                        style: TextStyle(
                          fontSize: context.rf(14),
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.rs(32)),
                      Text(
                        'How was your experience?',
                        style: TextStyle(
                            fontSize: context.rf(16),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.rs(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.amber500,
                              size: context.rs(42),
                            ),
                            tooltip: 'Rate ${index + 1} of 5',
                            onPressed: () => setState(() => _rating = index + 1),
                          );
                        }),
                      ),
                      SizedBox(height: context.rs(32)),
                      TextField(
                        controller: _noteController,
                        maxLines: 4,
                        style: TextStyle(fontSize: context.rf(15)),
                        decoration: InputDecoration(
                          hintText:
                              'Optional: Share anything about your experience...',
                          hintStyle: TextStyle(fontSize: context.rf(14)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.rs(16)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.rs(48)),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, context.rs(56)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16)))),
                  child: _isSubmitting
                      ? SizedBox(
                          height: context.rs(20),
                          width: context.rs(20),
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Submit Review',
                          style: TextStyle(
                              fontSize: context.rf(16),
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
