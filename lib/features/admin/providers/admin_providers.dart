import '../../../shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/admin_repository.dart';
import '../../../shared/models/incident_model.dart';
import '../../../shared/models/audit_log_model.dart';

part 'admin_providers.g.dart';

@riverpod
AdminRepository adminRepository(Ref ref) {
  return AdminRepository();
}

@riverpod
Stream<List<UserModel>> allUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchAllUsers();
}

@riverpod
Stream<List<UserModel>> pendingStudents(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchPendingVerifications();
}

@riverpod
Stream<List<IncidentModel>> allIncidents(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchIncidents();
}

@riverpod
Stream<List<AuditLogModel>> allAuditLogs(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchAuditLogs();
}

@riverpod
Stream<List<UserModel>> psychologistUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchUsersByRole('psychologist');
}

@riverpod
Stream<List<UserModel>> volunteerUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchUsersByRole('volunteer');
}
