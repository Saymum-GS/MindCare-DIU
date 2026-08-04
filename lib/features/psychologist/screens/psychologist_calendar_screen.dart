// lib/features/psychologist/screens/psychologist_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class PsychologistCalendarScreen extends StatefulWidget {
  const PsychologistCalendarScreen({super.key});

  @override
  State<PsychologistCalendarScreen> createState() =>
      _PsychologistCalendarScreenState();
}

class _PsychologistCalendarScreenState
    extends State<PsychologistCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _addSlot(TimeOfDay time) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    final end = start.add(const Duration(minutes: 50));

    try {
      if (start.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: Cannot schedule a slot in the past.'),
            backgroundColor: AppColors.red500,
          ));
        }
        return;
      }

      // Validation: Check for overlaps
      final startOfDay = DateTime(start.year, start.month, start.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingSlots = await FirebaseFirestore.instance
          .collection('psychologistSlots')
          .where('psychologistUid', isEqualTo: uid)
          .where('slotStart',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('slotStart', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      for (var doc in existingSlots.docs) {
        final existingStart = (doc['slotStart'] as Timestamp).toDate();
        final existingEnd = (doc['slotEnd'] as Timestamp).toDate();

        if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Error: This time slot overlaps with an existing slot.'),
              backgroundColor: AppColors.red500,
            ));
          }
          return;
        }
      }

      await FirebaseFirestore.instance.collection('psychologistSlots').add({
        'psychologistUid': uid,
        'slotStart': Timestamp.fromDate(start),
        'slotEnd': Timestamp.fromDate(end),
        'durationMinutes': 50,
        'isBooked': false,
        'bookedByUid': null,
        'bookingId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.red500,
        ));
      }
    }
  }

  Future<void> _deleteSlot(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('psychologistSlots')
          .doc(docId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.red500,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final startOfDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Manage Schedule',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('psychologistSlots')
            .where('psychologistUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading slots: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: AppLoadingState(itemCount: 4));
          }

          var docs = snapshot.data!.docs;
          final now = DateTime.now();

          // Client-side filtering and sorting
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final start = (data['slotStart'] as Timestamp?)?.toDate() ?? DateTime.now();
            final end = (data['slotEnd'] as Timestamp?)?.toDate() ?? DateTime.now();
            // Filter: Must be for the selected date, AND must not have ended yet
            return start
                    .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                start.isBefore(endOfDay) &&
                end.isAfter(now);
          }).toList();

          docs.sort((a, b) {
            final startA =
                ((a.data() as Map<String, dynamic>)['slotStart'] as Timestamp?)?.toDate() ?? DateTime.now();
            final startB =
                ((b.data() as Map<String, dynamic>)['slotStart'] as Timestamp?)?.toDate() ?? DateTime.now();
            return startA.compareTo(startB);
          });

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.gray200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        '50-min sessions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0, bottom: 80.0),
                    child: AppEmptyState(
                      icon: Icons.event_available_rounded,
                      title: 'No slots scheduled',
                      message: 'Tap the + button to add a time slot.',
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
                            .copyWith(bottom: 80), // Padding for FAB
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final start = (data['slotStart'] as Timestamp).toDate();
                      final end = (data['slotEnd'] as Timestamp).toDate();
                      final isBooked = data['isBooked'] as bool? ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? (isDark
                                  ? AppColors.sage600.withValues(alpha: 0.1)
                                  : AppColors.sage50)
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isBooked
                                  ? (isDark
                                      ? AppColors.sage600.withValues(alpha: 0.3)
                                      : AppColors.sage100)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.gray200)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? AppColors.sage500
                                  : AppColors.blue500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.schedule_rounded,
                                color: Colors.white),
                          ),
                          title: Text(
                            '${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.gray900,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                isBooked
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 14,
                                color: isBooked
                                    ? AppColors.sage600
                                    : AppColors.gray500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isBooked
                                    ? 'Booked by student'
                                    : 'Available for booking',
                                style: TextStyle(
                                  color: isBooked
                                      ? AppColors.sage600
                                      : (isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600),
                                  fontWeight: isBooked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          trailing: isBooked
                              ? null
                              : IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.red50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.red500,
                                        size: 20),
                                  ),
                                  onPressed: () => _deleteSlot(docs[index].id),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 9, minute: 0),
          );
          if (time != null) {
            _addSlot(time);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Slot', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
