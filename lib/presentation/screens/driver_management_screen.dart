import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState
    extends ConsumerState<DriverManagementScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Driver List',
      currentRoute: RoutePaths.driverManagement,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = _buildRows(data).where((row) {
            if (_search.trim().isEmpty) {
              return true;
            }
            final q = _search.toLowerCase();
            return '${row.driverCode} ${row.name} ${row.phone} ${row.currentTrip}'
                .toLowerCase()
                .contains(q);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                onChanged: (value) =>
                                    setState(() => _search = value),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search by driver code, name, phone, current trip',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed: () =>
                                    _openDriverDialog(context, ref),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Driver'),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _search = value),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Search by driver code, name, phone, current trip',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: () =>
                                    _openDriverDialog(context, ref),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Driver'),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Card(
                    child: rows.isEmpty
                        ? const Center(child: Text('No drivers found'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Driver Code')),
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Phone')),
                                      DataColumn(label: Text('License Expiry')),
                                      DataColumn(label: Text('Availability')),
                                      DataColumn(label: Text('Current Trip')),
                                      DataColumn(
                                          label: Text('Compliance Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: [
                                      for (final row in rows)
                                        DataRow(cells: [
                                          DataCell(Text(row.driverCode)),
                                          DataCell(Text(row.name)),
                                          DataCell(Text(row.phone)),
                                          DataCell(Text(row.licenseExpiry)),
                                          DataCell(Text(row.availability)),
                                          DataCell(Text(row.currentTrip)),
                                          DataCell(
                                            Text(
                                              row.complianceStatus,
                                              style: TextStyle(
                                                color: row.complianceStatus ==
                                                        'Valid'
                                                    ? const Color(0xFF15803D)
                                                    : const Color(0xFFB91C1C),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Wrap(
                                              spacing: 2,
                                              children: [
                                                IconButton(
                                                  tooltip: 'Edit',
                                                  onPressed: () =>
                                                      _openDriverDialog(
                                                    context,
                                                    ref,
                                                    existing: row.source,
                                                  ),
                                                  icon: const Icon(
                                                      Icons.edit_outlined),
                                                ),
                                                IconButton(
                                                  tooltip: 'Open Detail',
                                                  onPressed: () => context.push(
                                                    RoutePaths.driverDetailById(
                                                        row.driverCode),
                                                  ),
                                                  icon: const Icon(Icons
                                                      .open_in_new_rounded),
                                                ),
                                                IconButton(
                                                  tooltip:
                                                      'View Inspection Links',
                                                  onPressed: () => context.push(
                                                    RoutePaths.inspections,
                                                  ),
                                                  icon: const Icon(Icons
                                                      .fact_check_outlined),
                                                ),
                                                IconButton(
                                                  tooltip: 'View Trip History',
                                                  onPressed: () => context.push(
                                                    '${RoutePaths.driverDetailById(row.driverCode)}?tab=history',
                                                  ),
                                                  icon: const Icon(
                                                      Icons.history_outlined),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_DriverListRow> _buildRows(LogisticsUiState data) {
    return data.drivers.map((driver) {
      final status = _licenseStatus(driver.expiryDate);
      final currentTrip = data.assignedDriverId == driver.driverId
          ? (data.assignedOrderId == null ? '-' : 'TRP-${data.assignedOrderId}')
          : '-';
      return _DriverListRow(
        source: driver,
        driverCode: driver.driverId,
        name: driver.name,
        phone: driver.phone,
        licenseExpiry: driver.expiryDate,
        availability: driver.status,
        currentTrip: currentTrip,
        complianceStatus: status,
      );
    }).toList();
  }

  String _licenseStatus(String expiry) {
    final dt = DateTime.tryParse(expiry.trim());
    if (dt == null) {
      return 'Unknown';
    }
    final days = dt.difference(DateTime.now()).inDays;
    if (days < 0) {
      return 'Expired';
    }
    if (days <= 30) {
      return 'Expiring Soon';
    }
    return 'Valid';
  }

  Future<void> _openDriverDialog(
    BuildContext context,
    WidgetRef ref, {
    DriverData? existing,
  }) async {
    final isEdit = existing != null;
    final codeCtrl = TextEditingController(text: existing?.driverId ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final licenseCtrl = TextEditingController(text: existing?.licenseNo ?? '');
    final expiryCtrl = TextEditingController(text: existing?.expiryDate ?? '');
    final availabilityCtrl =
        TextEditingController(text: existing?.status ?? 'Available');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Driver' : 'Add Driver'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  enabled: !isEdit,
                  decoration: const InputDecoration(labelText: 'Driver Code'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: licenseCtrl,
                  decoration: const InputDecoration(labelText: 'License No'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expiryCtrl,
                  decoration: const InputDecoration(
                      labelText: 'License Expiry (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: availabilityCtrl,
                  decoration: const InputDecoration(labelText: 'Availability'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final vm = ref.read(logisticsViewModelProvider.notifier);
                final message = isEdit
                    ? vm.updateDriver(
                        driverCode: existing.driverId,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        licenseNo: licenseCtrl.text.trim(),
                        licenseExpiry: expiryCtrl.text.trim(),
                        availability: availabilityCtrl.text.trim(),
                      )
                    : vm.addDriver(
                        driverCode: codeCtrl.text.trim(),
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        licenseNo: licenseCtrl.text.trim(),
                        licenseExpiry: expiryCtrl.text.trim(),
                        availability: availabilityCtrl.text.trim(),
                      );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );

    codeCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    licenseCtrl.dispose();
    expiryCtrl.dispose();
    availabilityCtrl.dispose();
  }
}

class _DriverListRow {
  const _DriverListRow({
    required this.source,
    required this.driverCode,
    required this.name,
    required this.phone,
    required this.licenseExpiry,
    required this.availability,
    required this.currentTrip,
    required this.complianceStatus,
  });

  final DriverData source;
  final String driverCode;
  final String name;
  final String phone;
  final String licenseExpiry;
  final String availability;
  final String currentTrip;
  final String complianceStatus;
}
