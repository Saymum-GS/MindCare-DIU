// lib/shared/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String role; // student | volunteer | psychologist | admin
  final String displayName;
  final String pseudonym;
  final String? email;
  final bool isAnonymous;
  final bool isActive;
  final bool onboardingComplete;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  // Student fields
  final String? studentId;
  final bool? isDiuStudent;
  final bool? studentIdVerified;
  final String? latestRiskLevel; // green | yellow | red | null
  final bool? consentGiven;
  final String? campus;
  final String? batch;
  final String? preferredLanguage;
  final List<String>? supportInterests;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  // Volunteer fields
  final bool? isOnline;
  final int? totalChatsCompleted;
  final String? department;
  final String? academicYear;
  final String? whyIVolunteer;
  final String? badgeLevel;
  final List<String>? languagesSpoken;
  final List<String>? supportTopics;

  // Psychologist fields
  final String? title;
  final List<String>? specialties;
  final String? bio;
  final String? photoBase64Thumb;
  final bool? isOnCall;
  final bool? isVerified;
  final int? sessionFeeExternal;
  final int? sessionFeeDiu;
  final int? experienceYears;
  final String? education;
  final String? licenseNumber;
  final List<String>? consultationLanguages;
  final String? officeLocation;
  final List<String>? therapeuticApproaches;
  final String? consultingHours;

  const UserModel({
    required this.uid,
    required this.role,
    required this.displayName,
    required this.pseudonym,
    this.email,
    this.isAnonymous = true,
    this.isActive = true,
    this.onboardingComplete = false,
    this.fcmToken,
    this.createdAt,
    this.lastActiveAt,
    this.studentId,
    this.isDiuStudent,
    this.studentIdVerified,
    this.latestRiskLevel,
    this.consentGiven,
    this.campus,
    this.batch,
    this.preferredLanguage,
    this.supportInterests,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.isOnline,
    this.totalChatsCompleted,
    this.title,
    this.specialties,
    this.bio,
    this.photoBase64Thumb,
    this.isOnCall,
    this.isVerified,
    this.sessionFeeExternal,
    this.sessionFeeDiu,
    this.experienceYears,
    this.education,
    this.licenseNumber,
    this.consultationLanguages,
    this.department,
    this.academicYear,
    this.whyIVolunteer,
    this.badgeLevel,
    this.languagesSpoken,
    this.supportTopics,
    this.officeLocation,
    this.therapeuticApproaches,
    this.consultingHours,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      role: d['role'] as String? ?? 'student',
      displayName:
          d['displayName'] as String? ?? d['pseudonym'] as String? ?? 'User',
      pseudonym: d['pseudonym'] as String? ?? 'unknown_user',
      email: d['email'] as String?,
      isAnonymous: d['isAnonymous'] as bool? ?? true,
      isActive: d['isActive'] as bool? ?? true,
      onboardingComplete: d['onboardingComplete'] as bool? ?? false,
      fcmToken: d['fcmToken'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastActiveAt: (d['lastActiveAt'] as Timestamp?)?.toDate(),
      studentId: d['studentId'] as String?,
      isDiuStudent: d['isDiuStudent'] as bool?,
      studentIdVerified: d['studentIdVerified'] as bool?,
      latestRiskLevel: d['latestRiskLevel'] as String?,
      consentGiven: d['consentGiven'] as bool?,
      emergencyContactName: d['emergencyContactName'] as String?,
      emergencyContactPhone: d['emergencyContactPhone'] as String?,
      isOnline: d['isOnline'] as bool?,
      totalChatsCompleted: (d['totalChatsCompleted'] as num?)?.toInt(),
      title: d['title'] as String?,
      specialties: (d['specialties'] as List?)?.cast<String>(),
      bio: d['bio'] as String?,
      photoBase64Thumb: d['photoBase64Thumb'] as String?,
      isOnCall: d['isOnCall'] as bool?,
      isVerified: d['isVerified'] as bool?,
      sessionFeeExternal: (d['sessionFeeExternal'] as num?)?.toInt(),
      sessionFeeDiu: (d['sessionFeeDiu'] as num?)?.toInt(),
      experienceYears: (d['experienceYears'] as num?)?.toInt(),
      education: d['education'] as String?,
      licenseNumber: d['licenseNumber'] as String?,
      consultationLanguages: (d['consultationLanguages'] as List?)?.cast<String>(),
      department: d['department'] as String?,
      academicYear: d['academicYear'] as String?,
      whyIVolunteer: d['whyIVolunteer'] as String?,
      badgeLevel: d['badgeLevel'] as String?,
      languagesSpoken: (d['languagesSpoken'] as List?)?.cast<String>(),
      supportTopics: (d['supportTopics'] as List?)?.cast<String>(),
      campus: d['campus'] as String?,
      batch: d['batch'] as String?,
      preferredLanguage: d['preferredLanguage'] as String?,
      supportInterests: (d['supportInterests'] as List?)?.cast<String>(),
      officeLocation: d['officeLocation'] as String?,
      therapeuticApproaches: (d['therapeuticApproaches'] as List?)?.cast<String>(),
      consultingHours: d['consultingHours'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'role': role,
        'displayName': displayName,
        'pseudonym': pseudonym,
        'email': email,
        'isAnonymous': isAnonymous,
        'isActive': isActive,
        'onboardingComplete': onboardingComplete,
        'fcmToken': fcmToken,
        'studentId': studentId,
        'isDiuStudent': isDiuStudent ?? false,
        'studentIdVerified': studentIdVerified ?? false,
        'latestRiskLevel': latestRiskLevel,
        'consentGiven': consentGiven ?? false,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'campus': campus,
        'batch': batch,
        'preferredLanguage': preferredLanguage,
        'supportInterests': supportInterests ?? [],
        'isOnline': isOnline ?? false,
        'isOnCall': isOnCall ?? false,
        'isVerified': isVerified ?? false,
        'sessionFeeExternal': sessionFeeExternal ?? 1500,
        'sessionFeeDiu': sessionFeeDiu ?? 0,
        'specialties': specialties ?? [],
        'experienceYears': experienceYears,
        'education': education,
        'licenseNumber': licenseNumber,
        'consultationLanguages': consultationLanguages ?? ['English'],
        'officeLocation': officeLocation,
        'therapeuticApproaches': therapeuticApproaches ?? [],
        'consultingHours': consultingHours,
        'department': department,
        'academicYear': academicYear,
        'whyIVolunteer': whyIVolunteer,
        'badgeLevel': badgeLevel,
        'languagesSpoken': languagesSpoken ?? [],
        'supportTopics': supportTopics ?? [],
      };

  UserModel copyWith({
    String? role,
    String? studentId,
    bool? isDiuStudent,
    bool? isActive,
    bool? isOnline,
    bool? isOnCall,
    bool? isVerified,
    String? latestRiskLevel,
    String? photoBase64Thumb,
  }) =>
      UserModel(
        uid: uid,
        role: role ?? this.role,
        displayName: displayName,
        pseudonym: pseudonym,
        email: email,
        isAnonymous: isAnonymous,
        isActive: isActive ?? this.isActive,
        onboardingComplete: onboardingComplete,
        fcmToken: fcmToken,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt,
        studentId: studentId ?? this.studentId,
        isDiuStudent: isDiuStudent ?? this.isDiuStudent,
        studentIdVerified: studentIdVerified,
        latestRiskLevel: latestRiskLevel ?? this.latestRiskLevel,
        consentGiven: consentGiven,
        isOnline: isOnline ?? this.isOnline,
        totalChatsCompleted: totalChatsCompleted,
        title: title,
        specialties: specialties,
        bio: bio,
        photoBase64Thumb: photoBase64Thumb ?? this.photoBase64Thumb,
        isOnCall: isOnCall ?? this.isOnCall,
        isVerified: isVerified ?? this.isVerified,
        sessionFeeExternal: sessionFeeExternal,
        sessionFeeDiu: sessionFeeDiu,
      );
}
