import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MindCare@DIU'**
  String get appTitle;

  /// No description provided for @crisisHeadline.
  ///
  /// In en, this message translates to:
  /// **'You are not alone right now.'**
  String get crisisHeadline;

  /// No description provided for @crisisSubtext.
  ///
  /// In en, this message translates to:
  /// **'This page works without internet. Please read through these steps.'**
  String get crisisSubtext;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @kaanPeteRoi.
  ///
  /// In en, this message translates to:
  /// **'Kaan Pete Roi'**
  String get kaanPeteRoi;

  /// No description provided for @nationalEmergency.
  ///
  /// In en, this message translates to:
  /// **'National Emergency'**
  String get nationalEmergency;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a Conversation'**
  String get startConversation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @screening.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get screening;

  /// No description provided for @talk.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get talk;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @takePHQ9.
  ///
  /// In en, this message translates to:
  /// **'Depression Check (PHQ9)'**
  String get takePHQ9;

  /// No description provided for @takeGAD7.
  ///
  /// In en, this message translates to:
  /// **'Anxiety Check (GAD7)'**
  String get takeGAD7;

  /// No description provided for @phq9Description.
  ///
  /// In en, this message translates to:
  /// **'9 questions about how you have been feeling over the past 2 weeks'**
  String get phq9Description;

  /// No description provided for @gad7Description.
  ///
  /// In en, this message translates to:
  /// **'7 questions about anxiety and worry over the past 2 weeks'**
  String get gad7Description;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOf(int current, int total);

  /// No description provided for @notAtAll.
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get notAtAll;

  /// No description provided for @severalDays.
  ///
  /// In en, this message translates to:
  /// **'Several days'**
  String get severalDays;

  /// No description provided for @moreThanHalfDays.
  ///
  /// In en, this message translates to:
  /// **'More than half the days'**
  String get moreThanHalfDays;

  /// No description provided for @nearlyEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Nearly every day'**
  String get nearlyEveryDay;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @moderateRisk.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get moderateRisk;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk — Immediate Support'**
  String get highRisk;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @bookSession.
  ///
  /// In en, this message translates to:
  /// **'Book a Session'**
  String get bookSession;

  /// No description provided for @freeForDiuStudents.
  ///
  /// In en, this message translates to:
  /// **'Free for DIU Students'**
  String get freeForDiuStudents;

  /// No description provided for @perSession.
  ///
  /// In en, this message translates to:
  /// **'৳{amount} / session'**
  String perSession(int amount);

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get paymentTitle;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccess;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeeling;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @moodDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get moodDifficult;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNote;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// No description provided for @onlineToggle.
  ///
  /// In en, this message translates to:
  /// **'I am available to chat'**
  String get onlineToggle;

  /// No description provided for @offlineToggle.
  ///
  /// In en, this message translates to:
  /// **'Mark as offline'**
  String get offlineToggle;

  /// No description provided for @onCallToggle.
  ///
  /// In en, this message translates to:
  /// **'I am on-call for crisis alerts'**
  String get onCallToggle;

  /// No description provided for @escalate.
  ///
  /// In en, this message translates to:
  /// **'Escalate'**
  String get escalate;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters here.'**
  String get consentTitle;

  /// No description provided for @iAgree.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get iAgree;

  /// No description provided for @takeMeToCrisis.
  ///
  /// In en, this message translates to:
  /// **'Take me to Crisis Resources'**
  String get takeMeToCrisis;

  /// No description provided for @yourPseudonym.
  ///
  /// In en, this message translates to:
  /// **'Your private name on MindCare is:'**
  String get yourPseudonym;

  /// No description provided for @pseudonymExplanation.
  ///
  /// In en, this message translates to:
  /// **'This name is private. Use it when talking to volunteers and psychologists.'**
  String get pseudonymExplanation;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccount;

  /// No description provided for @secureAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Account'**
  String get secureAccount;

  /// No description provided for @linkEmail.
  ///
  /// In en, this message translates to:
  /// **'Link an email to recover your account if you lose your device'**
  String get linkEmail;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline — some features may be unavailable'**
  String get offlineBanner;

  /// No description provided for @slotTaken.
  ///
  /// In en, this message translates to:
  /// **'This slot was just taken — please choose another time'**
  String get slotTaken;

  /// No description provided for @sessionSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief summary of this session...'**
  String get sessionSummaryHint;

  /// No description provided for @saveSummary.
  ///
  /// In en, this message translates to:
  /// **'Save Summary'**
  String get saveSummary;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// No description provided for @rateYourSession.
  ///
  /// In en, this message translates to:
  /// **'How was your session?'**
  String get rateYourSession;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitFeedback;

  /// No description provided for @waitingForVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a volunteer...'**
  String get waitingForVolunteer;

  /// No description provided for @volunteerConnected.
  ///
  /// In en, this message translates to:
  /// **'A volunteer has joined.'**
  String get volunteerConnected;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'This session has ended.'**
  String get sessionEnded;

  /// No description provided for @noSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No slots available for this week. Check back soon.'**
  String get noSlotsAvailable;

  /// No description provided for @verifyDiuStudent.
  ///
  /// In en, this message translates to:
  /// **'Verify DIU Student Status'**
  String get verifyDiuStudent;

  /// No description provided for @adminApproveStudent.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApproveStudent;

  /// No description provided for @adminRejectStudent.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminRejectStudent;

  /// No description provided for @crisisAlertReceived.
  ///
  /// In en, this message translates to:
  /// **'Crisis alert for student {pseudonym}. Open the incidents page.'**
  String crisisAlertReceived(String pseudonym);

  /// No description provided for @phq9Preamble.
  ///
  /// In en, this message translates to:
  /// **'Over the last 2 weeks, how often have you been bothered by any of the following problems?'**
  String get phq9Preamble;

  /// No description provided for @phq9Q1.
  ///
  /// In en, this message translates to:
  /// **'Little interest or pleasure in doing things'**
  String get phq9Q1;

  /// No description provided for @phq9Q2.
  ///
  /// In en, this message translates to:
  /// **'Feeling down, depressed, or hopeless'**
  String get phq9Q2;

  /// No description provided for @phq9Q3.
  ///
  /// In en, this message translates to:
  /// **'Trouble falling or staying asleep, or sleeping too much'**
  String get phq9Q3;

  /// No description provided for @phq9Q4.
  ///
  /// In en, this message translates to:
  /// **'Feeling tired or having little energy'**
  String get phq9Q4;

  /// No description provided for @phq9Q5.
  ///
  /// In en, this message translates to:
  /// **'Poor appetite or overeating'**
  String get phq9Q5;

  /// No description provided for @phq9Q6.
  ///
  /// In en, this message translates to:
  /// **'Feeling bad about yourself — or that you are a failure or have let yourself or your family down'**
  String get phq9Q6;

  /// No description provided for @phq9Q7.
  ///
  /// In en, this message translates to:
  /// **'Trouble concentrating on things, such as reading the newspaper or watching television'**
  String get phq9Q7;

  /// No description provided for @phq9Q8.
  ///
  /// In en, this message translates to:
  /// **'Moving or speaking so slowly that other people could have noticed — or the opposite, being so fidgety or restless that you have been moving around a lot more than usual'**
  String get phq9Q8;

  /// No description provided for @phq9Q9.
  ///
  /// In en, this message translates to:
  /// **'Thoughts that you would be better off dead, or thoughts of hurting yourself in some way'**
  String get phq9Q9;

  /// No description provided for @gad7Preamble.
  ///
  /// In en, this message translates to:
  /// **'Over the last 2 weeks, how often have you been bothered by the following problems?'**
  String get gad7Preamble;

  /// No description provided for @gad7Q1.
  ///
  /// In en, this message translates to:
  /// **'Feeling nervous, anxious, or on edge'**
  String get gad7Q1;

  /// No description provided for @gad7Q2.
  ///
  /// In en, this message translates to:
  /// **'Not being able to stop or control worrying'**
  String get gad7Q2;

  /// No description provided for @gad7Q3.
  ///
  /// In en, this message translates to:
  /// **'Worrying too much about different things'**
  String get gad7Q3;

  /// No description provided for @gad7Q4.
  ///
  /// In en, this message translates to:
  /// **'Trouble relaxing'**
  String get gad7Q4;

  /// No description provided for @gad7Q5.
  ///
  /// In en, this message translates to:
  /// **'Being so restless that it is hard to sit still'**
  String get gad7Q5;

  /// No description provided for @gad7Q6.
  ///
  /// In en, this message translates to:
  /// **'Becoming easily annoyed or irritable'**
  String get gad7Q6;

  /// No description provided for @gad7Q7.
  ///
  /// In en, this message translates to:
  /// **'Feeling afraid, as if something awful might happen'**
  String get gad7Q7;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
