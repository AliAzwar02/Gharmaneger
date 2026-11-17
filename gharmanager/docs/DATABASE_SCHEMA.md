# Database schema

The initial migration is `supabase/migrations/202611080001_initial_schema.sql`.

| Table | Purpose and key relationships |
| --- | --- |
| `profiles` | One profile per `auth.users` account; role is landlord, tenant, or admin. |
| `properties` | Landlord-owned property records. |
| `units` | Units/portions belonging to one property. |
| `tenants` | Landlord-managed rental identity, separate from a login; optional unique `user_id` link. |
| `leases` | Connects one tenant record to one unit for a dated rental period. |
| `rent_records` | Monthly rent invoices for a lease. Unique `(lease_id, billing_month)` prevents duplicate months. |
| `utility_bills` | Lease-scoped utility and service charges. `document_path` stores a private object path, not a signed URL. |
| `payments` | Tenant payment claims. A trigger derives tenant and landlord from the lease and forces new claims to `submitted`. |
| `payment_allocations` | Connects a verified payment to exactly one rent invoice or utility bill. Client write grants are withheld pending a trusted allocation workflow. |
| `notifications` | Per-user notification history. |
| `maintenance_requests` | Tenant-submitted and landlord-updated lease requests. |
| `invitations` | Stores invitation token hashes and expiry. No client write grants; trusted Edge Function work remains. |

There can be at most one active lease per unit. Lease and invoice history is protected by restrictive foreign-key delete behavior. Amounts use `numeric(12,2)`, and billing months must be the first day of their month.

No fake users, properties, or financial rows are seeded. Tables with user data have RLS enabled. Policies scope rows to the owning landlord, the tenant linked to the lease, or an explicitly provisioned admin. Authenticated grants are narrower than table-wide CRUD where client-supplied fields could alter roles, tenant links, payment parties, or notification content.
