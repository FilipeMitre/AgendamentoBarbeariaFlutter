class ServiceModel {
  final int? id;
  final int barbershopId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final bool isAvailable;
  final String createdAt;

  ServiceModel({
    this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      barbershopId: map['barbershop_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      durationMinutes: map['duration_minutes'] as int,
      isAvailable: (map['is_available'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
