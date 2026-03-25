import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestFormScreen extends ConsumerStatefulWidget {
  const CustomerRequestFormScreen({super.key, this.enquiryNumber});

  final String? enquiryNumber;

  @override
  ConsumerState<CustomerRequestFormScreen> createState() =>
      _CustomerRequestFormScreenState();
}

class _CustomerRequestFormScreenState
    extends ConsumerState<CustomerRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _requestSource = TextEditingController(text: 'Phone');
  final _customerName = TextEditingController();
  final _requestType = TextEditingController(text: 'Transport Request');
  final _emailOrReference = TextEditingController();
  final _contact = TextEditingController();
  final _cargoType = TextEditingController();
  final _weightVolume = TextEditingController();
  final _pickup = TextEditingController();
  final _delivery = TextEditingController();
  final _notes = TextEditingController();

  DateTime _requestDate = DateTime.now();
  bool _hydrated = false;

  bool get _isEdit => (widget.enquiryNumber ?? '').trim().isNotEmpty;

  @override
  void dispose() {
    _requestSource.dispose();
    _customerName.dispose();
    _requestType.dispose();
    _emailOrReference.dispose();
    _contact.dispose();
    _cargoType.dispose();
    _weightVolume.dispose();
    _pickup.dispose();
    _delivery.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: _isEdit ? 'Edit Enquiry' : 'Add New Enquiry',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerRequest),
          child: const Text('Back to Register'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final source = _findEditingEnquiry(data.customerRequests);
          if (_isEdit && source == null) {
            return const Center(child: Text('Enquiry not found for edit.'));
          }
          if (!_hydrated && source != null) {
            _hydrate(source);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: _isEdit ? 'Edit Enquiry Form' : 'Add New Enquiry Form',
                subtitle:
                    'Complete enquiry fields and save. Edit opens auto-populated values.',
                icon: _isEdit ? Icons.edit_note : Icons.note_add_outlined,
                accent: const Color(0xFF0284C7),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _row(
                        TextFormField(
                          controller: _requestSource,
                          decoration: const InputDecoration(
                              labelText: 'Request Source'),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _requestType,
                          decoration:
                              const InputDecoration(labelText: 'Request Type'),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        TextFormField(
                          controller: _customerName,
                          decoration:
                              const InputDecoration(labelText: 'Customer Name'),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _emailOrReference,
                          decoration: const InputDecoration(
                            labelText: 'Email / Reference',
                          ),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        TextFormField(
                          controller: _contact,
                          decoration:
                              const InputDecoration(labelText: 'Contact'),
                          validator: _required,
                        ),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Request Date',
                              suffixIcon: Icon(Icons.date_range_outlined),
                            ),
                            child: Text(_formatDate(_requestDate)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        TextFormField(
                          controller: _cargoType,
                          decoration:
                              const InputDecoration(labelText: 'Cargo Type'),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _weightVolume,
                          decoration: const InputDecoration(
                            labelText: 'Weight / Volume',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        TextFormField(
                          controller: _pickup,
                          decoration: const InputDecoration(
                            labelText: 'Pickup Location',
                          ),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _delivery,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Location',
                          ),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                          label: Text(
                            _isEdit ? 'Update Enquiry' : 'Create Enquiry',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  CustomerRequestData? _findEditingEnquiry(List<CustomerRequestData> all) {
    if (!_isEdit) {
      return null;
    }
    for (final item in all) {
      if (item.enquiryNumber == widget.enquiryNumber) {
        return item;
      }
    }
    return null;
  }

  void _hydrate(CustomerRequestData source) {
    _requestSource.text = source.requestSource;
    _customerName.text = source.customerName;
    _requestType.text = source.requestType;
    _emailOrReference.text = source.emailOrReference;
    _contact.text = source.contact;
    _cargoType.text = source.cargoType;
    _weightVolume.text = source.weightVolume;
    _pickup.text = source.pickup;
    _delivery.text = source.delivery;
    _notes.text = source.notes;
    _requestDate = DateTime.tryParse(source.requestDate) ?? DateTime.now();
    _hydrated = true;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _requestDate,
    );
    if (selected != null) {
      setState(() => _requestDate = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final payload = CustomerRequestData(
      enquiryNumber: _isEdit ? (widget.enquiryNumber ?? '') : '',
      requestSource: _requestSource.text.trim(),
      customerName: _customerName.text.trim(),
      requestType: _requestType.text.trim(),
      emailOrReference: _emailOrReference.text.trim(),
      contact: _contact.text.trim(),
      cargoType: _cargoType.text.trim(),
      weightVolume: _weightVolume.text.trim(),
      pickup: _pickup.text.trim(),
      delivery: _delivery.text.trim(),
      requestDate: _formatDate(_requestDate),
      notes: _notes.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(logisticsViewModelProvider.notifier);
    final message = _isEdit
        ? notifier.updateEnquiry(payload)
        : notifier.addCustomerRequest(payload);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (message.contains('created.') || message.contains('updated.')) {
      context.go(RoutePaths.customerRequest);
    }
  }

  Widget _row(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
