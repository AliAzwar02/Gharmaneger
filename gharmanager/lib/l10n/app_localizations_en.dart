// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GharManager';

  @override
  String get splashEyebrow => 'FINTECH + PROPTECH SUITE';

  @override
  String get splashTagline => 'Smart Living & Rent Management';

  @override
  String get splashTrustMessage =>
      'Digital Rent Collection & NADRA-Verified Leases';

  @override
  String get splashReady => 'Ready!';

  @override
  String get splashCurrency => 'PKR • Rs';

  @override
  String get splashCountryTrust => 'Pakistan\'s Trusted PropTech Platform';

  @override
  String get setupTitle => 'Connect your Supabase project';

  @override
  String get setupDescription =>
      'Add the project URL and client key at build time to enable authentication and data access.';

  @override
  String get setupSecurityNote =>
      'Use only the publishable key (or legacy anon key) in this app. Never put a service-role or secret key in a mobile app.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to manage your rental account.';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get fullName => 'Full name';

  @override
  String get accountType => 'I am signing up as';

  @override
  String get landlord => 'Landlord';

  @override
  String get tenant => 'Tenant';

  @override
  String get invitationAccessNote =>
      'Tenant accounts can only access a rental after a landlord invitation is securely accepted.';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get validEmailRequired => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get passwordMinLength => 'Use at least 8 characters.';

  @override
  String get genericAuthError =>
      'We could not complete that request. Please try again.';

  @override
  String get checkEmail =>
      'Account created. Check your email to verify it before signing in.';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetEmailSent =>
      'If the account exists, a password reset email has been sent.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get foundationReady => 'Your account is connected';

  @override
  String get dashboardPlaceholder =>
      'Property and rent dashboards will be added in the next milestone.';

  @override
  String get setupRequired =>
      'Supabase configuration is required before signing in.';
}
