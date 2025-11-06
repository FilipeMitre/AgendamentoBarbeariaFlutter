class UserModel {
  final int? id;
  final String name;
  final String cpf;
  final String email;
  final String password;
  final String? phone;
  final double credits;
  final String role; // cliente, barbeiro, admin
  final String createdAt;
  final String updatedAt;

  UserModel({
    this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.password,
    this.phone,
    this.credits = 0.0,
    this.role = 'cliente',
    required this.createdAt,
    required this.updatedAt,
  });

  // Converter de Map para Model
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      cpf: map['cpf'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      credits: (map['credits'] as num?)?.toDouble() ?? 0.0,
      role: map['role'] as String? ?? map['papel'] as String? ?? 'cliente',
      createdAt: map['created_at'] as String? ?? map['criado_em'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? map['atualizado_em'] as String? ?? '',
    );
  }

  // Converter de Model para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'password': password,
      'phone': phone,
      'credits': credits,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Copiar com alterações
  UserModel copyWith({
    int? id,
    String? name,
    String? cpf,
    String? email,
    String? password,
    String? phone,
    double? credits,
    String? role,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      credits: credits ?? this.credits,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
