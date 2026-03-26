import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/vendor_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VendorListScreen extends ConsumerWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Vendor Master',
      currentRoute: RoutePaths.vendorMaster,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredVendors;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Vendor Search',
                  subtitle: 'Search and manage vendors from one place',
                  icon: Icons.search,
                  accent: const Color(0xFF2563EB),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText: 'Vendor Name',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(vendorViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.vendorForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Vendor'),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText: 'Vendor Name',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(vendorViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () => context.go(RoutePaths.vendorForm),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Vendor'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Vendor List',
                    subtitle: 'Master data for quotation and order creation',
                    icon: Icons.store_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No vendors found.'),
                          )
                        : (isMobile
                            ? _MobileVendorList(items: items)
                            : _DesktopVendorTable(items: items)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DesktopVendorTable extends StatefulWidget {
  const _DesktopVendorTable({required this.items});

  final List<VendorModel> items;

  @override
  State<_DesktopVendorTable> createState() => _DesktopVendorTableState();
}

class _DesktopVendorTableState extends State<_DesktopVendorTable> {
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
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                horizontalMargin: 14,
                columnSpacing: 20,
                dataRowMinHeight: 62,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('Vendor Name')),
                  DataColumn(label: Text('Company Name')),
                  DataColumn(label: Text('Contact')),
                  DataColumn(label: Text('Vendor Type')),
                  DataColumn(label: Text('Service Type')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final vendor in widget.items)
                    DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              vendor.vendorName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: Text(
                              vendor.companyName.isEmpty
                                  ? '-'
                                  : vendor.companyName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(vendor.contactNumber)),
                        DataCell(Text(vendor.vendorType.label)),
                        DataCell(Text(vendor.serviceType.label)),
                        DataCell(Text(vendor.status.label)),
                        DataCell(
                          SizedBox(
                            width: 168,
                            child: Row(
                              children: [
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context.go(
                                    RoutePaths.vendorViewById(vendor.vendorId),
                                  ),
                                  child: const Text('View'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context.go(
                                    '${RoutePaths.vendorForm}?id=${vendor.vendorId}',
                                  ),
                                  child: const Text('Edit'),
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
        );
      },
    );
  }
}

class _MobileVendorList extends StatelessWidget {
  const _MobileVendorList({required this.items});

  final List<VendorModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final vendor = items[index];
        return Container(
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
                vendor.vendorName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                  'Company: ${vendor.companyName.isEmpty ? '-' : vendor.companyName}'),
              Text('Contact: ${vendor.contactNumber}'),
              Text('Vendor Type: ${vendor.vendorType.label}'),
              Text('Service Type: ${vendor.serviceType.label}'),
              Text('Status: ${vendor.status.label}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go(RoutePaths.vendorViewById(vendor.vendorId)),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.go(
                      '${RoutePaths.vendorForm}?id=${vendor.vendorId}',
                    ),
                    child: const Text('Edit'),
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
