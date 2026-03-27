import '../../domain/entities/inspection.dart';

class InspectionTemplateItem {
  const InspectionTemplateItem({
    required this.name,
    this.category = 'General',
    required this.mandatory,
    required this.severity,
    this.requiresPhoto = false,
    this.requiresVideo = false,
    this.applicableVehicleType = 'Any',
  });

  final String name;
  final String category;
  final bool mandatory;
  final InspectionFailureSeverity severity;
  final bool requiresPhoto;
  final bool requiresVideo;
  final String applicableVehicleType;

  bool get requiredMedia => requiresPhoto || requiresVideo;

  InspectionTemplateItem copyWith({
    String? name,
    String? category,
    bool? mandatory,
    InspectionFailureSeverity? severity,
    bool? requiresPhoto,
    bool? requiresVideo,
    String? applicableVehicleType,
  }) {
    return InspectionTemplateItem(
      name: name ?? this.name,
      category: category ?? this.category,
      mandatory: mandatory ?? this.mandatory,
      severity: severity ?? this.severity,
      requiresPhoto: requiresPhoto ?? this.requiresPhoto,
      requiresVideo: requiresVideo ?? this.requiresVideo,
      applicableVehicleType:
          applicableVehicleType ?? this.applicableVehicleType,
    );
  }
}

