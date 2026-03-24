import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleItem {
  const RoleItem({
    required this.name,
    this.systemRole = false,
  });

  final String name;
  final bool systemRole;
}

class UserItem {
  const UserItem({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.driverName,
    required this.countryCode,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.email,
    required this.address,
    required this.licenseNumber,
    required this.licenseType,
    required this.licenseExpiryDate,
    required this.joiningDate,
    required this.experienceYears,
    required this.status,
    required this.role,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String driverName;
  final String countryCode;
  final String phoneNumber;
  final String alternateNumber;
  final String email;
  final String address;
  final String licenseNumber;
  final String licenseType;
  final String licenseExpiryDate;
  final String joiningDate;
  final int experienceYears;
  final String status;
  final String role;

  String get fullName => '$firstName $lastName';

  String get fullMobile => '$countryCode $phoneNumber';

  String get fullAlternateMobile =>
      alternateNumber.trim().isEmpty ? '-' : '$countryCode $alternateNumber';
}

class TransportItem {
  const TransportItem({
    required this.vehicleNumber,
    required this.vehicleName,
    required this.vehicleClass,
    required this.vehicleCategory,
    required this.vehicleType,
    required this.ownershipType,
    required this.vendorName,
    required this.capacity,
    required this.capacityUnit,
    required this.fuelType,
    required this.manufacturer,
    required this.model,
    required this.yearOfManufacture,
    required this.status,
    required this.availabilityStatus,
    required this.documents,
    required this.pdoCompliant,
  });

  final String vehicleNumber;
  final String vehicleName;
  final String vehicleClass;
  final String vehicleCategory;
  final String vehicleType;
  final String ownershipType;
  final String vendorName;
  final double capacity;
  final String capacityUnit;
  final String fuelType;
  final String manufacturer;
  final String model;
  final int yearOfManufacture;
  final String status;
  final String availabilityStatus;
  final List<VehicleDocumentItem> documents;
  final bool pdoCompliant;
}

class VehicleDocumentItem {
  const VehicleDocumentItem({
    required this.documentName,
    required this.mandatory,
    required this.documentNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.uploadFile,
    required this.status,
  });

  final String documentName;
  final bool mandatory;
  final String documentNumber;
  final String issueDate;
  final String expiryDate;
  final String uploadFile;
  final String status;
}

class AccessControlState {
  const AccessControlState({
    required this.roles,
    required this.users,
    required this.transports,
  });

  final List<RoleItem> roles;
  final List<UserItem> users;
  final List<TransportItem> transports;

  AccessControlState copyWith({
    List<RoleItem>? roles,
    List<UserItem>? users,
    List<TransportItem>? transports,
  }) {
    return AccessControlState(
      roles: roles ?? this.roles,
      users: users ?? this.users,
      transports: transports ?? this.transports,
    );
  }
}

final accessControlProvider =
    NotifierProvider<AccessControlNotifier, AccessControlState>(
  AccessControlNotifier.new,
);

class AccessControlNotifier extends Notifier<AccessControlState> {
  static const _defaultRoles = [
    'Admin',
    'Driver',
    'Transport Manager',
    'Journey manager',
  ];

  @override
  AccessControlState build() {
    return AccessControlState(
      roles: const [
        RoleItem(name: 'Admin', systemRole: true),
        RoleItem(name: 'Driver', systemRole: true),
        RoleItem(name: 'Transport Manager', systemRole: true),
        RoleItem(name: 'Journey manager', systemRole: true),
      ],
      users: const [],
      transports: const [],
    );
  }

  String addRole(String roleName) {
    final normalized = roleName.trim();
    if (normalized.isEmpty) {
      return 'Role name is required.';
    }

    final exists = state.roles.any(
      (role) => role.name.toLowerCase() == normalized.toLowerCase(),
    );
    if (exists ||
        _defaultRoles
            .any((role) => role.toLowerCase() == normalized.toLowerCase())) {
      return 'Role already exists.';
    }

    final nextRoles = [RoleItem(name: normalized), ...state.roles];
    state = state.copyWith(roles: nextRoles);
    return 'Role created successfully.';
  }

  String addUser({
    required String firstName,
    required String lastName,
    required String driverName,
    required String countryCode,
    required String phoneNumber,
    required String alternateNumber,
    required String email,
    required String address,
    required String licenseNumber,
    required String licenseType,
    required String licenseExpiryDate,
    required String joiningDate,
    required int experienceYears,
    required String status,
    required String role,
  }) {
    final cleanFirstName = firstName.trim();
    final cleanLastName = lastName.trim();
    final cleanDriverName = driverName.trim();
    final cleanCountryCode = countryCode.trim();
    final cleanPhoneNumber = phoneNumber.trim();
    final cleanAlternateNumber = alternateNumber.trim();
    final cleanEmail = email.trim();
    final cleanAddress = address.trim();
    final cleanLicenseNumber = licenseNumber.trim();
    final cleanLicenseType = licenseType.trim();
    final cleanLicenseExpiryDate = licenseExpiryDate.trim();
    final cleanJoiningDate = joiningDate.trim();
    final cleanStatus = status.trim();
    final cleanRole = role.trim();

    if (cleanFirstName.isEmpty ||
        cleanLastName.isEmpty ||
        cleanDriverName.isEmpty ||
        cleanCountryCode.isEmpty ||
        cleanPhoneNumber.isEmpty ||
        cleanEmail.isEmpty ||
        cleanAddress.isEmpty ||
        cleanLicenseNumber.isEmpty ||
        cleanLicenseType.isEmpty ||
        cleanLicenseExpiryDate.isEmpty ||
        cleanJoiningDate.isEmpty ||
        cleanStatus.isEmpty ||
        cleanRole.isEmpty) {
      return 'All user fields are required.';
    }

    if (!RegExp(r'^\+[0-9]{1,4}$').hasMatch(cleanCountryCode)) {
      return 'Country code must look like +968.';
    }

    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(cleanPhoneNumber)) {
      return 'Phone number must be 7-15 digits.';
    }

    if (cleanAlternateNumber.isNotEmpty &&
        !RegExp(r'^[0-9]{7,15}$').hasMatch(cleanAlternateNumber)) {
      return 'Alternate number must be 7-15 digits.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanEmail)) {
      return 'Enter a valid email address.';
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleanLicenseExpiryDate) ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleanJoiningDate)) {
      return 'Dates must follow YYYY-MM-DD format.';
    }

