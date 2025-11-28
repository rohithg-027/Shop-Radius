class ServiceBooking {
  final String id;
  final String serviceId;
  final String serviceName;
  final String customerId;
  final String vendorId;
  final String status; // Pending, Accepted, Completed
  final double totalAmount;
  final DateTime bookedAt;
  final String customerAddress;
  final String customerName;
  final String phoneNumber;
  final DateTime? scheduledDate;

  ServiceBooking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.customerId,
    required this.vendorId,
    required this.status,
    required this.totalAmount,
    required this.bookedAt,
    required this.customerAddress,
    required this.customerName,
    required this.phoneNumber,
    this.scheduledDate,
  });

  ServiceBooking copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? customerId,
    String? vendorId,
    String? status,
    double? totalAmount,
    DateTime? bookedAt,
    String? customerAddress,
    String? customerName,
    String? phoneNumber,
    DateTime? scheduledDate,
  }) {
    return ServiceBooking(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      bookedAt: bookedAt ?? this.bookedAt,
      customerAddress: customerAddress ?? this.customerAddress,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}