class InspectionTemplateRecord {
  const InspectionTemplateRecord({
    required this.id,
    required this.name,
    required this.inspectionType,
    this.description = '',
    this.frequency = 'On Demand',
    required this.applicableVehicleType,
    required this.isActive,
    required this.items,
    required this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final InspectionType inspectionType;
  final String description;
  final String frequency;
  final String applicableVehicleType;
  final bool isActive;
  final List<InspectionTemplateItem> items;
  final String updatedBy;
  final DateTime updatedAt;

  InspectionTemplateRecord copyWith({
    String? id,
    String? name,
    InspectionType? inspectionType,
    String? description,
    String? frequency,
    String? applicableVehicleType,
    bool? isActive,
    List<InspectionTemplateItem>? items,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return InspectionTemplateRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      inspectionType: inspectionType ?? this.inspectionType,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      applicableVehicleType:
          applicableVehicleType ?? this.applicableVehicleType,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InspectionTemplateStore {
  static final List<InspectionTemplateRecord> _items = _mockTemplates();

  static List<InspectionTemplateRecord> all() => List.unmodifiable(_items);

  static InspectionTemplateRecord? byId(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  static void upsert(InspectionTemplateRecord record) {
    final index = _items.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      _items[index] = record;
    } else {
      _items.insert(0, record);
    }
  }

  static void toggleActive(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    final item = _items[index];
    _items[index] = item.copyWith(
      isActive: !item.isActive,
      updatedAt: DateTime.now(),
      updatedBy: 'Admin',
    );
  }

  static String nextId() {
    return 'TPL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  static List<InspectionTemplateRecord> activeByType(InspectionType type) {
    return _items
        .where((item) => item.inspectionType == type && item.isActive)
        .toList(growable: false);
  }

  static InspectionTemplateRecord? resolveActiveTemplate({
    required InspectionType type,
    String vehicleType = 'Truck',
  }) {
    final normalizedVehicle = vehicleType.trim().toLowerCase();
    final candidates = activeByType(type);
    if (candidates.isEmpty) {
      return null;
    }
    final exact = candidates.where(
      (item) => item.applicableVehicleType.toLowerCase() == normalizedVehicle,
    );
    if (exact.isNotEmpty) {
      final sorted = exact.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sorted.first;
    }

    final sorted = candidates.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.first;
  }

  static List<InspectionTemplateRecord> _mockTemplates() {
    final now = DateTime.now();
    return [
      InspectionTemplateRecord(
        id: 'TPL-1001',
        name: 'Truck Pre-Trip Standard',
        inspectionType: InspectionType.preTrip,
        description:
            'Operational readiness checks before dispatch under journey management.',
        frequency: 'Before Every Dispatch',
        applicableVehicleType: 'Truck',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Tyres',
            category: 'Vehicle Readiness',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Brake System',
            category: 'Vehicle Readiness',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Route plan verification',
            category: 'Journey Management',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Communication plan',
            category: 'Journey Management',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Rest points validation',
            category: 'Journey Management',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Supervisor approval',
            category: 'Approvals',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
        ],
        updatedBy: 'Compliance Officer',
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1002',
        name: 'Trailer Safety Inspection',
        inspectionType: InspectionType.trailer,
        description: 'Trailer coupling and road-worthiness checks.',
        frequency: 'Daily',
        applicableVehicleType: 'Trailer',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Hitch Lock',
            category: 'Coupling',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Reflective Markings',
            category: 'Visibility',
            mandatory: false,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Landing gear',
            category: 'Structure',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Brake chambers',
            category: 'Braking',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
        ],
        updatedBy: 'Admin',
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1003',
        name: 'Pre-Departure Red Critical - Prime Mover',
        inspectionType: InspectionType.preDeparture,
        description:
            'Critical mechanical and safety checks that must pass before dispatch.',
        frequency: 'Before Every Dispatch',
        applicableVehicleType: 'Prime Mover',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Front driver side tyre',
            category: 'Tyres & Wheels',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Front passenger side tyre',
            category: 'Tyres & Wheels',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Drive axle rear tyres',
            category: 'Tyres & Wheels',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Brake actuators (PM & Trailer)',
            category: 'Braking System',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
            requiresVideo: true,
          ),
          InspectionTemplateItem(
            name: 'Foot brake',
            category: 'Braking System',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresVideo: true,
          ),
          InspectionTemplateItem(
            name: 'Handbrake',
            category: 'Braking System',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: '5th wheel and kingpin coupling',
            category: 'Coupling System',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Headlights and rear running lights',
            category: 'Lights & Signals',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Reverse light and alarm',
            category: 'Lights & Signals',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresVideo: true,
          ),
          InspectionTemplateItem(
            name: 'Seatbelt',
            category: 'Driver Safety & Cabin',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionTemplateItem(
            name: 'Fire extinguisher (PM & Trailer)',
            category: 'Safety Equipment',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Driver PPE',
            category: 'Safety Equipment',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
        ],
        updatedBy: 'Compliance Officer',
        updatedAt: now.subtract(const Duration(hours: 3, minutes: 30)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1004',
        name: 'Pre-Departure Amber Secondary - Prime Mover',
        inspectionType: InspectionType.preDeparture,
        description:
            'Secondary advisory checks for body, indicators, comfort, and telematics.',
        frequency: 'Before Every Dispatch',
        applicableVehicleType: 'Prime Mover',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Electrical and air connections',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Load bed condition',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'General body',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Indicators and beacon',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
            requiresVideo: true,
          ),
          InspectionTemplateItem(
            name: 'Fuel tank and leaks',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Dashboard warnings',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'First aid kit',
            category: 'Amber Secondary',
            mandatory: false,
            severity: InspectionFailureSeverity.low,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'TPMS and DFMS',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'ABS/EBS and ESC/RPS',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Horn / reverse alarm',
            category: 'Amber Secondary',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresVideo: true,
          ),
        ],
        updatedBy: 'Fleet Supervisor',
        updatedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1005',
        name: 'Load Security Critical - Heavy Trailer',
        inspectionType: InspectionType.loadSecurity,
        description:
            'Critical load securing controls for heavy trailers and hazardous loads.',
        frequency: 'Per Load Event',
        applicableVehicleType: 'Heavy Trailer',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Truck / Trailer type verification',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionTemplateItem(
            name: 'Hazard material segregation and restraint',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Trailer deck condition',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Loading gaps and redistribution check',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Lashing tools markings and condition',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Lashing and restrain angles',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiresVideo: true,
          ),
          InspectionTemplateItem(
            name: 'Load check at rest points',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Loading plan and lashing plan',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Headboard / cage availability',
            category: 'Critical Load Checks',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
        ],
        updatedBy: 'HSE Engineer',
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1006',
        name: 'Daily Driver Inspection - In Transit',
        inspectionType: InspectionType.trip,
        description:
            'Daily in-trip driver and behavior controls during execution.',
        frequency: 'Daily',
        applicableVehicleType: 'All',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Safety rule compliance',
            category: 'Behavior & Compliance',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Route adherence',
            category: 'Behavior & Compliance',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Load security check',
            category: 'Load Monitoring',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'IVMS / DFMS monitoring',
            category: 'Telematics',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Speed compliance',
            category: 'Telematics',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Rest compliance',
            category: 'Fatigue Management',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
        ],
        updatedBy: 'Operations Controller',
        updatedAt: now.subtract(const Duration(hours: 4, minutes: 10)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1007',
        name: 'Post-Trip Defect Reporting',
        inspectionType: InspectionType.safety,
        description:
            'Post-delivery defect and handover checks before closing trip.',
        frequency: 'After Every Trip',
        applicableVehicleType: 'All',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Vehicle defect reporting',
            category: 'Defects',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Damage inspection',
            category: 'Defects',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiresPhoto: true,
          ),
          InspectionTemplateItem(
            name: 'Fuel and trip logs review',
            category: 'Documentation',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'Inspection report submission',
            category: 'Documentation',
            mandatory: true,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'POD / DN verification',
            category: 'Documentation',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
        ],
        updatedBy: 'Dispatch Coordinator',
        updatedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1008',
        name: 'Compliance Certification Verification',
        inspectionType: InspectionType.safety,
        description:
            'Regulatory and certification validity checks for dispatch readiness.',
        frequency: 'Weekly',
        applicableVehicleType: 'All',
        isActive: false,
        items: const [
          InspectionTemplateItem(
            name: 'Vehicle license (ROP / Mulkiya)',
            category: 'Compliance / Certification',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionTemplateItem(
            name: 'RAS inspection validity',
            category: 'Compliance / Certification',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionTemplateItem(
            name: 'Driver license and H2S permit',
            category: 'Compliance / Certification',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
          ),
          InspectionTemplateItem(
            name: 'PDO passport',
            category: 'Compliance / Certification',
            mandatory: false,
            severity: InspectionFailureSeverity.medium,
          ),
          InspectionTemplateItem(
            name: 'IVMS / DFMS availability',
            category: 'Compliance / Certification',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
          InspectionTemplateItem(
            name: 'Third-party certifications (5th wheel / kingpin)',
            category: 'Compliance / Certification',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
          ),
        ],
        updatedBy: 'Compliance Lead',
        updatedAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
    ];
  }
}
