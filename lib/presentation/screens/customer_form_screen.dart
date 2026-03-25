import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../widgets/ops_shell.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _crController = TextEditingController();
  final _vatinController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'PDO';
  String _selectedCurrency = 'OMR';
  bool _hydrated = false;

  bool get _isEdit => (widget.customerId ?? '').trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _crController.dispose();
    _vatinController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerViewModelProvider);
    final customerViewModel = ref.read(customerViewModelProvider.notifier);

    Customer? existingCustomer;
    if (_isEdit) {
      for (final item in customerState.customers) {
        if (item.id == widget.customerId) {
          existingCustomer = item;
          break;
        }
      }
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

    if (!_hydrated && existingCustomer != null) {
      _nameController.text = existingCustomer.name;
      _addressController.text = existingCustomer.address;
      _emailController.text = existingCustomer.email;
      _phoneController.text = existingCustomer.phoneNumber;
      _crController.text = existingCustomer.crNumber;
      _vatinController.text = existingCustomer.vatinNumber;
      _contactController.text = existingCustomer.contactPerson;
      _selectedCategory = existingCustomer.category;
      _selectedCurrency = existingCustomer.currency;
      _hydrated = true;
    }

    return OpsShell(
      title: _isEdit ? 'Edit Customer' : 'Create Customer',
      currentRoute: RoutePaths.customerManagement,
      actions: const [],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          _isEdit ? 'Edit Customer' : 'Create Customer',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              context.go(RoutePaths.customerManagement),
                          child: const Text('Back to List'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      TextFormField(
                        controller: _crController,
                        decoration: const InputDecoration(
                          labelText: 'CR Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      TextFormField(
                        controller: _vatinController,
                        decoration: const InputDecoration(
                          labelText: 'VATIN Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRow(
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Customer Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: ['PDO', 'NON-PDO']
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency *',
                          border: OutlineInputBorder(),
                        ),
                        items: ['OMR', 'USD', 'EUR', 'AED']
                            .map(
                              (currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCurrency = value);
                          }
                        },
                      ),
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
                          onPressed: () => _submit(
                            context,
                            customerViewModel,
                            existingCustomer,
                          ),
                          icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                          label: Text(
                              _isEdit ? 'Update Customer' : 'Create Customer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
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

  void _submit(
    BuildContext context,
    CustomerViewModel viewModel,
    Customer? existingCustomer,
  ) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customer = Customer(
      id: existingCustomer?.id ??
          'CUST${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      crNumber: _crController.text.trim(),
      vatinNumber: _vatinController.text.trim(),
      currency: _selectedCurrency,
      contactPerson: _contactController.text.trim(),
      category: _selectedCategory,
      createdAt: existingCustomer?.createdAt ?? DateTime.now(),
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