    if (experienceYears < 0 || experienceYears > 60) {
      return 'Experience must be between 0 and 60 years.';
    }

    final roleExists = state.roles.any((item) => item.name == cleanRole);
    if (!roleExists) {
      return 'Selected role is invalid.';
    }

    final emailExists = state.users.any(
      (user) => user.email.toLowerCase() == cleanEmail.toLowerCase(),
    );
    if (emailExists) {
      return 'User email already exists.';
    }

    final userId = 'USR-${(state.users.length + 1).toString().padLeft(3, '0')}';
    final user = UserItem(
      userId: userId,
      firstName: cleanFirstName,
      lastName: cleanLastName,
      driverName: cleanDriverName,
      countryCode: cleanCountryCode,
      phoneNumber: cleanPhoneNumber,
      alternateNumber: cleanAlternateNumber,
      email: cleanEmail,
      address: cleanAddress,
      licenseNumber: cleanLicenseNumber,
      licenseType: cleanLicenseType,
      licenseExpiryDate: cleanLicenseExpiryDate,
      joiningDate: cleanJoiningDate,
      experienceYears: experienceYears,
      status: cleanStatus,
      role: cleanRole,
    );

    state = state.copyWith(users: [user, ...state.users]);
    return 'User created successfully.';
  }

  String addTransport({
    required String vehicleNumber,
    required String vehicleName,
    required String vehicleClass,
    required String vehicleCategory,
    required String vehicleType,
    required String ownershipType,
    required String vendorName,
    required double capacity,
    required String capacityUnit,
    required String fuelType,
    required String manufacturer,
    required String model,
    required int yearOfManufacture,
    required String status,
    required String availabilityStatus,
    required bool isPdoVehicleType,
    required List<VehicleDocumentItem> documents,
  }) {
    final cleanVehicleNumber = vehicleNumber.trim();
    final cleanVehicleName = vehicleName.trim();
    final cleanVehicleClass = vehicleClass.trim();
    final cleanVehicleCategory = vehicleCategory.trim();
    final cleanVehicleType = vehicleType.trim();
    final cleanOwnershipType = ownershipType.trim();
    final cleanVendorName = vendorName.trim();
    final cleanCapacityUnit = capacityUnit.trim();
    final cleanFuelType = fuelType.trim();
    final cleanManufacturer = manufacturer.trim();
    final cleanModel = model.trim();
    final cleanStatus = status.trim();
    final cleanAvailabilityStatus = availabilityStatus.trim();

    if (cleanVehicleNumber.isEmpty ||
        cleanVehicleName.isEmpty ||
        cleanVehicleClass.isEmpty ||
        cleanVehicleCategory.isEmpty ||
        cleanVehicleType.isEmpty ||
        cleanOwnershipType.isEmpty ||
        cleanCapacityUnit.isEmpty ||
        cleanFuelType.isEmpty ||
        cleanManufacturer.isEmpty ||
        cleanModel.isEmpty ||
        cleanStatus.isEmpty ||
        cleanAvailabilityStatus.isEmpty) {
      return 'All vehicle fields are required.';
    }

    if (cleanOwnershipType == 'Vendor Owned' && cleanVendorName.isEmpty) {
      return 'Vendor name is required for vendor-owned vehicles.';
    }

    if (capacity <= 0) {
      return 'Capacity must be a valid number.';
    }

    final currentYear = DateTime.now().year;
    if (yearOfManufacture < 1980 || yearOfManufacture > currentYear + 1) {
      return 'Year of manufacture is invalid.';
    }

    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    for (final document in documents) {
      if (document.documentName.trim().isEmpty) {
        continue;
      }
      final needsValues = document.mandatory ||
          document.documentNumber.trim().isNotEmpty ||
          document.issueDate.trim().isNotEmpty ||
          document.expiryDate.trim().isNotEmpty;
      if (!needsValues) {
        continue;
      }
      if (document.documentNumber.trim().isEmpty ||
          !datePattern.hasMatch(document.issueDate.trim()) ||
          !datePattern.hasMatch(document.expiryDate.trim())) {
        return 'Mandatory vehicle documents must include number, issue and expiry dates.';
      }
    }

    final duplicateVehicleNumber = state.transports.any(
      (item) =>
          item.vehicleNumber.toLowerCase() == cleanVehicleNumber.toLowerCase(),
    );
    if (duplicateVehicleNumber) {
      return 'Vehicle number already exists.';
    }

    final today = DateTime.now();
    bool missingMandatory = false;
    bool expiredMandatory = false;

    for (final document in documents) {
      if (!document.mandatory) {
        continue;
      }
      if (document.documentNumber.trim().isEmpty ||
          document.issueDate.trim().isEmpty ||
          document.expiryDate.trim().isEmpty) {
        missingMandatory = true;
        continue;
      }
      final expiry = DateTime.tryParse(document.expiryDate.trim());
      if (expiry == null || expiry.isBefore(today)) {
        expiredMandatory = true;
      }
    }

    if (cleanStatus == 'Active' && (missingMandatory || expiredMandatory)) {
      return 'Cannot activate vehicle: mandatory documents are missing or expired.';
    }

    final pdoCompliant = !isPdoVehicleType || (!missingMandatory && !expiredMandatory);

    final normalizedDocuments = [
      for (final document in documents)
        VehicleDocumentItem(
          documentName: document.documentName.trim(),
          mandatory: document.mandatory,
          documentNumber: document.documentNumber.trim(),
          issueDate: document.issueDate.trim(),
          expiryDate: document.expiryDate.trim(),
          uploadFile: document.uploadFile.trim(),
          status: document.status.trim(),
        ),
    ];

    final transport = TransportItem(
      vehicleNumber: cleanVehicleNumber,
      vehicleName: cleanVehicleName,
      vehicleClass: cleanVehicleClass,
      vehicleCategory: cleanVehicleCategory,
      vehicleType: cleanVehicleType,
      ownershipType: cleanOwnershipType,
      vendorName: cleanVendorName,
      capacity: capacity,
      capacityUnit: cleanCapacityUnit,
      fuelType: cleanFuelType,
      manufacturer: cleanManufacturer,
      model: cleanModel,
      yearOfManufacture: yearOfManufacture,
      status: cleanStatus,
      availabilityStatus: cleanAvailabilityStatus,
      documents: normalizedDocuments,
      pdoCompliant: pdoCompliant,
    );

    state = state.copyWith(transports: [transport, ...state.transports]);
    if (isPdoVehicleType && !pdoCompliant) {
      return 'Vehicle created, but Vehicle not compliant for PDO.';
    }
    return 'Vehicle created successfully.';
  }
}
