import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');

  static const _countryCodes = ['+968', '+971', '+973', '+974', '+965', '+91'];
  static const _licenseTypes = ['LMV', 'HMV', 'MCWG', 'Transport', 'Other'];
  static const _employmentStatuses = ['Active', 'On Leave', 'Inactive'];

  String? _selectedCountryCode;
  String? _selectedLicenseType;
  String? _selectedEmploymentStatus;
  String? _selectedRole;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _driverNameController.dispose();
    _phoneNumberController.dispose();
    _alternateNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryDateController.dispose();
    _joiningDateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessControlProvider);
    final documentState = ref.watch(moduleDocumentViewModelProvider);

    if (_selectedRole == null && state.roles.isNotEmpty) {
      _selectedRole = state.roles.first.name;
    }
    _selectedCountryCode ??= _countryCodes.first;
    _selectedLicenseType ??= _licenseTypes.first;
    _selectedEmploymentStatus ??= _employmentStatuses.first;

    final roleStillExists =
        state.roles.any((item) => item.name == _selectedRole);
    if (!roleStillExists && state.roles.isNotEmpty) {
      _selectedRole = state.roles.first.name;
    }

    return OpsShell(
      title: 'User Module',
      currentRoute: RoutePaths.userManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.transportManagement),
          child: const Text('Vehicle Master Module'),
        ),
        TextButton(
          onPressed: () => context.go(RoutePaths.documentManagement),
          child: const Text('Document Module'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OpsSectionCard(
            title: 'Create User',
            subtitle: 'All roles are available in role dropdown',
            icon: Icons.person_add_alt_1_outlined,
            accent: const Color(0xFF0EA5E9),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Personal Info'),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(labelText: 'Driver Name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCountryCode,
                          decoration:
                              const InputDecoration(labelText: 'Country Code'),
                          items: [
                            for (final code in _countryCodes)
                              DropdownMenuItem(
                                value: code,
                                child: Text(code),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedCountryCode = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          validator: (value) => _phoneValidator(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _alternateNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Alternate Number (Optional)'),
                    validator: (value) =>
                        _phoneValidator(value, optional: true),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  _sectionTitle(context, 'License Info'),
                  TextFormField(
                    controller: _licenseNumberController,
                    decoration:
                        const InputDecoration(labelText: 'License Number'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLicenseType,
                    decoration:
                        const InputDecoration(labelText: 'License Type'),
                    items: [
                      for (final type in _licenseTypes)
                        DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedLicenseType = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select license type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _dateField(
                    context: context,
                    controller: _licenseExpiryDateController,
                    label: 'License Expiry Date',
                  ),
                  const SizedBox(height: 10),
                  _sectionTitle(context, 'Work Info'),
                  _dateField(
                    context: context,
                    controller: _joiningDateController,
                    label: 'Joining Date',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Experience (Years)'),
                    validator: _experienceValidator,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEmploymentStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final status in _employmentStatuses)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedEmploymentStatus = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: [
                      for (final role in state.roles)
                        DropdownMenuItem(
                          value: role.name,
                          child: Text(role.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRole = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select a role';
                      }
                      return null;
                    },
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
                            .read(accessControlProvider.notifier)
                            .addUser(
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              driverName: _driverNameController.text,
                              countryCode: _selectedCountryCode ?? '',
                              phoneNumber: _phoneNumberController.text,
                              alternateNumber: _alternateNumberController.text,
                              email: _emailController.text,
                              address: _addressController.text,
                              licenseNumber: _licenseNumberController.text,
                              licenseType: _selectedLicenseType ?? '',
                              licenseExpiryDate:
                                  _licenseExpiryDateController.text,
                              joiningDate: _joiningDateController.text,
                              experienceYears:
                                  int.parse(_experienceController.text.trim()),
                              status: _selectedEmploymentStatus ?? '',
                              role: _selectedRole ?? '',
                            );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));

                        if (message.startsWith('User created')) {
                          _firstNameController.clear();
                          _lastNameController.clear();
                          _driverNameController.clear();
                          _phoneNumberController.clear();
                          _alternateNumberController.clear();
                          _emailController.clear();
                          _addressController.clear();
                          _licenseNumberController.clear();
                          _licenseExpiryDateController.clear();
                          _joiningDateController.clear();
                          _experienceController.text = '0';
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create User'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Users',
            subtitle: 'User list with personal, license and work info',
            icon: Icons.group_outlined,
            accent: const Color(0xFF2563EB),
            child: state.users.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('No users created yet.'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                      columns: const [
                        DataColumn(label: Text('User ID')),
                        DataColumn(label: Text('Driver Name')),
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Alternate Number')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('License Number')),
                        DataColumn(label: Text('License Type')),
                        DataColumn(label: Text('License Expiry Date')),
                        DataColumn(label: Text('Joining Date')),
                        DataColumn(label: Text('Experience (Yrs)')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Role')),
                      ],
                      rows: [
                        for (final user in state.users)
                          DataRow(
                            cells: [
                              DataCell(Text(user.userId)),
                              DataCell(Text(user.driverName)),
                              DataCell(Text(user.firstName)),
                              DataCell(Text(user.lastName)),
                              DataCell(Text(user.fullMobile)),
                              DataCell(Text(user.fullAlternateMobile)),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.address)),
                              DataCell(Text(user.licenseNumber)),
                              DataCell(Text(user.licenseType)),
                              DataCell(Text(user.licenseExpiryDate)),
                              DataCell(Text(user.joiningDate)),
                              DataCell(Text('${user.experienceYears}')),
                              DataCell(Text(user.status)),
                              DataCell(Text(user.role)),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'User Documents',
            subtitle: 'Documents tagged for User module (Driver license/photo)',
            icon: Icons.folder_open_outlined,
            accent: const Color(0xFF16A34A),
            child: documentState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(error.toString()),
              data: (docData) {
                final userDocs = docData.documentsForRole('Driver');
                if (userDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No user documents created yet.'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Document Name')),
                      DataColumn(label: Text('Document Type')),
                      DataColumn(label: Text('User Role')),
                    ],
                    rows: [
                      for (final item in userDocs)
                        DataRow(
                          cells: [
                            DataCell(Text(item.id)),
                            DataCell(Text(item.documentName)),
                            DataCell(Text(item.documentType)),
                            DataCell(Text(item.targetType)),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _phoneValidator(String? value, {bool optional = false}) {
    final raw = value?.trim() ?? '';
    if (optional && raw.isEmpty) {
      return null;
    }
    if (raw.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(raw)) {
      return '7-15 digits required';
    }
    return null;
  }

  String? _experienceValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Required';
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0 || parsed > 60) {
      return '0-60 years only';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(raw)) {
      return 'Invalid email';
    }
    return null;
  }

  Widget _dateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.date_range_outlined),
      ),
      onTap: () => _pickDate(context, controller),
      validator: _required,
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 20),
      initialDate: now,
    );
    if (picked == null) {
      return;
    }
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    controller.text = '${picked.year}-$month-$day';
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
