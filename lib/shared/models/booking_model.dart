// lib/shared/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PsychologistProfile {
  final String uid;
  final String displayName;
  final String? title;
  final List<String> specialties;
  final String? bio;
  final String? photoBase64Thumb;
  final bool isVerified;
  final int sessionFeeExternal;
  final int sessionFeeDiu;
  final int? experienceYears;
  final String? education;
  final String? licenseNumber;
  final List<String> consultationLanguages;
  final String? officeLocation;
  final List<String> therapeuticApproaches;
  final String? consultingHours;

  const PsychologistProfile({
    required this.uid,
    required this.displayName,
    this.title,
    this.specialties = const [],
    this.bio,
    this.photoBase64Thumb,
    this.isVerified = false,
    this.sessionFeeExternal = 1500,
    this.sessionFeeDiu = 0,
    this.experienceYears,
    this.education,
    this.licenseNumber,
    this.consultationLanguages = const ['English'],
    this.officeLocation,
    this.therapeuticApproaches = const [],
    this.consultingHours,
  });

  factory PsychologistProfile.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PsychologistProfile(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? 'Psychologist',
      title: d['title'] as String?,
      specialties: (d['specialties'] as List?)?.cast<String>() ?? [],
      bio: d['bio'] as String?,
      photoBase64Thumb: d['photoBase64Thumb'] as String?,
      isVerified: d['isVerified'] as bool? ?? false,
      sessionFeeExternal: (d['sessionFeeExternal'] as num?)?.toInt() ?? 1500,
      sessionFeeDiu: (d['sessionFeeDiu'] as num?)?.toInt() ?? 0,
      experienceYears: (d['experienceYears'] as num?)?.toInt(),
      education: d['education'] as String?,
      licenseNumber: d['licenseNumber'] as String?,
      consultationLanguages: (d['consultationLanguages'] as List?)?.cast<String>() ?? ['English'],
      officeLocation: d['officeLocation'] as String?,
      therapeuticApproaches: (d['therapeuticApproaches'] as List?)?.cast<String>() ?? [],
      consultingHours: d['consultingHours'] as String?,
    );
  }
}

class BookingSlot {
  final String id;
  final String psychologistUid;
  final DateTime slotStart;
  final DateTime slotEnd;
  final bool isBooked;

  const BookingSlot({
    required this.id,
    required this.psychologistUid,
    required this.slotStart,
    required this.slotEnd,
    this.isBooked = false,
  });

  factory BookingSlot.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BookingSlot(
      id: doc.id,
      psychologistUid: d['psychologistUid'] as String? ?? '',
      slotStart: (d['slotStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      slotEnd: (d['slotEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBooked: d['isBooked'] as bool? ?? false,
    );
  }
}

class BookingModel {
  final String id;
  final String studentUid;
  final String studentName;
  final bool isDiuStudent;
  final String psychologistUid;
  final String psychologistName;
  final DateTime slotStart;
  final DateTime slotEnd;
  final String sessionType; // video | audio | text
  final String status; // pending | confirmed | completed | cancelled
  final bool requiresPayment;
  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final int paymentAmountBdt;
  final String? meetLink;
  final String problemNote;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.isDiuStudent,
    required this.psychologistUid,
    required this.psychologistName,
    required this.slotStart,
    required this.slotEnd,
    required this.sessionType,
    required this.status,
    required this.requiresPayment,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    required this.paymentAmountBdt,
    this.meetLink,
    required this.problemNote,
    this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      studentUid: d['studentUid'] as String? ?? '',
      studentName: d['studentName'] as String? ??
          d['studentPseudonym'] as String? ??
          'Student',
      isDiuStudent: d['isDiuStudent'] as bool? ?? false,
      psychologistUid: d['psychologistUid'] as String? ?? '',
      psychologistName: d['psychologistName'] as String? ?? 'Psychologist',
      slotStart: (d['slotStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      slotEnd: (d['slotEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionType: d['sessionType'] as String? ?? 'video',
      status: d['status'] as String? ?? 'pending',
      requiresPayment: d['requiresPayment'] as bool? ?? false,
      paymentStatus: d['paymentStatus'] as String? ?? 'not_required',
      paymentMethod: d['paymentMethod'] as String?,
      paymentReference: d['paymentReference'] as String?,
      paymentAmountBdt: (d['paymentAmountBdt'] as num?)?.toInt() ?? 0,
      meetLink: d['meetLink'] as String?,
      problemNote: d['problemNote'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
