class SubVendorModel {
  const SubVendorModel({
    required this.id,
    required this.vendorId,
    required this.name,
  });

  final String id;
  final String vendorId;
  final String name;
}

class SubVendorMockDataSource {
  static const List<SubVendorModel> subVendors = [
    SubVendorModel(id: 'SV1', vendorId: 'VND-001', name: 'Al Maha Subvendors'),
    SubVendorModel(id: 'SV2', vendorId: 'VND-001', name: 'Oman Logistics Part'),
    SubVendorModel(id: 'SV3', vendorId: 'VND-002', name: 'Desert Sub Services'),
    SubVendorModel(id: 'SV4', vendorId: 'VND-002', name: 'Dune Buggy Co'),
    SubVendorModel(id: 'SV5', vendorId: 'VND-004', name: 'GLS Branch A'),
  ];
}
