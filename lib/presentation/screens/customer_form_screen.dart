import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
import '../widgets/module_document_upload_section.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortCodeController = TextEditingController();
  final _primaryContactController = TextEditingController();
  final _alternateContactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Oman');
  final _crController = TextEditingController();
  final _vatinController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _outstandingController = TextEditingController();
  final _paymentDelayController = TextEditingController();
  final _complaintsController = TextEditingController();
  final _slaController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _routeController = TextEditingController();
  final _specialDocumentsController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _restrictedRoutesController = TextEditingController();
  final _safetyRulesController = TextEditingController();
  final _inspectionTypeController = TextEditingController();
  final _blockReasonController = TextEditingController();

  String _selectedCustomerType = 'Corporate';
  String _selectedStatus = 'Active';
  String _selectedSegment = 'NON-PDO';
  String _selectedPaymentTerms = 'Net 30';
  String _selectedPaymentMode = 'Credit';
  String _selectedInvoiceCycle = 'Per Trip';
  String _selectedCurrency = 'OMR';
  String _selectedPriority = 'Normal';
  bool _podRequired = false;
  bool _dnRequired = false;
  bool _hasOverdue = false;
  bool _isBlocked = false;
  bool _hardBlock = true;
  bool _hydrated = false;
  String? _selectedPreferredVehicleType;
  String? _selectedPreferredRoute;

  bool get _isEdit => (widget.customerId ?? '').trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _shortCodeController.dispose();
    _primaryContactController.dispose();
    _alternateContactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _crController.dispose();
    _vatinController.dispose();
    _creditLimitController.dispose();
    _outstandingController.dispose();
    _paymentDelayController.dispose();
    _complaintsController.dispose();
    _slaController.dispose();
    _vehicleTypeController.dispose();
    _routeController.dispose();
    _specialDocumentsController.dispose();
    _certificationsController.dispose();
    _restrictedRoutesController.dispose();
    _safetyRulesController.dispose();
    _inspectionTypeController.dispose();
    _blockReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerViewModelProvider);
    final vehicleTypeState = ref.watch(vehicleTypeViewModelProvider).valueOrNull;
    final routeState = ref.watch(routeViewModelProvider).valueOrNull;
    final customerViewModel = ref.read(customerViewModelProvider.notifier);
    final preferredVehicleTypes = vehicleTypeState == null
        ? <String>[]
        : vehicleTypeState.items
            .where((item) => item.status.toLowerCase() == 'active')
            .map((item) => item.name.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList();
    preferredVehicleTypes.sort();
    final preferredRoutes = routeState == null
        ? <String>[]
        : routeState.routes
            .map((item) => '${item.routeCode} - ${item.routeName}'.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList();
    preferredRoutes.sort();

    Customer? existingCustomer;
    if (_isEdit) {
      for (final item in customerState.customers) {
        if (item.id == widget.customerId) {
          existingCustomer = item;
          break;
        }
      }
    }

    if (!_hydrated && existingCustomer != null) {
      _hydrate(existingCustomer);
    }

    if (customerState.isLoading) {
      return OpsShell(
        title: _isEdit ? 'Edit Customer' : 'Create Customer',
        currentRoute: RoutePaths.customerManagement,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEdit && existingCustomer == null) {
      return OpsShell(
        title: 'Edit Customer',
        currentRoute: RoutePaths.customerManagement,
        child: const Center(child: Text('Customer not found for edit.')),
      );
    }

    return OpsShell(
      title: _isEdit ? 'Edit Customer' : 'Create Customer',
      currentRoute: RoutePaths.customerManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _identitySection(),
                const SizedBox(height: 12),
                _contactSection(),
                const SizedBox(height: 12),
                _financialSection(),
                const SizedBox(height: 12),
                _operationalSection(preferredVehicleTypes, preferredRoutes),
                const SizedBox(height: 12),
                _complianceSection(),
                const SizedBox(height: 12),
                _controlSection(),
                const SizedBox(height: 12),
                const ModuleDocumentUploadSection(
                  moduleName: 'Customer',
                  title: 'Customer Document Uploads',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          context.go(RoutePaths.customerManagement),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () =>
                          _submit(context, customerViewModel, existingCustomer),
                      icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                      label:
                          Text(_isEdit ? 'Update Customer' : 'Create Customer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _identitySection() {
    return OpsSectionCard(
      title: 'Identity',
      subtitle: 'Business identity and ownership of this account',
      icon: Icons.badge_outlined,
      accent: const Color(0xFF2563EB),
      child: Column(
        children: [
          _buildRow(
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer Name *'),
              validator: _required,
            ),
            TextFormField(
              controller: _shortCodeController,
              decoration: const InputDecoration(labelText: 'Short Code *'),
              validator: _required,
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            DropdownButtonFormField<String>(
              value: _selectedCustomerType,
              decoration: const InputDecoration(labelText: 'Customer Type *'),
              items: const ['Corporate', 'Individual']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCustomerType = value);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status *'),
              items: const ['Active', 'Inactive']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            DropdownButtonFormField<String>(
              value: _selectedSegment,
              decoration:
                  const InputDecoration(labelText: 'Compliance Segment *'),
              items: const ['PDO', 'NON-PDO']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSegment = value);
                }
              },
            ),
            const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _contactSection() {
    return OpsSectionCard(
      title: 'Contact',
      subtitle: 'Primary and alternate communication channels',
      icon: Icons.contact_phone_outlined,
      accent: const Color(0xFF0891B2),
      child: Column(
        children: [
          _buildRow(
            TextFormField(
              controller: _primaryContactController,
              decoration:
                  const InputDecoration(labelText: 'Primary Contact Person *'),
              validator: _required,
            ),
            TextFormField(
              controller: _alternateContactController,
              decoration: const InputDecoration(labelText: 'Alternate Contact'),
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number *'),
              validator: _required,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: _validateEmail,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address *'),
            maxLines: 2,
            validator: _required,
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City *'),
              validator: _required,
            ),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country *'),
              validator: _required,
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _crController,
              decoration: const InputDecoration(labelText: 'CR Number *'),
              validator: _required,
            ),
            TextFormField(
              controller: _vatinController,
              decoration: const InputDecoration(labelText: 'VATIN Number *'),
              validator: _required,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialSection() {
    return OpsSectionCard(
      title: 'Financial',
      subtitle: 'Credit policy, invoice model, and payment behavior',
      icon: Icons.account_balance_wallet_outlined,
      accent: const Color(0xFFF59E0B),
      child: Column(
        children: [
          _buildRow(
            DropdownButtonFormField<String>(
              value: _selectedPaymentTerms,
              decoration: const InputDecoration(labelText: 'Payment Terms *'),
              items: const ['Advance', 'Net 15', 'Net 30', 'Net 60']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentTerms = value);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode *'),
              items: const ['Cash', 'Bank Transfer', 'Credit']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentMode = value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            DropdownButtonFormField<String>(
              value: _selectedInvoiceCycle,
              decoration: const InputDecoration(labelText: 'Invoice Cycle *'),
              items: const ['Per Trip', 'Weekly', 'Monthly']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedInvoiceCycle = value);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(labelText: 'Currency *'),
              items: const ['OMR', 'USD', 'EUR', 'AED']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _creditLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credit Limit *'),
              validator: _validateNumber,
            ),
            TextFormField(
              controller: _outstandingController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Current Outstanding'),
              validator: _validateNumberOptional,
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _paymentDelayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Avg Payment Delay (days)',
              ),
              validator: _validateNumberOptional,
            ),
            TextFormField(
              controller: _complaintsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Complaints Count'),
              validator: _validateNumberOptional,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Overdue invoices present'),
            value: _hasOverdue,
            onChanged: (value) => setState(() => _hasOverdue = value),
          ),
        ],
      ),
    );
  }

  Widget _operationalSection(
    List<String> preferredVehicleTypes,
    List<String> preferredRoutes,
  ) {
    final vehicleOptions = <String>[
      ...preferredVehicleTypes,
      if ((_selectedPreferredVehicleType ?? '').trim().isNotEmpty &&
          !preferredVehicleTypes.contains(_selectedPreferredVehicleType))
        _selectedPreferredVehicleType!,
    ];
    final routeOptions = <String>[
      ...preferredRoutes,
      if ((_selectedPreferredRoute ?? '').trim().isNotEmpty &&
          !preferredRoutes.contains(_selectedPreferredRoute))
        _selectedPreferredRoute!,
    ];

    return OpsSectionCard(
      title: 'Operational Rules',
      subtitle: 'Execution constraints for work order and trip closure',
      icon: Icons.rule_folder_outlined,
      accent: const Color(0xFF7C3AED),
      child: Column(
        children: [
          _buildRow(
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('POD Required'),
              value: _podRequired,
              onChanged: (value) => setState(() => _podRequired = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('DN Required'),
              value: _dnRequired,
              onChanged: (value) => setState(() => _dnRequired = value),
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            TextFormField(
              controller: _slaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'SLA Hours'),
              validator: _validateNumberOptional,
            ),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority Level *'),
              items: const ['Normal', 'High', 'Critical']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            DropdownButtonFormField<String?>(
              value: _selectedPreferredVehicleType,
              decoration: const InputDecoration(
                labelText: 'Preferred Vehicle Type (Master)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None'),
                ),
                for (final item in vehicleOptions)
                  DropdownMenuItem<String?>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPreferredVehicleType = value;
                  _vehicleTypeController.text = value ?? '';
                });
              },
            ),
            DropdownButtonFormField<String?>(
              value: _selectedPreferredRoute,
              decoration: const InputDecoration(
                labelText: 'Preferred Route (Master)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None'),
                ),
                for (final item in routeOptions)
                  DropdownMenuItem<String?>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPreferredRoute = value;
                  _routeController.text = value ?? '';
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _specialDocumentsController,
            decoration: const InputDecoration(
              labelText: 'Special Documents (comma-separated)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _complianceSection() {
    return OpsSectionCard(
      title: 'Compliance',
      subtitle: 'Certifications, route restrictions, and safety obligations',
      icon: Icons.verified_user_outlined,
      accent: const Color(0xFFDC2626),
      child: Column(
        children: [
          TextFormField(
            controller: _certificationsController,
            decoration: const InputDecoration(
              labelText: 'Special Certifications (comma-separated)',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _restrictedRoutesController,
            decoration: const InputDecoration(
              labelText: 'Restricted Routes (comma-separated)',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _safetyRulesController,
            decoration: const InputDecoration(
              labelText: 'Safety Rules (comma-separated)',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _inspectionTypeController,
            decoration: const InputDecoration(labelText: 'Inspection Type'),
          ),
        ],
      ),
    );
  }

  Widget _controlSection() {
    return OpsSectionCard(
      title: 'Status & Control',
      subtitle: 'Blocking policy and governance controls',
      icon: Icons.lock_person_outlined,
      accent: const Color(0xFF1D4ED8),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Blocked Customer'),
            value: _isBlocked,
            onChanged: (value) => setState(() => _isBlocked = value),
          ),
          if (_isBlocked)
            _buildRow(
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hard Block (disallow WO)'),
                value: _hardBlock,
                onChanged: (value) => setState(() => _hardBlock = value),
              ),
              TextFormField(
                controller: _blockReasonController,
                decoration: const InputDecoration(labelText: 'Block Reason *'),
                validator: (value) {
                  if (!_isBlocked) {
                    return null;
                  }
                  return _required(value);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          left,
          const SizedBox(height: 10),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  void _hydrate(Customer customer) {
    _nameController.text = customer.name;
    _shortCodeController.text = customer.shortCode;
    _primaryContactController.text = customer.primaryContactPerson;
    _alternateContactController.text = customer.alternateContact;
    _emailController.text = customer.email;
    _phoneController.text = customer.phoneNumber;
    _addressController.text = customer.billingAddress;
    _cityController.text = customer.city;
    _countryController.text = customer.country;
    _crController.text = customer.crNumber;
    _vatinController.text = customer.vatinNumber;
    _creditLimitController.text = customer.creditLimit.toStringAsFixed(0);
    _outstandingController.text = customer.outstandingAmount.toStringAsFixed(0);
    _paymentDelayController.text = customer.averagePaymentDelayDays.toString();
    _complaintsController.text = customer.complaintsCount.toString();
    _slaController.text = customer.slaHours.toString();
    _vehicleTypeController.text = customer.preferredVehicleType;
    _routeController.text = customer.preferredRoute;
    _selectedPreferredVehicleType =
        customer.preferredVehicleType.trim().isEmpty
            ? null
            : customer.preferredVehicleType.trim();
    _selectedPreferredRoute = customer.preferredRoute.trim().isEmpty
        ? null
        : customer.preferredRoute.trim();
    _specialDocumentsController.text =
        customer.specialDocumentsRequired.join(', ');
    _certificationsController.text =
        customer.specialCertificationsRequired.join(', ');
    _restrictedRoutesController.text = customer.restrictedRoutes.join(', ');
    _safetyRulesController.text = customer.safetyRules.join(', ');
    _inspectionTypeController.text = customer.mandatoryInspectionType;
    _blockReasonController.text = customer.blockReason;

    _selectedCustomerType = customer.customerType;
    _selectedStatus = customer.status;
    _selectedSegment = customer.segment;
    _selectedPaymentTerms = customer.paymentTerms;
    _selectedPaymentMode = customer.paymentMode;
    _selectedInvoiceCycle = customer.invoiceCycle;
    _selectedCurrency = customer.currency;
    _selectedPriority = customer.priorityLevel;
    _podRequired = customer.podRequired;
    _dnRequired = customer.dnRequired;
    _hasOverdue = customer.hasOverduePayments;
    _isBlocked = customer.isBlocked;
    _hardBlock = customer.hardBlock;
    _hydrated = true;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Invalid number';
    }
    return null;
  }

  String? _validateNumberOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Invalid number';
    }
    return null;
  }

  double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;
  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  List<String> _csvToList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int _computeRiskScore({
    required double creditLimit,
    required double outstanding,
    required int paymentDelay,
    required int complaints,
    required bool hasOverdue,
    required bool blocked,
  }) {
    var score = 0;
    if (creditLimit > 0) {
      final usagePercent = (outstanding / creditLimit) * 100;
      if (usagePercent >= 100) {
        score += 45;
      } else if (usagePercent >= 85) {
        score += 25;
      } else if (usagePercent >= 60) {
        score += 15;
      }
    }
    if (paymentDelay >= 30) {
      score += 30;
    } else if (paymentDelay >= 15) {
      score += 18;
    } else if (paymentDelay >= 5) {
      score += 10;
    }
    score += (complaints * 4).clamp(0, 20);
    if (hasOverdue) {
      score += 20;
    }
    if (blocked) {
      score += 10;
    }
    return score.clamp(0, 100);
  }

  String _deriveShortCode(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'CUS';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length < 3 ? parts.first.length : 3)
          .toUpperCase();
    }
    return parts.take(3).map((item) => item[0]).join().toUpperCase();
  }

  void _submit(
    BuildContext context,
    CustomerViewModel viewModel,
    Customer? existingCustomer,
  ) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final resolvedShortCode = _shortCodeController.text.trim().isEmpty
        ? _deriveShortCode(_nameController.text)
        : _shortCodeController.text.trim().toUpperCase();
    final creditLimit = _toDouble(_creditLimitController.text);
    final outstanding = _toDouble(_outstandingController.text);
    final paymentDelay = _toInt(_paymentDelayController.text);
    final complaints = _toInt(_complaintsController.text);
    final riskScore = _computeRiskScore(
      creditLimit: creditLimit,
      outstanding: outstanding,
      paymentDelay: paymentDelay,
      complaints: complaints,
      hasOverdue: _hasOverdue,
      blocked: _isBlocked,
    );

    final customer = Customer(
      id: existingCustomer?.id ??
          'CUST${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      shortCode: resolvedShortCode,
      customerType: _selectedCustomerType,
      status: _selectedStatus,
      segment: _selectedSegment,
      isBlocked: _isBlocked,
      hardBlock: _hardBlock,
      blockReason: _isBlocked ? _blockReasonController.text.trim() : '',
      billingAddress: _addressController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      alternateContact: _alternateContactController.text.trim(),
      crNumber: _crController.text.trim(),
      vatinNumber: _vatinController.text.trim(),
      currency: _selectedCurrency,
      primaryContactPerson: _primaryContactController.text.trim(),
      paymentTerms: _selectedPaymentTerms,
      creditLimit: creditLimit,
      outstandingAmount: outstanding,
      hasOverduePayments: _hasOverdue,
      paymentMode: _selectedPaymentMode,
      invoiceCycle: _selectedInvoiceCycle,
      averagePaymentDelayDays: paymentDelay,
      complaintsCount: complaints,
      riskScore: riskScore,
      podRequired: _podRequired,
      dnRequired: _dnRequired,
      specialDocumentsRequired: _csvToList(_specialDocumentsController.text),
      slaHours: _toInt(_slaController.text),
      preferredVehicleType: _vehicleTypeController.text.trim(),
      preferredRoute: _routeController.text.trim(),
      priorityLevel: _selectedPriority,
      specialCertificationsRequired: _csvToList(_certificationsController.text),
      restrictedRoutes: _csvToList(_restrictedRoutesController.text),
      safetyRules: _csvToList(_safetyRulesController.text),
      mandatoryInspectionType: _inspectionTypeController.text.trim(),
      activeWorkOrders: existingCustomer?.activeWorkOrders ?? 0,
      pendingInvoices: existingCustomer?.pendingInvoices ?? 0,
      overdueInvoices: existingCustomer?.overdueInvoices ?? 0,
      createdBy: existingCustomer?.createdBy ?? 'system',
      createdAt: existingCustomer?.createdAt ?? DateTime.now(),
      updatedBy: 'system',
      updatedAt: DateTime.now(),
    );

    if (_isEdit) {
      viewModel.updateCustomer(customer);
    } else {
      viewModel.addCustomer(customer);
    }

    context.go(RoutePaths.customerManagement);
  }
}
