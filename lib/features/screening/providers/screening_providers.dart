import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/screening_repository.dart';

final screeningRepositoryProvider =
    Provider<ScreeningRepository>((ref) => ScreeningRepository());
