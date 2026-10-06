class ImageService {
  static const String _corsProxy = 'https://images.weserv.nl/?url=';

  /// Generates a dynamic online network image URL using the place or hotel name as a search keyword.
  static String getPhotoForPlace(String placeName, {String category = 'tourist spot'}) {
    final cleanName = placeName.trim();
    final searchQuery = Uri.encodeComponent('$cleanName $category India');
    
    // Curated high-resolution Unsplash photo map for exact match speed
    final lowerName = cleanName.toLowerCase();
    if (lowerName.contains('kotappakonda') || lowerName.contains('trikoteswara')) {
      return _wrapProxy('https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800');
    } else if (lowerName.contains('guthikonda') || lowerName.contains('cave')) {
      return _wrapProxy('https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800');
    } else if (lowerName.contains('amaravathi') || lowerName.contains('stupa') || lowerName.contains('buddha')) {
      return _wrapProxy('https://images.unsplash.com/photo-1590059208019-15224887b38c?w=800');
    } else if (lowerName.contains('kondaveedu') || lowerName.contains('fort')) {
      return _wrapProxy('https://images.unsplash.com/photo-1590059208019-15224887b38c?w=800');
    } else if (lowerName.contains('mangalagiri') || lowerName.contains('temple')) {
      return _wrapProxy('https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800');
    } else if (lowerName.contains('uppalapadu') || lowerName.contains('bird') || lowerName.contains('pelican')) {
      return _wrapProxy('https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=800');
    } else if (lowerName.contains('kanaka durga') || lowerName.contains('indrakeeladri')) {
      return _wrapProxy('https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800');
    } else if (lowerName.contains('undavalli')) {
      return _wrapProxy('https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800');
    } else if (lowerName.contains('prakasam') || lowerName.contains('bhavani') || lowerName.contains('barrage')) {
      return _wrapProxy('https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800');
    }

    // Keyword-based Unsplash Source URL with CORS proxy
    return _wrapProxy('https://source.unsplash.com/featured/800x600/?$searchQuery');
  }

  /// Generates a dynamic online network image URL for hotels.
  static String getPhotoForHotel(String hotelName) {
    final cleanName = hotelName.trim();
    final searchQuery = Uri.encodeComponent('$cleanName hotel resort');

    final lowerName = cleanName.toLowerCase();
    if (lowerName.contains('grand palnadu') || lowerName.contains('luxury')) {
      return _wrapProxy('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800');
    } else if (lowerName.contains('surya regency') || lowerName.contains('residency')) {
      return _wrapProxy('https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800');
    }

    return _wrapProxy('https://source.unsplash.com/featured/800x600/?$searchQuery');
  }

  static String _wrapProxy(String rawUrl) {
    if (rawUrl.startsWith(_corsProxy)) return rawUrl;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return '$_corsProxy${Uri.encodeComponent(rawUrl)}';
    }
    return rawUrl;
  }
}
