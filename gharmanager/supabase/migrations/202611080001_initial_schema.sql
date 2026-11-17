-- GharManager foundation schema.
-- Apply with Supabase CLI or the SQL editor. No sample users or credentials are seeded.

create type public.app_role as enum ('landlord', 'tenant', 'admin');
create type public.property_status as enum ('active', 'inactive', 'archived');
create type public.unit_status as enum ('vacant', 'occupied', 'unavailable');
create type public.lease_status as enum ('draft', 'active', 'ended', 'terminated');
create type public.rent_status as enum ('draft', 'pending', 'partially_paid', 'paid', 'overdue', 'cancelled');
create type public.bill_status as enum ('pending', 'partially_paid', 'paid', 'overdue', 'cancelled');
create type public.payment_status as enum ('submitted', 'verified', 'rejected');
create type public.maintenance_status as enum ('submitted', 'in_progress', 'completed', 'rejected');
create type public.maintenance_priority as enum ('low', 'normal', 'high', 'urgent');
create type public.invitation_status as enum ('pending', 'accepted', 'revoked', 'expired');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '' check (char_length(full_name) <= 160),
  email text not null default '' check (char_length(email) <= 320),
  phone text check (phone is null or char_length(phone) <= 32),
  role public.app_role not null default 'tenant',
  preferred_language text not null default 'en' check (preferred_language in ('en', 'ur')),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  requested_role text := new.raw_user_meta_data ->> 'role';
begin
  insert into public.profiles (id, full_name, email, phone, role, preferred_language)
  values (
    new.id,
    coalesce(nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''), ''),
    coalesce(new.email, ''),
    nullif(btrim(new.raw_user_meta_data ->> 'phone'), ''),
    case requested_role when 'landlord' then 'landlord'::public.app_role
                        when 'tenant' then 'tenant'::public.app_role
                        else 'tenant'::public.app_role end,
    case new.raw_user_meta_data ->> 'preferred_language'
      when 'ur' then 'ur' else 'en' end
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'::public.app_role
  );
$$;

create or replace function public.is_landlord()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'landlord'::public.app_role
  );
$$;

create or replace function public.is_property_landlord(target_property uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.properties p
    join public.profiles profile on profile.id = p.landlord_id
    where p.id = target_property and p.landlord_id = (select auth.uid())
      and profile.role = 'landlord'::public.app_role
  );
$$;

create or replace function public.is_property_tenant(target_property uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.leases l
    join public.units u on u.id = l.unit_id
    join public.tenants t on t.id = l.tenant_id
    join public.profiles profile on profile.id = t.user_id
    where u.property_id = target_property and t.user_id = (select auth.uid())
      and profile.role = 'tenant'::public.app_role
  );
$$;

create or replace function public.is_unit_landlord(target_unit uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.units u
    join public.properties p on p.id = u.property_id
    join public.profiles profile on profile.id = p.landlord_id
    where u.id = target_unit and p.landlord_id = (select auth.uid())
      and profile.role = 'landlord'::public.app_role
  );
$$;

create or replace function public.is_unit_tenant(target_unit uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.leases l
    join public.tenants t on t.id = l.tenant_id
    join public.profiles profile on profile.id = t.user_id
    where l.unit_id = target_unit and t.user_id = (select auth.uid())
      and profile.role = 'tenant'::public.app_role
  );
$$;

create or replace function public.is_tenant_landlord(target_tenant uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tenants t
    join public.profiles profile on profile.id = t.landlord_id
    where t.id = target_tenant and t.landlord_id = (select auth.uid())
      and profile.role = 'landlord'::public.app_role
  );
$$;

create or replace function public.is_tenant_user(target_tenant uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tenants t
    join public.profiles profile on profile.id = t.user_id
    where t.id = target_tenant and t.user_id = (select auth.uid())
      and profile.role = 'tenant'::public.app_role
  );
$$;

