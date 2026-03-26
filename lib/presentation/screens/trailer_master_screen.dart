import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';
import 'trailer_store.dart';

class TrailerMasterScreen extends StatefulWidget {
  const TrailerMasterScreen({super.key});

  @override
  State<TrailerMasterScreen> createState() => _TrailerMasterScreenState();
}

class _TrailerMasterScreenState extends State<TrailerMasterScreen> {
  final _queryController = TextEditingController();
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _queryController.text.trim().toLowerCase();
    final items = TrailerStore.all().where((item) {
      if (query.isEmpty) {
        return true;
      }
      return '${item.code} ${item.type} ${item.capacity}'
          .toLowerCase()
          .contains(query);
    }).toList();

    return OpsShell(
      title: 'Trailer Master',
      currentRoute: RoutePaths.trailerMaster,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.trailerForm),
          icon: const Icon(Icons.add),
          label: const Text('Create Trailer'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OpsSectionCard(
              title: 'Search',
              subtitle: 'Search trailer by code, type, or capacity',
              icon: Icons.search,
              accent: const Color(0xFF2563EB),
              child: TextField(
                controller: _queryController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search trailer...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: OpsSectionCard(
                title: 'Trailer List',
                subtitle: 'Master trailer records',
                icon: Icons.rv_hookup_outlined,
                accent: const Color(0xFF16A34A),
                expandChild: true,
                child: items.isEmpty
                    ? const Center(child: Text('No trailers found.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            thumbVisibility: true,
                            controller: _verticalController,
                            child: SingleChildScrollView(
                              controller: _verticalController,
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: _horizontalController,
                                notificationPredicate: (n) =>
                                    n.metrics.axis == Axis.horizontal,
                                child: SingleChildScrollView(
                                  controller: _horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      horizontalMargin: 14,
                                      columnSpacing: 20,
                                      headingRowHeight: 52,
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 64,
                                      columns: const [
                                        DataColumn(label: Text('Trailer Code')),
                                        DataColumn(label: Text('Type')),
                                        DataColumn(label: Text('Capacity')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Availability')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: [
                                        for (final item in items)
                                          DataRow(
                                            cells: [
                                              DataCell(Text(item.code)),
                                              DataCell(Text(item.type)),
                                              DataCell(Text(item.capacity)),
                                              DataCell(Text(item.status)),
                                              DataCell(Text(item.availability)),
                                              DataCell(
                                                SizedBox(
                                                  width: 90,
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        tooltip: 'View',
                                                        constraints:
                                                            const BoxConstraints(
                                                          minWidth: 34,
                                                          minHeight: 34,
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () => context.go(
                                                          RoutePaths
                                                              .trailerViewByCode(
                                                                  item.code),
                                                        ),
                                                        icon: const Icon(
                                                            Icons.open_in_new_rounded),
                                                      ),
                                                      IconButton(
                                                        tooltip: 'Edit',
                                                        constraints:
                                                            const BoxConstraints(
                                                          minWidth: 34,
                                                          minHeight: 34,
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () => context.go(
                                                          RoutePaths.editTrailerByCode(
                                                              item.code),
                                                        ),
                                                        icon: const Icon(
                                                            Icons.edit_outlined),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
}
