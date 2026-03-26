import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cargo_model.dart';

abstract class CargoMockDataSource {
  Future<List<CargoModel>> getCargoTypes();
  Future<CargoModel?> getCargoByCode(String cargoCode);
  Future<List<CargoModel>> addCargo(CargoModel cargo);
  Future<List<CargoModel>> updateCargo(CargoModel cargo);
}

class CargoMockDataSourceImpl implements CargoMockDataSource {
  CargoMockDataSourceImpl();

  static const _cacheKey = 'cargo_master_records_v1';
  List<CargoModel>? _items;
  int _sequence = 1;

  Future<void> _ensureInitialized() async {
    if (_items != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _items = decoded
            .map((entry) => _fromMap(Map<String, dynamic>.from(entry)))
            .toList();
      } catch (_) {
        _items = _seedCargo();
      }
    } else {
      _items = _seedCargo();
    }

    _sequence = _nextSequence(_items!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _items!.map(_toMap).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  @override
  Future<List<CargoModel>> getCargoTypes() async {
    await _ensureInitialized();
    return _items!.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<CargoModel?> getCargoByCode(String cargoCode) async {
    await _ensureInitialized();
    for (final entry in _items!) {
      if (entry.cargoCode.toLowerCase() == cargoCode.toLowerCase()) {
        return entry.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<CargoModel>> addCargo(CargoModel cargo) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final code = cargo.cargoCode.trim().isEmpty
        ? _nextCargoCode()
        : cargo.cargoCode.trim();
    final next = cargo.copyWith(
      cargoCode: code,
      createdAt: now,
      updatedAt: now,
    );
    _items!.add(next);
    await _persist();
    return getCargoTypes();
  }

  @override
  Future<List<CargoModel>> updateCargo(CargoModel cargo) async {
    await _ensureInitialized();
    final index = _items!.indexWhere((entry) =>
        entry.cargoCode.toLowerCase() == cargo.cargoCode.toLowerCase());
    if (index == -1) {
      return getCargoTypes();
    }
    final existing = _items![index];
    _items![index] = cargo.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return getCargoTypes();
  }

  String _nextCargoCode() {
    final code = 'CG-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return code;
  }

  int _nextSequence(List<CargoModel> items) {
    var maxValue = 0;
    final pattern = RegExp(r'CG-(\d+)', caseSensitive: false);
    for (final item in items) {
      final match = pattern.firstMatch(item.cargoCode);
      final value = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue + 1;
  }

  CargoModel _fromMap(Map<String, dynamic> map) {
    return CargoModel(
      cargoCode: map['cargoCode'] as String? ?? '',
      cargoName: map['cargoName'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      subcategory: map['subcategory'] as String? ?? '',
      status: _cargoStatusFromName(map['status'] as String?),
      standardWeightRange: map['standardWeightRange'] as String? ?? '',
      length: (map['length'] as num?)?.toDouble(),
      width: (map['width'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      volumeSizeClass: map['volumeSizeClass'] as String? ?? '',
      oversized: map['oversized'] as bool? ?? false,
      riskLevel: _riskLevelFromName(map['riskLevel'] as String?),
      hazardous: map['hazardous'] as bool? ?? false,
      fragile: map['fragile'] as bool? ?? false,
      temperatureSensitive: map['temperatureSensitive'] as bool? ?? false,
      specialHandlingRequired: map['specialHandlingRequired'] as bool? ?? false,
      riskNotes: map['riskNotes'] as String? ?? '',
      preferredVehicleType: map['preferredVehicleType'] as String? ?? '',
      preferredTrailerType: map['preferredTrailerType'] as String? ?? '',
      loadingMethod: map['loadingMethod'] as String? ?? '',
      unloadingMethod: map['unloadingMethod'] as String? ?? '',
      lashingRequired: map['lashingRequired'] as bool? ?? false,
      escortRequired: map['escortRequired'] as bool? ?? false,
      specialEquipmentRequired:
          map['specialEquipmentRequired'] as String? ?? '',
      handlingInstructions: map['handlingInstructions'] as String? ?? '',
      specialComplianceRequired:
          map['specialComplianceRequired'] as bool? ?? false,
      requiredCertifications: _stringList(map['requiredCertifications']),
      requiredPermits: _stringList(map['requiredPermits']),
      authorityApprovalNeeded: map['authorityApprovalNeeded'] as bool? ?? false,
      customerIndustryRestrictions:
          map['customerIndustryRestrictions'] as String? ?? '',
      complianceNotes: map['complianceNotes'] as String? ?? '',
      inspectionRequired: map['inspectionRequired'] as bool? ?? false,
      inspectionTemplateType: map['inspectionTemplateType'] as String? ?? '',
      preDispatchInspectionRequired:
          map['preDispatchInspectionRequired'] as bool? ?? false,
      inTransitCheckRequired: map['inTransitCheckRequired'] as bool? ?? false,
      postDeliveryCheckRequired:
          map['postDeliveryCheckRequired'] as bool? ?? false,
      photoEvidenceMandatory: map['photoEvidenceMandatory'] as bool? ?? false,
      videoEvidenceMandatory: map['videoEvidenceMandatory'] as bool? ?? false,
      inspectionNotes: map['inspectionNotes'] as String? ?? '',
      restricted: map['restricted'] as bool? ?? false,
      restrictionReason: map['restrictionReason'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> _toMap(CargoModel item) {
    return {
      'cargoCode': item.cargoCode,
      'cargoName': item.cargoName,
      'category': item.category,
      'subcategory': item.subcategory,
      'status': item.status.name,
      'standardWeightRange': item.standardWeightRange,
      'length': item.length,
      'width': item.width,
      'height': item.height,
      'volumeSizeClass': item.volumeSizeClass,
      'oversized': item.oversized,
      'riskLevel': item.riskLevel.name,
      'hazardous': item.hazardous,
      'fragile': item.fragile,
      'temperatureSensitive': item.temperatureSensitive,
      'specialHandlingRequired': item.specialHandlingRequired,
      'riskNotes': item.riskNotes,
      'preferredVehicleType': item.preferredVehicleType,
      'preferredTrailerType': item.preferredTrailerType,
      'loadingMethod': item.loadingMethod,
      'unloadingMethod': item.unloadingMethod,
      'lashingRequired': item.lashingRequired,
      'escortRequired': item.escortRequired,
      'specialEquipmentRequired': item.specialEquipmentRequired,
      'handlingInstructions': item.handlingInstructions,
      'specialComplianceRequired': item.specialComplianceRequired,
      'requiredCertifications': item.requiredCertifications,
      'requiredPermits': item.requiredPermits,
      'authorityApprovalNeeded': item.authorityApprovalNeeded,
      'customerIndustryRestrictions': item.customerIndustryRestrictions,
      'complianceNotes': item.complianceNotes,
      'inspectionRequired': item.inspectionRequired,
      'inspectionTemplateType': item.inspectionTemplateType,
      'preDispatchInspectionRequired': item.preDispatchInspectionRequired,
      'inTransitCheckRequired': item.inTransitCheckRequired,
      'postDeliveryCheckRequired': item.postDeliveryCheckRequired,
      'photoEvidenceMandatory': item.photoEvidenceMandatory,
      'videoEvidenceMandatory': item.videoEvidenceMandatory,
      'inspectionNotes': item.inspectionNotes,
      'restricted': item.restricted,
      'restrictionReason': item.restrictionReason,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  List<String> _stringList(dynamic raw) {
    final list = raw as List<dynamic>? ?? const [];
    return list
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  CargoStatus _cargoStatusFromName(String? value) {
    for (final item in CargoStatus.values) {
      if (item.name == value) {
        return item;
      }
    }
    return CargoStatus.active;
  }

  CargoRiskLevel _riskLevelFromName(String? value) {
    for (final item in CargoRiskLevel.values) {
      if (item.name == value) {
        return item;
      }
    }
    return CargoRiskLevel.low;
  }
}

List<CargoModel> _seedCargo() {
  final now = DateTime.now();
  return [
    CargoModel(
      cargoCode: 'CG-001',
      cargoName: 'General Cargo',
      category: 'General',
      subcategory: 'Packaged Goods',
      status: CargoStatus.active,
      standardWeightRange: '1-20 Tons',
      length: null,
      width: null,
      height: null,
      volumeSizeClass: 'Medium',
      oversized: false,
      riskLevel: CargoRiskLevel.low,
      hazardous: false,
      fragile: false,
      temperatureSensitive: false,
      specialHandlingRequired: false,
      riskNotes: '',
      preferredVehicleType: 'Flatbed Truck',
      preferredTrailerType: 'Flatbed',
      loadingMethod: 'Forklift',
      unloadingMethod: 'Forklift',
      lashingRequired: false,
      escortRequired: false,
      specialEquipmentRequired: '',
      handlingInstructions: 'Standard secure loading procedure.',
      specialComplianceRequired: false,
      requiredCertifications: const [],
      requiredPermits: const [],
      authorityApprovalNeeded: false,
      customerIndustryRestrictions: '',
      complianceNotes: '',
      inspectionRequired: true,
      inspectionTemplateType: 'Pre-Trip Basic',
      preDispatchInspectionRequired: true,
      inTransitCheckRequired: false,
      postDeliveryCheckRequired: false,
      photoEvidenceMandatory: false,
      videoEvidenceMandatory: false,
      inspectionNotes: '',
      restricted: false,
      restrictionReason: '',
      createdAt: now,
      updatedAt: now,
    ),
    CargoModel(
      cargoCode: 'CG-002',
      cargoName: 'Heavy Equipment',
      category: 'Equipment',
      subcategory: 'Machinery',
      status: CargoStatus.active,
      standardWeightRange: '20-80 Tons',
      length: 10.0,
      width: 3.2,
      height: 3.5,
      volumeSizeClass: 'XL',
      oversized: true,
      riskLevel: CargoRiskLevel.high,
      hazardous: false,
      fragile: false,
      temperatureSensitive: false,
      specialHandlingRequired: true,
      riskNotes: 'High center of gravity. Route clearance required.',
      preferredVehicleType: 'Prime Mover',
      preferredTrailerType: 'Lowbed',
      loadingMethod: 'Crane Lift',
      unloadingMethod: 'Crane Lift',
      lashingRequired: true,
      escortRequired: true,
      specialEquipmentRequired: 'Heavy-duty shackles and chains',
      handlingInstructions: 'Use certified rigging and escort planning.',
      specialComplianceRequired: true,
      requiredCertifications: const ['Heavy Lift Handling'],
      requiredPermits: const ['Oversize Load Permit'],
      authorityApprovalNeeded: true,
      customerIndustryRestrictions: 'Oil and Gas sites need gate pre-approval.',
      complianceNotes: 'Escort and oversize route permit mandatory.',
      inspectionRequired: true,
      inspectionTemplateType: 'Heavy Load Securement',
      preDispatchInspectionRequired: true,
      inTransitCheckRequired: true,
      postDeliveryCheckRequired: true,
      photoEvidenceMandatory: true,
      videoEvidenceMandatory: false,
      inspectionNotes: 'Capture lashing points and axle load status.',
      restricted: false,
      restrictionReason: '',
      createdAt: now,
      updatedAt: now,
    ),
    CargoModel(
      cargoCode: 'CG-003',
      cargoName: 'Hazardous Chemical',
      category: 'Chemical',
      subcategory: 'Corrosive',
      status: CargoStatus.active,
      standardWeightRange: '1-25 Tons',
      length: null,
      width: null,
      height: null,
      volumeSizeClass: 'Medium',
      oversized: false,
      riskLevel: CargoRiskLevel.critical,
      hazardous: true,
      fragile: false,
      temperatureSensitive: true,
      specialHandlingRequired: true,
      riskNotes: 'Hazmat with spill and exposure risk.',
      preferredVehicleType: 'Hazmat Certified Truck',
      preferredTrailerType: 'Tanker',
      loadingMethod: 'Closed Transfer',
      unloadingMethod: 'Closed Transfer',
      lashingRequired: true,
      escortRequired: false,
      specialEquipmentRequired: 'PPE kit and spill response kit',
      handlingInstructions: 'Follow chemical MSDS and emergency protocol.',
      specialComplianceRequired: true,
      requiredCertifications: const ['Hazmat Certification'],
      requiredPermits: const ['Dangerous Goods Permit'],
      authorityApprovalNeeded: true,
      customerIndustryRestrictions: 'Restricted in residential corridors.',
      complianceNotes: 'Driver and fleet must be hazmat compliant.',
      inspectionRequired: true,
      inspectionTemplateType: 'Hazmat Compliance Checklist',
      preDispatchInspectionRequired: true,
      inTransitCheckRequired: true,
      postDeliveryCheckRequired: true,
      photoEvidenceMandatory: true,
      videoEvidenceMandatory: true,
      inspectionNotes: 'Evidence of placards and PPE is mandatory.',
      restricted: false,
      restrictionReason: '',
      createdAt: now,
      updatedAt: now,
    ),
    CargoModel(
      cargoCode: 'CG-004',
      cargoName: 'Fragile Instrument',
      category: 'Electronics',
      subcategory: 'Precision Equipment',
      status: CargoStatus.active,
      standardWeightRange: '0.1-2 Tons',
      length: null,
      width: null,
      height: null,
      volumeSizeClass: 'Small',
      oversized: false,
      riskLevel: CargoRiskLevel.medium,
      hazardous: false,
      fragile: true,
      temperatureSensitive: true,
      specialHandlingRequired: true,
      riskNotes: 'Shock-sensitive and vibration-sensitive.',
      preferredVehicleType: 'Box Truck',
      preferredTrailerType: 'Closed Body',
      loadingMethod: 'Manual + Cushioning',
      unloadingMethod: 'Manual + Cushioning',
      lashingRequired: true,
      escortRequired: false,
      specialEquipmentRequired: 'Shock absorbers and insulation blankets',
      handlingInstructions: 'Keep upright and avoid sudden braking.',
      specialComplianceRequired: false,
      requiredCertifications: const [],
      requiredPermits: const [],
      authorityApprovalNeeded: false,
      customerIndustryRestrictions: '',
      complianceNotes: '',
      inspectionRequired: true,
      inspectionTemplateType: 'Fragile Cargo Handling',
      preDispatchInspectionRequired: true,
      inTransitCheckRequired: true,
      postDeliveryCheckRequired: true,
      photoEvidenceMandatory: true,
      videoEvidenceMandatory: false,
      inspectionNotes: 'Take photos of packing and unloading condition.',
      restricted: false,
      restrictionReason: '',
      createdAt: now,
      updatedAt: now,
    ),
    CargoModel(
      cargoCode: 'CG-005',
      cargoName: 'Restricted Cylinder Batch',
      category: 'Gas',
      subcategory: 'Compressed Gas',
      status: CargoStatus.inactive,
      standardWeightRange: '5-12 Tons',
      length: null,
      width: null,
      height: null,
      volumeSizeClass: 'Medium',
      oversized: false,
      riskLevel: CargoRiskLevel.high,
      hazardous: true,
      fragile: false,
      temperatureSensitive: false,
      specialHandlingRequired: true,
      riskNotes: 'Regulatory hold on this batch profile.',
      preferredVehicleType: 'Cylinder Carrier',
      preferredTrailerType: 'Cylinder Rack',
      loadingMethod: 'Cylinder Clamp',
      unloadingMethod: 'Cylinder Clamp',
      lashingRequired: true,
      escortRequired: false,
      specialEquipmentRequired: 'Gas leak detector',
      handlingInstructions: 'Do not expose to direct heat source.',
      specialComplianceRequired: true,
      requiredCertifications: const ['Gas Handling Certification'],
      requiredPermits: const ['Compressed Gas Permit'],
      authorityApprovalNeeded: true,
      customerIndustryRestrictions: 'Not allowed for current contracts.',
      complianceNotes: 'Temporarily suspended by compliance.',
      inspectionRequired: true,
      inspectionTemplateType: 'Gas Cargo Safety',
      preDispatchInspectionRequired: true,
      inTransitCheckRequired: true,
      postDeliveryCheckRequired: true,
      photoEvidenceMandatory: true,
      videoEvidenceMandatory: false,
      inspectionNotes: 'Cylinders and valves must be photographed.',
      restricted: true,
      restrictionReason: 'Regulatory hold - pending renewal.',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
