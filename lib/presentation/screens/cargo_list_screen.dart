import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/cargo_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_policy_viewmodel.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CargoListScreen extends ConsumerWidget {
  const CargoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cargoViewModelProvider);
    final policy = ref.watch(cargoPolicyViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Cargo Master',
      currentRoute: RoutePaths.cargoMaster,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = data.filteredItems;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Search & Filters',
                  subtitle: 'Standardized cargo behavior and risk controls',
                  icon: Icons.tune_outlined,
                  accent: const Color(0xFF2563EB),
                  child: isMobile
                      ? Column(
                          children: [
                            _searchField(ref, data),
                            const SizedBox(height: 10),
                            _hardBlockToggle(context, ref, policy),
                            const SizedBox(height: 10),
                            _filters(ref, data, stacked: true),
                            const SizedBox(height: 10),
                            _createButton(context),
                          ],
                        )
                      : Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final stack = constraints.maxWidth < 980;
                                if (stack) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _searchField(ref, data),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: _createButton(context),
                                      ),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: _searchField(ref, data)),
                                    const SizedBox(width: 12),
                                    _createButton(context),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _filters(ref, data),
                            ),
                            const SizedBox(height: 10),
                            _hardBlockToggle(context, ref, policy),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Cargo List',
                    subtitle: 'Risk and operational behavior by cargo type',
                    icon: Icons.inventory_2_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: rows.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No cargo types found.'),
                          )
                        : (isMobile
                            ? _MobileCargoList(items: rows)
                            : _DesktopCargoTable(items: rows)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchField(WidgetRef ref, CargoUiState data) {
    return TextFormField(
      initialValue: data.query,
      decoration: const InputDecoration(
        labelText: 'Search (Name, Code, Category, Subcategory)',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: ref.read(cargoViewModelProvider.notifier).setQuery,
    );
  }

  Widget _filters(WidgetRef ref, CargoUiState data, {bool stacked = false}) {
    final content = [
      _dropdown(
        value: data.statusFilter,
        label: 'Status',
        options: const ['All', 'Active', 'Inactive'],
        onChanged: ref.read(cargoViewModelProvider.notifier).setStatusFilter,
      ),
      _dropdown(
        value: data.categoryFilter,
        label: 'Category',
        options: data.categoryOptions,
        onChanged: ref.read(cargoViewModelProvider.notifier).setCategoryFilter,
      ),
      _dropdown(
        value: data.hazardFilter,
        label: 'Hazardous',
        options: const ['All', 'Hazardous', 'Non-Hazardous'],
        onChanged: ref.read(cargoViewModelProvider.notifier).setHazardFilter,
      ),
      _dropdown(
        value: data.riskFilter,
        label: 'Risk Level',
        options: const ['All', 'Low', 'Medium', 'High', 'Critical'],
        onChanged: ref.read(cargoViewModelProvider.notifier).setRiskFilter,
      ),
      _dropdown(
        value: data.specialHandlingFilter,
        label: 'Special Handling',
        options: const ['All', 'Yes', 'No'],
        onChanged:
            ref.read(cargoViewModelProvider.notifier).setSpecialHandlingFilter,
      ),
      _dropdown(
        value: data.complianceFilter,
        label: 'Special Compliance',
        options: const ['All', 'Yes', 'No'],
        onChanged:
            ref.read(cargoViewModelProvider.notifier).setComplianceFilter,
      ),
    ];

    if (stacked) {
      return Column(
        children: [
          for (int i = 0; i < content.length; i++) ...[
            content[i],
            if (i != content.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: content);
  }

  Widget _dropdown({
    required String value,
    required String label,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : options.first,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in options)
            DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (next) {
          if (next != null) {
            onChanged(next);
          }
        },
      ),
    );
  }

  Widget _createButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.go(RoutePaths.cargoMasterForm),
      icon: const Icon(Icons.add),
      label: const Text('Create Cargo'),
    );
  }

  Widget _hardBlockToggle(
    BuildContext context,
    WidgetRef ref,
    CargoPolicyState policy,
  ) {
    final modeText =
        policy.hardBlockMode ? 'Hard-block mode' : 'Warning-only mode';
    final modeColor = policy.hardBlockMode
        ? const Color(0xFFB91C1C)
        : const Color(0xFF15803D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: modeColor.withValues(alpha: 0.08),
        border: Border.all(color: modeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.gpp_maybe_outlined, color: modeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cargo enforcement: $modeText',
              style: TextStyle(fontWeight: FontWeight.w700, color: modeColor),
            ),
          ),
          Switch(
            value: policy.hardBlockMode,
            onChanged: (value) async {
              await ref
                  .read(cargoPolicyViewModelProvider.notifier)
                  .setHardBlockMode(value);
              if (!context.mounted) {
                return;
              }
              final text = value
                  ? 'Cargo hard-block mode enabled.'
                  : 'Cargo warning-only mode enabled.';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(text)));
            },
          ),
        ],
      ),
    );
  }
}

