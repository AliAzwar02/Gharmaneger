# Security notes

## Implemented in the initial migration

- RLS is enabled for every application table in the migration.
- Landlords are scoped to their properties and related units, tenants, leases, bills, invoices, payments, and maintenance requests.
- Tenants are scoped through their linked tenant record and lease. A tenant cannot choose a landlord or tenant ID when submitting a payment; a trigger derives both parties from the lease.
- The tenant table's client insert/update grants omit `user_id` and `landlord_id` updates. Client signup cannot attach an account to an arbitrary landlord.
- Authenticated users cannot insert/update profile roles. The auth trigger accepts only landlord or tenant and falls back to tenant; admin must be provisioned through a trusted administrative path.
- Payment claims start as `submitted`. Tenants have no update grant. A landlord can only move a submitted claim to verified or rejected, and a trigger records reviewer and review time.
- Duplicate monthly rent records and multiple active leases for one unit are blocked by database constraints/indexes.
- The invitation table exposes no client write path. Invitation token redemption belongs in a trusted Edge Function.

## Required before production

- Implement and security-review Edge Functions for invitation creation/redemption, payment verification/allocation, notifications, and scheduled rent generation.
- Add audited, transactional payment allocation logic before allowing verified payments to affect invoice balances.
- Create private Storage buckets and owner/tenant RLS for documents; issue short-lived signed URLs server-side.
- Configure Supabase email verification, password reset redirects, rate limits, and production URL allowlists.
- Provision the first admin through a trusted SQL/admin operation. Never allow a client to promote itself.
- Run policy tests in Supabase with at least two landlord users and two tenant users before production. Those live checks cannot run until a Supabase project is connected.

## Client configuration

The Flutter binary receives `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` at build time. Publishable/anon keys are client credentials protected by RLS, not secrets. A service-role key, secret API key, database password, or signing secret must never be added to the app or its build defines.
