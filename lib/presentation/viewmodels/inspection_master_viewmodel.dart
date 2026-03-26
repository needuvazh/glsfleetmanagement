import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inspection_master_mock_datasource.dart';
import '../../domain/entities/inspection_master.dart';
import '../../domain/entities/sub_vendor.dart';

final inspectionTypesProvider = Provider<List<InspectionTypeMaster>>((ref) {
  return InspectionMasterMockDataSource.types;
});

final inspectionChecklistsProvider = Provider<List<InspectionChecklistItemMaster>>((ref) {
  return InspectionMasterMockDataSource.checklists;
});

final subVendorsProvider = Provider.family<List<SubVendorModel>, String>((ref, vendorId) {
  return SubVendorMockDataSource.subVendors.where((s) => s.vendorId == vendorId).toList();
});
