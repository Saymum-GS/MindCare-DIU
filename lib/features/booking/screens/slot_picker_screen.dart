import '../providers/booking_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/data/audit_repository.dart';
// lib/features/booking/screens/slot_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/widgets/app_empty_state.dart';

class SlotPickerScreen extends ConsumerStatefulWidget {
  final PsychologistProfile profile;

  const SlotPickerScreen({super.key, required this.profile});

  @override
  ConsumerState<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends ConsumerState<SlotPickerScreen> {
  bool _isBooking = false;

  Future<void> _handleSlotTap(BookingSlot slot, bool isDiuStudent) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    String selectedMode = 'in_person';
    final noteController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customize Your Session',
                        style: TextStyle(
                            fontSize: context.rf(20),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you would like to connect with ${widget.profile.displayName}.',
                      style: TextStyle(
                          fontSize: context.rf(14), color: AppColors.gray500),
                    ),
                    const SizedBox(height: 20),
                    _buildModeOption(
                      setModalState: setModalState,
                      currentValue: selectedMode,
                      value: 'in_person',
                      icon: Icons.business_rounded,
                      title: 'In-Person Appointment (DIU Campus)',
                      subtitle: widget.profile.officeLocation ?? 'DSC Counseling Center / Room 302',
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    const SizedBox(height: 10),
                    _buildModeOption(
                      setModalState: setModalState,
                      currentValue: selectedMode,
                      value: 'video',
                      icon: Icons.videocam_rounded,
                      title: 'Online Video Consultation',
                      subtitle: 'Secure Google Meet link provided before session',
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    const SizedBox(height: 10),
                    _buildModeOption(
                      setModalState: setModalState,
                      currentValue: selectedMode,
                      value: 'audio',
                      icon: Icons.call_rounded,
                      title: 'Online Voice Consultation',
                      subtitle: 'Voice-only private consultation session',
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    const SizedBox(height: 10),
                    _buildModeOption(
                      setModalState: setModalState,
                      currentValue: selectedMode,
                      value: 'text',
                      icon: Icons.chat_bubble_rounded,
                      title: 'Live Chat Consultation',
                      subtitle: 'Text-based counseling session',
                      onChanged: (val) => setModalState(() => selectedMode = val!),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Topic / Note for Psychologist (Optional)',
                        hintText: 'e.g. Academic stress, anxiety, family concerns...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52)),
                        onPressed: () {
                          Navigator.pop(ctx, true);
                        },
                        child: Text(
                          isDiuStudent
                              ? 'Confirm Free Booking'
                              : 'Proceed to Checkout',
                          style: TextStyle(
                              fontSize: context.rf(16),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((proceed) async {
      if (proceed != true) return;
      if (!mounted) return;
      final problemNote =
          noteController.text.trim().isEmpty ? 'None' : noteController.text.trim();

      if (isDiuStudent) {
        setState(() => _isBooking = true);
        try {
          final repository = ref.read(bookingRepositoryProvider);
          final bookingId = await repository.createBooking(
            slot: slot,
            profile: widget.profile,
            sessionType: selectedMode,
            isDiuStudent: true,
            studentName: user.displayName,
            problemNote: problemNote,
          );

          await AuditRepository().logAction(
            action: 'booking.created',
            targetUid: widget.profile.uid,
            targetCollection: 'bookings',
            targetDocId: bookingId,
            metadata: {
              'type': 'free',
              'slot': slot.slotStart.toIso8601String(),
              'sessionType': selectedMode,
            },
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Session booked successfully!')));
            context.pop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Failed to book: $e')));
          }
        } finally {
          if (mounted) {
            setState(() => _isBooking = false);
          }
        }
      } else {
        context.push('/checkout', extra: {
          'slot': slot,
          'profile': widget.profile,
          'sessionType': selectedMode,
          'problemNote': problemNote,
        });
      }
    });
  }

  Widget _buildModeOption({
    required StateSetter setModalState,
    required String currentValue,
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blue500.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppColors.blue500 : AppColors.gray500.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.blue500 : AppColors.gray600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.blue500 : null)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: currentValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: AppColors.blue500,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(psychologistSlotsProvider(widget.profile.uid));
    final userAsync =
        ref.watch(currentUserProvider); // To get isDiuStudent status
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDiuStudent = userAsync.valueOrNull?.isDiuStudent ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text('Book with ${widget.profile.displayName.split(' ')[0]}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          slotsAsync.when(
            loading: () => const Center(child: AppLoadingState(itemCount: 4)),
            error: (err, stack) => Center(
                child: Text('Error: $err',
                    style: const TextStyle(color: AppColors.red500))),
            data: (slots) {
              if (slots.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No available slots',
                  message: 'This professional has no open slots.\nPlease try again later.',
                );
              }

              // Group slots by date
              final grouped = <String, List<BookingSlot>>{};
              for (final slot in slots) {
                final dateKey =
                    DateFormat('EEEE, MMMM d').format(slot.slotStart);
                grouped.putIfAbsent(dateKey, () => []).add(slot);
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.blue50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.blue100),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.darkSurface2 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline,
                              color: AppColors.blue500, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isDiuStudent
                                ? 'As a DIU student, your sessions are completely free. Select an available time slot.'
                                : 'Each session is 50 minutes. Select an available time slot to proceed to payment.',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.blue400
                                    : AppColors.blue700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...grouped.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
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
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.gray400),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: entry.value.map((slot) {
                              return _SlotChip(
                                slot: slot,
                                onTap: () => _handleSlotTap(slot, isDiuStudent),
                                isDark: isDark,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          if (_isBooking)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: AppLoadingState(itemCount: 4)),
            ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final BookingSlot slot;
  final VoidCallback onTap;
  final bool isDark;

  const _SlotChip(
      {required this.slot, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(slot.slotStart);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.blue50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkBorderSoft : AppColors.blue100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded,
                size: 14,
                color: isDark ? AppColors.blue400 : AppColors.blue600),
            const SizedBox(width: 6),
            Text(
              timeStr,
              style: TextStyle(
                color: isDark ? AppColors.blue400 : AppColors.blue700,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
