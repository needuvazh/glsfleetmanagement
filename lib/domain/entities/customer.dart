class Customer {
  final String id;
  final String name;
  final String address;
  final String email;
  final String phoneNumber;
  final String crNumber;
  final String vatinNumber;
  final String currency;
  final String contactPerson;
  final String category; // PDO or NON-PDO
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.phoneNumber,
    required this.crNumber,
    required this.vatinNumber,
    required this.currency,
    required this.contactPerson,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      crNumber: json['crNumber'] as String,
      vatinNumber: json['vatinNumber'] as String,
      currency: json['currency'] as String? ?? 'OMR',
      contactPerson: json['contactPerson'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
      'crNumber': crNumber,
      'vatinNumber': vatinNumber,
      'currency': currency,
      'contactPerson': contactPerson,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? address,
    String? email,
    String? phoneNumber,
    String? crNumber,
    String? vatinNumber,
    String? currency,
    String? contactPerson,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      crNumber: crNumber ?? this.crNumber,
      vatinNumber: vatinNumber ?? this.vatinNumber,
      currency: currency ?? this.currency,
      contactPerson: contactPerson ?? this.contactPerson,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Customer(id: $id, name: $name, category: $category, contact: $contactPerson)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          crNumber == other.crNumber;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ crNumber.hashCode;
}
