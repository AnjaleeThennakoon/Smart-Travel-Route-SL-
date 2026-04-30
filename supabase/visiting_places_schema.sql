-- Create visiting_places table
CREATE TABLE public.visiting_places (
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
CREATE INDEX idx_visiting_places_user_id ON public.visiting_places(user_id);
CREATE INDEX idx_visiting_places_category ON public.visiting_places(category);
CREATE INDEX idx_visiting_places_created_at ON public.visiting_places(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.visiting_places ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist
DROP POLICY IF EXISTS "Users can view their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can insert their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can update their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Users can delete their own visiting places" ON public.visiting_places;
DROP POLICY IF EXISTS "Anyone can view all visiting places" ON public.visiting_places;

-- Create RLS policies - all users can view, but only owner can modify
CREATE POLICY "Anyone can view all visiting places" ON public.visiting_places
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own visiting places" ON public.visiting_places
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own visiting places" ON public.visiting_places
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own visiting places" ON public.visiting_places
    FOR DELETE USING (auth.uid() = user_id);