import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      child: customerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go(RoutePaths.customerForm),
                        icon: const Icon(Icons.add),
                        label: const Text('Create New'),
                      ),
                    ],
                  ),
                ),
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
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  ['All', 'PDO', 'NON-PDO'].map((category) {
                                final isSelected =
                                    _selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(
                                          () => _selectedCategory = category);
                                    },
                                    backgroundColor: Colors.grey[200],
                                    selectedColor:
                                        primaryColor.withOpacity(0.3),
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
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                              label: Text('Customer ID')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Category')),
                                          DataColumn(
                                              label: Text('Contact Person')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Phone')),
                                          DataColumn(label: Text('Currency')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: [
                                          for (final customer
                                              in filteredCustomers)
                                            DataRow(cells: [
                                              DataCell(Text(customer.id)),
                                              DataCell(Text(customer.name)),
                                              DataCell(Text(customer.category)),
                                              DataCell(
                                                  Text(customer.contactPerson)),
                                              DataCell(Text(customer.email)),
                                              DataCell(
                                                  Text(customer.phoneNumber)),
                                              DataCell(Text(customer.currency)),
                                              DataCell(
                                                Wrap(
                                                  spacing: 4,
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed: () =>
                                                          context.go(
                                                        RoutePaths
                                                            .customerViewById(
                                                                customer.id),
                                                      ),
                                                      icon: const Icon(Icons
                                                          .visibility_outlined),
                                                      label: const Text('View'),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () =>
                                                          context.go(
                                                        RoutePaths
                                                            .editCustomerById(
                                                                customer.id),
                                                      ),
                                                      icon: const Icon(
                                                          Icons.edit_outlined),
                                                      label: const Text('Edit'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return _CustomerCard(
                                  customer: customer,
                                  onEdit: () => context.go(
                                    RoutePaths.editCustomerById(customer.id),
                                  ),
                                  onDelete: () => _showDeleteConfirmation(
                                    context,
                                    customer,
                                    customerViewModel,
                                  ),
                                  onView: () => context.go(
                                      RoutePaths.customerViewById(customer.id)),
                                );
                              },
                            ),
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
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onView,
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
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
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