create table public.properties (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid not null references public.profiles(id) on delete restrict,
  property_name text not null check (char_length(btrim(property_name)) between 1 and 160),
  property_type text not null check (property_type in ('house', 'apartment', 'building', 'commercial', 'portion')),
  address text not null check (char_length(btrim(address)) between 1 and 500),
  city text not null check (char_length(btrim(city)) between 1 and 120),
  area text check (area is null or char_length(area) <= 120),
  description text check (description is null or char_length(description) <= 4000),
  status public.property_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.units (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete restrict,
  unit_name text not null check (char_length(btrim(unit_name)) between 1 and 120),
  monthly_rent numeric(12, 2) not null check (monthly_rent >= 0),
  security_deposit numeric(12, 2) not null default 0 check (security_deposit >= 0),
  status public.unit_status not null default 'vacant',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, unit_name)
);

create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references public.profiles(id) on delete set null,
  landlord_id uuid not null references public.profiles(id) on delete restrict,
  full_name text not null check (char_length(btrim(full_name)) between 1 and 160),
  phone text check (phone is null or char_length(phone) <= 32),
  email text check (email is null or char_length(email) <= 320),
  cnic_number text check (cnic_number is null or char_length(cnic_number) <= 32),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.leases (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units(id) on delete restrict,
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  start_date date not null,
  end_date date,
  monthly_rent numeric(12, 2) not null check (monthly_rent >= 0),
  due_day smallint not null check (due_day between 1 and 31),
  security_deposit numeric(12, 2) not null default 0 check (security_deposit >= 0),
  status public.lease_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date is null or end_date >= start_date)
);

create unique index leases_one_active_per_unit
  on public.leases(unit_id) where status = 'active';
create index leases_tenant_id_idx on public.leases(tenant_id);

create or replace function public.validate_lease_assignment()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  unit_owner uuid;
  tenant_owner uuid;
begin
  select p.landlord_id into unit_owner
  from public.units u join public.properties p on p.id = u.property_id
  where u.id = new.unit_id;
  select t.landlord_id into tenant_owner
  from public.tenants t where t.id = new.tenant_id;
  if unit_owner is null or tenant_owner is null or unit_owner <> tenant_owner then
    raise exception 'Lease unit and tenant must belong to the same landlord';
  end if;
  return new;
end;
$$;

create trigger leases_validate_assignment
  before insert or update of unit_id, tenant_id on public.leases
  for each row execute function public.validate_lease_assignment();

create table public.rent_records (
  id uuid primary key default gen_random_uuid(),
  lease_id uuid not null references public.leases(id) on delete restrict,
  invoice_number text not null unique check (char_length(btrim(invoice_number)) between 1 and 64),
  billing_month date not null check (extract(day from billing_month) = 1),
  amount numeric(12, 2) not null check (amount > 0),
  paid_amount numeric(12, 2) not null default 0 check (paid_amount >= 0 and paid_amount <= amount),
  due_date date not null,
  status public.rent_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (lease_id, billing_month)
);
create index rent_records_due_date_idx on public.rent_records(due_date, status);
create index rent_records_lease_id_idx on public.rent_records(lease_id);

create table public.utility_bills (
  id uuid primary key default gen_random_uuid(),
  lease_id uuid not null references public.leases(id) on delete restrict,
  bill_type text not null check (bill_type in ('electricity', 'gas', 'water', 'internet', 'maintenance', 'other')),
  amount numeric(12, 2) not null check (amount > 0),
  billing_month date not null check (extract(day from billing_month) = 1),
  issue_date date not null,
  due_date date not null,
  document_path text check (document_path is null or char_length(document_path) <= 1024),
  status public.bill_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (due_date >= issue_date)
);
create index utility_bills_lease_due_idx on public.utility_bills(lease_id, due_date, status);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  lease_id uuid not null references public.leases(id) on delete restrict,
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  landlord_id uuid not null references public.profiles(id) on delete restrict,
  amount numeric(12, 2) not null check (amount > 0),
  payment_method text not null check (payment_method in ('cash', 'bank_transfer', 'easypaisa', 'jazzcash', 'other', 'online')),
  transaction_reference text check (transaction_reference is null or char_length(transaction_reference) <= 160),
  payment_status public.payment_status not null default 'submitted',
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  check ((payment_status = 'submitted' and reviewed_at is null) or
         (payment_status in ('verified', 'rejected') and reviewed_at is not null))
);
create index payments_lease_created_idx on public.payments(lease_id, created_at desc);
create unique index payments_landlord_reference_unique
  on public.payments(landlord_id, transaction_reference)
  where transaction_reference is not null and transaction_reference <> '';

