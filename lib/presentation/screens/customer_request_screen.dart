import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestScreen extends ConsumerWidget {
  const CustomerRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Enquiry Register',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.customerRequestForm),
          icon: const Icon(Icons.add),
          label: const Text('Add New Enquiry'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: OpsSectionCard(
              title: 'Enquiry Register',
              subtitle: 'Track all enquiries and manage view/edit actions.',
              icon: Icons.table_chart_outlined,
              accent: const Color(0xFF0EA5E9),
              child: _RegisterTable(enquiries: data.customerRequests),
            ),
          );
        },
      ),
    );
  }
}

class _RegisterTable extends StatelessWidget {
  const _RegisterTable({required this.enquiries});

  final List<CustomerRequestData> enquiries;

  @override
  Widget build(BuildContext context) {
    if (enquiries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(child: Text('No enquiries found.')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF6FF)),
        columns: const [
          DataColumn(label: Text('Enquiry No')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Source')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Cargo')),
          DataColumn(label: Text('Route')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final enquiry in enquiries)
            DataRow(
              cells: [
                DataCell(Text(enquiry.enquiryNumber)),
                DataCell(Text(enquiry.requestDate)),
                DataCell(Text(enquiry.requestSource)),
                DataCell(Text(enquiry.customerName)),
                DataCell(Text(enquiry.cargoType)),
                DataCell(Text('${enquiry.pickup} -> ${enquiry.delivery}')),
                DataCell(_statusPill(enquiry.status)),
                DataCell(
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go(
                            RoutePaths.customerRequestViewById(
                                enquiry.enquiryNumber)),
                        child: const Text('View'),
                      ),
                      OutlinedButton(
                        onPressed: enquiry.status == 'Cancelled'
                            ? null
                            : () => context.go(
                                  '${RoutePaths.customerRequestForm}?enquiryNumber=${enquiry.enquiryNumber}',
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

  Widget _statusPill(String status) {
    final s = status.toLowerCase();
    if (s == 'cancelled') {
      return const OpsPill(label: 'Cancelled', color: Color(0xFFDC2626));
    }
    if (s == 'detail collection') {
      return const OpsPill(
          label: 'Detail Collection', color: Color(0xFF0284C7));
    }
    return OpsPill(label: status, color: const Color(0xFF16A34A));
  }
}
