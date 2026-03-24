import '../../domain/entities/dashboard.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.kpis,
    required super.weeklyMileageKm,
    required super.vehicleStatusShare,
  });

  factory DashboardDataModel.fromMap(Map<String, dynamic> map) {
    final kpiMap = map['kpis'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final weeklyMileage =
        (map['weeklyMileageKm'] as List<dynamic>? ?? <dynamic>[])
            .map((entry) => MileagePoint(
                  label: entry['day'] as String? ?? '',
                  value: (entry['value'] as num?)?.toDouble() ?? 0,
                ))
            .toList();

    final statusShare =
        (map['vehicleStatusShare'] as List<dynamic>? ?? <dynamic>[])
            .map((entry) => StatusShare(
                  status: entry['status'] as String? ?? '',
                  value: (entry['value'] as num?)?.toInt() ?? 0,
                ))
            .toList();

    return DashboardDataModel(
      kpis: DashboardKpis(
        totalVehicles: (kpiMap['totalVehicles'] as num?)?.toInt() ?? 0,
        activeVehicles: (kpiMap['activeVehicles'] as num?)?.toInt() ?? 0,
        inMaintenance: (kpiMap['inMaintenance'] as num?)?.toInt() ?? 0,
        criticalAlerts: (kpiMap['criticalAlerts'] as num?)?.toInt() ?? 0,
        avgFuelConsumptionLPer100Km:
            (kpiMap['avgFuelConsumptionLPer100km'] as num?)?.toDouble() ?? 0,
      ),
      weeklyMileageKm: weeklyMileage,
      vehicleStatusShare: statusShare,
    );
  }
}
