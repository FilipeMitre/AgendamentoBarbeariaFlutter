class AppointmentModel {
  final int? id;
  final int userId;
  final int barbershopId;
  final int barberId;
  final int serviceId;
  final String appointmentDate;
  final String appointmentTime;
  final String status; // pending, confirmed, completed, cancelled
  final double totalPrice;
  final String paymentMethod;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  AppointmentModel({
    this.id,
    required this.userId,
    required this.barbershopId,
    required this.barberId,
    required this.serviceId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = 'pending',
    required this.totalPrice,
    this.paymentMethod = 'credits',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      barbershopId: map['barbershop_id'] as int,
      barberId: map['barber_id'] as int,
      serviceId: map['service_id'] as int,
      appointmentDate: map['appointment_date'] as String,
      appointmentTime: map['appointment_time'] as String,
      status: map['status'] as String,
      totalPrice: (map['total_price'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'barbershop_id': barbershopId,
      'barber_id': barberId,
      'service_id': serviceId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
