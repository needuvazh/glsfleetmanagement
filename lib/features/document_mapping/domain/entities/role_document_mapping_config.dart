class RoleDocumentMappingConfig {
  const RoleDocumentMappingConfig({
    required this.roles,
    required this.allDocuments,
    required this.roleDocumentMap,
  });

  final List<String> roles;
  final List<String> allDocuments;
  final Map<String, List<String>> roleDocumentMap;
}
