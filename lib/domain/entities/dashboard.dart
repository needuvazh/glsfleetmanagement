class DashboardData {
  const DashboardData({
    required this.kpis,
    required this.weeklyMileageKm,
    required this.vehicleStatusShare,
  });

  final DashboardKpis kpis;
  final List<MileagePoint> weeklyMileageKm;
  final List<StatusShare> vehicleStatusShare;

  DashboardData copyWith({
    DashboardKpis? kpis,
    List<MileagePoint>? weeklyMileageKm,
    List<StatusShare>? vehicleStatusShare,
  }) {
    return DashboardData(
      kpis: kpis ?? this.kpis,
      weeklyMileageKm: weeklyMileageKm ?? this.weeklyMileageKm,
      vehicleStatusShare: vehicleStatusShare ?? this.vehicleStatusShare,
    );
  }
}

class DashboardKpis {
  const DashboardKpis({
    required this.totalVehicles,
    required this.activeVehicles,
    required this.inMaintenance,
    required this.criticalAlerts,
    required this.avgFuelConsumptionLPer100Km,
  });

  final int totalVehicles;
  final int activeVehicles;
  final int inMaintenance;
  final int criticalAlerts;
  final double avgFuelConsumptionLPer100Km;

  DashboardKpis copyWith({
    int? totalVehicles,
    int? activeVehicles,
    int? inMaintenance,
    int? criticalAlerts,
    double? avgFuelConsumptionLPer100Km,
  }) {
    return DashboardKpis(
      totalVehicles: totalVehicles ?? this.totalVehicles,
      activeVehicles: activeVehicles ?? this.activeVehicles,
      inMaintenance: inMaintenance ?? this.inMaintenance,
      criticalAlerts: criticalAlerts ?? this.criticalAlerts,
      avgFuelConsumptionLPer100Km:
          avgFuelConsumptionLPer100Km ?? this.avgFuelConsumptionLPer100Km,
    );
  }
}

class MileagePoint {
  const MileagePoint({required this.label, required this.value});

  final String label;
  final double value;

  MileagePoint copyWith({String? label, double? value}) {
    return MileagePoint(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}

class StatusShare {
  const StatusShare({required this.status, required this.value});

  final String status;
  final int value;

  StatusShare copyWith({String? status, int? value}) {
    return StatusShare(
      status: status ?? this.status,
      value: value ?? this.value,
    );
  }
}
