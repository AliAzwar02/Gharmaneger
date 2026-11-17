# Architecture

## Flutter

The app uses a feature-oriented layout. Screens contain form and presentation state; `AuthenticationRepository` is the data boundary for Supabase Auth. Riverpod provides the Supabase client and repository, while GoRouter owns route transitions and redirects when Supabase Auth emits session changes.

The app initializes Supabase only when a syntactically valid URL and client key are provided with Dart defines. Without them, it renders a setup screen so the app remains launchable without inventing credentials. Supabase's publishable key (or legacy anon key) is acceptable in a client app; service-role and secret keys are not.

Localization uses Flutter's generated localization framework from `lib/l10n/app_*.arb`. English and Urdu are supported. Flutter's Urdu locale metadata supplies RTL directionality.

## Authentication foundation

- Signup metadata contains only a chosen `landlord` or `tenant` role and the display name.
- A database trigger creates the matching profile. Its role allowlist never accepts `admin` from user metadata.
- Profile role changes are not granted to authenticated users at the SQL column privilege layer.
- Session persistence is handled by Supabase Flutter; GoRouter reacts to Auth state changes.
- Password reset delegates to Supabase Auth. Email verification and redirect URLs must be configured in the Supabase project.
- A tenant account is not linked to a rental record by signup. The invitations table is prepared, but invitation creation/redemption and email delivery must be implemented in a trusted Supabase Edge Function before tenant assignment is enabled.

## Backend

PostgreSQL is the source of truth. UUID identifiers, foreign keys, restrictive delete behavior for financial history, unique lease/invoice constraints, and RLS policies are in the initial migration. Monetary fields use `numeric(12,2)`.

Apply schema changes through ordered SQL migrations. Avoid dashboard-only schema changes. Private document storage policies and signed URL issuance are a follow-on before uploading CNIC or lease documents.
