import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerViewScreen extends ConsumerWidget {
  const CustomerViewScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);

    if (state.isLoading) {
      return OpsShell(
        title: 'Customer Details',
        currentRoute: RoutePaths.customerManagement,
        actions: [
          TextButton(
            onPressed: () => context.go(RoutePaths.customerManagement),
            child: const Text('Back to List'),
          ),
        ],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Customer? customer;
    for (final item in state.customers) {
      if (item.id == customerId) {
        customer = item;
        break;
      }
    }

    if (customer == null) {
      return OpsShell(
        title: 'Customer Details',
        currentRoute: RoutePaths.customerManagement,
        actions: [
          TextButton(
            onPressed: () => context.go(RoutePaths.customerManagement),
            child: const Text('Back to List'),
          ),
        ],
        child: const Center(child: Text('Customer not found.')),
      );
    }

    final currentCustomer = customer;

    return OpsShell(
      title: 'Customer Details',
      currentRoute: RoutePaths.customerManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: DefaultTabController(
        length: 7,
        child: Column(
          children: [
            OpsSectionCard(
              title: currentCustomer.name,
              subtitle:
                  '${currentCustomer.id} - ${currentCustomer.shortCode} - ${currentCustomer.customerType}',
              icon: Icons.business_center_outlined,
              accent: const Color(0xFF1D4ED8),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OpsPill(
                    label: currentCustomer.status,
                    color: currentCustomer.isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => context
                        .go(RoutePaths.editCustomerById(currentCustomer.id)),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OpsPill(
                    label: 'Risk ${currentCustomer.riskScore}',
                    color: currentCustomer.riskScore >= 70
                        ? const Color(0xFFDC2626)
                        : currentCustomer.riskScore >= 40
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF16A34A),
                  ),
                  OpsPill(
                    label:
                        'Credit ${currentCustomer.creditUsagePercent.toStringAsFixed(0)}%',
                    color: currentCustomer.isCreditExceeded
                        ? const Color(0xFFDC2626)
                        : currentCustomer.isNearCreditLimit
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF16A34A),
                  ),
                  OpsPill(
                    label: currentCustomer.segment,
                    color: const Color(0xFF2563EB),
                  ),
                  if (currentCustomer.hasOverduePayments)
                    const OpsPill(label: 'Overdue', color: Color(0xFFDC2626)),
                  if (currentCustomer.isBlocked)
                    OpsPill(
                      label: currentCustomer.hardBlock
                          ? 'Hard Block'
                          : 'Soft Block',
                      color: const Color(0xFF7F1D1D),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Summary'),
                Tab(text: 'Financial'),
                Tab(text: 'Operations Rules'),
                Tab(text: 'Compliance'),
                Tab(text: 'Work Orders'),
                Tab(text: 'Invoices'),
                Tab(text: 'Audit History'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _summaryTab(currentCustomer),
                  _financialTab(currentCustomer),
                  _operationsTab(currentCustomer),
                  _complianceTab(currentCustomer),
                  _workOrdersTab(currentCustomer),
                  _invoicesTab(currentCustomer),
                  _auditTab(currentCustomer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Identity',
          [
            _pair('Customer ID', customer.id),
            _pair('Short Code', customer.shortCode),
            _pair('Type', customer.customerType),
            _pair('Status', customer.status),
          ],
        ),
        const SizedBox(height: 10),
        _section(
          'Contact',
          [
            _pair('Primary Contact', customer.primaryContactPerson),
            _pair('Phone', customer.phoneNumber),
            _pair('Email', customer.email),
            _pair('Alternate Contact', customer.alternateContact),
            _pair('Address', customer.billingAddress),
            _pair('City/Country', '${customer.city}, ${customer.country}'),
          ],
        ),
      ],
    );
  }

  Widget _financialTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Commercial Terms',
          [
            _pair('Payment Terms', customer.paymentTerms),
            _pair('Payment Mode', customer.paymentMode),
            _pair('Invoice Cycle', customer.invoiceCycle),
            _pair('Currency', customer.currency),
          ],
        ),
        const SizedBox(height: 10),
        _section(
          'Credit Control',
          [
            _pair('Credit Limit', customer.creditLimit.toStringAsFixed(2)),
            _pair('Outstanding', customer.outstandingAmount.toStringAsFixed(2)),
            _pair('Credit Usage',
                '${customer.creditUsagePercent.toStringAsFixed(1)}%'),
            _pair(
                'Overdue Payment', customer.hasOverduePayments ? 'Yes' : 'No'),
            _pair('Average Delay', '${customer.averagePaymentDelayDays} days'),
            _pair('Risk Score', '${customer.riskScore} / 100'),
          ],
        ),
      ],
    );
  }

  Widget _operationsTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Execution Rules',
          [
            _pair('POD Required', customer.podRequired ? 'Yes' : 'No'),
            _pair('DN Required', customer.dnRequired ? 'Yes' : 'No'),
            _pair('SLA', '${customer.slaHours} hours'),
            _pair('Preferred Vehicle', customer.preferredVehicleType),
            _pair('Preferred Route', customer.preferredRoute),
            _pair('Priority', customer.priorityLevel),
            _pair('Special Documents',
                customer.specialDocumentsRequired.join(', ')),
          ],
        ),
      ],
    );
  }

  Widget _complianceTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Compliance Rules',
          [
            _pair('Segment', customer.segment),
            _pair('Certifications',
                customer.specialCertificationsRequired.join(', ')),
            _pair('Restricted Routes', customer.restrictedRoutes.join(', ')),
            _pair('Safety Rules', customer.safetyRules.join(', ')),
            _pair('Inspection Type', customer.mandatoryInspectionType),
            _pair('CR Number', customer.crNumber),
            _pair('VATIN Number', customer.vatinNumber),
          ],
        ),
      ],
    );
  }

  Widget _workOrdersTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Work Order Snapshot',
          [
            _pair('Active Work Orders', '${customer.activeWorkOrders}'),
            _pair('Block Status', customer.isBlocked ? 'Blocked' : 'Open'),
            _pair(
              'WO Creation Rule',
              customer.isBlocked && customer.hardBlock
                  ? 'Hard-blocked due to control policy'
                  : customer.isCreditExceeded
                      ? 'Credit exceeded - prevent new WO'
                      : 'Eligible for WO creation',
            ),
          ],
        ),
      ],
    );
  }

  Widget _invoicesTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Invoice Snapshot',
          [
            _pair('Pending Invoices', '${customer.pendingInvoices}'),
            _pair('Overdue Invoices', '${customer.overdueInvoices}'),
            _pair('Payment Delay', '${customer.averagePaymentDelayDays} days'),
            _pair('Complaints', '${customer.complaintsCount}'),
          ],
        ),
      ],
    );
  }

  Widget _auditTab(Customer customer) {
    return ListView(
      children: [
        _section(
          'Audit Trail',
          [
            _pair('Created By', customer.createdBy),
            _pair('Created At', customer.createdAt.toIso8601String()),
            _pair('Updated By', customer.updatedBy ?? '-'),
            _pair('Updated At', customer.updatedAt?.toIso8601String() ?? '-'),
            _pair('Blocked', customer.isBlocked ? 'Yes' : 'No'),
            _pair('Block Reason', customer.blockReason),
          ],
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _pair(String label, String value) {
    final safeValue = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(safeValue)),
        ],
      ),
    );
  }
}
