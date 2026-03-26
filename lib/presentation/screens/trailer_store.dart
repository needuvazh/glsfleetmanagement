class TrailerRecord {
  const TrailerRecord({
    required this.code,
    required this.type,
    required this.capacity,
    required this.status,
    required this.availability,
    required this.description,
  });

  final String code;
  final String type;
  final String capacity;
  final String status;
  final String availability;
  final String description;

  TrailerRecord copyWith({
    String? code,
    String? type,
    String? capacity,
    String? status,
    String? availability,
    String? description,
  }) {
    return TrailerRecord(
      code: code ?? this.code,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      availability: availability ?? this.availability,
      description: description ?? this.description,
    );
  }
}

class TrailerStore {
  static final List<TrailerRecord> _items = [
    const TrailerRecord(
      code: 'TRL-001',
      type: 'Flatbed',
      capacity: '40 FT',
      status: 'Active',
      availability: 'Available',
      description: 'General flatbed trailer for dry cargo.',
    ),
    const TrailerRecord(
      code: 'TRL-002',
      type: 'Lowbed',
      capacity: '60 FT',
      status: 'Active',
      availability: 'Assigned',
      description: 'Lowbed trailer for heavy equipment transport.',
    ),
    const TrailerRecord(
      code: 'TRL-003',
      type: 'Tanker',
      capacity: '30 KL',
      status: 'Inactive',
      availability: 'Blocked',
      description: 'Liquid cargo tanker currently blocked for dispatch.',
    ),
  ];

  static List<TrailerRecord> all() => List.unmodifiable(_items);

  static TrailerRecord? byCode(String code) {
    final target = code.trim().toLowerCase();
    for (final item in _items) {
      if (item.code.toLowerCase() == target) {
        return item;
      }
    }
    return null;
  }

  static String upsert(TrailerRecord record, {String? originalCode}) {
    final code = record.code.trim();
    if (code.isEmpty) {
      return 'Trailer code is required.';
    }

    final original = originalCode?.trim().toLowerCase();
    final duplicate = _items.any(
      (item) =>
          item.code.toLowerCase() == code.toLowerCase() &&
          item.code.toLowerCase() != original,
    );
    if (duplicate) {
      return 'Trailer code already exists.';
    }

    if (original != null && original.isNotEmpty) {
      final index = _items.indexWhere((item) => item.code.toLowerCase() == original);
      if (index >= 0) {
        _items[index] = record;
        return 'Trailer updated successfully.';
      }
    }

    _items.insert(0, record);
    return 'Trailer created successfully.';
  }
}
