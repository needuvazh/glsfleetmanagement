import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class QuotationDecisionScreen extends ConsumerStatefulWidget {
  const QuotationDecisionScreen({super.key, required this.quoteRef});
  final String quoteRef;

  @override
  ConsumerState<QuotationDecisionScreen> createState() =>
      _QuotationDecisionScreenState();
}

class _QuotationDecisionScreenState
    extends ConsumerState<QuotationDecisionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _decision = 'Pending'; // Pending / Accepted / Rejected
  final _responseDateCtrl = TextEditingController();
  final _customerPoCtrl = TextEditingController();
  final _rejectionReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _responseDateCtrl.dispose();
    _customerPoCtrl.dispose();
    _rejectionReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Transactions / Quotation / Decision',
      currentRoute: RoutePaths.quotation,
      actions: [
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.quotation),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          final quotation = data.quotations
              .where((q) => q.quoteRef == widget.quoteRef)
              .firstOrNull;

          if (quotation == null) {
            return const Center(child: Text('Quotation not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Context
                    OpsSectionCard(
                      title: 'Quotation Context',
                      subtitle: 'Review quotation details before recording decision.',
                      icon: Icons.receipt_long_outlined,
                      accent: const Color(0xFF64748B),
                      child: Column(
                        children: [
                          _pair('Quotation No', quotation.quoteRef, 'Status', quotation.status),
                          _pair('Customer', quotation.customer, 'Enquiry Ref', quotation.enquiryRef.isEmpty ? '-' : quotation.enquiryRef),
                          _pair('Rate (OMR)', quotation.rate.toStringAsFixed(2), 'Validity', quotation.validityDate.isEmpty ? '-' : quotation.validityDate),
                          if (quotation.terms.isNotEmpty)
                            _pair('Terms', quotation.terms, 'Remarks', quotation.remarks.isEmpty ? '-' : quotation.remarks),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decision Section
                    OpsSectionCard(
                      title: 'Record Customer Decision',
                      subtitle: 'Accepted quotation triggers Work Order creation.',
                      icon: Icons.how_to_vote_outlined,
                      accent: const Color(0xFF8B5CF6),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _decision,
                            decoration: const InputDecoration(labelText: 'Decision *'),
                            validator: (v) =>
                                (v == null || v == 'Pending') ? 'Select a decision' : null,
                            items: const [
                              DropdownMenuItem(value: 'Pending', child: Text('— Select Decision —')),
                              DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
                              DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                            ],
                            onChanged: (val) =>
                                setState(() => _decision = val ?? 'Pending'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _responseDateCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Response Date',
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _responseDateCtrl.text =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          if (_decision == 'Accepted') ...[
                            TextFormField(
                              controller: _customerPoCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Customer PO / Confirmation Ref *'),
                              validator: (v) =>
                                  (_decision == 'Accepted' &&
                                          (v == null || v.trim().isEmpty))
                                      ? 'PO / Confirmation reference required'
                                      : null,
                            ),
                          ],
                          if (_decision == 'Rejected') ...[
                            TextFormField(
                              controller: _rejectionReasonCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                  labelText: 'Rejection Reason *'),
                              validator: (v) =>
                                  (_decision == 'Rejected' &&
                                          (v == null || v.trim().isEmpty))
                                      ? 'Rejection reason required'
                                      : null,
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (_decision == 'Accepted')
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Accepting this quotation will advance the enquiry status to "Decision Received".',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_decision == 'Rejected')
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.cancel_outlined,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Rejecting this quotation will close the associated enquiry flow.',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go(RoutePaths.quotation),
                          child: const Text('Cancel'),
                        ),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Save Decision'),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final msg = ref
        .read(logisticsViewModelProvider.notifier)
        .recordQuotationDecision(
          quoteRef: widget.quoteRef,
          decision: _decision,
          responseDate: _responseDateCtrl.text.trim(),
          customerPoRef: _customerPoCtrl.text.trim(),
          rejectionReason: _rejectionReasonCtrl.text.trim(),
        );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
    if (msg.contains('recorded:')) {
      context.go(RoutePaths.quotation);
    }
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
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
