# GharManager

GharManager is a Flutter Android app foundation for property and rent management in Pakistan. The first milestone establishes app architecture, Supabase authentication plumbing, and a PostgreSQL schema with landlord/tenant Row Level Security.

## Requirements

- Flutter 3.47.9 or newer compatible stable release
- Android Studio and Android SDK
- A Supabase project for live authentication and database access

The SDK paths on this workstation are `D:\softwares\flutter`, `D:\softwares\Android Studio`, and `D:\softwares\Sdk`. Configure Flutter if needed:

```powershell
flutter config --android-sdk "D:\softwares\Sdk"
flutter doctor -v
```

Install Android SDK Command-line Tools and accept Android SDK licenses if Flutter Doctor requests them.

## Supabase setup

1. Create a Supabase project in the Supabase Dashboard.
2. Copy the Project URL and the **publishable key** from the project's Connect/API settings. A legacy anon key is also accepted.
3. Copy `env/development.example.json` to `env/development.json` and fill those two values. The real file is ignored by Git.
4. Never use a service-role or secret key in Flutter, a Dart define file, or any client-side configuration.
5. Apply the SQL migration in `supabase/migrations/202611080001_initial_schema.sql` using the Supabase CLI or the Dashboard SQL Editor. Review the migration before applying it to a production project.

The client key is public by design; authorization depends on Auth and RLS. Keep private credentials out of the mobile app.

## Run the app

From this folder:

```powershell
flutter pub get
flutter gen-l10n
flutter run --dart-define-from-file=env/development.json
```

With no credentials, the app opens a setup screen. `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` can also be passed as separate `--dart-define` values.

## Authentication behavior

- Landlord and tenant are the only roles offered at signup. Admin is never accepted from signup metadata.
- A database trigger creates the profile after Supabase Auth creates the account and normalizes unknown roles to tenant.
- Email verification is controlled by the Supabase project's Auth settings.
- Password reset uses Supabase Auth's email flow.
- Tenant signup alone does not grant access to any landlord or rental records. Linking a tenant account requires a trusted invitation redemption workflow; that Edge Function is not part of this milestone.

## Project structure

- `lib/core`: app configuration, routing, services, and themes
- `lib/features`: authentication and a small signed-in placeholder
- `lib/shared`: shared models and widgets
- `lib/l10n`: English and Urdu ARB translations, including RTL locale support
- `supabase/migrations`: versioned database schema and RLS policies
- `docs`: architecture, schema, and security notes

## Development checks

```powershell
flutter analyze
flutter test
```

Live signup, login, password reset, database access, and RLS isolation checks require Supabase credentials and separate landlord/tenant test accounts.