create or replace function public.prepare_payment_submission()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  assigned_tenant uuid;
  assigned_landlord uuid;
begin
  select t.id, p.landlord_id into assigned_tenant, assigned_landlord
  from public.leases l
  join public.tenants t on t.id = l.tenant_id
  join public.units u on u.id = l.unit_id
  join public.properties p on p.id = u.property_id
  where l.id = new.lease_id and t.user_id = (select auth.uid());
  if assigned_tenant is null then
    raise exception 'Payment must be submitted for an assigned tenant lease';
  end if;
  new.tenant_id := assigned_tenant;
  new.landlord_id := assigned_landlord;
  new.payment_status := 'submitted';
  new.reviewed_by := null;
  new.reviewed_at := null;
  return new;
end;
$$;

create trigger payments_prepare_submission
  before insert on public.payments
  for each row execute function public.prepare_payment_submission();

create or replace function public.guard_payment_review()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.payment_status is distinct from old.payment_status then
    if old.payment_status <> 'submitted' or
      not (
        public.is_property_landlord((
         select u.property_id from public.leases l
         join public.units u on u.id = l.unit_id where l.id = old.lease_id
        )) or public.is_admin()
      ) then
      raise exception 'Only the assigned landlord may review a submitted payment';
    end if;
    if new.payment_status not in ('verified', 'rejected') then
      raise exception 'Invalid payment review transition';
    end if;
    new.reviewed_by := (select auth.uid());
    new.reviewed_at := now();
  else
    new.reviewed_by := old.reviewed_by;
    new.reviewed_at := old.reviewed_at;
  end if;
  new.lease_id := old.lease_id;
  new.tenant_id := old.tenant_id;
  new.landlord_id := old.landlord_id;
  new.amount := old.amount;
  new.payment_method := old.payment_method;
  new.transaction_reference := old.transaction_reference;
  return new;
end;
$$;

create trigger payments_guard_review
  before update on public.payments
  for each row execute function public.guard_payment_review();

create table public.payment_allocations (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id) on delete restrict,
  rent_record_id uuid references public.rent_records(id) on delete restrict,
  utility_bill_id uuid references public.utility_bills(id) on delete restrict,
  allocated_amount numeric(12, 2) not null check (allocated_amount > 0),
  created_at timestamptz not null default now(),
  check ((rent_record_id is not null)::integer + (utility_bill_id is not null)::integer = 1)
);
create index payment_allocations_payment_idx on public.payment_allocations(payment_id);
create index payment_allocations_rent_idx on public.payment_allocations(rent_record_id) where rent_record_id is not null;
create index payment_allocations_bill_idx on public.payment_allocations(utility_bill_id) where utility_bill_id is not null;

create or replace function public.validate_payment_allocation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  payment_lease uuid;
  target_lease uuid;
  payment_state public.payment_status;
begin
  select p.lease_id, p.payment_status into payment_lease, payment_state
  from public.payments p where p.id = new.payment_id;
  if payment_state <> 'verified' then
    raise exception 'Allocations can only be recorded for verified payments';
  end if;
  if new.rent_record_id is not null then
    select r.lease_id into target_lease from public.rent_records r where r.id = new.rent_record_id;
  else
    select b.lease_id into target_lease from public.utility_bills b where b.id = new.utility_bill_id;
  end if;
  if target_lease is null or target_lease <> payment_lease then
    raise exception 'Payment and invoice must belong to the same lease';
  end if;
  return new;
