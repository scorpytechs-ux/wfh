import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    required super.id,
    required super.customerName,
    required super.contractNumber,
    required super.mobile,
    super.email,
    super.address,
    super.dob,
    required super.contractValue,
    required super.contractMonths,
    required super.installmentAmount,
    required super.status,
    required super.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      customerName: json['customerName'],
      contractNumber: json['contractNumber'],
      mobile: json['mobile'],
      email: json['email'],
      address: json['address'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      contractValue: (json['contractValue'] as num).toDouble(),
      contractMonths: json['contractMonths'] as int,
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'contractNumber': contractNumber,
      'mobile': mobile,
      'email': email,
      'address': address,
      'dob': dob?.toIso8601String(),
      'contractValue': contractValue,
      'contractMonths': contractMonths,
      'installmentAmount': installmentAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      customerName: customer.customerName,
      contractNumber: customer.contractNumber,
      mobile: customer.mobile,
      email: customer.email,
      address: customer.address,
      dob: customer.dob,
      contractValue: customer.contractValue,
      contractMonths: customer.contractMonths,
      installmentAmount: customer.installmentAmount,
      status: customer.status,
      createdAt: customer.createdAt,
    );
  }
}
