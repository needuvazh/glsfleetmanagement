import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';
import 'inspection_template_store.dart';

class InspectionTemplateManagementScreen extends StatefulWidget {
  const InspectionTemplateManagementScreen({super.key});

  @override
  State<InspectionTemplateManagementScreen> createState() =>
      _InspectionTemplateManagementScreenState();
}

class _InspectionTemplateManagementScreenState
    extends State<InspectionTemplateManagementScreen> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final templates = InspectionTemplateStore.all();

    return OpsShell(
      title: 'Inspection Checklist Templates',
      currentRoute: RoutePaths.inspectionTemplates,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isMobile
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.go(RoutePaths.inspectionTemplateForm),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Template'),
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            'Template Register',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => context.go(RoutePaths.inspectionTemplateForm),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Template'),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalController,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontalController,
                          notificationPredicate: (notification) =>
                              notification.metrics.axis == Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                horizontalMargin: 14,
                                columnSpacing: 18,
                                headingRowHeight: 52,
                                dataRowMinHeight: 60,
                                dataRowMaxHeight: 70,
                                columns: const [
                                  DataColumn(label: Text('Template Name')),
                                  DataColumn(label: Text('Inspection Type')),
                                  DataColumn(label: Text('Applicable Vehicle')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Items')),
                                  DataColumn(label: Text('Updated By')),
                                  DataColumn(label: Text('Updated At')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: [
                                  for (final template in templates)
                                    DataRow(cells: [
                                      DataCell(
                                        ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(maxWidth: 220),
                                          child: Text(
                                            template.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(template.inspectionType.label)),
                                      DataCell(Text(template.applicableVehicleType)),
                                      DataCell(
                                        Text(
                                          template.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            color: template.isActive
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text('${template.items.length}')),
                                      DataCell(Text(template.updatedBy)),
                                      DataCell(Text(_fmtDateTime(template.updatedAt))),
                                      DataCell(
                                        SizedBox(
                                          width: 114,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'View',
                                                constraints: const BoxConstraints(
                                                    minWidth: 34, minHeight: 34),
                                                padding: EdgeInsets.zero,
                                                onPressed: () => context.go(
                                                  RoutePaths
                                                      .inspectionTemplateViewById(
                                                          template.id),
                                                ),
                                                icon: const Icon(
                                                    Icons.open_in_new_rounded),
                                              ),
                                              IconButton(
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(
                                                    minWidth: 34, minHeight: 34),
                                                padding: EdgeInsets.zero,
                                                onPressed: () => context.go(
                                                  RoutePaths
                                                      .editInspectionTemplateById(
                                                          template.id),
                                                ),
                                                icon:
                                                    const Icon(Icons.edit_outlined),
                                              ),
                                              PopupMenuButton<String>(
                                                tooltip: 'More Actions',
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (_) => const [
                                                  PopupMenuItem(
                                                    value: 'toggle',
                                                    child: Text('Toggle Active'),
                                                  ),
                                                ],
                                                onSelected: (_) {
                                                  setState(() {
                                                    InspectionTemplateStore
                                                        .toggleActive(template.id);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
}
