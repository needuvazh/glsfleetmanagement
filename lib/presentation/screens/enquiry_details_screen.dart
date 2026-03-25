import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class EnquiryDetailsScreen extends ConsumerStatefulWidget {
  const EnquiryDetailsScreen({super.key});

  @override
  ConsumerState<EnquiryDetailsScreen> createState() =>
      _EnquiryDetailsScreenState();
}

class _EnquiryDetailsScreenState extends ConsumerState<EnquiryDetailsScreen> {
  CustomerRequestData? _selected;

  final _cargoType = TextEditingController();
  final _pickup = TextEditingController();
  final _route = TextEditingController();
  final _destination = TextEditingController();
  final _quantity = TextEditingController();
  final _dimensions = TextEditingController();
  final _weightVolume = TextEditingController();
  final _customerRequirement = TextEditingController();
  final _requiredVehicleType = TextEditingController();
  final _tentativeDispatchDate = TextEditingController();

  bool _hazardous = false;
  bool _routeRiskFlag = false;
  String _pdoSpec = 'Non-PDO';

  @override
  void dispose() {
    _cargoType.dispose();
    _pickup.dispose();
    _route.dispose();
    _destination.dispose();
    _quantity.dispose();
    _dimensions.dispose();
    _weightVolume.dispose();
    _customerRequirement.dispose();
    _requiredVehicleType.dispose();
    _tentativeDispatchDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Gather Key Details',
      currentRoute: RoutePaths.enquiryDetails,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerRequest),
          child: const Text('Back to Enquiry'),
        ),
        TextButton(
          onPressed: () => context.go(RoutePaths.feasibilityQuotation),
          child: const Text('Go to Feasibility'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final active = data.customerRequests
              .where((item) => item.status != 'Cancelled')
              .toList();

          if (_selected == null && active.isNotEmpty) {
            _load(active.first);
          } else if (_selected != null) {
            final fresh = active
                .where((item) => item.enquiryNumber == _selected!.enquiryNumber)
                .toList();
            if (fresh.isNotEmpty) {
              _selected = fresh.first;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 1),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Enquiry Selection',
                subtitle:
                    'Choose enquiry and collect full transport requirement.',
                icon: Icons.playlist_add_check_circle_outlined,
                accent: const Color(0xFF0284C7),
                child: active.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('No active enquiries found.'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Enquiry No')),
                            DataColumn(label: Text('Customer')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: [
                            for (final enquiry in active)
                              DataRow(cells: [
                                DataCell(Text(enquiry.enquiryNumber)),
                                DataCell(Text(enquiry.customerName)),
                                DataCell(Text(enquiry.status)),
                                DataCell(
                                  OutlinedButton(
                                    onPressed: () =>
                                        setState(() => _load(enquiry)),
                                    child: const Text('Open'),
                                  ),
                                ),
                              ]),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Transport Requirement Details',
                subtitle:
                    'Capture cargo, route, quantities, dimensions, risk and requirement data.',
                icon: Icons.fact_check_outlined,
                accent: const Color(0xFF16A34A),
                child: _selected == null
                    ? const Text('Select an enquiry first.')
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Enquiry: ${_selected!.enquiryNumber}  |  Customer: ${_selected!.customerName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _cargoType,
                            decoration: const InputDecoration(
                                labelText: 'Cargo Type *'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _hazardous
                                      ? 'Hazardous'
                                      : 'Non-Hazardous',
                                  decoration: const InputDecoration(
                                    labelText: 'Hazardous / Non-Hazardous',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Non-Hazardous',
                                      child: Text('Non-Hazardous'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Hazardous',
                                      child: Text('Hazardous'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() =>
                                        _hazardous = value == 'Hazardous');
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _pdoSpec,
                                  decoration: const InputDecoration(
                                    labelText: 'PDO / Non-PDO',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'PDO', child: Text('PDO')),
                                    DropdownMenuItem(
                                      value: 'Non-PDO',
                                      child: Text('Non-PDO'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _pdoSpec = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_hazardous)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                border:
                                    Border.all(color: const Color(0xFFF59E0B)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Hazardous load selected: compliance flag will be enabled.',
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pickup,
                                  decoration: const InputDecoration(
                                    labelText: 'Pickup Location *',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _destination,
                                  decoration: const InputDecoration(
                                      labelText: 'Destination *'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _route,
                            decoration:
                                const InputDecoration(labelText: 'Route'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _quantity,
                                  decoration: const InputDecoration(
                                      labelText: 'Quantity'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _dimensions,
                                  decoration: const InputDecoration(
                                      labelText: 'Dimensions'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _weightVolume,
                            decoration: const InputDecoration(
                                labelText: 'Weight / Volume'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _customerRequirement,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Customer Specific Requirement',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _requiredVehicleType,
                            decoration: const InputDecoration(
                              labelText: 'Required Vehicle Type',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _tentativeDispatchDate,
                            decoration: const InputDecoration(
                              labelText: 'Tentative Dispatch Date (YYYY-MM-DD)',
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            value: _routeRiskFlag,
                            onChanged: (value) {
                              setState(() => _routeRiskFlag = value ?? false);
                            },
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Route Risk Flag'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Key Details'),
                            ),
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

  void _load(CustomerRequestData enquiry) {
    _selected = enquiry;
    _cargoType.text = enquiry.cargoType;
    _pickup.text = enquiry.pickup;
    _route.text = enquiry.route.isEmpty
        ? '${enquiry.pickup} -> ${enquiry.delivery}'
        : enquiry.route;
    _destination.text = enquiry.delivery;
    _quantity.text = enquiry.quantity;
    _dimensions.text = enquiry.dimensions;
    _weightVolume.text = enquiry.weightVolume;
    _customerRequirement.text = enquiry.customerSpecificRequirement;
    _requiredVehicleType.text = enquiry.requiredVehicleType;
    _tentativeDispatchDate.text = enquiry.tentativeDispatchDate;
    _hazardous = enquiry.hazardous;
    _routeRiskFlag = enquiry.routeRiskFlag;
    _pdoSpec = enquiry.pdoSpec.isEmpty ? 'Non-PDO' : enquiry.pdoSpec;
  }

  void _save() {
    if (_selected == null) {
      return;
    }
    final message =
        ref.read(logisticsViewModelProvider.notifier).gatherEnquiryKeyDetails(
              enquiryNumber: _selected!.enquiryNumber,
              cargoType: _cargoType.text,
              hazardous: _hazardous,
              pdoSpec: _pdoSpec,
              pickup: _pickup.text,
              route: _route.text,
              destination: _destination.text,
              quantity: _quantity.text,
              dimensions: _dimensions.text,
              weightVolume: _weightVolume.text,
              customerSpecificRequirement: _customerRequirement.text,
              requiredVehicleType: _requiredVehicleType.text,
              tentativeDispatchDate: _tentativeDispatchDate.text,
              routeRiskFlag: _routeRiskFlag,
            );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('ready for feasibility and costing')) {
      context.go(RoutePaths.feasibilityQuotation);
    }
  }
}
