import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/vehicle_type_master_model.dart';

abstract class VehicleTypeMasterMockDataSource {
  Future<List<VehicleTypeMasterModel>> getVehicleTypes();
  Future<VehicleTypeMasterModel?> getVehicleTypeById(String vehicleTypeId);
  Future<List<VehicleTypeMasterModel>> addVehicleType(
    VehicleTypeMasterModel item,
  );
  Future<List<VehicleTypeMasterModel>> updateVehicleType(
    VehicleTypeMasterModel item,
  );
}

class VehicleTypeMasterMockDataSourceImpl
    implements VehicleTypeMasterMockDataSource {
  VehicleTypeMasterMockDataSourceImpl();

  static const _cacheKey = 'vehicle_type_master_records_v3';
  List<VehicleTypeMasterModel>? _items;
  int _sequence = 5;

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
        _items = _seedItems();
      }
    } else {
      _items = _seedItems();
    }

    _sequence = _nextSequence(_items!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(_items!.map(_toMap).toList()),
    );
  }

  @override
  Future<List<VehicleTypeMasterModel>> getVehicleTypes() async {
    await _ensureInitialized();
    return _items!.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<VehicleTypeMasterModel?> getVehicleTypeById(String vehicleTypeId) async {
    await _ensureInitialized();
    for (final item in _items!) {
      if (item.vehicleTypeId == vehicleTypeId) {
        return item.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<VehicleTypeMasterModel>> addVehicleType(
    VehicleTypeMasterModel item,
  ) async {
    await _ensureInitialized();
    final next = item.copyWith(
      vehicleTypeId: item.vehicleTypeId.trim().isEmpty
          ? _nextVehicleTypeId()
          : item.vehicleTypeId,
    );
    _items!.add(next);
    await _persist();
    return getVehicleTypes();
  }

  @override
  Future<List<VehicleTypeMasterModel>> updateVehicleType(
    VehicleTypeMasterModel item,
  ) async {
    await _ensureInitialized();
    final index = _items!.indexWhere(
      (entry) => entry.vehicleTypeId == item.vehicleTypeId,
    );
    if (index == -1) {
      return getVehicleTypes();
    }
    _items![index] = item;
    await _persist();
    return getVehicleTypes();
  }

  String _nextVehicleTypeId() {
    final id = 'VT-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }

  int _nextSequence(List<VehicleTypeMasterModel> items) {
    var maxValue = 0;
    for (final item in items) {
      final parsed = int.tryParse(item.vehicleTypeId.split('-').last) ?? 0;
      if (parsed > maxValue) {
        maxValue = parsed;
      }
    }
    return maxValue + 1;
  }

  VehicleTypeMasterModel _fromMap(Map<String, dynamic> map) {
    return VehicleTypeMasterModel(
      vehicleTypeId: map['vehicleTypeId'] as String? ?? '',
      vehicleTypeName: map['vehicleTypeName'] as String? ?? '',
      vehicleCategory: _enumByName(
        VehicleCategoryType.values,
        map['vehicleCategory'] as String?,
        VehicleCategoryType.goods,
      ),
      description: map['description'] as String? ?? '',
      seatingCapacity: (map['seatingCapacity'] as num?)?.toInt() ?? 0,
      loadCapacity: (map['loadCapacity'] as num?)?.toDouble() ?? 0,
      axleType: _enumByName(
        AxleType.values,
        map['axleType'] as String?,
        AxleType.axle4x2,
      ),
      bodyType: _enumByName(
        BodyType.values,
        map['bodyType'] as String?,
        BodyType.flatbed,
      ),
      fuelType: _enumByName(
        FuelType.values,
        map['fuelType'] as String?,
        FuelType.diesel,
      ),
      transmissionType: _enumByName(
        TransmissionType.values,
        map['transmissionType'] as String?,
        TransmissionType.manual,
      ),
      acType: _enumByName(
        AcType.values,
        map['acType'] as String?,
        AcType.nonAc,
      ),
      baseFarePerKm: (map['baseFarePerKm'] as num?)?.toDouble() ?? 0,
      baseFarePerHour: (map['baseFarePerHour'] as num?)?.toDouble() ?? 0,
      mileage: (map['mileage'] as num?)?.toDouble() ?? 0,
      maxTripDistance: (map['maxTripDistance'] as num?)?.toDouble(),
      maxDrivingHoursPerDay:
          (map['maxDrivingHoursPerDay'] as num?)?.toDouble(),
      documents: _readDocuments(map['documents'] as List<dynamic>?),
      status: _enumByName(
        RecordStatusType.values,
        map['status'] as String?,
        RecordStatusType.active,
      ),
    );
  }

  Map<String, dynamic> _toMap(VehicleTypeMasterModel item) {
    return {
      'vehicleTypeId': item.vehicleTypeId,
      'vehicleTypeName': item.vehicleTypeName,
      'vehicleCategory': item.vehicleCategory.name,
      'description': item.description,
      'seatingCapacity': item.seatingCapacity,
      'loadCapacity': item.loadCapacity,
      'axleType': item.axleType.name,
      'bodyType': item.bodyType.name,
      'fuelType': item.fuelType.name,
      'transmissionType': item.transmissionType.name,
      'acType': item.acType.name,
      'baseFarePerKm': item.baseFarePerKm,
      'baseFarePerHour': item.baseFarePerHour,
      'mileage': item.mileage,
      'maxTripDistance': item.maxTripDistance,
      'maxDrivingHoursPerDay': item.maxDrivingHoursPerDay,
      'documents': [
        for (final doc in item.documents)
          {
            'documentId': doc.documentId,
            'documentType': doc.documentType.name,
            'documentName': doc.documentName,
            'filePath': doc.filePath,
            'uploadedAt': doc.uploadedAt.toIso8601String(),
            'uploadedBy': doc.uploadedBy,
            'isMandatory': doc.isMandatory,
          },
      ],
      'status': item.status.name,
    };
  }

  List<VehicleTypeTemplateDocument> _readDocuments(List<dynamic>? raw) {
    if (raw == null) {
      return const [];
    }
    return raw
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .map(
          (map) => VehicleTypeTemplateDocument(
            documentId: map['documentId'] as String? ?? '',
            documentType: _enumByName(
              VehicleTypeDocumentType.values,
              map['documentType'] as String?,
              VehicleTypeDocumentType.other,
            ),
            documentName: map['documentName'] as String? ?? '',
            filePath: map['filePath'] as String? ?? '',
            uploadedAt:
                DateTime.tryParse(map['uploadedAt'] as String? ?? '') ??
                    DateTime.now(),
            uploadedBy: map['uploadedBy'] as String? ?? '',
            isMandatory: map['isMandatory'] as bool? ?? false,
          ),
        )
        .toList();
  }

  T _enumByName<T>(
    List<T> values,
    String? raw,
    T fallback,
  ) {
    for (final value in values) {
      if (value is Enum && value.name == raw) {
        return value;
      }
    }
    return fallback;
  }
}

List<VehicleTypeMasterModel> _seedItems() {
  return [
    VehicleTypeMasterModel(
      vehicleTypeId: 'VT-001',
      vehicleTypeName: 'Prime Mover',
      vehicleCategory: VehicleCategoryType.goods,
      description: 'Heavy tractor head for trailer haulage and refinery runs.',
      seatingCapacity: 2,
      loadCapacity: 40,
      axleType: AxleType.axle6x4,
      bodyType: BodyType.flatbed,
      fuelType: FuelType.diesel,
      transmissionType: TransmissionType.manual,
      acType: AcType.ac,
      baseFarePerKm: 0.95,
      baseFarePerHour: 18,
      mileage: 3.2,
      maxTripDistance: 850,
      maxDrivingHoursPerDay: 9,
      documents: [
        VehicleTypeTemplateDocument(
          documentId: 'DOC-VT-001',
          documentType: VehicleTypeDocumentType.rcTemplate,
          documentName: 'Prime Mover RC Template',
          filePath: '/mock/vehicle-types/prime-mover-rc-template.pdf',
          uploadedAt: DateTime(2026, 1, 10),
          uploadedBy: 'fleet.admin',
          isMandatory: true,
        ),
      ],
      status: RecordStatusType.active,
    ),
    VehicleTypeMasterModel(
      vehicleTypeId: 'VT-002',
      vehicleTypeName: '10 Ton Truck',
      vehicleCategory: VehicleCategoryType.goods,
      description: 'General cargo truck for regional deliveries and retail loads.',
      seatingCapacity: 3,
      loadCapacity: 10,
      axleType: AxleType.axle4x2,
      bodyType: BodyType.box,
      fuelType: FuelType.diesel,
      transmissionType: TransmissionType.manual,
      acType: AcType.ac,
      baseFarePerKm: 0.58,
      baseFarePerHour: 11,
      mileage: 5.6,
      maxTripDistance: 450,
      maxDrivingHoursPerDay: 8,
      documents: [
        VehicleTypeTemplateDocument(
          documentId: 'DOC-VT-002',
          documentType: VehicleTypeDocumentType.permitFormat,
          documentName: '10 Ton Permit Format',
          filePath: '/mock/vehicle-types/10-ton-permit-format.pdf',
          uploadedAt: DateTime(2026, 2, 5),
          uploadedBy: 'ops.supervisor',
          isMandatory: false,
        ),
      ],
      status: RecordStatusType.active,
    ),
    VehicleTypeMasterModel(
      vehicleTypeId: 'VT-003',
      vehicleTypeName: 'Bus 50 Seater',
      vehicleCategory: VehicleCategoryType.passenger,
      description: 'Crew transport bus for camp shifts and staff rotation.',
      seatingCapacity: 50,
      loadCapacity: 0,
      axleType: AxleType.axle4x2,
      bodyType: BodyType.busCoach,
      fuelType: FuelType.diesel,
      transmissionType: TransmissionType.automatic,
      acType: AcType.ac,
      baseFarePerKm: 0.72,
      baseFarePerHour: 15,
      mileage: 4.9,
      maxTripDistance: 320,
      maxDrivingHoursPerDay: 10,
      documents: [
        VehicleTypeTemplateDocument(
          documentId: 'DOC-VT-003',
          documentType: VehicleTypeDocumentType.insuranceTemplate,
          documentName: 'Bus Insurance Template',
          filePath: '/mock/vehicle-types/bus-insurance-template.jpg',
          uploadedAt: DateTime(2026, 1, 22),
          uploadedBy: 'compliance.lead',
          isMandatory: true,
        ),
      ],
      status: RecordStatusType.active,
    ),
    VehicleTypeMasterModel(
      vehicleTypeId: 'VT-004',
      vehicleTypeName: 'Water Tanker',
      vehicleCategory: VehicleCategoryType.goods,
      description: 'Bulk water tanker for remote site supply movements.',
      seatingCapacity: 2,
      loadCapacity: 18,
      axleType: AxleType.axle6x4,
      bodyType: BodyType.tanker,
      fuelType: FuelType.diesel,
      transmissionType: TransmissionType.manual,
      acType: AcType.nonAc,
      baseFarePerKm: 0.88,
      baseFarePerHour: 17,
      mileage: 3.8,
      maxTripDistance: 500,
      maxDrivingHoursPerDay: 9,
      documents: [],
      status: RecordStatusType.inactive,
    ),
  ];
}
