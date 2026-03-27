import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/logistics_flow.dart';
import '../services/quotation_pdf_service.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class QuotationFormScreen extends ConsumerStatefulWidget {
  const QuotationFormScreen({super.key, this.quoteRef});
  final String? quoteRef;

  @override
  ConsumerState<QuotationFormScreen> createState() =>
      _QuotationFormScreenState();
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Enquiry linkage
  String? _selectedEnquiryRef;

  // Auto-populated from enquiry (read-only display)
  String _customer = '';
  String _contact = '';
  String _pickup = '';
  String _delivery = '';
  String _route = '';
  String _cargoType = '';
  String _weightVolume = '';
  String _requiredVehicleType = '';
  String _tentativeDispatchDate = '';
  String _enquiryNotes = '';

  // Form editable fields
  final _dateCtrl = TextEditingController();
  final _validityCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _costSummaryCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  bool _hydrated = false;

  bool get _isEdit => widget.quoteRef != null;
  bool get _hasEnquiry => _selectedEnquiryRef != null;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _validityCtrl.dispose();
    _rateCtrl.dispose();
    _costSummaryCtrl.dispose();
    _termsCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _populateFromEnquiry(CustomerRequestData enq) {
    setState(() {
      _customer = enq.customerName;
      _contact = enq.contact;
      _pickup = enq.pickup;
      _delivery = enq.delivery;
      _route = enq.routeName.isNotEmpty ? enq.routeName : enq.route;
      _cargoType = enq.cargoType;
      _weightVolume = enq.weightVolume;
      _requiredVehicleType = enq.requiredVehicleType;
      _tentativeDispatchDate = enq.tentativeDispatchDate;
      _enquiryNotes = enq.notes;
      // Pre-fill remarks with enquiry notes if empty
      if (_remarksCtrl.text.isEmpty && enq.notes.isNotEmpty) {
        _remarksCtrl.text = enq.notes;
      }
    });
  }

  void _hydrateEdit(QuotationData q) {
    if (_hydrated) return;
    _selectedEnquiryRef = q.enquiryRef.isEmpty ? null : q.enquiryRef;
    _customer = q.customer;
    _dateCtrl.text = q.date;
    _validityCtrl.text = q.validityDate;
    _rateCtrl.text = q.rate > 0 ? q.rate.toString() : '';
    _costSummaryCtrl.text = q.costSummary;
    _termsCtrl.text = q.terms;
    _remarksCtrl.text = q.remarks;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: _isEdit
          ? 'Transactions / Quotation / Edit'
          : 'Transactions / Quotation / Add',
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
          final enquiries = data.customerRequests
              .where((e) => e.status != 'Cancelled')
              .toList();

          if (_isEdit && !_hydrated) {
            final q = data.quotations
                .where((q) => q.quoteRef == widget.quoteRef)
                .firstOrNull;
            if (q != null) {
              _hydrateEdit(q);
              // Also backfill enquiry details from linked enquiry
              if (q.enquiryRef.isNotEmpty) {
                final enq = enquiries
                    .where((e) => e.enquiryNumber == q.enquiryRef)
                    .firstOrNull;
                if (enq != null) _populateFromEnquiry(enq);
              }
            }
          } else if (!_isEdit && !_hydrated) {
            _dateCtrl.text = _todayString();
            _hydrated = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Quotation Header ──────────────────────────────
                    OpsSectionCard(
                      title: 'Quotation Header',
                      subtitle: 'Select an Enquiry to auto-populate details.',
                      icon: Icons.info_outline,
                      accent: const Color(0xFF0284C7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEdit)
                            _ro('Quotation No', widget.quoteRef ?? ''),
                          if (_isEdit) const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedEnquiryRef,
                            decoration: const InputDecoration(
                                labelText: 'Enquiry Reference *'),
                            validator: (v) =>
                                v == null ? 'Enquiry reference required' : null,
                            items: [
                              for (final e in enquiries)
                                DropdownMenuItem(
                                  value: e.enquiryNumber,
                                  child: Text(
                                      '${e.enquiryNumber}  ·  ${e.customerName}  [${e.status}]'),
                                ),
                            ],
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => _selectedEnquiryRef = val);
                              final enq = enquiries.firstWhere(
                                  (e) => e.enquiryNumber == val);
                              _populateFromEnquiry(enq);
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dateCtrl,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Quotation Date',
                                      suffixIcon: Icon(Icons.calendar_today,
                                          size: 18)),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(
                                          () => _dateCtrl.text = _fmt(picked));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _validityCtrl,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Validity Date *',
                                      suffixIcon: Icon(Icons.event_outlined,
                                          size: 18)),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Validity date required'
                                          : null,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 30)),
                                    );
                                    if (picked != null) {
                                      setState(() =>
                                          _validityCtrl.text = _fmt(picked));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Auto-populated Enquiry Details ────────────────
                    if (_hasEnquiry) ...[
                      OpsSectionCard(
                        title: 'Enquiry Details (Auto-populated)',
                        subtitle:
                            'Read-only. Sourced from the selected enquiry.',
                        icon: Icons.auto_awesome_outlined,
                        accent: const Color(0xFF7C3AED),
                        child: Column(
                          children: [
                            _row2('Customer', _customer, 'Contact', _contact),
                            const SizedBox(height: 10),
                            _row2('Pickup', _pickup, 'Delivery', _delivery),
                            const SizedBox(height: 10),
                            _ro('Route', _route.isEmpty ? '—' : _route),
                            const SizedBox(height: 10),
                            _row2('Cargo Type', _cargoType.isEmpty ? '—' : _cargoType,
                                'Weight / Volume',
                                _weightVolume.isEmpty ? '—' : _weightVolume),
                            const SizedBox(height: 10),
                            _row2(
                                'Required Vehicle',
                                _requiredVehicleType.isEmpty
                                    ? '—'
                                    : _requiredVehicleType,
                                'Tentative Dispatch',
                                _tentativeDispatchDate.isEmpty
                                    ? '—'
                                    : _tentativeDispatchDate),
                            if (_enquiryNotes.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _ro('Enquiry Notes', _enquiryNotes),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Commercial Details ────────────────────────────
                    OpsSectionCard(
                      title: 'Commercial Details',
                      subtitle:
                          'Rate, cost breakdown, payment terms, and remarks.',
                      icon: Icons.monetization_on_outlined,
                      accent: const Color(0xFF10B981),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _rateCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: 'Rate (OMR) *'),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Rate required';
                                    if ((double.tryParse(v) ?? 0) <= 0)
                                      return 'Rate must be > 0';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _costSummaryCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Cost Summary'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _termsCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Payment Terms'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _remarksCtrl,
                            maxLines: 3,
                            decoration:
                                const InputDecoration(labelText: 'Remarks'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Attachment ────────────────────────────────────
                    OpsSectionCard(
                      title: 'Attachment',
                      subtitle: 'Quote file attachment (placeholder).',
                      icon: Icons.attach_file_outlined,
                      accent: const Color(0xFF64748B),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                              '📎  Drag & drop or tap to attach quote file',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Action buttons ────────────────────────────────
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        if (_isEdit)
                          OutlinedButton.icon(
                            onPressed: () => _downloadPdf(),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Download PDF'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => _save('Draft'),
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save Draft'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _save('Sent'),
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Send Quotation'),
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

  void _save(String status) {
    if (!_formKey.currentState!.validate()) return;
    final quotation = QuotationData(
      quoteRef: _isEdit ? (widget.quoteRef ?? '') : '',
      enquiryRef: _selectedEnquiryRef ?? '',
      customer: _customer,
      date: _dateCtrl.text.trim(),
      validityDate: _validityCtrl.text.trim(),
      rate: double.tryParse(_rateCtrl.text.trim()) ?? 0,
      costSummary: _costSummaryCtrl.text.trim(),
      terms: _termsCtrl.text.trim(),
      remarks: _remarksCtrl.text.trim(),
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final msg =
        ref.read(logisticsViewModelProvider.notifier).saveQuotation(quotation);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
    if (msg.contains('saved.')) {
      context.go(RoutePaths.quotation);
    }
  }

  Future<void> _downloadPdf() async {
    final quoteRef = widget.quoteRef ?? '';
    if (quoteRef.trim().isEmpty) {
      return;
    }

    final model = QuotationModel(
      quotationNo: quoteRef,
      date: _dateCtrl.text.trim(),
      validityDate: _validityCtrl.text.trim(),
      customer: _customer,
      contact: _contact,
      pickup: _pickup,
      delivery: _delivery,
      route: _route,
      cargoType: _cargoType,
      weight: _weightVolume,
      vehicle: _requiredVehicleType,
      dispatchDate: _tentativeDispatchDate,
      notes: _enquiryNotes,
      rate: _rateCtrl.text.trim().isEmpty ? '0.00' : _rateCtrl.text.trim(),
      costSummary: _costSummaryCtrl.text.trim(),
      paymentTerms: _termsCtrl.text.trim(),
      remarks: _remarksCtrl.text.trim(),
    );

    try {
      final bytes = await generateQuotationPdf(model);
      await Printing.layoutPdf(
        name: '${quoteRef.trim()}.pdf',
        onLayout: (format) async => bytes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated PDF for $quoteRef')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate PDF for $quoteRef')),
      );
    }
  }

  /// Read-only full-width display field
  Widget _ro(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Two read-only fields side by side
  Widget _row2(String l1, String v1, String l2, String v2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ro(l1, v1)),
        const SizedBox(width: 12),
        Expanded(child: _ro(l2, v2)),
      ],
    );
  }

  String _todayString() => _fmt(DateTime.now());
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
