# Setup Guide: Visiting Places with Photo Upload

## Step 1: Create Database Table in Supabase

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the SQL from `supabase/setup_storage_and_visiting_places.sql`
5. Run the query

## Step 2: Create Storage Bucket

1. Go to **Storage** in Supabase Dashboard
2. Click **Create a new bucket**
3. Name it: `place_photos`
4. Choose **PRIVATE** for privacy settings
5. Click **Create bucket**

## Step 3: Set Storage Policies

### Option A: Via Dashboard (Recommended for first time)
1. Go to Storage → place_photos bucket
2. Click **Policies** tab
3. Click **New Policy**
4. Select **get()** template (for reading)
5. Paste this condition:
   ```
   bucket_id = 'place_photos'
   ```
6. Add similar policies for INSERT and DELETE

### Option B: Via SQL
After creating the bucket, run the storage policy SQL from `setup_storage_and_visiting_places.sql`

## Step 4: Update Your App Settings

Make sure your Supabase project URL and API key are correctly configured in your app initialization.

## Features Implemented

✅ **Direct Photo Upload**
- Pick photos from camera or gallery
- Preview selected photos before saving
- Remove photos before saving

✅ **Database Storage**
- Visiting places saved to `visiting_places` table
- Photos stored in Supabase storage
- Photo URLs saved in database

✅ **Complete Data Flow**
1. User enters place name, description, photos
2. Clicks "Save place"
3. Place is saved to database
4. Photos are uploaded to storage
5. Photo URLs are added to database record
6. Markers appear on map

## Troubleshooting

### "Failed to save visiting place" error
- Check if `visiting_places` table exists in database
- Verify storage bucket `place_photos` is created and PRIVATE
- Check RLS policies are properly configured
- Look at app console for detailed error messages (printed with `debugPrint`)

### Photos not uploading
- Ensure storage policies are set up
- Check that bucket name is exactly: `place_photos`
- Verify user is authenticated before saving
- Check file permissions on device

### Markers not appearing
- Verify place was actually saved (check database)
- Ensure `_loadSavedVisitingPlaces()` is being called
- Check that latitude/longitude values are valid

## Database Schema Reference

### visiting_places table
```
- visiting_place_id: UUID (primary key)
- user_id: UUID (references users)
- name: VARCHAR(255)
- description: TEXT (optional)
- photos: TEXT[] (array of photo URLs, optional)
- latitude: DOUBLE PRECISION
- longitude: DOUBLE PRECISION
- category: VARCHAR(100)
- created_at: TIMESTAMP WITH TIME ZONE
```

## API Methods

### In lib/services/api_service.dart

```dart
// Save visiting place
saveVisitingPlaceForCurrentUser({
  required String name,
  String? description,
  List<String>? photos,
  required double latitude,
  required double longitude,
  String category = 'Visiting Places',
})

// Upload photo to storage
uploadVisitingPlacePhoto(String visitingPlaceId, String filePath)

// Get all user's visiting places
getCurrentUserVisitingPlaces()

// Update visiting place photos
updateVisitingPlacePhotos(String visitingPlaceId, List<String> photoUrls)
```

## Testing

1. Run `flutter run`
2. Open "Add Places" page
3. Long-press on map
4. Select "Visiting Places"
5. Fill in place name (required)
6. Add photos using Camera or Gallery buttons
7. Click "Save place"
8. Check that place appears on map
9. Verify place saved in Supabase database

---

For more help, check the debug console output for specific error messages!