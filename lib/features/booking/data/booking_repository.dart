// lib/features/booking/data/booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/models/booking_model.dart';
import '../../../core/services/notification_service.dart';

class BookingRepository {
  final _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Stream<List<PsychologistProfile>> watchVerifiedPsychologists() {
    return _db
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: 'psychologist')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PsychologistProfile.fromFirestore(d)).toList());
  }

  Stream<List<BookingSlot>> getAvailableSlots(String psychologistUid) {
    final now = DateTime.now();
    return _db
        .collection(FirestorePaths.psychologistSlots)
        .where('psychologistUid', isEqualTo: psychologistUid)
        .where('isBooked', isEqualTo: false)
        .where('slotStart', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('slotStart')
        .snapshots()
        .map((s) => s.docs.map((d) => BookingSlot.fromFirestore(d)).toList());
  }

  Stream<List<BookingModel>> watchMyBookings() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection(FirestorePaths.bookings)
        .where('studentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  Future<String> createBooking({
    required BookingSlot slot,
    required PsychologistProfile profile,
    required String studentName,
    required bool isDiuStudent,
    required String sessionType,
    required String problemNote,
    String? paymentMethod,
    String? paymentReference,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final bookingRef = _db.collection(FirestorePaths.bookings).doc();
    final slotRef =
        _db.collection(FirestorePaths.psychologistSlots).doc(slot.id);

    await _db.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      if (slotSnap.data()?['isBooked'] == true) {
        throw Exception('SLOT_TAKEN');
      }
      final requiresPayment = !isDiuStudent;
      final amount = isDiuStudent ? 0 : profile.sessionFeeExternal;

      tx.update(slotRef, {
        'isBooked': true,
        'bookedByUid': uid,
        'bookingId': bookingRef.id,
      });
      tx.set(bookingRef, {
        'studentUid': uid,
        'studentName': studentName,
        'isDiuStudent': isDiuStudent,
        'psychologistUid': profile.uid,
        'psychologistName': profile.displayName,
        'slotStart': Timestamp.fromDate(slot.slotStart),
        'slotEnd': Timestamp.fromDate(slot.slotEnd),
        'sessionType': sessionType,
        'status': 'pending',
        'requiresPayment': requiresPayment,
        'paymentStatus': requiresPayment
            ? (paymentReference != null ? 'completed' : 'pending')
            : 'not_required',
        'paymentMethod': paymentMethod,
        'paymentReference': paymentReference,
        'paymentAmountBdt': amount,
        'meetLink': null,
        'problemNote': problemNote,
        'slotId': slot.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    // Notify the psychologist
    await _notificationService.sendNotification(
      recipientUid: profile.uid,
      title: 'New Booking Request',
      body: 'You have a new session booking from $studentName.',
      type: 'booking',
      relatedId: bookingRef.id,
    );

    return bookingRef.id;
  }

  Stream<List<BookingSlot>> watchMySlots(String psychologistUid) {
    return _db
        .collection(FirestorePaths.psychologistSlots)
        .where('psychologistUid', isEqualTo: psychologistUid)
        .orderBy('slotStart')
        .snapshots()
        .map((s) => s.docs.map((d) => BookingSlot.fromFirestore(d)).toList());
  }

  Future<void> addSlot(String psychologistUid, DateTime start) async {
    await _db.collection(FirestorePaths.psychologistSlots).add({
      'psychologistUid': psychologistUid,
      'slotStart': Timestamp.fromDate(start),
      'slotEnd': Timestamp.fromDate(start.add(const Duration(minutes: 50))),
      'durationMinutes': 50,
      'isBooked': false,
      'bookedByUid': null,
      'bookingId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSlot(String slotId) async {
    await _db.collection(FirestorePaths.psychologistSlots).doc(slotId).delete();
  }

  Stream<List<BookingModel>> watchPsychologistBookings(String uid) {
    return _db
        .collection(FirestorePaths.bookings)
        .where('psychologistUid', isEqualTo: uid)
        .orderBy('slotStart', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }
}
