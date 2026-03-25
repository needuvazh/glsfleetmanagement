import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../widgets/ops_shell.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final customerState = ref.watch(customerViewModelProvider);
    final customerViewModel = ref.read(customerViewModelProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    var filteredCustomers = customerState.customers
        .where((cust) =>
            cust.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cust.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cust.contactPerson
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();

    if (_selectedCategory != 'All') {
      filteredCustomers = filteredCustomers
          .where((cust) => cust.category == _selectedCategory)
          .toList();
    }

    return OpsShell(
      title: 'Customer Management',
      currentRoute: RoutePaths.customerManagement,
      actions: [
        FilledButton.icon(
          onPressed: () =>
              _showCustomerDialog(context, null, customerViewModel),
          icon: const Icon(Icons.add),
          label: const Text('Create New'),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search customers...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'PDO', 'NON-PDO'].map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = category);
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: primaryColor.withOpacity(0.3),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : isDesktop
                    ? Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Customer ID')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Category')),
                              DataColumn(label: Text('Contact Person')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Currency')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: [
                              for (final customer in filteredCustomers)
                                DataRow(cells: [
                                  DataCell(Text(customer.id)),
                                  DataCell(Text(customer.name)),
                                  DataCell(Text(customer.category)),
                                  DataCell(Text(customer.contactPerson)),
                                  DataCell(Text(customer.email)),
                                  DataCell(Text(customer.phoneNumber)),
                                  DataCell(Text(customer.currency)),
                                  DataCell(
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _showCustomerDetails(
                                            context,
                                            customer,
                                          ),
                                          icon: const Icon(
                                              Icons.visibility_outlined),
                                          label: const Text('View'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _showCustomerDialog(
                                            context,
                                            customer,
                                            customerViewModel,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                          label: const Text('Edit'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _CustomerCard(
                            customer: customer,
                            onEdit: () => _showCustomerDialog(
                              context,
                              customer,
                              customerViewModel,
                            ),
                            onDelete: () => _showDeleteConfirmation(
                              context,
                              customer,
                              customerViewModel,
                            ),
                            onViewDetails: () =>
                                _showCustomerDetails(context, customer),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog(
      BuildContext context, Customer? customer, CustomerViewModel viewModel) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final addressController =
        TextEditingController(text: customer?.address ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController =
        TextEditingController(text: customer?.phoneNumber ?? '');
    final crController = TextEditingController(text: customer?.crNumber ?? '');
    final vatinController =
        TextEditingController(text: customer?.vatinNumber ?? '');
    final contactController =
        TextEditingController(text: customer?.contactPerson ?? '');
    String selectedCategory = customer?.category ?? 'PDO';
    String selectedCurrency = customer?.currency ?? 'OMR';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: crController,
                decoration: const InputDecoration(
                  labelText: 'CR Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vatinController,
                decoration: const InputDecoration(
                  labelText: 'VATIN Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Customer Category',
                  border: OutlineInputBorder(),
                ),
                items: ['PDO', 'NON-PDO'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: ['OMR', 'USD', 'EUR', 'AED'].map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedCurrency = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCustomer = Customer(
                id: customer?.id ??
                    'CUST${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                address: addressController.text,
                email: emailController.text,
                phoneNumber: phoneController.text,
                crNumber: crController.text,
                vatinNumber: vatinController.text,
                currency: selectedCurrency,
                contactPerson: contactController.text,
                category: selectedCategory,
                createdAt: customer?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (customer == null) {
                viewModel.addCustomer(newCustomer);
              } else {
                viewModel.updateCustomer(newCustomer);
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Customer customer, CustomerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.deleteCustomer(customer.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CustomerDetailsSheet(customer: customer),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          customer.contactPerson,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: customer.category == 'PDO'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer.category,
                      style: TextStyle(
                        color: customer.category == 'PDO'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    customer.phoneNumber,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerDetailsSheet extends StatelessWidget {
  final Customer customer;

  const _CustomerDetailsSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              customer.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _DetailRow('Category', customer.category),
            _DetailRow('Contact Person', customer.contactPerson),
            _DetailRow('Email', customer.email),
            _DetailRow('Phone', customer.phoneNumber),
            _DetailRow('Address', customer.address),
            _DetailRow('CR Number', customer.crNumber),
            _DetailRow('VATIN Number', customer.vatinNumber),
            _DetailRow('Currency', customer.currency),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
