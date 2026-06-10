-- Gym Workout Tracker — Supabase schema for cloud sync (Phase 3).
-- Run this in the Supabase SQL editor after creating your project.
--
-- Each table mirrors the local SQLite schema with snake_case columns. Rows are
-- keyed by `uuid` (the cross-device identity) and scoped to a user via
-- `user_id`. Row Level Security restricts every row to its owner. The app
-- never uploads seeded/preset rows — only the user's own data.
--
-- Notes:
--  * `updated_at` drives last-write-wins; the client always sets it.
--  * `is_deleted` carries tombstones so deletions propagate.
--  * Progress-photo image bytes are NOT synced in this phase (file_path only);
--    on a second device the image will be missing until Supabase Storage is
--    added in a later phase.

-- ── exercises (custom exercises only) ───────────────────────────────────────
create table if not exists exercises (
  uuid          uuid primary key,
  user_id       uuid not null references auth.users (id) on delete cascade,
  name          text not null,
  category      text not null,
  muscle_group  text not null default '',
  equipment     text not null default '',
  is_custom     boolean not null default true,
  updated_at    timestamptz not null,
  is_deleted    boolean not null default false
);

-- ── routines (user routines only) ───────────────────────────────────────────
create table if not exists routines (
  uuid        uuid primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null,
  is_preset   boolean not null default false,
  updated_at  timestamptz not null,
  is_deleted  boolean not null default false
);

-- ── routine_exercises ───────────────────────────────────────────────────────
create table if not exists routine_exercises (
  uuid          uuid primary key,
  user_id       uuid not null references auth.users (id) on delete cascade,
  routine_uuid  uuid not null,
  exercise_uuid uuid not null,
  target_sets   integer not null,
  target_reps   integer not null,
  order_index   integer not null,
  updated_at    timestamptz not null,
  is_deleted    boolean not null default false
);

-- ── workout_sessions ────────────────────────────────────────────────────────
create table if not exists workout_sessions (
  uuid         uuid primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  date         text not null,
  duration     integer not null,
  routine_name text not null,
  notes        text,
  updated_at   timestamptz not null,
  is_deleted   boolean not null default false
);

-- ── workout_sets ────────────────────────────────────────────────────────────
create table if not exists workout_sets (
  uuid             uuid primary key,
  user_id          uuid not null references auth.users (id) on delete cascade,
  session_uuid     uuid not null,
  exercise_uuid    uuid not null,
  weight           double precision not null,
  reps             integer not null,
  is_completed     boolean not null default false,
  duration_seconds integer,
  distance_meters  double precision,
  updated_at       timestamptz not null,
  is_deleted       boolean not null default false
);

-- ── body_measurements ───────────────────────────────────────────────────────
create table if not exists body_measurements (
  uuid                uuid primary key,
  user_id             uuid not null references auth.users (id) on delete cascade,
  date                text not null,
  body_weight         double precision not null,
  body_fat_percentage double precision not null,
  waist               double precision,
  chest               double precision,
  arms                double precision,
  hips                double precision,
  thighs              double precision,
  updated_at          timestamptz not null,
  is_deleted          boolean not null default false
);

-- ── progress_photos (path/note only; image bytes not synced) ────────────────
create table if not exists progress_photos (
  uuid        uuid primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  date        text not null,
  file_path   text not null,
  note        text,
  updated_at  timestamptz not null,
  is_deleted  boolean not null default false
);

-- ── Indexes backing the incremental pull (fetch since watermark) ────────────
create index if not exists idx_exercises_user_updated         on exercises (user_id, updated_at);
create index if not exists idx_routines_user_updated          on routines (user_id, updated_at);
create index if not exists idx_routine_exercises_user_updated on routine_exercises (user_id, updated_at);
create index if not exists idx_workout_sessions_user_updated  on workout_sessions (user_id, updated_at);
create index if not exists idx_workout_sets_user_updated      on workout_sets (user_id, updated_at);
create index if not exists idx_body_measurements_user_updated on body_measurements (user_id, updated_at);
create index if not exists idx_progress_photos_user_updated   on progress_photos (user_id, updated_at);

-- ── Row Level Security: each user sees and writes only their own rows ────────
do $$
declare
  t text;
begin
  foreach t in array array[
    'exercises','routines','routine_exercises','workout_sessions',
    'workout_sets','body_measurements','progress_photos'
  ]
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "owner_all" on %I;', t);
    execute format(
      'create policy "owner_all" on %I for all '
      'using (auth.uid() = user_id) with check (auth.uid() = user_id);', t);
  end loop;
end $$;
