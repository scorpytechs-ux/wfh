class Customer {
  final String id;
  final String customerName;
  final String contractNumber;
  final String mobile;
  final String? email;
  final String? address;
  final DateTime? dob;
  final double contractValue;
  final int contractMonths;
  final double installmentAmount;
  final String status;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.customerName,
    required this.contractNumber,
    required this.mobile,
    this.email,
    this.address,
    this.dob,
    required this.contractValue,
    required this.contractMonths,
    required this.installmentAmount,
    required this.status,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? customerName,
    String? contractNumber,
    String? mobile,
    String? email,
    String? address,
    DateTime? dob,
    double? contractValue,
    int? contractMonths,
    double? installmentAmount,
    String? status,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      contractNumber: contractNumber ?? this.contractNumber,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      contractValue: contractValue ?? this.contractValue,
      contractMonths: contractMonths ?? this.contractMonths,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
