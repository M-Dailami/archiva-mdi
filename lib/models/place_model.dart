/// Model data tempat bersejarah
class Place {
  final String id;
  final String name;
  final String location;
  final String province;
  final String category; // Arsitektur, Sejarah, Peristiwa, Tokoh
  final String description;
  final String imageUrl;
  final List<String> galleryImages;
  final String openHours;
  final String ticketPrice;
  final int moduleCount;
  final List<HistoricalModule> modules;
  final DateTime? addedDate;
  final String? gmapsUrl;

  const Place({
    required this.id,
    required this.name,
    required this.location,
    required this.province,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.galleryImages = const [],
    this.openHours = '08:00 - 16:00',
    this.ticketPrice = 'Gratis',
    this.moduleCount = 3,
    this.modules = const [],
    this.addedDate,
    this.gmapsUrl,
  });
}

/// Model modul pembelajaran sejarah
class HistoricalModule {
  final String id;
  final String title;
  final String placeId;
  final String content;
  final String period;
  final List<String> keyFacts;

  const HistoricalModule({
    required this.id,
    required this.title,
    required this.placeId,
    required this.content,
    this.period = '',
    this.keyFacts = const [],
  });
}
