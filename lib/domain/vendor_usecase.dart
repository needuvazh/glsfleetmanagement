import '../data/vendor_repository.dart';
import 'vendor_model.dart';

class VendorUseCase {
  VendorUseCase(this._repository);

  final VendorRepository _repository;

  Future<List<VendorModel>> getVendors() => _repository.getVendors();

  Future<List<VendorModel>> getActiveVendors() => _repository.getActiveVendors();

  Future<List<VendorModel>> getActiveVendorsByServiceType(
    VendorServiceType serviceType,
  ) {
    return _repository.getActiveVendorsByServiceType(serviceType);
  }

  Future<List<VendorModel>> addVendor(VendorModel vendor) =>
      _repository.addVendor(vendor);

  Future<List<VendorModel>> updateVendor(VendorModel vendor) =>
      _repository.updateVendor(vendor);

  Future<VendorModel?> getVendorById(String vendorId) =>
      _repository.getVendorById(vendorId);
}
