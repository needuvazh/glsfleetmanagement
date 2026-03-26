import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cargo_model.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestFormScreen extends ConsumerStatefulWidget {
  const CustomerRequestFormScreen({super.key, this.enquiryNumber});

  final String? enquiryNumber;

  @override
  ConsumerState<CustomerRequestFormScreen> createState() =>
      _CustomerRequestFormScreenState();
}

class _CustomerRequestFormScreenState extends ConsumerState<CustomerRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Request Info
  String _requestSource = 'Phone';
  final List<String> _requestSourceOptions = ['EMAIL', 'Direct', 'Phone'];
  String? _selectedCustomerId;
  final _customerName = TextEditingController(); // Fallback if no master
  final _contact = TextEditingController();
  final _emailOrReference = TextEditingController();

  // Transport Requirement
  String? _selectedCargoCode;
  final _cargoType = TextEditingController();
  String _pdoSpec = 'Non-PDO';
  final _pickup = TextEditingController();
  final _delivery = TextEditingController();
  String? _selectedRouteId;
  final _quantity = TextEditingController();
  final _weightVolume = TextEditingController();
  final _dimensions = TextEditingController();
  DateTime? _tentativeDispatchDate;

  // Notes
  final _notes = TextEditingController();

  DateTime _requestDate = DateTime.now();
  bool _hydrated = false;

  bool get _isEdit => (widget.enquiryNumber ?? '').trim().isNotEmpty;

  @override
  void dispose() {
    _customerName.dispose();
    _contact.dispose();
    _emailOrReference.dispose();
    _cargoType.dispose();
    _pickup.dispose();
    _delivery.dispose();
    _quantity.dispose();
    _weightVolume.dispose();
    _dimensions.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final routeData = ref.watch(routeViewModelProvider).valueOrNull;
    final cargoData = ref.watch(cargoViewModelProvider).valueOrNull;
    final customerData = ref.watch(customerViewModelProvider).customers;

    return OpsShell(
      title: _isEdit ? 'Edit Enquiry' : 'Add New Enquiry',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerRequest),
          child: const Text('Cancel / Back'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final selectableCargo = (cargoData?.items ?? const <CargoModel>[])
              .where((item) => item.isSelectable)
              .toList();
          
          final source = _findEditingEnquiry(data.customerRequests);
          if (_isEdit && source == null) {
            return const Center(child: Text('Enquiry not found for edit.'));
          }
          final activeCustomers = customerData.where((c) => c.status == 'Active').toList();

          if (!_hydrated && source != null) {
            _hydrate(source, activeCustomers, routeData?.routes ?? const []);
          }

          CargoModel? selectedCargo;
          if (_selectedCargoCode != null) {
            selectedCargo = ref.read(cargoViewModelProvider.notifier).findByCode(_selectedCargoCode);
          }

          final cargoDropdownItems = <CargoModel>[...selectableCargo];
          if (_isEdit && selectedCargo != null && !cargoDropdownItems.any((entry) => entry.cargoCode == selectedCargo?.cargoCode)) {
            cargoDropdownItems.add(selectedCargo);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Section 1: Basic Request Info
                    OpsSectionCard(
                      title: 'Basic Request Info',
                      subtitle: 'Customer and reference details.',
                      icon: Icons.person_outline,
                      accent: const Color(0xFF0284C7),
                      child: Column(
                        children: [
                          if (_isEdit)
                            _row(
                              TextFormField(
                                initialValue: widget.enquiryNumber,
                                readOnly: true,
                                decoration: const InputDecoration(labelText: 'Enquiry No', filled: true),
                              ),
                              _dateField(
                                label: 'Request Date',
                                date: _requestDate,
                                onSelect: (d) => setState(() => _requestDate = d),
                              ),
                            )
                          else
                            _row(
                              _dateField(
                                label: 'Request Date',
                                date: _requestDate,
                                onSelect: (d) => setState(() => _requestDate = d),
                              ),
                              DropdownButtonFormField<String>(
                                value: _requestSource,
                                decoration: const InputDecoration(labelText: 'Request Source *'),
                                items: _requestSourceOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _requestSource = val);
                                },
                              ),
                            ),
                          const SizedBox(height: 10),
                          _row(
                            DropdownButtonFormField<String?>(
                              value: _selectedCustomerId,
                              decoration: const InputDecoration(labelText: 'Customer *'),
                              validator: (val) => val == null ? 'Required' : null,
                              items: [
                                for (final c in activeCustomers)
                                  DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.shortCode})')),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCustomerId = val;
                                  if (val != null) {
                                    final cust = activeCustomers.firstWhere((c) => c.id == val);
                                    _customerName.text = cust.name;
                                    _contact.text = cust.primaryContactPerson;
                                    if (_emailOrReference.text.isEmpty) _emailOrReference.text = cust.email;
                                  }
                                });
                              },
                            ),
                            TextFormField(
                              controller: _contact,
                              decoration: const InputDecoration(labelText: 'Contact Person'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailOrReference,
                            decoration: const InputDecoration(labelText: 'Reference No / Email'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Transport Requirement
                    OpsSectionCard(
                      title: 'Transport Requirement',
                      subtitle: 'Cargo, route, and volume logic.',
                      icon: Icons.local_shipping_outlined,
                      accent: const Color(0xFF16A34A),
                      child: Column(
                        children: [
                          _row(
                            DropdownButtonFormField<String>(
                              value: _selectedCargoCode,
                              decoration: const InputDecoration(labelText: 'Cargo Type *'),
                              validator: _required,
                              items: [
                                for (final cargo in cargoDropdownItems)
                                  DropdownMenuItem(
                                    value: cargo.cargoCode,
                                    child: Text('${cargo.cargoName} (${cargo.cargoCode})', overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  final selected = ref.read(cargoViewModelProvider.notifier).findByCode(value);
                                  if (selected != null) {
                                    setState(() {
                                      _selectedCargoCode = selected.cargoCode;
                                      _cargoType.text = selected.cargoName;
                                    });
                                  }
                                }
                              },
                            ),
                            DropdownButtonFormField<String>(
                              value: _pdoSpec,
                              decoration: const InputDecoration(labelText: 'PDO / Non-PDO'),
                              items: const [
                                DropdownMenuItem(value: 'Non-PDO', child: Text('Non-PDO')),
                                DropdownMenuItem(value: 'PDO', child: Text('PDO')),
                              ],
                              onChanged: (val) => setState(() => _pdoSpec = val ?? 'Non-PDO'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String?>(
                            value: _selectedRouteId,
                            decoration: const InputDecoration(labelText: 'Route Master *'),
                            validator: (val) => val == null ? 'Required' : null,
                            items: [
                              for (final route in (routeData?.routes ?? const <RouteLocationModel>[]))
                                DropdownMenuItem<String?>(
                                  value: route.routeId,
                                  child: Text('${route.routeCode} • ${route.routeName}'),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedRouteId = value);
                              _applySelectedRoute(value, routeData?.routes ?? const <RouteLocationModel>[]);
                            },
                          ),
                          const SizedBox(height: 10),
                          _row(
                            TextFormField(
                              controller: _pickup,
                              decoration: const InputDecoration(labelText: 'Pickup Location *', filled: true),
                              readOnly: true,
                              validator: _required,
                            ),
                            TextFormField(
                              controller: _delivery,
                              decoration: const InputDecoration(labelText: 'Delivery Location *', filled: true),
                              readOnly: true,
                              validator: _required,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _row(
                            TextFormField(
                              controller: _quantity,
                              decoration: const InputDecoration(labelText: 'Quantity'),
                              validator: (val) => _validateVolumeFields(),
                            ),
                            TextFormField(
                              controller: _weightVolume,
                              decoration: const InputDecoration(labelText: 'Weight / Volume'),
                              validator: (val) => _validateVolumeFields(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _row(
                            TextFormField(
                              controller: _dimensions,
                              decoration: const InputDecoration(labelText: 'Dimensions (LxWxH)'),
                            ),
                            _dateField(
                              label: 'Tentative Dispatch Date',
                              date: _tentativeDispatchDate,
                              onSelect: (d) => setState(() => _tentativeDispatchDate = d),
                              allowNull: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Notes
                    OpsSectionCard(
                      title: 'Notes',
                      subtitle: 'Additional remarks and instructions.',
                      icon: Icons.note_outlined,
                      accent: const Color(0xFFF59E0B),
                      child: TextFormField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Remarks'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.go(RoutePaths.customerRequest),
                          child: const Text('Cancel'),
                        ),
                        OutlinedButton(
                          onPressed: () => _save('Draft'),
                          child: const Text('Save Draft'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _save('Submit'),
                          icon: const Icon(Icons.check),
                          label: const Text('Submit'),
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

  String? _validateVolumeFields() {
    if (_quantity.text.trim().isEmpty && _weightVolume.text.trim().isEmpty && _dimensions.text.trim().isEmpty) {
      return 'At least one size field required';
    }
    return null;
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

  Widget _dateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelect,
    bool allowNull = false,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: date ?? DateTime.now(),
        );
        if (selected != null) onSelect(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.date_range_outlined),
        ),
        child: Text(date != null ? _formatDate(date) : (allowNull ? 'Not set' : '')),
      ),
    );
  }

  CustomerRequestData? _findEditingEnquiry(List<CustomerRequestData> all) {
    if (!_isEdit) return null;
    for (final item in all) {
      if (item.enquiryNumber == widget.enquiryNumber) {
        return item;
      }
    }
    return null;
  }

  void _hydrate(CustomerRequestData source, List<Customer> customers, List<RouteLocationModel> routes) {
    if (_requestSourceOptions.contains(source.requestSource)) {
      _requestSource = source.requestSource;
    } else if (source.requestSource.toUpperCase() == 'EMAIL') {
      _requestSource = 'EMAIL';
    } else if (source.requestSource.toLowerCase() == 'direct') {
      _requestSource = 'Direct';
    } else {
      _requestSource = 'Phone';
    }
    _customerName.text = source.customerName;
    
    // Attempt to match customer name to a master customer ID
    for (var c in customers) {
      if (c.name.toLowerCase() == source.customerName.toLowerCase()) {
        _selectedCustomerId = c.id;
        break;
      }
    }

    _contact.text = source.contact;
    _emailOrReference.text = source.emailOrReference;
    
    _cargoType.text = source.cargoType;
    _selectedCargoCode = ref.read(cargoViewModelProvider.notifier).findByName(source.cargoType)?.cargoCode;
    
    _pdoSpec = source.pdoSpec;
    if (_pdoSpec.isEmpty) _pdoSpec = 'Non-PDO';

    _pickup.text = source.pickup;
    _delivery.text = source.delivery;
    _selectedRouteId = source.routeMasterId.isEmpty ? null : source.routeMasterId;
    if (_selectedRouteId != null && !routes.any((r) => r.routeId == _selectedRouteId)) {
      _selectedRouteId = null;
    }
    
    _quantity.text = source.quantity;
    _weightVolume.text = source.weightVolume;
    _dimensions.text = source.dimensions;
    _tentativeDispatchDate = DateTime.tryParse(source.tentativeDispatchDate);

    _notes.text = source.notes;
    
    _requestDate = DateTime.tryParse(source.requestDate) ?? DateTime.now();
    _hydrated = true;
  }

  void _applySelectedRoute(String? routeId, List<RouteLocationModel> routes) {
    if (routeId == null) {
      // Unlink
      return;
    }
    RouteLocationModel? selected;
    for (final route in routes) {
      if (route.routeId == routeId) {
        selected = route;
        break;
      }
    }
    if (selected != null) {
      _pickup.text = selected.startLocation.locationName;
      _delivery.text = selected.endLocation.locationName;
    }
  }

  void _save(String action) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    RouteLocationModel? selectedRoute;
    final routeList = ref.read(routeViewModelProvider).valueOrNull?.routes ?? const [];
    for (final route in routeList) {
      if (route.routeId == _selectedRouteId) {
        selectedRoute = route;
        break;
      }
    }

    final now = DateTime.now();
    final status = action == 'Submit' ? 'New Enquiry' : 'Draft';

    final payload = CustomerRequestData(
      enquiryNumber: _isEdit ? (widget.enquiryNumber ?? '') : '',
      requestSource: _requestSource,
      customerName: _customerName.text.trim(),
      requestType: 'Transport Request',
      emailOrReference: _emailOrReference.text.trim(),
      contact: _contact.text.trim(),
      cargoType: (_selectedCargoCode == null
              ? _cargoType.text.trim()
              : (ref.read(cargoViewModelProvider.notifier).findByCode(_selectedCargoCode)?.cargoName ?? _cargoType.text.trim()))
          .trim(),
      pdoSpec: _pdoSpec,
      quantity: _quantity.text.trim(),
      weightVolume: _weightVolume.text.trim(),
      dimensions: _dimensions.text.trim(),
      tentativeDispatchDate: _tentativeDispatchDate != null ? _formatDate(_tentativeDispatchDate!) : '',
      pickup: _pickup.text.trim(),
      delivery: _delivery.text.trim(),
      requestDate: _formatDate(_requestDate),
      notes: _notes.text.trim(),
      routeMasterId: selectedRoute?.routeId ?? '',
      routeCode: selectedRoute?.routeCode ?? '',
      routeName: selectedRoute?.routeName ?? '',
      route: selectedRoute == null
          ? '${_pickup.text.trim()} -> ${_delivery.text.trim()}'
          : '${selectedRoute.routeCode} • ${selectedRoute.routeName}',
      routeRiskLevel: selectedRoute?.riskLevel.label ?? 'Low',
      routeOperationalStatus: selectedRoute?.status.label ?? 'Active',
      routeRestricted: selectedRoute != null ? !selectedRoute.isSelectableForNewOperations : false,
      routeRestrictionReason: selectedRoute?.restrictionReason ?? '',
      status: _isEdit ? (_findEditingEnquiry(ref.read(logisticsViewModelProvider).valueOrNull?.customerRequests ?? [])?.status ?? status) : status,
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(logisticsViewModelProvider.notifier);
    final message = _isEdit
        ? notifier.updateEnquiry(payload)
        : notifier.addCustomerRequest(payload);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('created.') || message.contains('updated.')) {
      context.go(RoutePaths.customerRequest);
    }
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}
