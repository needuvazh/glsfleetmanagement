import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/oman_fleet_master.dart';

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
    required this.registrationNumber,
    required this.ownershipType,
    required this.baseLocation,
    required this.vendorName,
    required this.capacity,
    required this.capacityUnit,
    required this.fuelType,
    required this.manufacturer,
    required this.model,
    required this.yearOfManufacture,
    required this.status,
    required this.availabilityStatus,
    required this.assignmentAllowed,
    required this.dispatchBlocked,
    required this.blockReason,
    required this.currentLocation,
    required this.currentWorkOrder,
    required this.registrationExpiry,
    required this.insuranceExpiry,
    required this.permitExpiry,
    required this.inspectionExpiry,
    required this.ivmsInstalled,
    required this.dfmsInstalled,
    required this.escortRequired,
    required this.lastServiceDate,
    required this.nextServiceDue,
    required this.maintenanceStatus,
    required this.maintenanceNotes,
    required this.suspensionReason,
    required this.preferredRoutes,
    required this.preferredCargoTypes,
    required this.region,
    required this.nightDrivingAllowed,
    required this.specialRestrictions,
    required this.documents,
    required this.pdoCompliant,
  });

  final String vehicleNumber;
  final String vehicleName;
  final String vehicleClass;
  final String vehicleCategory;
  final String vehicleType;
  final String registrationNumber;
  final String ownershipType;
  final String baseLocation;
  final String vendorName;
  final double capacity;
  final String capacityUnit;
  final String fuelType;
  final String manufacturer;
  final String model;
  final int yearOfManufacture;
  final String status;
  final String availabilityStatus;
  final bool assignmentAllowed;
  final bool dispatchBlocked;
  final String blockReason;
  final String currentLocation;
  final String currentWorkOrder;
  final String registrationExpiry;
  final String insuranceExpiry;
  final String permitExpiry;
  final String inspectionExpiry;
  final bool ivmsInstalled;
  final bool dfmsInstalled;
  final bool escortRequired;
  final String lastServiceDate;
  final String nextServiceDue;
  final String maintenanceStatus;
  final String maintenanceNotes;
  final String suspensionReason;
  final List<String> preferredRoutes;
  final List<String> preferredCargoTypes;
  final String region;
  final bool nightDrivingAllowed;
  final String specialRestrictions;
  final List<VehicleDocumentItem> documents;
  final bool pdoCompliant;

  bool get complianceReady {
    final regValid = _isDateValid(registrationExpiry);
    final insuranceValid = _isDateValid(insuranceExpiry);
    final permitValid = _isDateValid(permitExpiry);
    final inspectionValid = _isDateValid(inspectionExpiry);
    return regValid && insuranceValid && permitValid && inspectionValid;
  }

  bool get assignmentEligible {
    final operationalStatus = status.toLowerCase() == 'active';
    final available = availabilityStatus.toLowerCase() == 'available';
    final suspended = suspensionReason.trim().isNotEmpty;
    return operationalStatus &&
        assignmentAllowed &&
        available &&
        !dispatchBlocked &&
        !suspended;
  }

  static bool _isDateValid(String dateValue) {
    final parsed = DateTime.tryParse(dateValue.trim());
    if (parsed == null) {
      return false;
    }
    return !parsed.isBefore(DateTime.now());
  }
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
    String registrationNumber = '',
    required String ownershipType,
    String baseLocation = 'Muscat',
    required String vendorName,
    required double capacity,
    required String capacityUnit,
    required String fuelType,
    required String manufacturer,
    required String model,
    required int yearOfManufacture,
    required String status,
    required String availabilityStatus,
    bool assignmentAllowed = true,
    bool dispatchBlocked = false,
    String blockReason = '',
    String currentLocation = '',
    String currentWorkOrder = '',
    String registrationExpiry = '',
    String insuranceExpiry = '',
    String permitExpiry = '',
    String inspectionExpiry = '',
    bool ivmsInstalled = true,
    bool dfmsInstalled = true,
    bool escortRequired = false,
    String lastServiceDate = '',
    String nextServiceDue = '',
    String maintenanceStatus = 'Good',
    String maintenanceNotes = '',
    String suspensionReason = '',
    List<String> preferredRoutes = const [],
    List<String> preferredCargoTypes = const [],
    String region = '',
    bool nightDrivingAllowed = true,
    String specialRestrictions = '',
    required bool isPdoVehicleType,
    required List<VehicleDocumentItem> documents,
  }) {
    final cleanVehicleNumber = vehicleNumber.trim();
    final cleanVehicleName = vehicleName.trim();
    final cleanVehicleClass = vehicleClass.trim();
    final cleanVehicleCategory = vehicleCategory.trim();
    final cleanVehicleType = vehicleType.trim();
    final cleanRegistrationNumber = registrationNumber.trim();
    final cleanOwnershipType = ownershipType.trim();
    final cleanBaseLocation = baseLocation.trim();
    final cleanVendorName = vendorName.trim();
    final cleanCapacityUnit = capacityUnit.trim();
    final cleanFuelType = fuelType.trim();
    final cleanManufacturer = manufacturer.trim();
    final cleanModel = model.trim();
    final cleanStatus = status.trim();
    final cleanAvailabilityStatus = availabilityStatus.trim();
    final cleanCurrentLocation = currentLocation.trim();
    final cleanCurrentWorkOrder = currentWorkOrder.trim();
    final cleanBlockReason = blockReason.trim();
    final cleanSuspensionReason = suspensionReason.trim();
    final cleanRegion = region.trim();
    final cleanSpecialRestrictions = specialRestrictions.trim();

    if (cleanVehicleNumber.isEmpty ||
        cleanVehicleName.isEmpty ||
        cleanVehicleClass.isEmpty ||
        cleanVehicleCategory.isEmpty ||
        cleanVehicleType.isEmpty ||
        cleanRegistrationNumber.isEmpty ||
        cleanOwnershipType.isEmpty ||
        cleanBaseLocation.isEmpty ||
        cleanCapacityUnit.isEmpty ||
        cleanFuelType.isEmpty ||
        cleanManufacturer.isEmpty ||
        cleanModel.isEmpty ||
        cleanStatus.isEmpty ||
        cleanAvailabilityStatus.isEmpty) {
      return 'All vehicle fields are required.';
    }

    if (cleanOwnershipType == 'Contracted' && cleanVendorName.isEmpty) {
      return 'Vendor name is required for contracted vehicles.';
    }

    if (!OmanFleetMaster.fleetTypes.contains(cleanVehicleType)) {
      return 'Vehicle type must be one of Oman Fleet Master types.';
    }

    if (!OmanFleetMaster.ownershipTypes.contains(cleanOwnershipType)) {
      return 'Ownership type must be Owned or Contracted.';
    }

    if (!OmanFleetMaster.omanLocations.contains(cleanBaseLocation)) {
      return 'Base location must be a supported Oman location.';
    }

    if (!OmanFleetMaster.activeStatuses.contains(cleanStatus)) {
      return 'Status must be Active or Inactive.';
    }

    if (!OmanFleetMaster.availabilityStatuses
        .contains(cleanAvailabilityStatus)) {
      return 'Availability must be Available, Assigned, Maintenance, or Blocked.';
    }

    if (dispatchBlocked && cleanBlockReason.isEmpty) {
      return 'Block reason is required when dispatch is blocked.';
    }

    if (!assignmentAllowed && cleanSuspensionReason.isEmpty) {
      return 'Suspension reason is required when assignment is disabled.';
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

    final pdoCompliant =
        !isPdoVehicleType || (!missingMandatory && !expiredMandatory);

    if (!datePattern.hasMatch(registrationExpiry.trim()) ||
        !datePattern.hasMatch(insuranceExpiry.trim()) ||
        !datePattern.hasMatch(permitExpiry.trim()) ||
        !datePattern.hasMatch(inspectionExpiry.trim())) {
      return 'Registration, insurance, permit, and inspection validity dates are required (YYYY-MM-DD).';
    }

    if (lastServiceDate.trim().isEmpty || nextServiceDue.trim().isEmpty) {
      return 'Last service date and next service due date are required.';
    }

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
      registrationNumber: cleanRegistrationNumber,
      ownershipType: cleanOwnershipType,
      baseLocation: cleanBaseLocation,
      vendorName: cleanVendorName,
      capacity: capacity,
      capacityUnit: cleanCapacityUnit,
      fuelType: cleanFuelType,
      manufacturer: cleanManufacturer,
      model: cleanModel,
      yearOfManufacture: yearOfManufacture,
      status: cleanStatus,
      availabilityStatus: cleanAvailabilityStatus,
      assignmentAllowed: assignmentAllowed,
      dispatchBlocked: dispatchBlocked,
      blockReason: cleanBlockReason,
      currentLocation: cleanCurrentLocation,
      currentWorkOrder: cleanCurrentWorkOrder,
      registrationExpiry: registrationExpiry.trim(),
      insuranceExpiry: insuranceExpiry.trim(),
      permitExpiry: permitExpiry.trim(),
      inspectionExpiry: inspectionExpiry.trim(),
      ivmsInstalled: ivmsInstalled,
      dfmsInstalled: dfmsInstalled,
      escortRequired: escortRequired,
      lastServiceDate: lastServiceDate.trim(),
      nextServiceDue: nextServiceDue.trim(),
      maintenanceStatus:
          maintenanceStatus.trim().isEmpty ? 'Good' : maintenanceStatus.trim(),
      maintenanceNotes: maintenanceNotes.trim(),
      suspensionReason: cleanSuspensionReason,
      preferredRoutes: preferredRoutes,
      preferredCargoTypes: preferredCargoTypes,
      region: cleanRegion,
      nightDrivingAllowed: nightDrivingAllowed,
      specialRestrictions: cleanSpecialRestrictions,
      documents: normalizedDocuments,
      pdoCompliant: pdoCompliant,
    );

    state = state.copyWith(transports: [transport, ...state.transports]);
    if (isPdoVehicleType && !pdoCompliant) {
      return 'Vehicle created, but Vehicle not compliant for PDO.';
    }
    return 'Vehicle created successfully.';
  }

  String markMaintenance(String vehicleNumber, {String notes = ''}) {
    final index = state.transports
        .indexWhere((item) => item.vehicleNumber == vehicleNumber);
    if (index < 0) {
      return 'Fleet not found.';
    }
    final current = state.transports[index];
    final updated = TransportItem(
      vehicleNumber: current.vehicleNumber,
      vehicleName: current.vehicleName,
      vehicleClass: current.vehicleClass,
      vehicleCategory: current.vehicleCategory,
      vehicleType: current.vehicleType,
      registrationNumber: current.registrationNumber,
      ownershipType: current.ownershipType,
      baseLocation: current.baseLocation,
      vendorName: current.vendorName,
      capacity: current.capacity,
      capacityUnit: current.capacityUnit,
      fuelType: current.fuelType,
      manufacturer: current.manufacturer,
      model: current.model,
      yearOfManufacture: current.yearOfManufacture,
      status: current.status,
      availabilityStatus: 'Maintenance',
      assignmentAllowed: false,
      dispatchBlocked: true,
      blockReason:
          notes.trim().isEmpty ? 'Maintenance in progress' : notes.trim(),
      currentLocation: current.currentLocation,
      currentWorkOrder: current.currentWorkOrder,
      registrationExpiry: current.registrationExpiry,
      insuranceExpiry: current.insuranceExpiry,
      permitExpiry: current.permitExpiry,
      inspectionExpiry: current.inspectionExpiry,
      ivmsInstalled: current.ivmsInstalled,
      dfmsInstalled: current.dfmsInstalled,
      escortRequired: current.escortRequired,
      lastServiceDate: current.lastServiceDate,
      nextServiceDue: current.nextServiceDue,
      maintenanceStatus: 'Maintenance',
      maintenanceNotes: notes.trim(),
      suspensionReason: 'Maintenance',
      preferredRoutes: current.preferredRoutes,
      preferredCargoTypes: current.preferredCargoTypes,
      region: current.region,
      nightDrivingAllowed: current.nightDrivingAllowed,
      specialRestrictions: current.specialRestrictions,
      documents: current.documents,
      pdoCompliant: current.pdoCompliant,
    );

    final next = [...state.transports];
    next[index] = updated;
    state = state.copyWith(transports: next);
    return 'Fleet marked as maintenance.';
  }

  String deactivateTransport(String vehicleNumber, {String reason = ''}) {
    final index = state.transports
        .indexWhere((item) => item.vehicleNumber == vehicleNumber);
    if (index < 0) {
      return 'Fleet not found.';
    }
    final current = state.transports[index];
    final updated = TransportItem(
      vehicleNumber: current.vehicleNumber,
      vehicleName: current.vehicleName,
      vehicleClass: current.vehicleClass,
      vehicleCategory: current.vehicleCategory,
      vehicleType: current.vehicleType,
      registrationNumber: current.registrationNumber,
      ownershipType: current.ownershipType,
      baseLocation: current.baseLocation,
      vendorName: current.vendorName,
      capacity: current.capacity,
      capacityUnit: current.capacityUnit,
      fuelType: current.fuelType,
      manufacturer: current.manufacturer,
      model: current.model,
      yearOfManufacture: current.yearOfManufacture,
      status: 'Inactive',
      availabilityStatus: 'Blocked',
      assignmentAllowed: false,
      dispatchBlocked: true,
      blockReason: reason.trim().isEmpty ? 'Deactivated' : reason.trim(),
      currentLocation: current.currentLocation,
      currentWorkOrder: current.currentWorkOrder,
      registrationExpiry: current.registrationExpiry,
      insuranceExpiry: current.insuranceExpiry,
      permitExpiry: current.permitExpiry,
      inspectionExpiry: current.inspectionExpiry,
      ivmsInstalled: current.ivmsInstalled,
      dfmsInstalled: current.dfmsInstalled,
      escortRequired: current.escortRequired,
      lastServiceDate: current.lastServiceDate,
      nextServiceDue: current.nextServiceDue,
      maintenanceStatus: current.maintenanceStatus,
      maintenanceNotes: current.maintenanceNotes,
      suspensionReason: reason.trim().isEmpty ? 'Deactivated' : reason.trim(),
      preferredRoutes: current.preferredRoutes,
      preferredCargoTypes: current.preferredCargoTypes,
      region: current.region,
      nightDrivingAllowed: current.nightDrivingAllowed,
      specialRestrictions: current.specialRestrictions,
      documents: current.documents,
      pdoCompliant: current.pdoCompliant,
    );

    final next = [...state.transports];
    next[index] = updated;
    state = state.copyWith(transports: next);
    return 'Fleet deactivated.';
  }

  String updateTransportBasics({
    required String vehicleNumber,
    required String vehicleType,
    required String registrationNumber,
    required String baseLocation,
    required String ownershipType,
    required String availabilityStatus,
    required bool assignmentAllowed,
    required bool dispatchBlocked,
    required String blockReason,
    required String status,
    required String suspensionReason,
    required String registrationExpiry,
    required String insuranceExpiry,
    required String permitExpiry,
    required String inspectionExpiry,
  }) {
    final index = state.transports
        .indexWhere((item) => item.vehicleNumber == vehicleNumber);
    if (index < 0) {
      return 'Fleet not found.';
    }

    if (!OmanFleetMaster.fleetTypes.contains(vehicleType)) {
      return 'Invalid Oman fleet type selected.';
    }
    if (!OmanFleetMaster.omanLocations.contains(baseLocation)) {
      return 'Invalid base location selected.';
    }
    if (!OmanFleetMaster.ownershipTypes.contains(ownershipType)) {
      return 'Invalid ownership type selected.';
    }
    if (!OmanFleetMaster.activeStatuses.contains(status)) {
      return 'Invalid status selected.';
    }
    if (!OmanFleetMaster.availabilityStatuses.contains(availabilityStatus)) {
      return 'Invalid availability status selected.';
    }
    if (dispatchBlocked && blockReason.trim().isEmpty) {
      return 'Block reason is required when dispatch is blocked.';
    }
    if (!assignmentAllowed && suspensionReason.trim().isEmpty) {
      return 'Suspension reason is required when assignment is disabled.';
    }

    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!datePattern.hasMatch(registrationExpiry.trim()) ||
        !datePattern.hasMatch(insuranceExpiry.trim()) ||
        !datePattern.hasMatch(permitExpiry.trim()) ||
        !datePattern.hasMatch(inspectionExpiry.trim())) {
      return 'Compliance validity dates must be in YYYY-MM-DD format.';
    }

    final current = state.transports[index];
    final updated = TransportItem(
      vehicleNumber: current.vehicleNumber,
      vehicleName: current.vehicleName,
      vehicleClass: OmanFleetMaster.vehicleClassForType(vehicleType),
      vehicleCategory:
          OmanFleetMaster.vehicleClassForType(vehicleType) == 'Light'
              ? 'Light Vehicle'
              : 'Heavy Vehicle',
      vehicleType: vehicleType,
      registrationNumber: registrationNumber.trim(),
      ownershipType: ownershipType,
      baseLocation: baseLocation,
      vendorName: current.vendorName,
      capacity: current.capacity,
      capacityUnit: current.capacityUnit,
      fuelType: current.fuelType,
      manufacturer: current.manufacturer,
      model: current.model,
      yearOfManufacture: current.yearOfManufacture,
      status: status,
      availabilityStatus: availabilityStatus,
      assignmentAllowed: assignmentAllowed,
      dispatchBlocked: dispatchBlocked,
      blockReason: blockReason.trim(),
      currentLocation: current.currentLocation,
      currentWorkOrder: current.currentWorkOrder,
      registrationExpiry: registrationExpiry.trim(),
      insuranceExpiry: insuranceExpiry.trim(),
      permitExpiry: permitExpiry.trim(),
      inspectionExpiry: inspectionExpiry.trim(),
      ivmsInstalled: current.ivmsInstalled,
      dfmsInstalled: current.dfmsInstalled,
      escortRequired: current.escortRequired,
      lastServiceDate: current.lastServiceDate,
      nextServiceDue: current.nextServiceDue,
      maintenanceStatus: current.maintenanceStatus,
      maintenanceNotes: current.maintenanceNotes,
      suspensionReason: suspensionReason.trim(),
      preferredRoutes: current.preferredRoutes,
      preferredCargoTypes: current.preferredCargoTypes,
      region: current.region,
      nightDrivingAllowed: current.nightDrivingAllowed,
      specialRestrictions: current.specialRestrictions,
      documents: current.documents,
      pdoCompliant: current.pdoCompliant,
    );

    final next = [...state.transports];
    next[index] = updated;
    state = state.copyWith(transports: next);
    return 'Fleet updated successfully.';
  }
}
