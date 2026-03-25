enum VendorType {
  own('Own'),
  thirdParty('Third-party');

  const VendorType(this.label);
  final String label;
}

enum VendorServiceType {
  pdo('PDO'),
  nonPdo('Non-PDO');

  const VendorServiceType(this.label);
  final String label;
}

enum VendorStatus {
  active('Active'),
  inactive('Inactive');

  const VendorStatus(this.label);
  final String label;
}

class VendorModel {
  const VendorModel({
    required this.vendorId,
    required this.vendorName,
    required this.companyName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.vendorType,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String vendorId;
  final String vendorName;
  final String companyName;
  final String contactNumber;
  final String email;
  final String address;
  final VendorType vendorType;
  final VendorServiceType serviceType;
  final VendorStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == VendorStatus.active;

  VendorModel copyWith({
    String? vendorId,
    String? vendorName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? address,
    VendorType? vendorType,
    VendorServiceType? serviceType,
    VendorStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      companyName: companyName ?? this.companyName,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      vendorType: vendorType ?? this.vendorType,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