end;
$$;

create trigger payment_allocations_validate
  before insert or update on public.payment_allocations
  for each row execute function public.validate_payment_allocation();

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  body text not null check (char_length(body) between 1 and 4000),
  notification_type text not null check (char_length(notification_type) between 1 and 64),
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create index notifications_user_created_idx on public.notifications(user_id, created_at desc);

create table public.maintenance_requests (
  id uuid primary key default gen_random_uuid(),
  lease_id uuid not null references public.leases(id) on delete restrict,
  title text not null check (char_length(btrim(title)) between 1 and 160),
  description text not null check (char_length(btrim(description)) between 1 and 4000),
  priority public.maintenance_priority not null default 'normal',
  status public.maintenance_status not null default 'submitted',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index maintenance_requests_lease_created_idx
  on public.maintenance_requests(lease_id, created_at desc);

create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  landlord_id uuid not null references public.profiles(id) on delete restrict,
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  email text not null check (char_length(email) between 3 and 320),
  token_hash text not null unique check (char_length(token_hash) = 64),
  status public.invitation_status not null default 'pending',
  expires_at timestamptz not null,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  check ((status = 'accepted') = (accepted_at is not null))
);
create index invitations_landlord_created_idx on public.invitations(landlord_id, created_at desc);

create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger properties_updated_at before update on public.properties
  for each row execute function public.set_updated_at();
create trigger units_updated_at before update on public.units
  for each row execute function public.set_updated_at();
create trigger tenants_updated_at before update on public.tenants
  for each row execute function public.set_updated_at();
create trigger leases_updated_at before update on public.leases
  for each row execute function public.set_updated_at();
create trigger rent_records_updated_at before update on public.rent_records
  for each row execute function public.set_updated_at();
create trigger utility_bills_updated_at before update on public.utility_bills
  for each row execute function public.set_updated_at();
create trigger maintenance_requests_updated_at before update on public.maintenance_requests
  for each row execute function public.set_updated_at();

create index properties_landlord_idx on public.properties(landlord_id);
create index units_property_idx on public.units(property_id);
create index tenants_landlord_idx on public.tenants(landlord_id);
create index tenants_user_id_idx on public.tenants(user_id) where user_id is not null;
create index leases_unit_status_idx on public.leases(unit_id, status);

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.units enable row level security;
alter table public.tenants enable row level security;
alter table public.leases enable row level security;
alter table public.rent_records enable row level security;
alter table public.utility_bills enable row level security;
alter table public.payments enable row level security;
alter table public.payment_allocations enable row level security;
alter table public.notifications enable row level security;
alter table public.maintenance_requests enable row level security;
alter table public.invitations enable row level security;

revoke all on public.profiles, public.properties, public.units, public.tenants,
  public.leases, public.rent_records, public.utility_bills, public.payments,
  public.payment_allocations, public.notifications, public.maintenance_requests,
  public.invitations from public, anon, authenticated;

grant usage on type public.app_role, public.property_status, public.unit_status,
  public.lease_status, public.rent_status, public.bill_status, public.payment_status,
  public.maintenance_status, public.maintenance_priority, public.invitation_status
  to authenticated;

grant select on public.profiles to authenticated;
grant update (full_name, phone, preferred_language, avatar_url) on public.profiles to authenticated;
grant select, insert, update on public.properties to authenticated;
grant select, insert, update on public.units to authenticated;
grant select on public.tenants to authenticated;
grant insert (landlord_id, full_name, phone, email, cnic_number) on public.tenants to authenticated;
grant update (full_name, phone, email, cnic_number) on public.tenants to authenticated;
grant select, insert, update on public.leases to authenticated;
grant select on public.rent_records to authenticated;
grant insert (lease_id, invoice_number, billing_month, amount, due_date, status)
  on public.rent_records to authenticated;
