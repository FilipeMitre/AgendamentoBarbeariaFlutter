class ServiceModel {
  final int? id;
  final int barberId;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final bool isAvailable;
  final String? barberName;
  final String createdAt;

  ServiceModel({
    this.id,
    required this.barberId,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    this.isAvailable = true,
    this.barberName,
    required this.createdAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      barberId: map['barberId'] as int? ?? map['id_barbeiro'] as int,
      name: map['name'] as String? ?? map['nome'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? (map['preco_creditos'] as num).toDouble(),
      duration: map['duration'] as int? ?? map['duracao_minutos'] as int,
      isAvailable: map['is_available'] == 1 || map['is_available'] == true,
      barberName: map['barberName'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_barbeiro': barberId,
      'nome': name,
      'description': description,
      'preco_creditos': price,
      'duracao_minutos': duration,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
