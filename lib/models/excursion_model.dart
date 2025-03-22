class ExcursionModel {
  final String title;
  final String description;
  final String image;
  final String url;
  
  ExcursionModel({
    required this.title,
    required this.description,
    required this.image,
    required this.url,
  });
  
  // Factory constructor from Map
  factory ExcursionModel.fromMap(Map<String, String> map) {
    return ExcursionModel(
      title: map['title'] ?? 'Unnamed Excursion',
      description: map['description'] ?? '',
      image: map['image'] ?? 'assets/images/placeholder.jpg',
      url: map['url'] ?? '',
    );
  }
  
  // Convert to Map
  Map<String, String> toMap() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'url': url,
    };
  }
}