grant update (amount, due_date, status) on public.rent_records to authenticated;
grant select, insert, update on public.utility_bills to authenticated;
grant select on public.payments to authenticated;
grant insert (lease_id, amount, payment_method, transaction_reference) on public.payments to authenticated;
grant update (payment_status) on public.payments to authenticated;
grant select on public.payment_allocations to authenticated;
grant select on public.notifications to authenticated;
grant update (is_read) on public.notifications to authenticated;
grant select on public.maintenance_requests to authenticated;
grant insert (lease_id, title, description, priority) on public.maintenance_requests to authenticated;
grant update (status) on public.maintenance_requests to authenticated;
grant select on public.invitations to authenticated;

grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_landlord() to authenticated;
grant execute on function public.is_property_landlord(uuid) to authenticated;
grant execute on function public.is_property_tenant(uuid) to authenticated;
grant execute on function public.is_unit_landlord(uuid) to authenticated;
grant execute on function public.is_unit_tenant(uuid) to authenticated;
grant execute on function public.is_tenant_landlord(uuid) to authenticated;
grant execute on function public.is_tenant_user(uuid) to authenticated;
revoke all on function public.handle_new_auth_user() from public, anon, authenticated;
revoke all on function public.validate_lease_assignment() from public, anon, authenticated;
revoke all on function public.prepare_payment_submission() from public, anon, authenticated;
revoke all on function public.guard_payment_review() from public, anon, authenticated;
revoke all on function public.validate_payment_allocation() from public, anon, authenticated;
revoke all on function public.is_admin() from public, anon;
revoke all on function public.is_landlord() from public, anon;
revoke all on function public.is_property_landlord(uuid) from public, anon;
revoke all on function public.is_property_tenant(uuid) from public, anon;
revoke all on function public.is_unit_landlord(uuid) from public, anon;
revoke all on function public.is_unit_tenant(uuid) from public, anon;
revoke all on function public.is_tenant_landlord(uuid) from public, anon;
revoke all on function public.is_tenant_user(uuid) from public, anon;

create policy profiles_select_self_or_admin on public.profiles
  for select to authenticated using (id = (select auth.uid()) or public.is_admin());
create policy profiles_update_self_or_admin on public.profiles
  for update to authenticated using (id = (select auth.uid()) or public.is_admin())
  with check (id = (select auth.uid()) or public.is_admin());

create policy properties_select_related on public.properties
  for select to authenticated using (
    (landlord_id = (select auth.uid()) and public.is_landlord())
    or public.is_property_tenant(id) or public.is_admin()
  );
create policy properties_insert_owner on public.properties
  for insert to authenticated with check (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  );
create policy properties_update_owner on public.properties
  for update to authenticated using (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  ) with check (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  );

create policy units_select_related on public.units
  for select to authenticated using (
    public.is_unit_landlord(id) or public.is_unit_tenant(id) or public.is_admin()
  );
create policy units_insert_owner on public.units
  for insert to authenticated with check (public.is_property_landlord(property_id) or public.is_admin());
create policy units_update_owner on public.units
  for update to authenticated using (public.is_unit_landlord(id) or public.is_admin())
  with check (public.is_property_landlord(property_id) or public.is_admin());

create policy tenants_select_related on public.tenants
  for select to authenticated using (
    public.is_tenant_landlord(id) or public.is_tenant_user(id) or public.is_admin()
  );
create policy tenants_insert_owner on public.tenants
  for insert to authenticated with check (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  );
create policy tenants_update_owner on public.tenants
  for update to authenticated using (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  ) with check (
    (landlord_id = (select auth.uid()) and public.is_landlord()) or public.is_admin()
  );

create policy leases_select_related on public.leases
  for select to authenticated using (
    public.is_unit_landlord(unit_id) or public.is_tenant_user(tenant_id) or public.is_admin()
  );
