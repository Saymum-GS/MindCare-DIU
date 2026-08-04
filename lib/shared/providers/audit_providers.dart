import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_repository.dart';
import '../models/audit_log_model.dart';

final auditRepositoryProvider =
    Provider<AuditRepository>((ref) => AuditRepository());

final allAuditLogsProvider = StreamProvider<List<AuditLogModel>>((ref) {
  return ref.watch(auditRepositoryProvider).watchAuditLogs();
});
