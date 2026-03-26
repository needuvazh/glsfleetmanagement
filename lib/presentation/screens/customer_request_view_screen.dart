import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestViewScreen extends ConsumerWidget {
  const CustomerRequestViewScreen({
    super.key,
    required this.enquiryNumber,
  });

  final String enquiryNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Enquiry / View',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go(RoutePaths.customerRequest),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          CustomerRequestData? enquiry;
          for (final item in data.customerRequests) {
            if (item.enquiryNumber == enquiryNumber) {
              enquiry = item;
              break;
            }
          }

          if (enquiry == null) {
            return const Center(child: Text('Enquiry not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Summary
              _buildHeaderSummary(context, enquiry),
              const SizedBox(height: 16),

              // Status Timeline
              _buildTimeline(context, enquiry),
              const SizedBox(height: 16),

              // Captured Request Details
              OpsSectionCard(
                title: 'Request Details',
                subtitle: 'Complete breakdown of transport requirements.',
                icon: Icons.assignment_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pair('Request Date', enquiry.requestDate, 'Request Source', enquiry.requestSource),
                    _pair('Customer', enquiry.customerName, 'Contact Person', enquiry.contact),
                    _pair('Reference No', enquiry.emailOrReference.isEmpty ? '-' : enquiry.emailOrReference, 'Cargo Type', enquiry.cargoType),
                    _pair('PDO / Non-PDO', enquiry.pdoSpec, 'Hazardous', enquiry.hazardous ? 'Yes' : 'No'),
                    _pair('Pickup', enquiry.pickup, 'Delivery', enquiry.delivery),
                    _pair('Route', enquiry.route.isEmpty ? '-' : enquiry.route, 'Quantity', enquiry.quantity.isEmpty ? '-' : enquiry.quantity),
                    _pair('Weight / Volume', enquiry.weightVolume.isEmpty ? '-' : enquiry.weightVolume, 'Dimensions', enquiry.dimensions.isEmpty ? '-' : enquiry.dimensions),
                    _pair('Tentative Dispatch', enquiry.tentativeDispatchDate.isEmpty ? '-' : enquiry.tentativeDispatchDate, 'Required Vehicle', enquiry.requiredVehicleType.isEmpty ? '-' : enquiry.requiredVehicleType),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Related Notes
              OpsSectionCard(
                title: 'Notes & Remarks',
                subtitle: 'Internal remarks from the customer or team.',
                icon: Icons.note_outlined,
                accent: const Color(0xFFF59E0B),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(enquiry.notes.isEmpty ? 'No notes provided.' : enquiry.notes),
                ),
              ),
              const SizedBox(height: 16),

              // Audit Preview
              OpsSectionCard(
                title: 'Audit Preview',
                subtitle: 'High-level activity log for this record.',
                icon: Icons.history_outlined,
                accent: const Color(0xFF64748B),
                child: Column(
                  children: [
                    _auditRow('Created', _formatDateTime(enquiry.createdAt), 'System'),
                    const Divider(),
                    _auditRow('Last Updated', _formatDateTime(enquiry.updatedAt), 'System'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSummary(BuildContext context, CustomerRequestData enquiry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enquiry ${enquiry.enquiryNumber}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${enquiry.customerName} • ${enquiry.cargoType}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                _statusChip(enquiry.status),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('${RoutePaths.customerRequestForm}?enquiryNumber=${enquiry.enquiryNumber}'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              const SizedBox(height: 8),
              if (enquiry.status != 'Closed' && enquiry.status != 'Cancelled')
                OutlinedButton.icon(
                  onPressed: () {
                    // Convert to Review Logic Placeholder
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending to Review...')));
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Send to Review'),
                ),
              const SizedBox(height: 8),
              if (enquiry.status != 'Closed' && enquiry.status != 'Cancelled')
                TextButton.icon(
                  onPressed: () {
                    // Close Enquiry Logic Placeholder
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Closing Enquiry...')));
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Close Enquiry', style: TextStyle(color: Colors.red)),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, CustomerRequestData enquiry) {
    final steps = ['New Enquiry', 'Detail Collection', 'Ready for Review', 'Quotation', 'Closed'];
    int currentIndex = 0;
    
    if (enquiry.status == 'New Enquiry') currentIndex = 0;
    else if (enquiry.status == 'Detail Collection') currentIndex = 1;
    else if (enquiry.status == 'Ready for Review') currentIndex = 2;
    else if (enquiry.status == 'Quotation') currentIndex = 3;
    else if (enquiry.status == 'Closed' || enquiry.status == 'Cancelled') currentIndex = 4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex <= currentIndex;
                final isActive = stepIndex == currentIndex;

                return Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.blue : (isCompleted ? Colors.green : Colors.grey[200]),
                          border: Border.all(color: isActive ? Colors.blue.shade700 : Colors.transparent, width: 2),
                        ),
                        child: Icon(
                          isCompleted && !isActive ? Icons.check : isActive ? Icons.circle : null,
                          size: 16,
                          color: isCompleted ? Colors.white : Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[stepIndex],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.black : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentIndex;
                return Expanded(
                  flex: 2,
                  child: Container(
                    height: 4,
                    color: isCompleted ? Colors.green : Colors.grey[200],
                    margin: const EdgeInsets.only(bottom: 24), // Align with circles
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg = Colors.green.shade100;
    Color fg = Colors.green.shade800;
    if (status == 'Cancelled' || status == 'Closed') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade800;
    } else if (status == 'Detail Collection') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
    } else if (status == 'Ready for Review') {
      bg = Colors.purple.shade100;
      fg = Colors.purple.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _auditRow(String label, String value, String user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text(value)),
          Expanded(flex: 2, child: Text('By: $user', style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _pair(String l1, String v1, String l2, String v2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: _kv(l1, v1)),
          const SizedBox(width: 16),
          Expanded(child: _kv(l2, v2)),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
