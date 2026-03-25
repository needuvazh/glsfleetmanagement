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
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vendorForm),
          child: const Text('Create Vendor'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredVendors;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search',
                subtitle: 'Search by vendor name',
                icon: Icons.search,
                accent: const Color(0xFF2563EB),
                child: TextFormField(
                  initialValue: data.searchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Vendor Name',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged:
                      ref.read(vendorViewModelProvider.notifier).setSearchQuery,
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Vendor List',
                subtitle: 'Master data for quotation and order creation',
                icon: Icons.store_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.vendorForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Vendor'),
                ),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No vendors found.'),
                      )
                    : (isMobile
                        ? _MobileVendorList(items: items)
                        : _DesktopVendorTable(items: items)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopVendorTable extends StatelessWidget {
  const _DesktopVendorTable({required this.items});

  final List<VendorModel> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
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
          for (final vendor in items)
            DataRow(
              cells: [
                DataCell(Text(vendor.vendorName)),
                DataCell(Text(vendor.companyName.isEmpty ? '-' : vendor.companyName)),
                DataCell(Text(vendor.contactNumber)),
                DataCell(Text(vendor.vendorType.label)),
                DataCell(Text(vendor.serviceType.label)),
                DataCell(Text(vendor.status.label)),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go(
                          RoutePaths.vendorViewById(vendor.vendorId),
                        ),
                        child: const Text('View'),
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '${RoutePaths.vendorForm}?id=${vendor.vendorId}',
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileVendorList extends StatelessWidget {
  const _MobileVendorList({required this.items});

  final List<VendorModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
              Text('Company: ${vendor.companyName.isEmpty ? '-' : vendor.companyName}'),
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
