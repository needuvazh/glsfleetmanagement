import '../../domain/entities/inspection.dart';

class InspectionTemplateItem {
  const InspectionTemplateItem({
    required this.name,
    required this.mandatory,
    required this.severity,
    required this.requiredMedia,
  });

  final String name;
  final bool mandatory;
  final InspectionFailureSeverity severity;
  final bool requiredMedia;

  InspectionTemplateItem copyWith({
    String? name,
    bool? mandatory,
    InspectionFailureSeverity? severity,
    bool? requiredMedia,
  }) {
    return InspectionTemplateItem(
      name: name ?? this.name,
      mandatory: mandatory ?? this.mandatory,
      severity: severity ?? this.severity,
      requiredMedia: requiredMedia ?? this.requiredMedia,
    );
  }
}

class InspectionTemplateRecord {
  const InspectionTemplateRecord({
    required this.id,
    required this.name,
    required this.inspectionType,
    required this.applicableVehicleType,
    required this.isActive,
    required this.items,
    required this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final InspectionType inspectionType;
  final String applicableVehicleType;
  final bool isActive;
  final List<InspectionTemplateItem> items;
  final String updatedBy;
  final DateTime updatedAt;

  InspectionTemplateRecord copyWith({
    String? id,
    String? name,
    InspectionType? inspectionType,
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
      applicableVehicleType: applicableVehicleType ?? this.applicableVehicleType,
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

  static List<InspectionTemplateRecord> _mockTemplates() {
    final now = DateTime.now();
    return [
      InspectionTemplateRecord(
        id: 'TPL-1001',
        name: 'Truck Pre-Trip Standard',
        inspectionType: InspectionType.preTrip,
        applicableVehicleType: 'Truck',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Tyres',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiredMedia: true,
          ),
          InspectionTemplateItem(
            name: 'Brake System',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiredMedia: true,
          ),
        ],
        updatedBy: 'Compliance Officer',
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      InspectionTemplateRecord(
        id: 'TPL-1002',
        name: 'Trailer Safety Inspection',
        inspectionType: InspectionType.trailer,
        applicableVehicleType: 'Trailer',
        isActive: true,
        items: const [
          InspectionTemplateItem(
            name: 'Hitch Lock',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiredMedia: true,
          ),
          InspectionTemplateItem(
            name: 'Reflective Markings',
            mandatory: false,
            severity: InspectionFailureSeverity.medium,
            requiredMedia: false,
          ),
        ],
        updatedBy: 'Admin',
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }
}