create policy leases_insert_owner on public.leases
  for insert to authenticated with check (
    public.is_unit_landlord(unit_id) and public.is_tenant_landlord(tenant_id) or public.is_admin()
  );
create policy leases_update_owner on public.leases
  for update to authenticated using (public.is_unit_landlord(unit_id) or public.is_admin())
  with check (
    public.is_unit_landlord(unit_id) and public.is_tenant_landlord(tenant_id) or public.is_admin()
  );

create policy rent_records_select_related on public.rent_records
  for select to authenticated using (
    exists (
      select 1 from public.leases l
      where l.id = lease_id and (
        public.is_unit_landlord(l.unit_id) or public.is_tenant_user(l.tenant_id)
      )
    ) or public.is_admin()
  );
create policy rent_records_insert_landlord on public.rent_records
  for insert to authenticated with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  );
create policy rent_records_update_landlord on public.rent_records
  for update to authenticated using (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  ) with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  );

create policy utility_bills_select_related on public.utility_bills
  for select to authenticated using (
    exists (
      select 1 from public.leases l
      where l.id = lease_id and (
        public.is_unit_landlord(l.unit_id) or public.is_tenant_user(l.tenant_id)
      )
    ) or public.is_admin()
  );
create policy utility_bills_insert_landlord on public.utility_bills
  for insert to authenticated with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  );
create policy utility_bills_update_landlord on public.utility_bills
  for update to authenticated using (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  ) with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  );

create policy payments_select_participants on public.payments
  for select to authenticated using (
    public.is_unit_landlord((select l.unit_id from public.leases l where l.id = lease_id))
    or public.is_tenant_user(tenant_id) or public.is_admin()
  );
create policy payments_insert_assigned_tenant on public.payments
  for insert to authenticated with check (
    public.is_tenant_user(tenant_id) or public.is_admin()
  );
create policy payments_update_landlord_review on public.payments
  for update to authenticated using (
    public.is_unit_landlord((select l.unit_id from public.leases l where l.id = lease_id))
    or public.is_admin()
  ) with check (
    public.is_unit_landlord((select l.unit_id from public.leases l where l.id = lease_id))
    or public.is_admin()
  );

create policy payment_allocations_select_participants on public.payment_allocations
  for select to authenticated using (
    exists (
      select 1 from public.payments p
      where p.id = payment_id and (
        public.is_unit_landlord((select l.unit_id from public.leases l where l.id = p.lease_id))
        or public.is_tenant_user(p.tenant_id)
      )
    ) or public.is_admin()
  );

create policy notifications_select_owner on public.notifications
  for select to authenticated using (user_id = (select auth.uid()) or public.is_admin());
create policy notifications_update_read_state on public.notifications
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy maintenance_select_lease_participants on public.maintenance_requests
  for select to authenticated using (
    exists (
      select 1 from public.leases l
      where l.id = lease_id and (
        public.is_unit_landlord(l.unit_id) or public.is_tenant_user(l.tenant_id)
      )
    ) or public.is_admin()
  );
create policy maintenance_insert_assigned_tenant on public.maintenance_requests
  for insert to authenticated with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_tenant_user(l.tenant_id))
  );
create policy maintenance_update_landlord on public.maintenance_requests
  for update to authenticated using (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  ) with check (
    exists (select 1 from public.leases l where l.id = lease_id and public.is_unit_landlord(l.unit_id))
    or public.is_admin()
  );

create policy invitations_select_landlord on public.invitations
  for select to authenticated using (landlord_id = (select auth.uid()) or public.is_admin());

comment on table public.invitations is
  'Invitation token hashes only. Creation and redemption must be implemented in a trusted Edge Function; client roles receive no write grants.';
comment on column public.utility_bills.document_path is
  'Private storage object path only. Generate signed URLs on demand; do not persist signed URLs.';
comment on table public.payment_allocations is
  'Only trusted backend workflows should write allocations after payment verification.';

