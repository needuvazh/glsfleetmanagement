import '../../domain/entities/module_document.dart';

class ModuleDocumentModel extends ModuleDocument {
  const ModuleDocumentModel({
    required super.id,
    required super.documentName,
    required super.targetType,
    required super.documentType,
  });

  factory ModuleDocumentModel.fromMap(Map<String, dynamic> map) {
    return ModuleDocumentModel(
      id: map['id'] as String? ?? '',
      documentName: map['documentName'] as String? ?? '',
      targetType: map['targetType'] as String? ?? 'Driver',
      documentType: map['documentType'] as String? ?? 'PDF',
    );
  }
}
