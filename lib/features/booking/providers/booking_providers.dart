import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../../../shared/models/booking_model.dart';

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => BookingRepository());

final verifiedPsychologistsProvider =
    StreamProvider<List<PsychologistProfile>>((ref) {
  return ref.watch(bookingRepositoryProvider).watchVerifiedPsychologists();
});

final psychologistSlotsProvider =
    StreamProvider.family<List<BookingSlot>, String>((ref, uid) {
  return ref.watch(bookingRepositoryProvider).getAvailableSlots(uid);
});

final myBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  return ref.watch(bookingRepositoryProvider).watchMyBookings();
});

final psychologistBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, uid) {
  return ref.watch(bookingRepositoryProvider).watchPsychologistBookings(uid);
});
