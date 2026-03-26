class InspectionTypeMaster {
  const InspectionTypeMaster({
    required this.id,
    required this.name,
    required this.categories,
  });

  final String id;
  final String name;
  final List<InspectionCategoryMaster> categories;
}

class InspectionCategoryMaster {
  const InspectionCategoryMaster({
    required this.id,
    required this.name,
  });

  final String id;
  final String name; // Red, Amber, Inspection Critical
}

class InspectionChecklistItemMaster {
  const InspectionChecklistItemMaster({
    required this.id,
    required this.categoryId,
    required this.sno,
    required this.description,
  });

  final String id;
  final String categoryId;
  final int sno;
  final String description;
}
