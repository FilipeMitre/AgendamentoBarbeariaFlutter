class BarbershopModel {
  final int? id;
  final String name;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String phone;
  final String openingHours;
  final double rating;
  final bool isOpen;
  final String createdAt;

  BarbershopModel({
    this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.openingHours,
    this.rating = 0.0,
    this.isOpen = true,
    required this.createdAt,
  });

  factory BarbershopModel.fromMap(Map<String, dynamic> map) {
    return BarbershopModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      phone: map['phone'] as String,
      openingHours: map['opening_hours'] as String,
      rating: (map['rating'] as num).toDouble(),
      isOpen: (map['is_open'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'opening_hours': openingHours,
      'rating': rating,
      'is_open': isOpen ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
