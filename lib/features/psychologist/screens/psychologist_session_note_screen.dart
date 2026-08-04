import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';

class PsychologistSessionNoteScreen extends StatefulWidget {
  final String slotId;
  const PsychologistSessionNoteScreen({super.key, required this.slotId});

  @override
  State<PsychologistSessionNoteScreen> createState() =>
      _PsychologistSessionNoteScreenState();
}

class _PsychologistSessionNoteScreenState
    extends State<PsychologistSessionNoteScreen> {
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final doc = await FirebaseFirestore.instance
        .collection('privateNotes')
        .doc(widget.slotId)
        .get();
    if (mounted) {
      setState(() {
        _noteController.text = doc.data()?['sessionNote'] ?? '';
      });
    }
  }

  Future<void> _saveNote() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('privateNotes')
          .doc(widget.slotId)
          .set({
        'sessionNote': _noteController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Note saved securely.'),
          backgroundColor: AppColors.sage500,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.red500,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Session Note'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: AppColors.gray500),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These notes are strictly private and cannot be viewed by the student.',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.gray500,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AppSurface(
                padding: const EdgeInsets.all(0),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Enter clinical notes here...',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveNote,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: AppLoadingState(itemCount: 1, height: 20))
                    : const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
