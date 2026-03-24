class ModuleDocument {
  const ModuleDocument({
    required this.id,
    required this.documentName,
    required this.targetType,
    required this.documentType,
  });

  final String id;
  final String documentName;
  final String targetType;
  final String documentType;

  ModuleDocument copyWith({
    String? id,
    String? documentName,
    String? targetType,
    String? documentType,
  }) {
    return ModuleDocument(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      targetType: targetType ?? this.targetType,
      documentType: documentType ?? this.documentType,
    );
  }
}