class _DesktopCargoTable extends ConsumerStatefulWidget {
  const _DesktopCargoTable({required this.items});

  final List<CargoModel> items;

  @override
  ConsumerState<_DesktopCargoTable> createState() => _DesktopCargoTableState();
}

class _DesktopCargoTableState extends ConsumerState<_DesktopCargoTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _horizontalController,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                horizontalMargin: 14,
                columnSpacing: 20,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 74,
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Cargo Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Risk')),
                  DataColumn(label: Text('Hazardous')),
                  DataColumn(label: Text('Preferred Vehicle')),
                  DataColumn(label: Text('Inspection Linked')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in widget.items)
                    DataRow(
                      cells: [
                        DataCell(Text(item.cargoCode)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              item.cargoName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              '${item.category} / ${item.subcategory}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(_riskChip(item.riskLevel)),
                        DataCell(Text(item.hazardous ? 'Yes' : 'No')),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              item.preferredVehicleType.isEmpty
                                  ? '-'
                                  : item.preferredVehicleType,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(
                            item.inspectionTemplateType.isEmpty ? 'No' : 'Yes')),
                        DataCell(Text(item.isSelectable ? 'Active' : 'Restricted')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(66, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: () => context.go(
                                  RoutePaths.cargoMasterViewByCode(
                                      item.cargoCode),
                                ),
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(66, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: () => context.go(
                                  '${RoutePaths.cargoMasterForm}?code=${item.cargoCode}',
                                ),
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(84, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: item.isSelectable
                                    ? () => _confirmDeactivate(
                                          context,
                                          ref,
                                          item,
                                        )
                                    : null,
                                child: const Text('Deactivate'),
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
          ),
        );
      },
    );
  }
}

class _MobileCargoList extends ConsumerWidget {
  const _MobileCargoList({required this.items});

  final List<CargoModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFDCE6F7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${items[i].cargoName} (${items[i].cargoCode})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('Category: ${items[i].category} / ${items[i].subcategory}'),
              Row(
                children: [
                  const Text('Risk: '),
                  _riskChip(items[i].riskLevel),
                ],
              ),
              Text('Hazardous: ${items[i].hazardous ? 'Yes' : 'No'}'),
              Text(
                  'Vehicle: ${items[i].preferredVehicleType.isEmpty ? '-' : items[i].preferredVehicleType}'),
              Text('Status: ${items[i].isSelectable ? 'Active' : 'Restricted'}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => context
                        .go(RoutePaths.cargoMasterViewByCode(items[i].cargoCode)),
                    child: const Text('View'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go(
                        '${RoutePaths.cargoMasterForm}?code=${items[i].cargoCode}'),
                    child: const Text('Edit'),
                  ),
                  OutlinedButton(
                    onPressed: items[i].isSelectable
                        ? () => _confirmDeactivate(context, ref, items[i])
                        : null,
                    child: const Text('Deactivate'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _riskChip(CargoRiskLevel level) {
  Color color;
  switch (level) {
    case CargoRiskLevel.low:
      color = const Color(0xFF16A34A);
      break;
    case CargoRiskLevel.medium:
      color = const Color(0xFFF59E0B);
      break;
    case CargoRiskLevel.high:
      color = const Color(0xFFEA580C);
      break;
    case CargoRiskLevel.critical:
      color = const Color(0xFFDC2626);
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Text(
      level.label,
      style: TextStyle(color: color, fontWeight: FontWeight.w700),
    ),
  );
}

Future<void> _confirmDeactivate(
  BuildContext context,
  WidgetRef ref,
  CargoModel item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Deactivate Cargo'),
      content: Text(
          'Deactivate ${item.cargoName}? It will not be selectable for new work orders.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Deactivate'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final message = await ref
      .read(cargoViewModelProvider.notifier)
      .deactivateCargo(item.cargoCode);
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
