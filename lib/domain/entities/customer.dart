class Customer {
  final String id;
  final String name;
  final String shortCode;
  final String customerType;
  final String status;
  final String segment;
  final bool isBlocked;
  final bool hardBlock;
  final String blockReason;
  final String billingAddress;
  final String city;
  final String country;
  final String email;
  final String phoneNumber;
  final String alternateContact;
  final String crNumber;
  final String vatinNumber;
  final String currency;
  final String primaryContactPerson;
  final String paymentTerms;
  final double creditLimit;
  final double outstandingAmount;
  final bool hasOverduePayments;
  final String paymentMode;
  final String invoiceCycle;
  final int averagePaymentDelayDays;
  final int complaintsCount;
  final int riskScore;
  final bool podRequired;
  final bool dnRequired;
  final List<String> specialDocumentsRequired;
  final int slaHours;
  final String preferredVehicleType;
  final String preferredRoute;
  final String priorityLevel;
  final List<String> specialCertificationsRequired;
  final List<String> restrictedRoutes;
  final List<String> safetyRules;
  final String mandatoryInspectionType;
  final int activeWorkOrders;
  final int pendingInvoices;
  final int overdueInvoices;
  final String createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.customerType,
    required this.status,
    required this.segment,
    required this.billingAddress,
    required this.city,
    required this.country,
    required this.email,
    required this.phoneNumber,
    this.alternateContact = '',
    required this.crNumber,
    required this.vatinNumber,
    required this.currency,
    required this.primaryContactPerson,
    required this.paymentTerms,
    this.creditLimit = 0,
    this.outstandingAmount = 0,
    this.hasOverduePayments = false,
    required this.paymentMode,
    required this.invoiceCycle,
    this.averagePaymentDelayDays = 0,
    this.complaintsCount = 0,
    this.riskScore = 0,
    this.podRequired = false,
    this.dnRequired = false,
    this.specialDocumentsRequired = const [],
    this.slaHours = 0,
    this.preferredVehicleType = '',
    this.preferredRoute = '',
    this.priorityLevel = 'Normal',
    this.specialCertificationsRequired = const [],
    this.restrictedRoutes = const [],
    this.safetyRules = const [],
    this.mandatoryInspectionType = '',
    this.activeWorkOrders = 0,
    this.pendingInvoices = 0,
    this.overdueInvoices = 0,
    this.isBlocked = false,
    this.hardBlock = true,
    this.blockReason = '',
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  bool get isActive => status == 'Active';
  bool get isCreditExceeded =>
      creditLimit > 0 && outstandingAmount > creditLimit;
  bool get isNearCreditLimit {
    if (creditLimit <= 0 || isCreditExceeded) {
      return false;
    }
    return (outstandingAmount / creditLimit) >= 0.85;
  }

  bool get isHighRisk =>
      riskScore >= 70 || hasOverduePayments || isCreditExceeded || isBlocked;

  double get creditUsagePercent {
    if (creditLimit <= 0) {
      return 0;
    }
    final ratio = (outstandingAmount / creditLimit) * 100;
    return ratio.isFinite ? ratio.clamp(0, 999) : 0;
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      shortCode: (json['shortCode'] as String?)?.trim().isNotEmpty == true
          ? json['shortCode'] as String
          : _deriveShortCode(json['name'] as String? ?? ''),
      customerType: json['customerType'] as String? ?? 'Corporate',
      status: json['status'] as String? ?? 'Active',
      segment: json['segment'] as String? ??
          json['category'] as String? ??
          'NON-PDO',
      isBlocked: json['isBlocked'] as bool? ?? false,
      hardBlock: json['hardBlock'] as bool? ?? true,
      blockReason: json['blockReason'] as String? ?? '',
      billingAddress:
          json['billingAddress'] as String? ?? json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'Oman',
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      alternateContact: json['alternateContact'] as String? ?? '',
      crNumber: json['crNumber'] as String,
      vatinNumber: json['vatinNumber'] as String,
      currency: json['currency'] as String? ?? 'OMR',
      primaryContactPerson: json['primaryContactPerson'] as String? ??
          json['contactPerson'] as String? ??
          '',
      paymentTerms: json['paymentTerms'] as String? ?? 'Net 30',
      creditLimit: _toDouble(json['creditLimit']),
      outstandingAmount: _toDouble(json['outstandingAmount']),
      hasOverduePayments: json['hasOverduePayments'] as bool? ?? false,
      paymentMode: json['paymentMode'] as String? ?? 'Credit',
      invoiceCycle: json['invoiceCycle'] as String? ?? 'Per Trip',
      averagePaymentDelayDays: _toInt(json['averagePaymentDelayDays']),
      complaintsCount: _toInt(json['complaintsCount']),
      riskScore: _toInt(json['riskScore']),
      podRequired: json['podRequired'] as bool? ?? false,
      dnRequired: json['dnRequired'] as bool? ?? false,
      specialDocumentsRequired: _toStringList(json['specialDocumentsRequired']),
      slaHours: _toInt(json['slaHours']),
      preferredVehicleType: json['preferredVehicleType'] as String? ?? '',
      preferredRoute: json['preferredRoute'] as String? ?? '',
      priorityLevel: json['priorityLevel'] as String? ?? 'Normal',
      specialCertificationsRequired:
          _toStringList(json['specialCertificationsRequired']),
      restrictedRoutes: _toStringList(json['restrictedRoutes']),
      safetyRules: _toStringList(json['safetyRules']),
      mandatoryInspectionType: json['mandatoryInspectionType'] as String? ?? '',
      activeWorkOrders: _toInt(json['activeWorkOrders']),
      pendingInvoices: _toInt(json['pendingInvoices']),
      overdueInvoices: _toInt(json['overdueInvoices']),
      createdBy: json['createdBy'] as String? ?? 'system',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortCode': shortCode,
      'customerType': customerType,
      'status': status,
      'segment': segment,
      'isBlocked': isBlocked,
      'hardBlock': hardBlock,
      'blockReason': blockReason,
      'billingAddress': billingAddress,
      'city': city,
      'country': country,
      'email': email,
      'phoneNumber': phoneNumber,
      'alternateContact': alternateContact,
      'crNumber': crNumber,
      'vatinNumber': vatinNumber,
      'currency': currency,
      'primaryContactPerson': primaryContactPerson,
      'paymentTerms': paymentTerms,
      'creditLimit': creditLimit,
      'outstandingAmount': outstandingAmount,
      'hasOverduePayments': hasOverduePayments,
      'paymentMode': paymentMode,
      'invoiceCycle': invoiceCycle,
      'averagePaymentDelayDays': averagePaymentDelayDays,
      'complaintsCount': complaintsCount,
      'riskScore': riskScore,
      'podRequired': podRequired,
      'dnRequired': dnRequired,
      'specialDocumentsRequired': specialDocumentsRequired,
      'slaHours': slaHours,
      'preferredVehicleType': preferredVehicleType,
      'preferredRoute': preferredRoute,
      'priorityLevel': priorityLevel,
      'specialCertificationsRequired': specialCertificationsRequired,
      'restrictedRoutes': restrictedRoutes,
      'safetyRules': safetyRules,
      'mandatoryInspectionType': mandatoryInspectionType,
      'activeWorkOrders': activeWorkOrders,
      'pendingInvoices': pendingInvoices,
      'overdueInvoices': overdueInvoices,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? shortCode,
    String? customerType,
    String? status,
    String? segment,
    bool? isBlocked,
    bool? hardBlock,
    String? blockReason,
    String? billingAddress,
    String? city,
    String? country,
    String? email,
    String? phoneNumber,
    String? alternateContact,
    String? crNumber,
    String? vatinNumber,
    String? currency,
    String? primaryContactPerson,
    String? paymentTerms,
    double? creditLimit,
    double? outstandingAmount,
    bool? hasOverduePayments,
    String? paymentMode,
    String? invoiceCycle,
    int? averagePaymentDelayDays,
    int? complaintsCount,
    int? riskScore,
    bool? podRequired,
    bool? dnRequired,
    List<String>? specialDocumentsRequired,
    int? slaHours,
    String? preferredVehicleType,
    String? preferredRoute,
    String? priorityLevel,
    List<String>? specialCertificationsRequired,
    List<String>? restrictedRoutes,
    List<String>? safetyRules,
    String? mandatoryInspectionType,
    int? activeWorkOrders,
    int? pendingInvoices,
    int? overdueInvoices,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      customerType: customerType ?? this.customerType,
      status: status ?? this.status,
      segment: segment ?? this.segment,
      isBlocked: isBlocked ?? this.isBlocked,
      hardBlock: hardBlock ?? this.hardBlock,
      blockReason: blockReason ?? this.blockReason,
      billingAddress: billingAddress ?? this.billingAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternateContact: alternateContact ?? this.alternateContact,
      crNumber: crNumber ?? this.crNumber,
      vatinNumber: vatinNumber ?? this.vatinNumber,
      currency: currency ?? this.currency,
      primaryContactPerson: primaryContactPerson ?? this.primaryContactPerson,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      hasOverduePayments: hasOverduePayments ?? this.hasOverduePayments,
      paymentMode: paymentMode ?? this.paymentMode,
      invoiceCycle: invoiceCycle ?? this.invoiceCycle,
      averagePaymentDelayDays:
          averagePaymentDelayDays ?? this.averagePaymentDelayDays,
      complaintsCount: complaintsCount ?? this.complaintsCount,
      riskScore: riskScore ?? this.riskScore,
      podRequired: podRequired ?? this.podRequired,
      dnRequired: dnRequired ?? this.dnRequired,
      specialDocumentsRequired:
          specialDocumentsRequired ?? this.specialDocumentsRequired,
      slaHours: slaHours ?? this.slaHours,
      preferredVehicleType: preferredVehicleType ?? this.preferredVehicleType,
      preferredRoute: preferredRoute ?? this.preferredRoute,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      specialCertificationsRequired:
          specialCertificationsRequired ?? this.specialCertificationsRequired,
      restrictedRoutes: restrictedRoutes ?? this.restrictedRoutes,
      safetyRules: safetyRules ?? this.safetyRules,
      mandatoryInspectionType:
          mandatoryInspectionType ?? this.mandatoryInspectionType,
      activeWorkOrders: activeWorkOrders ?? this.activeWorkOrders,
      pendingInvoices: pendingInvoices ?? this.pendingInvoices,
      overdueInvoices: overdueInvoices ?? this.overdueInvoices,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Customer(id: $id, name: $name, shortCode: $shortCode, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _deriveShortCode(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'CUS';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 3))
          .toUpperCase();
    }
    return parts.take(3).map((part) => part[0]).join().toUpperCase();
  }
}
