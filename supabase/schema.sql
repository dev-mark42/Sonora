-- SONORA: ejecutar en Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);
create table if not exists public.tracks (
  id text primary key,
  source text not null,
  source_id text,
  title text not null,
  artist text,
  album text,
  genre text,
  mood text,
  cover_url text,
  audio_url text,
  download_url text,
  download_allowed boolean not null default false,
  license_url text,
  source_url text,
  duration_seconds integer,
  is_published boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.playlists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  is_public boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.playlist_tracks (
  playlist_id uuid not null references public.playlists(id) on delete cascade,
  track_id text not null references public.tracks(id) on delete cascade,
  position integer not null default 0,
  added_at timestamptz not null default now(),
  primary key (playlist_id,track_id)
);
create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  track_id text not null references public.tracks(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id,track_id)
);
create table if not exists public.listening_history (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  track_id text not null references public.tracks(id) on delete cascade,
  listened_at timestamptz not null default now(),
  listened_seconds integer not null default 0
);
create index if not exists tracks_search_idx on public.tracks using gin(to_tsvector('simple',coalesce(title,'')||' '||coalesce(artist,'')||' '||coalesce(genre,'')));
create index if not exists history_user_date_idx on public.listening_history(user_id,listened_at desc);

alter table public.profiles enable row level security;
alter table public.tracks enable row level security;
alter table public.playlists enable row level security;
alter table public.playlist_tracks enable row level security;
alter table public.favorites enable row level security;
alter table public.listening_history enable row level security;
create policy "profiles read own" on public.profiles for select to authenticated using (auth.uid()=id);
create policy "profiles update own" on public.profiles for update to authenticated using (auth.uid()=id) with check (auth.uid()=id);
create policy "published tracks readable" on public.tracks for select using (is_published=true);
create policy "admin manages tracks" on public.tracks for all to authenticated using (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')) with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));
create policy "playlist owner manages" on public.playlists for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "playlist tracks visible" on public.playlist_tracks for select using (exists(select 1 from public.playlists p where p.id=playlist_id and (p.is_public or p.user_id=auth.uid())));
create policy "playlist owner changes tracks" on public.playlist_tracks for all to authenticated using (exists(select 1 from public.playlists p where p.id=playlist_id and p.user_id=auth.uid())) with check (exists(select 1 from public.playlists p where p.id=playlist_id and p.user_id=auth.uid()));
create policy "favorites owner" on public.favorites for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "history owner" on public.listening_history for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());

-- Crear perfil al registrar usuario.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'display_name','')); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
