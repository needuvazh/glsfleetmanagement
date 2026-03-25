import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/vendor_model.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FeasibilityQuotationScreen extends ConsumerStatefulWidget {
  const FeasibilityQuotationScreen({super.key});

  @override
  ConsumerState<FeasibilityQuotationScreen> createState() =>
      _FeasibilityQuotationScreenState();
}

class _FeasibilityQuotationScreenState
    extends ConsumerState<FeasibilityQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _quoteRef = TextEditingController();
  final _salesPerson = TextEditingController();
  final _customer = TextEditingController();
  final _customerContact = TextEditingController();
  final _workDescription = TextEditingController();
  final _noOfTrips = TextEditingController(text: '1');
  final _kilometer = TextEditingController(text: '100');
  final _rate = TextEditingController(text: '1');
  final _customerRate = TextEditingController(text: '500');
  VendorServiceType _selectedServiceType = VendorServiceType.pdo;
  String? _selectedVendorId;
  bool _managerOverride = false;

  int? _selectedRequestIndex;
  bool _quoteRefManuallyEdited = false;
  bool _isProgrammaticQuoteRefUpdate = false;

  @override
  void initState() {
    super.initState();
    _date.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _date.dispose();
    _quoteRef.dispose();
    _salesPerson.dispose();
    _customer.dispose();
    _customerContact.dispose();
    _workDescription.dispose();
    _noOfTrips.dispose();
    _kilometer.dispose();
    _rate.dispose();
    _customerRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final vendorState = ref.watch(vendorViewModelProvider);

    return OpsShell(
      title: 'Feasibility & Quotation',
      currentRoute: RoutePaths.feasibilityQuotation,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.workOrderFlow),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          _syncQuoteRef(data.quotations);
          final activeVendors = vendorState.valueOrNull?.vendors
                  .where(
                    (vendor) =>
                        vendor.status == VendorStatus.active &&
                        vendor.serviceType == _selectedServiceType,
                  )
                  .toList() ??
              const [];
          if (_selectedVendorId != null &&
              !activeVendors.any((vendor) => vendor.vendorId == _selectedVendorId)) {
            _selectedVendorId = null;
          }

          final amount = _currentAmount;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 0),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Create Quotation',
                subtitle:
                    'Fill quotation details: SlNo, DATE, QUOTE REF, SALES PERSON, CUSTOMER, CUSTOMER CONTACT, WORK DESCRIPTION, NO OF TRIPS, Kilometer, RATE, AMOUNT',
                icon: Icons.price_check_outlined,
                accent: const Color(0xFF16A34A),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedRequestIndex,
                        decoration: const InputDecoration(
                          labelText: 'Auto-populate from Customer Request',
                        ),
                        items: [
                          for (int i = 0; i < data.customerRequests.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child:
                                  Text(data.customerRequests[i].customerName),
                            ),
                        ],
                        onChanged: (index) {
                          if (index == null) {
                            return;
                          }
                          setState(() {
                            _selectedRequestIndex = index;
                            _applyRequest(
                              data.customerRequests[index],
                              quotations: data.quotations,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customerRate,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Customer Rate (for feasibility)',
                        ),
                        validator: _positiveDouble,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<VendorServiceType>(
                        value: _selectedServiceType,
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                        ),
                        items: [
                          for (final item in VendorServiceType.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedServiceType = value;
                            _selectedVendorId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedVendorId,
                        decoration: const InputDecoration(
                          labelText: 'Suggested Active Vendor',
                        ),
                        items: [
                          for (final vendor in activeVendors)
                            DropdownMenuItem(
                              value: vendor.vendorId,
                              child: Text('${vendor.vendorName} (${vendor.contactNumber})'),
                            ),
                        ],
                        onChanged: activeVendors.isEmpty
                            ? null
                            : (value) => setState(() => _selectedVendorId = value),
                      ),
                      if (activeVendors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No active vendors available for selected service type.',
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _managerOverride,
                        onChanged: (value) {
                          setState(() => _managerOverride = value ?? false);
                          ref
                              .read(logisticsViewModelProvider.notifier)
                              .setManagerOverride(_managerOverride);
                        },
                        title: const Text('Manager Override'),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: _selectedRequestIndex == null
                              ? null
                              : () {
                                  final request =
                                      data.customerRequests[_selectedRequestIndex!];
                                  final message = ref
                                      .read(logisticsViewModelProvider.notifier)
                                      .runFeasibilityCheck(
                                        request: request,
                                        customerRate:
                                            double.tryParse(_customerRate.text.trim()) ?? 0,
                                        managerOverride: _managerOverride,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                },
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('Run Feasibility Check'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: data.isFeasible || data.managerOverride
                              ? const Color(0xFFEAF7EF)
                              : const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: data.isFeasible || data.managerOverride
                                ? const Color(0xFFBBF7D0)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Text(
                          'Available Vehicles: ${data.availableVehicleCount}\n'
                          'Available Drivers: ${data.availableDriverCount}\n'
                          'Estimated Travel Time: ${data.estimatedTravelHours.toStringAsFixed(1)} hrs\n'
                          'Night Driving Required: ${data.nightDrivingRequired ? 'Yes' : 'No'}\n'
                          'Fuel Cost: ${data.fuelCost.toStringAsFixed(2)}\n'
                          'Driver Cost: ${data.driverCost.toStringAsFixed(2)}\n'
                          'Vendor Cost: ${data.vendorCost.toStringAsFixed(2)}\n'
                          'Total Cost: ${data.totalCost.toStringAsFixed(2)}\n'
                          'Profit: ${data.profit.toStringAsFixed(2)}\n'
                          'Decision: ${(data.isFeasible || data.managerOverride) ? 'Feasible' : 'Not Feasible'}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _date,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'DATE',
                          suffixIcon: Icon(Icons.date_range_outlined),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _date.text = _formatDate(picked);
                              _syncQuoteRef(data.quotations);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _quoteRef,
                        decoration:
                            const InputDecoration(labelText: 'QUOTE REF'),
                        validator: _required,
                        onChanged: (_) {
                          if (_isProgrammaticQuoteRefUpdate) {
                            return;
                          }
                          _quoteRefManuallyEdited = true;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _salesPerson,
                        decoration:
                            const InputDecoration(labelText: 'SALES PERSON'),
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customer,
                        decoration:
                            const InputDecoration(labelText: 'CUSTOMER'),
                        validator: _required,
                        onChanged: (_) {
                          setState(() {
                            _syncQuoteRef(data.quotations);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customerContact,
                        decoration: const InputDecoration(
                            labelText: 'CUSTOMER CONTACT'),
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _workDescription,
                        decoration: const InputDecoration(
                            labelText: 'WORK DESCRIPTION'),
                        validator: _required,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _noOfTrips,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'NO OF TRIPS'),
                              validator: _positiveInt,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _kilometer,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration:
                                  const InputDecoration(labelText: 'Kilometer'),
                              validator: _positiveDouble,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _rate,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration:
                                  const InputDecoration(labelText: 'RATE'),
                              validator: _positiveDouble,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'AMOUNT: ${amount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            final message = ref
                                .read(logisticsViewModelProvider.notifier)
                                .addQuotation(
                                  date: _date.text.trim(),
                                  quoteRef: _quoteRef.text.trim(),
                                  salesPerson: _salesPerson.text.trim(),
                                  customer: _customer.text.trim(),
                                  customerContact: _customerContact.text.trim(),
                                  workDescription: _workDescription.text.trim(),
                                  noOfTrips: int.parse(_noOfTrips.text.trim()),
                                  kilometer:
                                      double.parse(_kilometer.text.trim()),
                                  rate: double.parse(_rate.text.trim()),
                                );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(message)));

                            if (message.startsWith('Quotation created')) {
                              _quoteRefManuallyEdited = false;
                              _syncQuoteRef(
                                data.quotations,
                                nextOffset: 2,
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Quotation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Quotations',
                subtitle: 'Approve quotations and download quotation copy',
                icon: Icons.description_outlined,
                accent: const Color(0xFF0EA5E9),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                    columns: const [
                      DataColumn(label: Text('SlNo')),
                      DataColumn(label: Text('DATE')),
                      DataColumn(label: Text('QUOTE REF')),
                      DataColumn(label: Text('SALES PERSON')),
                      DataColumn(label: Text('CUSTOMER')),
                      DataColumn(label: Text('CUSTOMER CONTACT')),
                      DataColumn(label: Text('WORK DESCRIPTION')),
                      DataColumn(label: Text('NO OF TRIPS')),
                      DataColumn(label: Text('Kilometer')),
                      DataColumn(label: Text('RATE')),
                      DataColumn(label: Text('AMOUNT')),
                      DataColumn(label: Text('Approval')),
                      DataColumn(label: Text('Download')),
                    ],
                    rows: [
                      for (final quotation in data.quotations)
                        DataRow(
                          cells: [
                            DataCell(Text('${quotation.slNo}')),
                            DataCell(Text(quotation.date)),
                            DataCell(Text(quotation.quoteRef)),
                            DataCell(Text(quotation.salesPerson)),
                            DataCell(Text(quotation.customer)),
                            DataCell(Text(quotation.customerContact)),
                            DataCell(SizedBox(
                              width: 220,
                              child: Text(
                                quotation.workDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(Text('${quotation.noOfTrips}')),
                            DataCell(
                                Text(quotation.kilometer.toStringAsFixed(2))),
                            DataCell(Text(quotation.rate.toStringAsFixed(2))),
                            DataCell(Text(quotation.amount.toStringAsFixed(2))),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  ref
                                      .read(logisticsViewModelProvider.notifier)
                                      .setQuoteStatus(quotation.quoteRef, value);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'Pending',
                                    child: Text('Pending'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Approved',
                                    child: Text('Approved'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Rejected',
                                    child: Text('Rejected'),
                                  ),
                                ],
                                child: Chip(
                                  label: Text(
                                    data.quoteStatusByRef[quotation.quoteRef] ??
                                        'Pending',
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _downloadQuotation(quotation),
                                    icon: const Icon(Icons.download_outlined),
                                    tooltip: 'Download quotation',
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Quotation ${quotation.quoteRef} sent to customer (mock)',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Send'),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter valid number';
    }
    return null;
  }

  String? _positiveDouble(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter valid number';
    }
    return null;
  }

  double get _currentAmount {
    final trips = int.tryParse(_noOfTrips.text.trim()) ?? 0;
    final kilometer = double.tryParse(_kilometer.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ?? 0;
    return trips * kilometer * rate;
  }

  void _applyRequest(
    CustomerRequestData request, {
    required List<QuotationData> quotations,
  }) {
    _selectedServiceType = _inferServiceType(request.cargoType);
    _selectedVendorId = null;
    _customer.text = request.customerName;
    _customerContact.text = request.contact;
    _workDescription.text =
        '${request.cargoType} - ${request.pickup} to ${request.delivery}';
    _date.text = request.date;
    _quoteRefManuallyEdited = false;
    _syncQuoteRef(quotations);
  }

  void _syncQuoteRef(List<QuotationData> quotations, {int nextOffset = 1}) {
    if (_quoteRefManuallyEdited) {
      return;
    }
    _isProgrammaticQuoteRefUpdate = true;
    _quoteRef.text = _buildQuoteRef(
      quotations,
      customer: _customer.text,
      date: _date.text,
      nextOffset: nextOffset,
    );
    _isProgrammaticQuoteRefUpdate = false;
  }

  String _buildQuoteRef(
    List<QuotationData> quotations, {
    required String customer,
    required String date,
    int nextOffset = 1,
  }) {
    final cleanName =
        customer.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final customerCode = (cleanName.isEmpty
        ? 'GEN'
        : cleanName.substring(0, cleanName.length > 4 ? 4 : cleanName.length));
    final dateCode = date.replaceAll('-', '');
    final base =
        'QTN-$customerCode-${dateCode.isEmpty ? _formatDate(DateTime.now()).replaceAll('-', '') : dateCode}';
    int samePrefixCount = 0;
    for (final item in quotations) {
      if (item.quoteRef.startsWith('$base-')) {
        samePrefixCount++;
      }
    }
    final sequence = (samePrefixCount + nextOffset).toString().padLeft(3, '0');
    return '$base-$sequence';
  }

  VendorServiceType _inferServiceType(String input) {
    final normalized = input.toLowerCase();
    if (normalized.contains('pdo')) {
      return VendorServiceType.pdo;
    }
    return VendorServiceType.nonPdo;
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _downloadQuotation(QuotationData quotation) async {
    final content = StringBuffer()
      ..writeln('QUOTATION')
      ..writeln('SlNo: ${quotation.slNo}')
      ..writeln('DATE: ${quotation.date}')
      ..writeln('QUOTE REF: ${quotation.quoteRef}')
      ..writeln('SALES PERSON: ${quotation.salesPerson}')
      ..writeln('CUSTOMER: ${quotation.customer}')
      ..writeln('CUSTOMER CONTACT: ${quotation.customerContact}')
      ..writeln('WORK DESCRIPTION: ${quotation.workDescription}')
      ..writeln('NO OF TRIPS: ${quotation.noOfTrips}')
      ..writeln('Kilometer: ${quotation.kilometer.toStringAsFixed(2)}')
      ..writeln('RATE: ${quotation.rate.toStringAsFixed(2)}')
      ..writeln('AMOUNT: ${quotation.amount.toStringAsFixed(2)}');

    try {
      await FileSaver.instance.saveFile(
        name: quotation.quoteRef,
        bytes: Uint8List.fromList(utf8.encode(content.toString())),
        fileExtension: 'txt',
        mimeType: MimeType.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${quotation.quoteRef}.txt')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to download ${quotation.quoteRef}')),
      );
    }
  }
}
