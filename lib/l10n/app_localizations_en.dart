// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MindCare@DIU';

  @override
  String get crisisHeadline => 'You are not alone right now.';

  @override
  String get crisisSubtext =>
      'This page works without internet. Please read through these steps.';

  @override
  String get callNow => 'Call Now';

  @override
  String get kaanPeteRoi => 'Kaan Pete Roi';

  @override
  String get nationalEmergency => 'National Emergency';

  @override
  String get startConversation => 'Start a Conversation';

  @override
  String get home => 'Home';

  @override
  String get screening => 'Screening';

  @override
  String get talk => 'Talk';

  @override
  String get learn => 'Learn';

  @override
  String get settings => 'Settings';

  @override
  String get takePHQ9 => 'Depression Check (PHQ9)';

  @override
  String get takeGAD7 => 'Anxiety Check (GAD7)';

  @override
  String get phq9Description =>
      '9 questions about how you have been feeling over the past 2 weeks';

  @override
  String get gad7Description =>
      '7 questions about anxiety and worry over the past 2 weeks';

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get notAtAll => 'Not at all';

  @override
  String get severalDays => 'Several days';

  @override
  String get moreThanHalfDays => 'More than half the days';

  @override
  String get nearlyEveryDay => 'Nearly every day';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get moderateRisk => 'Moderate Risk';

  @override
  String get highRisk => 'High Risk — Immediate Support';

  @override
  String get yourScore => 'Your Score';

  @override
  String get bookSession => 'Book a Session';

  @override
  String get freeForDiuStudents => 'Free for DIU Students';

  @override
  String perSession(int amount) {
    return '৳$amount / session';
  }

  @override
  String get paymentTitle => 'Complete Payment';

  @override
  String get paymentSuccess => 'Payment Successful';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get howAreYouFeeling => 'How are you feeling today?';

  @override
  String get moodGreat => 'Great';

  @override
  String get moodGood => 'Good';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodLow => 'Low';

  @override
  String get moodDifficult => 'Difficult';

  @override
  String get addNote => 'Add a note (optional)';

  @override
  String get logMood => 'Log Mood';

  @override
  String get onlineToggle => 'I am available to chat';

  @override
  String get offlineToggle => 'Mark as offline';

  @override
  String get onCallToggle => 'I am on-call for crisis alerts';

  @override
  String get escalate => 'Escalate';

  @override
  String get consentTitle => 'Your privacy matters here.';

  @override
  String get iAgree => 'I understand and agree';

  @override
  String get takeMeToCrisis => 'Take me to Crisis Resources';

  @override
  String get yourPseudonym => 'Your private name on MindCare is:';

  @override
  String get pseudonymExplanation =>
      'This name is private. Use it when talking to volunteers and psychologists.';

  @override
  String get selectLanguage => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get deleteAccount => 'Delete My Account';

  @override
  String get secureAccount => 'Secure Your Account';

  @override
  String get linkEmail =>
      'Link an email to recover your account if you lose your device';

  @override
  String get offlineBanner =>
      'You are offline — some features may be unavailable';

  @override
  String get slotTaken =>
      'This slot was just taken — please choose another time';

  @override
  String get sessionSummaryHint => 'Write a brief summary of this session...';

  @override
  String get saveSummary => 'Save Summary';

  @override
  String get endSession => 'End Session';

  @override
  String get rateYourSession => 'How was your session?';

  @override
  String get submitFeedback => 'Submit';

  @override
  String get waitingForVolunteer => 'Waiting for a volunteer...';

  @override
  String get volunteerConnected => 'A volunteer has joined.';

  @override
  String get sessionEnded => 'This session has ended.';

  @override
  String get noSlotsAvailable =>
      'No slots available for this week. Check back soon.';

  @override
  String get verifyDiuStudent => 'Verify DIU Student Status';

  @override
  String get adminApproveStudent => 'Approve';

  @override
  String get adminRejectStudent => 'Reject';

  @override
  String crisisAlertReceived(String pseudonym) {
    return 'Crisis alert for student $pseudonym. Open the incidents page.';
  }

  @override
  String get phq9Preamble =>
      'Over the last 2 weeks, how often have you been bothered by any of the following problems?';

  @override
  String get phq9Q1 => 'Little interest or pleasure in doing things';

  @override
  String get phq9Q2 => 'Feeling down, depressed, or hopeless';

  @override
  String get phq9Q3 =>
      'Trouble falling or staying asleep, or sleeping too much';

  @override
  String get phq9Q4 => 'Feeling tired or having little energy';

  @override
  String get phq9Q5 => 'Poor appetite or overeating';

  @override
  String get phq9Q6 =>
      'Feeling bad about yourself — or that you are a failure or have let yourself or your family down';

  @override
  String get phq9Q7 =>
      'Trouble concentrating on things, such as reading the newspaper or watching television';

  @override
  String get phq9Q8 =>
      'Moving or speaking so slowly that other people could have noticed — or the opposite, being so fidgety or restless that you have been moving around a lot more than usual';

  @override
  String get phq9Q9 =>
      'Thoughts that you would be better off dead, or thoughts of hurting yourself in some way';

  @override
  String get gad7Preamble =>
      'Over the last 2 weeks, how often have you been bothered by the following problems?';

  @override
  String get gad7Q1 => 'Feeling nervous, anxious, or on edge';

  @override
  String get gad7Q2 => 'Not being able to stop or control worrying';

  @override
  String get gad7Q3 => 'Worrying too much about different things';

  @override
  String get gad7Q4 => 'Trouble relaxing';

  @override
  String get gad7Q5 => 'Being so restless that it is hard to sit still';

  @override
  String get gad7Q6 => 'Becoming easily annoyed or irritable';

  @override
  String get gad7Q7 => 'Feeling afraid, as if something awful might happen';
}
