-- IMPORTANT: Run this in your Supabase SQL Editor

-- 1. Create visiting_places table (if not already created)
CREATE TABLE IF NOT EXISTS public.visiting_places (
    visiting_place_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    photos TEXT[], -- Array of photo URLs
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    category VARCHAR(100) DEFAULT 'Visiting Places',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_visiting_places_user_id ON public.visiting_places(user_id);
CREATE INDEX IF NOT EXISTS idx_visiting_places_category ON public.visiting_places(category);
CREATE INDEX IF NOT EXISTS idx_visiting_places_created_at ON public.visiting_places(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.visiting_places ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can insert their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can update their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can delete their own visiting places" ON public.visiting_places;

-- Create RLS policies
CREATE POLICY "Users can view their own visiting places" ON public.visiting_places
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own visiting places" ON public.visiting_places
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own visiting places" ON public.visiting_places
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own visiting places" ON public.visiting_places
    FOR DELETE USING (auth.uid() = user_id);

-- 2. Create hotels table for hotel saves
CREATE TABLE IF NOT EXISTS public.hotels (
    hotel_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    hotel_name VARCHAR(255) NOT NULL,
    description TEXT,
    contact_number VARCHAR(50),
    photos TEXT[], -- Array of photo URLs
    price_per_night DOUBLE PRECISION,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    category VARCHAR(100) DEFAULT 'Hotels',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hotels_user_id ON public.hotels(user_id);
CREATE INDEX IF NOT EXISTS idx_hotels_category ON public.hotels(category);
CREATE INDEX IF NOT EXISTS idx_hotels_created_at ON public.hotels(created_at);

ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own hotels" ON public.hotels;
DROP POLICY IF EXISTS "Users can insert their own hotels" ON public.hotels;
DROP POLICY IF EXISTS "Users can update their own hotels" ON public.hotels;
DROP POLICY IF EXISTS "Users can delete their own hotels" ON public.hotels;
DROP POLICY IF EXISTS "Anyone can view all hotels" ON public.hotels;

-- Allow all authenticated users to view all hotels
CREATE POLICY "Anyone can view all hotels" ON public.hotels
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own hotels" ON public.hotels
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own hotels" ON public.hotels
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own hotels" ON public.hotels
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Create hotel_ratings table for hotel ratings
CREATE TABLE IF NOT EXISTS public.hotel_ratings (
    rating_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    hotel_id UUID NOT NULL REFERENCES public.hotels(hotel_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(hotel_id, user_id) -- one rating per user per hotel
);

CREATE INDEX IF NOT EXISTS idx_hotel_ratings_hotel_id ON public.hotel_ratings(hotel_id);
CREATE INDEX IF NOT EXISTS idx_hotel_ratings_user_id ON public.hotel_ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_hotel_ratings_created_at ON public.hotel_ratings(created_at);

ALTER TABLE public.hotel_ratings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view all hotel ratings" ON public.hotel_ratings;
DROP POLICY IF EXISTS "Users can insert their own ratings" ON public.hotel_ratings;
DROP POLICY IF EXISTS "Users can update their own ratings" ON public.hotel_ratings;
DROP POLICY IF EXISTS "Users can delete their own ratings" ON public.hotel_ratings;

-- Allow all authenticated users to view all ratings
CREATE POLICY "Anyone can view all hotel ratings" ON public.hotel_ratings
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own ratings" ON public.hotel_ratings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own ratings" ON public.hotel_ratings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own ratings" ON public.hotel_ratings
    FOR DELETE USING (auth.uid() = user_id);

-- 5. Storage bucket setup (Do this in Supabase dashboard)
-- - Go to Storage menu
-- - Create a new bucket named: place_photos
-- - Set it to PRIVATE
-- - Add the following policies in the bucket's policy editor:

-- Policy 1: Allow users to upload photos to their own folders
CREATE POLICY "Users can upload photos" ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'place_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow users to read their own photos
CREATE POLICY "Users can read their own photos" ON storage.objects FOR SELECT 
USING (
  bucket_id = 'place_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 3: Allow users to delete their own photos
CREATE POLICY "Users can delete their own photos" ON storage.objects FOR DELETE 
USING (
  bucket_id = 'place_photos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);