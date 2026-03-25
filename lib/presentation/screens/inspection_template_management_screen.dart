import 'package:flutter/material.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';

class InspectionTemplateManagementScreen extends StatefulWidget {
  const InspectionTemplateManagementScreen({super.key});

  @override
  State<InspectionTemplateManagementScreen> createState() =>
      _InspectionTemplateManagementScreenState();
}

class _InspectionTemplateManagementScreenState
    extends State<InspectionTemplateManagementScreen> {
  late List<_InspectionTemplate> _templates;

  @override
  void initState() {
    super.initState();
    _templates = _mockTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: 'Inspection Checklist Templates',
      currentRoute: RoutePaths.inspectionTemplates,
      actions: [
        FilledButton.icon(
          onPressed: () => _openTemplateDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Create Template'),
        ),
        const SizedBox(width: 8),
      ],
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Template Name')),
              DataColumn(label: Text('Inspection Type')),
              DataColumn(label: Text('Applicable Vehicle Type')),
              DataColumn(label: Text('Active Status')),
              DataColumn(label: Text('Items Count')),
              DataColumn(label: Text('Updated By')),
              DataColumn(label: Text('Updated At')),
              DataColumn(label: Text('Action')),
            ],
            rows: [
              for (final template in _templates)
                DataRow(
                  cells: [
                    DataCell(Text(template.name)),
                    DataCell(Text(template.inspectionType.label)),
                    DataCell(Text(template.applicableVehicleType)),
                    DataCell(
                      Switch(
                        value: template.isActive,
                        onChanged: (value) {
                          setState(() {
                            template.isActive = value;
                            template.updatedAt = DateTime.now();
                          });
                        },
                      ),
                    ),
                    DataCell(Text('${template.items.length}')),
                    DataCell(Text(template.updatedBy)),
                    DataCell(Text(_fmtDateTime(template.updatedAt))),
                    DataCell(
                      Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Edit Template',
                            onPressed: () =>
                                _openTemplateDialog(existing: template),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Toggle Active',
                            onPressed: () {
                              setState(() {
                                template.isActive = !template.isActive;
                                template.updatedAt = DateTime.now();
                              });
                            },
                            icon: Icon(
                              template.isActive
                                  ? Icons.toggle_on_outlined
                                  : Icons.toggle_off_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTemplateDialog({_InspectionTemplate? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final vehicleTypeCtrl =
        TextEditingController(text: existing?.applicableVehicleType ?? 'Truck');
    var type = existing?.inspectionType ?? InspectionType.preTrip;
    final items = existing == null
        ? <_TemplateItemDraft>[_TemplateItemDraft(name: 'Tyres')]
        : existing.items
            .map(
              (item) => _TemplateItemDraft(
                name: item.name,
                mandatory: item.mandatory,
                requiredMedia: item.requiredMedia,
                severity: item.severity,
              ),
            )
            .toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title:
                  Text(existing == null ? 'Create Template' : 'Edit Template'),
              content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Template Name'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<InspectionType>(
                              value: type,
                              decoration: const InputDecoration(
                                labelText: 'Inspection Type',
                              ),
                              items: [
                                for (final value in InspectionType.values)
                                  DropdownMenuItem(
                                    value: value,
                                    child: Text(value.label),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setInnerState(() => type = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: vehicleTypeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Applicable Vehicle Type',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text('Checklist Items',
                              style: Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setInnerState(() {
                                items.add(_TemplateItemDraft(name: 'New Item'));
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      for (var i = 0; i < items.length; i++)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: items[i].nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Item Name',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete item',
                                      onPressed: () {
                                        if (items.length == 1) {
                                          return;
                                        }
                                        setInnerState(() {
                                          items.removeAt(i);
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        value: items[i].mandatory,
                                        onChanged: (value) {
                                          setInnerState(() {
                                            items[i].mandatory = value ?? false;
                                          });
                                        },
                                        title: const Text('Mandatory'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        value: items[i].requiredMedia,
                                        onChanged: (value) {
                                          setInnerState(() {
                                            items[i].requiredMedia =
                                                value ?? false;
                                          });
                                        },
                                        title: const Text('Required Media'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField<
                                          InspectionFailureSeverity>(
                                        value: items[i].severity,
                                        decoration: const InputDecoration(
                                          labelText: 'Failure Severity',
                                        ),
                                        items: [
                                          for (final value
                                              in InspectionFailureSeverity
                                                  .values)
                                            DropdownMenuItem(
                                              value: value,
                                              child: Text(value.label),
                                            ),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setInnerState(() {
                                              items[i].severity = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Template name is required.')),
                      );
                      return;
                    }
                    final nextItems = items
                        .map(
                          (item) => _TemplateItem(
                            name: item.nameController.text.trim(),
                            mandatory: item.mandatory,
                            severity: item.severity,
                            requiredMedia: item.requiredMedia,
                          ),
                        )
                        .where((item) => item.name.isNotEmpty)
                        .toList();

                    if (nextItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'At least one checklist item is required.')),
                      );
                      return;
                    }

                    setState(() {
                      if (existing == null) {
                        _templates.insert(
                          0,
                          _InspectionTemplate(
                            id: 'TPL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            name: name,
                            inspectionType: type,
                            applicableVehicleType:
                                vehicleTypeCtrl.text.trim().isEmpty
                                    ? 'Truck'
                                    : vehicleTypeCtrl.text.trim(),
                            isActive: true,
                            items: nextItems,
                            updatedBy: 'Admin',
                            updatedAt: DateTime.now(),
                          ),
                        );
                      } else {
                        existing.name = name;
                        existing.inspectionType = type;
                        existing.applicableVehicleType =
                            vehicleTypeCtrl.text.trim().isEmpty
                                ? existing.applicableVehicleType
                                : vehicleTypeCtrl.text.trim();
                        existing.items = nextItems;
                        existing.updatedBy = 'Admin';
                        existing.updatedAt = DateTime.now();
                      }
                    });

                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(existing == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    vehicleTypeCtrl.dispose();
    for (final item in items) {
      item.dispose();
    }
  }

  String _fmtDateTime(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/${value.year} $h:$min';
  }

  List<_InspectionTemplate> _mockTemplates() {
    final now = DateTime.now();
    return [
      _InspectionTemplate(
        id: 'TPL-1001',
        name: 'Truck Pre-Trip Standard',
        inspectionType: InspectionType.preTrip,
        applicableVehicleType: 'Truck',
        isActive: true,
        items: [
          _TemplateItem(
            name: 'Tyres',
            mandatory: true,
            severity: InspectionFailureSeverity.high,
            requiredMedia: true,
          ),
          _TemplateItem(
            name: 'Brake System',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiredMedia: true,
          ),
        ],
        updatedBy: 'Compliance Officer',
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      _InspectionTemplate(
        id: 'TPL-1002',
        name: 'Trailer Safety Inspection',
        inspectionType: InspectionType.trailer,
        applicableVehicleType: 'Trailer',
        isActive: true,
        items: [
          _TemplateItem(
            name: 'Hitch Lock',
            mandatory: true,
            severity: InspectionFailureSeverity.critical,
            requiredMedia: true,
          ),
          _TemplateItem(
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

class _InspectionTemplate {
  _InspectionTemplate({
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
  String name;
  InspectionType inspectionType;
  String applicableVehicleType;
  bool isActive;
  List<_TemplateItem> items;
  String updatedBy;
  DateTime updatedAt;
}

class _TemplateItem {
  _TemplateItem({
    required this.name,
    required this.mandatory,
    required this.severity,
    required this.requiredMedia,
  });

  final String name;
  final bool mandatory;
  final InspectionFailureSeverity severity;
  final bool requiredMedia;
}

class _TemplateItemDraft {
  _TemplateItemDraft({
    required String name,
    this.mandatory = false,
    this.requiredMedia = false,
    this.severity = InspectionFailureSeverity.low,
  }) : nameController = TextEditingController(text: name);

  final TextEditingController nameController;
  bool mandatory;
  bool requiredMedia;
  InspectionFailureSeverity severity;

  void dispose() {
    nameController.dispose();
  }
}
