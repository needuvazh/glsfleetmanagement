import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/vendor_model.dart';

abstract class VendorMockDataSource {
  Future<List<VendorModel>> getVendors();
  Future<VendorModel?> getVendorById(String vendorId);
  Future<List<VendorModel>> addVendor(VendorModel vendor);
  Future<List<VendorModel>> updateVendor(VendorModel vendor);
}

class VendorMockDataSourceImpl implements VendorMockDataSource {
  VendorMockDataSourceImpl();

  static const _cacheKey = 'vendor_master_records_v1';
  List<VendorModel>? _vendors;
  int _sequence = 6;

  Future<void> _ensureInitialized() async {
    if (_vendors != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final cached = decoded
            .map((entry) => _vendorFromMap(Map<String, dynamic>.from(entry)))
            .toList();
        _vendors = cached;
      } catch (_) {
        _vendors = _seedVendors();
      }
    } else {
      _vendors = _seedVendors();
    }

    _sequence = _nextSequence(_vendors!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _vendors!.map(_vendorToMap).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  @override
  Future<List<VendorModel>> getVendors() async {
    await _ensureInitialized();
    return _vendors!.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<VendorModel?> getVendorById(String vendorId) async {
    await _ensureInitialized();
    for (final vendor in _vendors!) {
      if (vendor.vendorId == vendorId) {
        return vendor.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<VendorModel>> addVendor(VendorModel vendor) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final next = vendor.copyWith(
      vendorId:
          vendor.vendorId.trim().isEmpty ? _nextVendorId() : vendor.vendorId,
      createdAt: now,
      updatedAt: now,
    );
    _vendors!.add(next);
    await _persist();
    return getVendors();
  }

  @override
  Future<List<VendorModel>> updateVendor(VendorModel vendor) async {
    await _ensureInitialized();
    final index =
        _vendors!.indexWhere((entry) => entry.vendorId == vendor.vendorId);
    if (index == -1) {
      return getVendors();
    }
    final existing = _vendors![index];
    _vendors![index] = vendor.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return getVendors();
  }

  String _nextVendorId() {
    final id = 'VND-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }

  int _nextSequence(List<VendorModel> vendors) {
    var maxValue = 0;
    for (final vendor in vendors) {
      final parts = vendor.vendorId.split('-');
      if (parts.length < 2) {
        continue;
      }
      final parsed = int.tryParse(parts.last) ?? 0;
      if (parsed > maxValue) {
        maxValue = parsed;
      }
    }
    return maxValue + 1;
  }

  VendorModel _vendorFromMap(Map<String, dynamic> map) {
    return VendorModel(
      vendorId: map['vendorId'] as String? ?? '',
      vendorName: map['vendorName'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      vendorType: _vendorTypeFromName(map['vendorType'] as String?),
      serviceType: _serviceTypeFromName(map['serviceType'] as String?),
      status: _vendorStatusFromName(map['status'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> _vendorToMap(VendorModel vendor) {
    return {
      'vendorId': vendor.vendorId,
      'vendorName': vendor.vendorName,
      'companyName': vendor.companyName,
      'contactNumber': vendor.contactNumber,
      'email': vendor.email,
      'address': vendor.address,
      'vendorType': vendor.vendorType.name,
      'serviceType': vendor.serviceType.name,
      'status': vendor.status.name,
      'createdAt': vendor.createdAt.toIso8601String(),
      'updatedAt': vendor.updatedAt.toIso8601String(),
    };
  }

  VendorType _vendorTypeFromName(String? value) {
    for (final item in VendorType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return VendorType.thirdParty;
  }

  VendorServiceType _serviceTypeFromName(String? value) {
    for (final item in VendorServiceType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return VendorServiceType.nonPdo;
  }

  VendorStatus _vendorStatusFromName(String? value) {
    for (final item in VendorStatus.values) {
      if (item.name == value) {
        return item;
      }
    }
    return VendorStatus.active;
  }
}

List<VendorModel> _seedVendors() {
  final now = DateTime.now();
  return [
    VendorModel(
      vendorId: 'VND-001',
      vendorName: 'ABC Transport',
      companyName: 'ABC Transport LLC',
      contactNumber: '+96891000001',
      email: 'ops@abctransport.com',
      address: 'Muscat Industrial Area, Oman',
      vendorType: VendorType.thirdParty,
      serviceType: VendorServiceType.pdo,
      status: VendorStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    VendorModel(
      vendorId: 'VND-002',
      vendorName: 'Desert Fleet',
      companyName: 'Desert Fleet Services',
      contactNumber: '+96891000002',
      email: 'dispatch@desertfleet.com',
      address: 'Sohar Port Road, Oman',
      vendorType: VendorType.thirdParty,
      serviceType: VendorServiceType.nonPdo,
      status: VendorStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    VendorModel(
      vendorId: 'VND-003',
      vendorName: 'Oman Logistics',
      companyName: 'Oman Logistics Co.',
      contactNumber: '+96891000003',
      email: 'support@omanlogistics.com',
      address: 'Salalah Free Zone, Oman',
      vendorType: VendorType.thirdParty,
      serviceType: VendorServiceType.pdo,
      status: VendorStatus.inactive,
      createdAt: now,
      updatedAt: now,
    ),
    VendorModel(
      vendorId: 'VND-004',
      vendorName: 'GLS Own Fleet',
      companyName: 'Greenfield Logistics Services LLC',
      contactNumber: '+96891000004',
      email: 'fleet@greenfield.com',
      address: 'Muscat HQ, Oman',
      vendorType: VendorType.own,
      serviceType: VendorServiceType.pdo,
      status: VendorStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    VendorModel(
      vendorId: 'VND-005',
      vendorName: 'Highway Movers',
      companyName: 'Highway Movers SPC',
      contactNumber: '+96891000005',
      email: 'info@highwaymovers.com',
      address: 'Nizwa Logistics Yard, Oman',
      vendorType: VendorType.thirdParty,
      serviceType: VendorServiceType.nonPdo,
      status: VendorStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
