import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/widgets/app_surface.dart';

class SessionSummaryScreen extends StatefulWidget {
  final String sessionId;

  const SessionSummaryScreen({super.key, required this.sessionId});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  final _summaryController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitSummary() async {
    if (_summaryController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.chatSessions)
          .doc(widget.sessionId)
          .update({
        'summary': _summaryController.text.trim(),
      });
      if (mounted) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        String role = 'student';
        if (uid != null) {
          final doc = await FirebaseFirestore.instance
              .collection(FirestorePaths.users)
              .doc(uid)
              .get();
          role = doc.data()?['role'] as String? ?? 'student';
        }
        if (!mounted) return;
        if (role == 'volunteer') {
          context.go('/volunteer');
        } else if (role == 'psychologist') {
          context.go('/psychologist/home');
        } else if (role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Notes'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a brief reflection on this session',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your notes help maintain continuity of care and track progress over time.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _summaryController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Discussed anxiety triggers, suggested deep breathing...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitSummary,
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Notes'),
            ),
          ],
        ),
      ),
    );
  }
}
