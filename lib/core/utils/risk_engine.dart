enum RiskLevel { green, yellow, red }

class RiskResult {
  final int totalScore;
  final String severity;
  final RiskLevel riskLevel;
  final bool suicidalIdeationFlagged;
  final String instrument;

  const RiskResult({
    required this.totalScore,
    required this.severity,
    required this.riskLevel,
    required this.suicidalIdeationFlagged,
    required this.instrument,
  });

  RiskResult copyWith({
    RiskLevel? riskLevel,
    bool? suicidalIdeationFlagged,
    String? severity,
    String? instrument,
  }) =>
      RiskResult(
        totalScore: totalScore,
        severity: severity ?? this.severity,
        riskLevel: riskLevel ?? this.riskLevel,
        suicidalIdeationFlagged:
            suicidalIdeationFlagged ?? this.suicidalIdeationFlagged,
        instrument: instrument ?? this.instrument,
      );
}

class RiskEngine {
  RiskEngine._();

  static RiskResult scorePHQ9(List<int> answers) {
    int total = answers.fold(0, (sum, val) => sum + val);
    bool q9Flag = false;
    String severity = 'minimal';
    RiskLevel riskLevel = RiskLevel.green;

    if (answers.length == 9 && answers[8] > 0) {
      q9Flag = true;
      riskLevel = RiskLevel.red;
      severity = 'severe';
    }

    if (total >= 20) {
      severity = 'severe';
      riskLevel = RiskLevel.red;
    } else if (total >= 15) {
      severity = 'moderatelySevere';
      riskLevel = RiskLevel.red;
    } else if (total >= 10) {
      severity = 'moderate';
      riskLevel = RiskLevel.yellow;
    } else if (total >= 5) {
      severity = 'mild';
      riskLevel = RiskLevel.green;
    }

    // Q9 Override
    if (q9Flag) {
      riskLevel = RiskLevel.red;
    }

    return RiskResult(
      totalScore: total,
      severity: severity,
      riskLevel: riskLevel,
      suicidalIdeationFlagged: q9Flag,
      instrument: 'PHQ9',
    );
  }

  static RiskResult scoreGAD7(List<int> answers) {
    int total = answers.fold(0, (sum, val) => sum + val);

    String severity = 'minimal';
    RiskLevel riskLevel = RiskLevel.green;

    if (total >= 15) {
      severity = 'severe';
      riskLevel = RiskLevel.red;
    } else if (total >= 10) {
      severity = 'moderate';
      riskLevel = RiskLevel.yellow;
    } else if (total >= 5) {
      severity = 'mild';
      riskLevel = RiskLevel.green;
    }

    return RiskResult(
      totalScore: total,
      suicidalIdeationFlagged: false,
      severity: severity,
      riskLevel: riskLevel,
      instrument: 'GAD7',
    );
  }

  static String severityDisplayLabel(String severity) {
    switch (severity) {
      case 'minimal':
        return 'Minimal Symptoms';
      case 'mild':
        return 'Mild Symptoms';
      case 'moderate':
        return 'Moderate Symptoms';
      case 'moderatelySevere':
        return 'Moderately Severe';
      case 'severe':
        return 'Severe Symptoms';
      default:
        return severity;
    }
  }

  static String riskLevelDisplayLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return '🟢 Low Risk';
      case RiskLevel.yellow:
        return '🟡 Moderate Risk';
      case RiskLevel.red:
        return '🔴 High Risk';
    }
  }

  static String recommendedAction(RiskLevel level, String instrument) {
    switch (level) {
      case RiskLevel.red:
        return 'Your responses suggest you may be going through a very difficult time. '
            'Please reach out to a crisis helpline or talk to a professional as soon as possible. '
            'You are not alone, and help is available right now.';
      case RiskLevel.yellow:
        return 'Your responses indicate moderate symptoms. We recommend talking to '
            'a peer volunteer or booking a session with one of our psychologists. '
            'Early support can make a real difference.';
      case RiskLevel.green:
        return 'Great news - your responses suggest minimal symptoms right now. '
            'Keep taking care of yourself, and explore our self-care resources '
            'to maintain your wellbeing.';
    }
  }
}
