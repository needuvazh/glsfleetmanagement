import '../domain/vendor_model.dart';
import 'vendor_mock_datasource.dart';

abstract class VendorRepository {
  Future<List<VendorModel>> getVendors();
  Future<List<VendorModel>> getActiveVendors();
  Future<List<VendorModel>> getActiveVendorsByServiceType(
    VendorServiceType serviceType,
  );
  Future<VendorModel?> getVendorById(String vendorId);
  Future<List<VendorModel>> addVendor(VendorModel vendor);
  Future<List<VendorModel>> updateVendor(VendorModel vendor);
}

class VendorRepositoryImpl implements VendorRepository {
  VendorRepositoryImpl({required VendorMockDataSource dataSource})
      : _dataSource = dataSource;

  final VendorMockDataSource _dataSource;

  @override
  Future<List<VendorModel>> getVendors() => _dataSource.getVendors();

  @override
  Future<List<VendorModel>> getActiveVendors() async {
    final list = await _dataSource.getVendors();
    return list.where((vendor) => vendor.isActive).toList();
  }

  @override
  Future<List<VendorModel>> getActiveVendorsByServiceType(
    VendorServiceType serviceType,
  ) async {
    final list = await getActiveVendors();
    return list.where((vendor) => vendor.serviceType == serviceType).toList();
  }

  @override
  Future<VendorModel?> getVendorById(String vendorId) =>
      _dataSource.getVendorById(vendorId);

  @override
  Future<List<VendorModel>> addVendor(VendorModel vendor) =>
      _dataSource.addVendor(vendor);

  @override
  Future<List<VendorModel>> updateVendor(VendorModel vendor) =>
      _dataSource.updateVendor(vendor);
}
