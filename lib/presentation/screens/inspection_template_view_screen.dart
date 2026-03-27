import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';
import 'inspection_template_store.dart';

class InspectionTemplateViewScreen extends StatelessWidget {
  const InspectionTemplateViewScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context) {
    final record = InspectionTemplateStore.byId(templateId);
    if (record == null) {
      return const OpsShell(
        title: 'Template View',
        currentRoute: RoutePaths.inspectionTemplates,
        child: Center(child: Text('Template not found.')),
      );
    }
    return OpsShell(
      title: 'Inspection Template View',
      currentRoute: RoutePaths.inspectionTemplates,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _row('Template ID', record.id),
                  _row('Inspection Type', record.inspectionType.label),
                  _row('Description',
                      record.description.isEmpty ? '-' : record.description),
                  _row('Frequency', record.frequency),
                  _row('Applicable Vehicle', record.applicableVehicleType),
                  _row('Status', record.isActive ? 'Active' : 'Inactive'),
                  _row('Updated By', record.updatedBy),
                  _row('Updated At', _fmtDateTime(record.updatedAt)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checklist Items',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  for (final category in _categories(record.items)) ...[
                    Text(
                      category,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    for (final item in record.items
                        .where((entry) => entry.category == category))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(
                          'Mandatory: ${item.mandatory ? 'Yes' : 'No'} | '
                          'Photo: ${item.requiresPhoto ? 'Required' : 'Optional'} | '
                          'Video: ${item.requiresVideo ? 'Required' : 'Optional'} | '
                          'Severity: ${item.severity.label}',
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go(RoutePaths.inspectionTemplates),
                child: const Text('Back to List'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context
                    .go(RoutePaths.editInspectionTemplateById(record.id)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Template'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/${value.year} $h:$min';
  }

  List<String> _categories(List<InspectionTemplateItem> items) {
    final set = <String>{};
    for (final item in items) {
      set.add(item.category);
    }
    return set.toList(growable: false);
  }
}
