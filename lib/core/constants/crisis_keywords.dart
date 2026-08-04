class CrisisDetectionResult {
  final bool detected;
  final String? level; // 'high' or 'medium'

  CrisisDetectionResult({required this.detected, this.level});
}

const List<String> kCrisisHighEn = [
  'suicide',
  'kill myself',
  'want to die',
  'end my life',
  'end it all',
  'not worth living',
  'better off dead',
];

const List<String> kCrisisMediumEn = [
  'self harm',
  'cut myself',
  'worthless',
  'no hope',
  'can\'t go on',
  'giving up',
];

CrisisDetectionResult detectCrisisClientSide(String message) {
  final lowerMsg = message.toLowerCase();

  for (final word in kCrisisHighEn) {
    if (lowerMsg.contains(word)) {
      return CrisisDetectionResult(detected: true, level: 'high');
    }
  }

  for (final word in kCrisisMediumEn) {
    if (lowerMsg.contains(word)) {
      return CrisisDetectionResult(detected: true, level: 'medium');
    }
  }

  return CrisisDetectionResult(detected: false);
}
