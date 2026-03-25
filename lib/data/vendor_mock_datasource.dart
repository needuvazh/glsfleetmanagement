import '../domain/vendor_model.dart';

abstract class VendorMockDataSource {
  Future<List<VendorModel>> getVendors();
  Future<VendorModel?> getVendorById(String vendorId);
  Future<List<VendorModel>> addVendor(VendorModel vendor);
  Future<List<VendorModel>> updateVendor(VendorModel vendor);
}

class VendorMockDataSourceImpl implements VendorMockDataSource {
  VendorMockDataSourceImpl() : _vendors = _seedVendors();

  final List<VendorModel> _vendors;
  int _sequence = 6;

  @override
  Future<List<VendorModel>> getVendors() async {
    return _vendors.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<VendorModel?> getVendorById(String vendorId) async {
    for (final vendor in _vendors) {
      if (vendor.vendorId == vendorId) {
        return vendor.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<VendorModel>> addVendor(VendorModel vendor) async {
    final now = DateTime.now();
    final next = vendor.copyWith(
      vendorId: vendor.vendorId.trim().isEmpty ? _nextVendorId() : vendor.vendorId,
      createdAt: now,
      updatedAt: now,
    );
    _vendors.add(next);
    return getVendors();
  }

  @override
  Future<List<VendorModel>> updateVendor(VendorModel vendor) async {
    final index = _vendors.indexWhere((entry) => entry.vendorId == vendor.vendorId);
    if (index == -1) {
      return getVendors();
    }
    final existing = _vendors[index];
    _vendors[index] = vendor.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return getVendors();
  }

  String _nextVendorId() {
    final id = 'VND-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
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
