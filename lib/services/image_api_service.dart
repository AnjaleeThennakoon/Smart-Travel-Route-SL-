// lib/services/image_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageApiService {
  // ==================== API KEYS ====================
  // Your Pixabay API Key
  static const String pixabayApiKey = '55627625-535dc0e19d73c5f6d224ba55d';
  static const String pixabayBaseUrl = 'https://pixabay.com/api/';

  // Unsplash API (Alternative - optional)
  static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  static const String unsplashBaseUrl = 'https://api.unsplash.com';

  // Using Pixabay (change to unsplash if needed)
  static ApiProvider currentProvider = ApiProvider.pixabay;

  // ==================== MAIN SEARCH METHOD ====================
  static Future<List<Map<String, dynamic>>> searchImages(String query) async {
    if (currentProvider == ApiProvider.pixabay) {
      return await _searchPixabay(query);
    } else {
      return await _searchUnsplash(query);
    }
  }

  // ==================== PIXABAY SEARCH (FIXED) ====================
  static Future<List<Map<String, dynamic>>> _searchPixabay(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$pixabayBaseUrl?key=$pixabayApiKey&q=$encodedQuery&image_type=photo&per_page=10&safesearch=true';

      print('🖼️ Pixabay URL: $url'); // Debug

      final response = await http.get(Uri.parse(url));

      print('📡 Response status: ${response.statusCode}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Response data: ${data.keys}'); // Debug

        final List<dynamic> hits = data['hits'] ?? [];
        print('🔍 Found ${hits.length} images for: $query'); // Debug

        return hits
            .map(
              (hit) => {
                'id': hit['id'].toString(),
                'url': hit['webformatURL'] ?? '',
                'largeUrl': hit['largeImageURL'] ?? '',
                'hdUrl': hit['fullHDURL'] ?? hit['largeImageURL'] ?? '',
                'tags': hit['tags'] ?? '',
                'user': hit['user'] ?? '',
                'likes': hit['likes'] ?? 0,
                'downloads': hit['downloads'] ?? 0,
              },
            )
            .toList();
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Pixabay API Exception: $e');
      return [];
    }
  }

  // ==================== UNSPLASH SEARCH ====================
  static Future<List<Map<String, dynamic>>> _searchUnsplash(
    String query,
  ) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$unsplashBaseUrl/search/photos?query=$encodedQuery&per_page=10';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Client-ID $unsplashAccessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results
            .map(
              (photo) => {
                'id': photo['id'].toString(),
                'url': photo['urls']['regular'] ?? '',
                'largeUrl': photo['urls']['full'] ?? '',
                'thumb': photo['urls']['thumb'] ?? '',
                'description':
                    photo['description'] ?? photo['alt_description'] ?? '',
                'photographer': photo['user']['name'] ?? '',
                'likes': photo['likes'] ?? 0,
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Unsplash API Error: $e');
      return [];
    }
  }

  // ==================== GET DESTINATION IMAGE (FIXED) ====================
  static Future<String> getDestinationImage(
    String destinationName,
    String country,
  ) async {
    try {
      final query = '$destinationName $country travel landmark';
      print('📍 Getting destination image for: $query');

      final images = await searchImages(query);

      if (images.isNotEmpty &&
          images[0]['url'] != null &&
          images[0]['url'].toString().isNotEmpty) {
        final imageUrl = images[0]['url'].toString();
        print(
          '✅ Found destination image: ${imageUrl.substring(0, imageUrl.length > 50 ? 50 : imageUrl.length)}...',
        );
        return imageUrl;
      }

      print('⚠️ No image found, using fallback');
      return _getLocalDestinationImage(destinationName);
    } catch (e) {
      print('❌ Error getting destination image: $e');
      return _getLocalDestinationImage(destinationName);
    }
  }

  // ==================== GET DESTINATION GALLERY (FIXED) ====================
  static Future<List<String>> getDestinationGallery(
    String destinationName,
    String country,
  ) async {
    try {
      final query = '$destinationName $country beautiful view';
      print('📸 Getting destination gallery for: $query');

      final images = await searchImages(query);
      print('📊 Found ${images.length} images from API');

      List<String> gallery = [];

      for (int i = 0; i < images.length && i < 3; i++) {
        final url = images[i]['url']?.toString() ?? '';
        if (url.isNotEmpty) {
          gallery.add(url);
          print('✅ Added gallery image ${i + 1}');
        }
      }

      // Fill with fallback images if needed
      while (gallery.length < 3) {
        final fallbackUrl = _getLocalDestinationImage(destinationName);
        gallery.add(fallbackUrl);
        print('🖼️ Added fallback image ${gallery.length}');
      }

      print('🎯 Final gallery has ${gallery.length} images');
      return gallery;
    } catch (e) {
      print('❌ Error getting destination gallery: $e');
      return [
        _getLocalDestinationImage(destinationName),
        _getLocalDestinationImage(destinationName),
        _getLocalDestinationImage(destinationName),
      ];
    }
  }

  // ==================== GET HOTEL IMAGE (FIXED) ====================
  static Future<String> getHotelImage(String hotelName, String location) async {
    try {
      final query = '$hotelName $location hotel room luxury';
      print('🏨 Getting hotel image for: $query');

      final images = await searchImages(query);

      if (images.isNotEmpty &&
          images[0]['url'] != null &&
          images[0]['url'].toString().isNotEmpty) {
        final imageUrl = images[0]['url'].toString();
        print(
          '✅ Found hotel image: ${imageUrl.substring(0, imageUrl.length > 50 ? 50 : imageUrl.length)}...',
        );
        return imageUrl;
      }

      print('⚠️ No hotel image found, using fallback');
      return _getLocalHotelImage(hotelName);
    } catch (e) {
      print('❌ Error getting hotel image: $e');
      return _getLocalHotelImage(hotelName);
    }
  }

  // ==================== GET HOTEL GALLERY (FIXED - MAIN FIX) ====================
  static Future<List<String>> getHotelGallery(
    String hotelName,
    String location,
  ) async {
    try {
      final query = '$hotelName $location hotel';
      print('🏨🏨 Getting hotel gallery for: $query');

      final images = await searchImages(query);
      print('📊 Found ${images.length} images from API for hotel gallery');

      List<String> gallery = [];

      // Debug: Print each image URL
      for (int i = 0; i < images.length; i++) {
        print('  Image $i: ${images[i]['url']}');
      }

      // Get up to 3 images
      for (int i = 0; i < images.length && i < 3; i++) {
        String? url;

        // Try different possible key names
        if (images[i].containsKey('url') && images[i]['url'] != null) {
          url = images[i]['url'].toString();
        } else if (images[i].containsKey('webformatURL') &&
            images[i]['webformatURL'] != null) {
          url = images[i]['webformatURL'].toString();
        } else if (images[i].containsKey('largeImageURL') &&
            images[i]['largeImageURL'] != null) {
          url = images[i]['largeImageURL'].toString();
        } else if (images[i].containsKey('largeUrl') &&
            images[i]['largeUrl'] != null) {
          url = images[i]['largeUrl'].toString();
        }

        if (url != null && url.isNotEmpty) {
          gallery.add(url);
          print(
            '✅ Added hotel gallery image ${i + 1}: ${url.substring(0, url.length > 50 ? 50 : url.length)}...',
          );
        }
      }

      // Fill with fallback images if needed
      while (gallery.length < 3) {
        final fallbackUrl = _getLocalHotelImage(hotelName);
        gallery.add(fallbackUrl);
        print('🖼️ Added fallback hotel image ${gallery.length}');
      }

      print('🎯 Final hotel gallery has ${gallery.length} images');
      return gallery;
    } catch (e) {
      print('❌ Error in getHotelGallery: $e');
      return [
        _getLocalHotelImage(hotelName),
        _getLocalHotelImage(hotelName),
        _getLocalHotelImage(hotelName),
      ];
    }
  }

  // ==================== TEST METHOD (To verify API is working) ====================
  static Future<bool> testApiConnection() async {
    try {
      print('🔧 Testing API connection...');
      final results = await searchImages('Sri Lanka travel');
      print('✅ API test completed. Found ${results.length} images');
      return results.isNotEmpty;
    } catch (e) {
      print('❌ API test failed: $e');
      return false;
    }
  }

  // ==================== FALLBACK LOCAL IMAGES ====================
  static String _getLocalDestinationImage(String name) {
    final Map<String, String> localImages = {
      'Sigiriya Rock':
          'https://images.pexels.com/photos/1633522/pexels-photo-1633522.jpeg?w=800',
      'Ella Gap':
          'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?w=800',
      'Bentota Beach':
          'https://images.pexels.com/photos/457882/pexels-photo-457882.jpeg?w=800',
      'Galle Fort':
          'https://images.pexels.com/photos/2144270/pexels-photo-2144270.jpeg?w=800',
      'Temple of Tooth':
          'https://images.pexels.com/photos/2462023/pexels-photo-2462023.jpeg?w=800',
      'Nuwara Eliya':
          'https://images.pexels.com/photos/660113/pexels-photo-660113.jpeg?w=800',
      'Mirissa Beach':
          'https://images.pexels.com/photos/753626/pexels-photo-753626.jpeg?w=800',
      'Anuradhapura':
          'https://images.pexels.com/photos/2082103/pexels-photo-2082103.jpeg?w=800',
      'Polonnaruwa':
          'https://images.pexels.com/photos/2082103/pexels-photo-2082103.jpeg?w=800',
      'Yala National Park':
          'https://images.pexels.com/photos/1549362/pexels-photo-1549362.jpeg?w=800',
    };
    return localImages[name] ??
        'https://images.pexels.com/photos/147411/italy-mountains-dawn-daybreak-147411.jpeg?w=800';
  }

  static String _getLocalHotelImage(String name) {
    final Map<String, String> localHotelImages = {
      'Grand Plaza Hotel':
          'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?w=800',
      'Sunset Resort':
          'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg?w=800',
      'Sigiriya Lodge':
          'https://images.pexels.com/photos/261481/pexels-photo-261481.jpeg?w=800',
      'Ella Retreat':
          'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?w=800',
      'Kandy City Hotel':
          'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?w=800',
      'Galle Fort Inn':
          'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?w=800',
      'Mirissa Beach Hotel':
          'https://images.pexels.com/photos/753626/pexels-photo-753626.jpeg?w=800',
      'Nuwara Eliya Bungalow':
          'https://images.pexels.com/photos/660113/pexels-photo-660113.jpeg?w=800',
    };
    return localHotelImages[name] ??
        'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?w=800';
  }
}

enum ApiProvider { pixabay, unsplash }
