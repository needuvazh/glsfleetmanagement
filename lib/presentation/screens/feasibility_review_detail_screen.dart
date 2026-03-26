import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FeasibilityReviewDetailScreen extends ConsumerStatefulWidget {
  const FeasibilityReviewDetailScreen({super.key, required this.enquiryNumber});

  final String enquiryNumber;

  @override
  ConsumerState<FeasibilityReviewDetailScreen> createState() =>
      _FeasibilityReviewDetailScreenState();
}

class _FeasibilityReviewDetailScreenState
    extends ConsumerState<FeasibilityReviewDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Operational
  String _feasibleDecision = 'Pending'; // 'Pending', 'Yes', 'No'
  final _vehicleSuitability = TextEditingController();
  final _routeSuitability = TextEditingController();
  final _manpowerReadiness = TextEditingController();

  // Risk & Commercial
  String _riskLevel = 'Low'; // 'Low', 'Medium', 'High', 'Critical'
  final _estimatedCost = TextEditingController();
  final _paymentTerms = TextEditingController();
  String _creditCheckStatus = 'Pending'; // 'Pending', 'Approved', 'Rejected'
  final _internalRemarks = TextEditingController();

  bool _hydrated = false;

  @override
  void dispose() {
    _vehicleSuitability.dispose();
    _routeSuitability.dispose();
    _manpowerReadiness.dispose();
    _estimatedCost.dispose();
    _paymentTerms.dispose();
    _internalRemarks.dispose();
    super.dispose();
  }

  void _hydrate(CustomerRequestData source) {
    if (_hydrated) return;
    _feasibleDecision = source.feasibilityStatus == 'Feasible' ? 'Yes' : (source.feasibilityStatus == 'Not Feasible' ? 'No' : 'Pending');
    _riskLevel = source.feasibilityRiskLevel;
    _estimatedCost.text = source.estimatedCost > 0 ? source.estimatedCost.toString() : '';
    _paymentTerms.text = source.paymentTerms;
    _creditCheckStatus = source.creditCheckStatus;
    _internalRemarks.text = source.feasibilityRemarks;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Feasibility Review / Evaluate',
      currentRoute: RoutePaths.feasibilityReview,
      actions: [
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.feasibilityReview),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to List'),
        )
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final enquiry = data.customerRequests.where((e) => e.enquiryNumber == widget.enquiryNumber).firstOrNull;

          if (enquiry == null) {
            return const Center(child: Text('Enquiry not found.'));
          }

          _hydrate(enquiry);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Context Header
                    _buildContextBox(enquiry),
                    const SizedBox(height: 16),

                    // Section: Operational Feasibility
                    OpsSectionCard(
                      title: 'Operational Feasibility',
                      subtitle: 'Assess fleet, route, and personnel readiness.',
                      icon: Icons.precision_manufacturing_outlined,
                      accent: const Color(0xFF0284C7),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text('Is this request operationally feasible?', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _feasibleDecision,
                                  decoration: const InputDecoration(labelText: 'Decision *'),
                                  validator: (v) {
                                    if (v == null || v == 'Pending') return 'Feasibility decision mandatory';
                                    return null;
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 'Pending', child: Text('Pending Select')),
                                    DropdownMenuItem(value: 'Yes', child: Text('Yes - Feasible')),
                                    DropdownMenuItem(value: 'No', child: Text('No - Not Feasible')),
                                  ],
                                  onChanged: (val) => setState(() => _feasibleDecision = val ?? 'Pending'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _row(
                            TextFormField(
                              controller: _vehicleSuitability,
                              decoration: const InputDecoration(labelText: 'Vehicle Suitability Notes'),
                            ),
                            TextFormField(
                              controller: _routeSuitability,
                              decoration: const InputDecoration(labelText: 'Route Suitability Notes'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _manpowerReadiness,
                            decoration: const InputDecoration(labelText: 'Manpower Readiness Notes'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Risk & Commercial Review
                    OpsSectionCard(
                      title: 'Risk & Commercial Review',
                      subtitle: 'Evaluate operational risks and financial elements.',
                      icon: Icons.monetization_on_outlined,
                      accent: const Color(0xFF10B981),
                      child: Column(
                        children: [
                          _row(
                            DropdownButtonFormField<String>(
                              value: _riskLevel,
                              decoration: const InputDecoration(labelText: 'Risk Level *'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Risk level mandatory';
                                return null;
                              },
                              items: const [
                                DropdownMenuItem(value: 'Low', child: Text('Low')),
                                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'High', child: Text('High')),
                                DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                              ],
                              onChanged: (val) => setState(() => _riskLevel = val ?? 'Low'),
                            ),
                            TextFormField(
                              controller: _estimatedCost,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Estimated Internal Cost *'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Cost required before quotation';
                                if (double.tryParse(v) == null) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _row(
                            DropdownButtonFormField<String>(
                              value: _creditCheckStatus,
                              decoration: const InputDecoration(labelText: 'Credit Check'),
                              items: const [
                                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                              ],
                              onChanged: (val) => setState(() => _creditCheckStatus = val ?? 'Pending'),
                            ),
                            TextFormField(
                              controller: _paymentTerms,
                              decoration: const InputDecoration(labelText: 'Proposed Payment Terms'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _internalRemarks,
                            maxLines: 2,
                            decoration: const InputDecoration(labelText: 'Internal Commercial Remarks'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _save(enquiry, 'Hold'),
                          icon: const Icon(Icons.pause),
                          label: const Text('Reject / Hold'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _save(enquiry, 'Save'),
                          icon: const Icon(Icons.save),
                          label: const Text('Save Review (Draft)'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            if (_feasibleDecision != 'Yes') {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot mark Ready for Quotation unless Feasible is Yes.')));
                              return;
                            }
                            _save(enquiry, 'Ready');
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark Ready for Quotation'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContextBox(CustomerRequestData enquiry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Context: ${enquiry.enquiryNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Customer: ${enquiry.customerName}'),
          Text('Cargo: ${enquiry.cargoType} (${enquiry.quantity} | ${enquiry.weightVolume})'),
          Text('Route: ${enquiry.pickup} -> ${enquiry.delivery}'),
        ],
      ),
    );
  }

  Widget _row(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  void _save(CustomerRequestData enquiry, String action) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String nextFeasibilityState = 'Pending';
    if (_feasibleDecision == 'Yes') nextFeasibilityState = 'Feasible';
    else if (_feasibleDecision == 'No') nextFeasibilityState = 'Not Feasible';

    String appStatus = enquiry.status; // Base status
    if (action == 'Ready') {
      appStatus = 'Ready for Quotation'; // Advancing workflow
    } else if (action == 'Hold') {
      nextFeasibilityState = 'Not Feasible';
    }

    final updated = enquiry.copyWith(
      feasibilityStatus: nextFeasibilityState,
      feasibilityRiskLevel: _riskLevel,
      estimatedCost: double.tryParse(_estimatedCost.text.trim()) ?? 0,
      paymentTerms: _paymentTerms.text.trim(),
      creditCheckStatus: _creditCheckStatus,
      feasibilityRemarks: _internalRemarks.text.trim(),
      reviewedBy: 'Ops Manager', // Mock logged in user
      status: appStatus,
      updatedAt: DateTime.now(),
    );

    final msg = ref.read(logisticsViewModelProvider.notifier).updateEnquiry(updated);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    if (msg.contains('updated.')) {
      context.go(RoutePaths.feasibilityReview);
    }
  }
}
