-- Trips created by each user after shortest-path planning.
create table if not exists public.trips (
  trip_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  trip_name varchar(255) not null,
  description text,
  start_location varchar(255),
  total_distance double precision,
  total_duration int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_trips_user_id on public.trips(user_id);
create index if not exists idx_trips_created_at on public.trips(created_at desc);

-- Ordered places for each trip.
create table if not exists public.trip_places (
  trip_place_id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(trip_id) on delete cascade,
  place_name varchar(255) not null,
  latitude double precision,
  longitude double precision,
  visit_order int not null,
  distance_from_previous double precision,
  duration_from_previous int,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_trip_places_trip_order
  on public.trip_places(trip_id, visit_order);

create index if not exists idx_trip_places_trip_id
  on public.trip_places(trip_id);

-- Hotels added by users from the Add Places page.
create table if not exists public.hotels (
  hotel_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  hotel_name varchar(255) not null,
  description text,
  contact_number varchar(50),
  photos text[],
  price_per_night double precision,
  latitude double precision not null,
  longitude double precision not null,
  category varchar(100) not null default 'Hotels',
  created_at timestamptz not null default now()
);

create index if not exists idx_hotels_user_id on public.hotels(user_id);
create index if not exists idx_hotels_category on public.hotels(category);
create index if not exists idx_hotels_created_at on public.hotels(created_at);

-- Enable Row Level Security (RLS)
alter table public.hotels enable row level security;

-- Drop old policies if they exist
drop policy if exists "Users can view their own hotels" on public.hotels;
drop policy if exists "Users can insert their own hotels" on public.hotels;
drop policy if exists "Users can update their own hotels" on public.hotels;
drop policy if exists "Users can delete their own hotels" on public.hotels;
drop policy if exists "Anyone can view all hotels" on public.hotels;

-- Create RLS policies - all users can view, but only owner can modify
create policy "Anyone can view all hotels" on public.hotels
    for select using (true);

create policy "Users can insert their own hotels" on public.hotels
    for insert with check (auth.uid() = user_id);

create policy "Users can update their own hotels" on public.hotels
    for update using (auth.uid() = user_id);

create policy "Users can delete their own hotels" on public.hotels
    for delete using (auth.uid() = user_id);

-- Hotel ratings by users
create table if not exists public.hotel_ratings (
  rating_id uuid primary key default gen_random_uuid(),
  hotel_id uuid not null references public.hotels(hotel_id) on delete cascade,
  user_id uuid not null references public.users(user_id) on delete cascade,
  rating int not null check (rating >= 1 and rating <= 5),
  created_at timestamptz not null default now(),
  unique(hotel_id, user_id) -- one rating per user per hotel
);

create index if not exists idx_hotel_ratings_hotel_id on public.hotel_ratings(hotel_id);
create index if not exists idx_hotel_ratings_user_id on public.hotel_ratings(user_id);
create index if not exists idx_hotel_ratings_created_at on public.hotel_ratings(created_at);

-- Enable Row Level Security (RLS)
alter table public.hotel_ratings enable row level security;

-- Drop old policies if they exist
drop policy if exists "Anyone can view all hotel ratings" on public.hotel_ratings;
drop policy if exists "Users can insert their own ratings" on public.hotel_ratings;
drop policy if exists "Users can update their own ratings" on public.hotel_ratings;
drop policy if exists "Users can delete their own ratings" on public.hotel_ratings;

-- Create RLS policies - all users can view, but only owner can modify
create policy "Anyone can view all hotel ratings" on public.hotel_ratings
    for select using (true);

create policy "Users can insert their own ratings" on public.hotel_ratings
    for insert with check (auth.uid() = user_id);

create policy "Users can update their own ratings" on public.hotel_ratings
    for update using (auth.uid() = user_id);

create policy "Users can delete their own ratings" on public.hotel_ratings
    for delete using (auth.uid() = user_id);
