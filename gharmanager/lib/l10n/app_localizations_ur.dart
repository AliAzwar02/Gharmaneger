// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'گھر مینیجر';

  @override
  String get splashEyebrow => 'فِن ٹیک + پراپ ٹیک پلیٹ فارم';

  @override
  String get splashTagline => 'آسان رہائش اور کرایہ مینجمنٹ';

  @override
  String get splashTrustMessage =>
      'ڈیجیٹل کرایہ وصولی اور نادرا سے تصدیق شدہ معاہدے';

  @override
  String get splashReady => 'تیار ہے!';

  @override
  String get splashCurrency => 'پاکستانی روپیہ';

  @override
  String get splashCountryTrust => 'پاکستان کا قابلِ اعتماد پراپ ٹیک پلیٹ فارم';

  @override
  String get setupTitle => 'اپنے Supabase پروجیکٹ سے منسلک کریں';

  @override
  String get setupDescription =>
      'تصدیق اور ڈیٹا تک رسائی کے لیے پروجیکٹ کا URL اور کلائنٹ کی محفوظ طریقے سے شامل کریں۔';

  @override
  String get setupSecurityNote =>
      'صرف publishable key یا پرانی anon key استعمال کریں۔ موبائل ایپ میں service-role یا secret key ہرگز شامل نہ کریں۔';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get signInSubtitle =>
      'اپنے کرایہ اکاؤنٹ کا انتظام کرنے کے لیے سائن اِن کریں۔';

  @override
  String get email => 'ای میل پتہ';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get signIn => 'سائن اِن';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get fullName => 'پورا نام';

  @override
  String get accountType => 'میں کس حیثیت سے اکاؤنٹ بنا رہا/رہی ہوں';

  @override
  String get landlord => 'مالک مکان';

  @override
  String get tenant => 'کرایہ دار';

  @override
  String get invitationAccessNote =>
      'کرایہ دار کو اپنی رہائش تک رسائی مالک مکان کی محفوظ دعوت قبول کرنے کے بعد ملے گی۔';

  @override
  String get requiredField => 'یہ خانہ پُر کرنا ضروری ہے۔';

  @override
  String get validEmailRequired => 'درست ای میل پتہ درج کریں۔';

  @override
  String get passwordRequired => 'اپنا پاس ورڈ درج کریں۔';

  @override
  String get passwordMinLength => 'کم از کم 8 حروف استعمال کریں۔';

  @override
  String get genericAuthError => 'درخواست مکمل نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get checkEmail =>
      'اکاؤنٹ بن گیا۔ سائن اِن سے پہلے تصدیق کے لیے ای میل دیکھیں۔';

  @override
  String get resetPasswordTitle => 'پاس ورڈ دوبارہ ترتیب دیں';

  @override
  String get sendResetLink => 'ری سیٹ لنک بھیجیں';

  @override
  String get resetEmailSent =>
      'اگر یہ اکاؤنٹ موجود ہے تو پاس ورڈ ری سیٹ ای میل بھیج دی گئی ہے۔';

  @override
  String get backToSignIn => 'سائن اِن پر واپس جائیں';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get foundationReady => 'آپ کا اکاؤنٹ منسلک ہے';

  @override
  String get dashboardPlaceholder =>
      'پراپرٹی اور کرایہ ڈیش بورڈ اگلے مرحلے میں شامل ہوں گے۔';

  @override
  String get setupRequired => 'سائن اِن سے پہلے Supabase کی ترتیب ضروری ہے۔';
}
