import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key, this.editUserId});

  final String? editUserId;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(userViewModelProvider);
    final formState = ref.watch(userFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit User' : 'Create User',
      currentRoute: RoutePaths.userManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.userManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          UserModel? editUser;
          if (widget.editUserId != null) {
            for (final user in data.users) {
              if (user.userId == widget.editUserId) {
                editUser = user;
                break;
              }
            }
          }

          if (widget.editUserId != null && editUser == null) {
            return const Center(child: Text('User not found.'));
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref.read(userFormProvider.notifier).initialize(editUser),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(userFormProvider);
          final notifier = ref.read(userFormProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode ? 'Update User Details' : 'Create User',
                subtitle:
                    'Work information stays fixed. Personal and contact sections adapt to the selected role.',
                icon: Icons.person_add_alt_1_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Form(
                  key: _formKey,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (form.isEditMode) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OpsPill(
                                label: 'User ID: ${form.originalUserId}',
                                color: const Color(0xFF2563EB),
                              ),
                              OpsPill(
                                label: form.status.label,
                                color: form.status == UserStatusType.active
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        _sectionTitle(context, 'Work Information'),
                        _ResponsiveUserGrid(
                          items: [
                            _UserGridItem(
                              child: SearchableSelectionField<UserRoleType>(
                                key: const ValueKey('role'),
                                label: 'Role',
                                value: form.selectedRole,
                                items: UserRoleType.values,
                                itemLabel: (item) => item.label,
                                onSelected: notifier.setRole,
                                validator: (value) =>
                                    value == null ? 'Required' : null,
                              ),
                            ),
                            _UserGridItem(
                              child: SearchableSelectionField<DepartmentType>(
                                key: const ValueKey('department'),
                                label: 'Department',
                                value: form.department,
                                items: DepartmentType.values,
                                itemLabel: (item) => item.label,
                                onSelected: notifier.setDepartment,
                                validator: (value) =>
                                    value == null ? 'Required' : null,
                              ),
                            ),
                            _UserGridItem(
                              child: _UserTextField(
                                key: const ValueKey('employeeId'),
                                label: 'Employee ID',
                                initialValue: form.employeeId,
                                onChanged: notifier.setEmployeeId,
                                validator: _required,
                              ),
                            ),
                            _UserGridItem(
                              child: _DatePickerField(
                                fieldId: 'joiningDate',
                                label: 'Joining Date',
                                value: form.joiningDate,
                                onTap: () => _pickDate(
                                  context: context,
                                  initialDate: form.joiningDate,
                                  onSelected: notifier.setJoiningDate,
                                ),
                                validator: (value) =>
                                    value == null ? 'Required' : null,
                              ),
                            ),
                            _UserGridItem(
                              child: DropdownButtonFormField<UserStatusType>(
                                key: const ValueKey('status'),
                                initialValue: form.status,
                                decoration:
                                    const InputDecoration(labelText: 'Status'),
                                items: [
                                  for (final item in UserStatusType.values)
                                    DropdownMenuItem(
                                      value: item,
                                      child: Text(item.label),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.setStatus(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle(context, 'Authentication'),
                        _ResponsiveUserGrid(
                          items: _buildAuthenticationItems(form, notifier),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: KeyedSubtree(
                            key: ValueKey(form.selectedRole),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(context, 'Personal Information'),
                                _ResponsiveUserGrid(
                                  items:
                                      _buildPersonalInfoItems(form, notifier),
                                ),
                                const SizedBox(height: 20),
                                _sectionTitle(context, 'Contact Information'),
                                _ResponsiveUserGrid(
                                  items: _buildContactInfoItems(form, notifier),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  context.go(RoutePaths.userManagement),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _submit,
                              child: Text(form.isEditMode ? 'Update' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_UserGridItem> _buildPersonalInfoItems(
    UserFormState form,
    UserFormNotifier notifier,
  ) {
    final items = <_UserGridItem>[
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('firstName'),
          label: 'First Name',
          initialValue: form.firstName,
          onChanged: notifier.setFirstName,
          validator: _required,
        ),
      ),
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('lastName'),
          label: 'Last Name',
          initialValue: form.lastName,
          onChanged: notifier.setLastName,
          validator: _required,
        ),
      ),
    ];

    if (form.selectedRole == UserRoleType.driver) {
      items.addAll([
        _UserGridItem(
          child: _UserTextField(
            key: const ValueKey('licenseNumber'),
            label: 'License Number',
            initialValue: form.licenseNumber,
            onChanged: notifier.setLicenseNumber,
            validator: _required,
          ),
        ),
        _UserGridItem(
          child: _DatePickerField(
            fieldId: 'licenseExpiry',
            label: 'License Expiry Date',
            value: form.licenseExpiryDate,
            onTap: () => _pickDate(
              context: context,
              initialDate: form.licenseExpiryDate,
              onSelected: notifier.setLicenseExpiryDate,
            ),
            validator: (value) => value == null ? 'Required' : null,
          ),
        ),
      ]);
    }

    return items;
  }

  List<_UserGridItem> _buildAuthenticationItems(
    UserFormState form,
    UserFormNotifier notifier,
  ) {
    return [
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('username'),
          label: 'Username',
          initialValue: form.username,
          onChanged: notifier.setUsername,
          validator: _usernameValidator,
        ),
      ),
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('password'),
          label: form.isEditMode ? 'Password' : 'Temporary Password',
          initialValue: form.password,
          onChanged: notifier.setPassword,
          validator: (value) =>
              _passwordValidator(value, required: !form.isEditMode),
          obscureText: true,
        ),
      ),
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('confirmPassword'),
          label: form.isEditMode ? 'Confirm Password' : 'Confirm Password',
          initialValue: form.confirmPassword,
          onChanged: notifier.setConfirmPassword,
          validator: (value) => _confirmPasswordValidator(
            value,
            password: form.password,
            required: !form.isEditMode || form.password.trim().isNotEmpty,
          ),
          obscureText: true,
        ),
      ),
    ];
  }

  List<_UserGridItem> _buildContactInfoItems(
    UserFormState form,
    UserFormNotifier notifier,
  ) {
    final items = <_UserGridItem>[
      _UserGridItem(
        child: SearchableSelectionField<CountryCodeType>(
          key: const ValueKey('countryCode'),
          label: 'Country Code',
          value: form.countryCode,
          items: CountryCodeType.values,
          itemLabel: (item) => item.label,
          onSelected: notifier.setCountryCode,
          validator: (value) => value == null ? 'Required' : null,
        ),
      ),
      _UserGridItem(
        child: _UserTextField(
          key: const ValueKey('phoneNumber'),
          label: 'Phone Number',
          initialValue: form.phoneNumber,
          onChanged: notifier.setPhoneNumber,
          keyboardType: TextInputType.phone,
          validator: _phoneValidator,
        ),
      ),
    ];

    switch (form.selectedRole) {
      case UserRoleType.admin:
        items.addAll([
          _UserGridItem(
            child: _UserTextField(
              key: const ValueKey('email'),
              label: 'Email',
              initialValue: form.email,
              onChanged: notifier.setEmail,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
          ),
          _UserGridItem(
            span: 2,
            child: _UserTextField(
              key: const ValueKey('address'),
              label: 'Address',
              initialValue: form.address,
              onChanged: notifier.setAddress,
              maxLines: 2,
              validator: _required,
            ),
          ),
        ]);
        break;
      case UserRoleType.driver:
        items.add(
          _UserGridItem(
            child: _UserTextField(
              key: const ValueKey('alternateNumber'),
              label: 'Alternate Number',
              initialValue: form.alternateNumber,
              onChanged: notifier.setAlternateNumber,
              keyboardType: TextInputType.phone,
              validator: (value) => _phoneValidator(value, optional: true),
            ),
          ),
        );
        break;
      case UserRoleType.dispatcher:
        items.add(
          _UserGridItem(
            child: _UserTextField(
              key: const ValueKey('email'),
              label: 'Email',
              initialValue: form.email,
              onChanged: notifier.setEmail,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
          ),
        );
        break;
    }

    return items;
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _usernameValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]{3,30}$').hasMatch(raw)) {
      return '3-30 letters, numbers, . _ or -';
    }
    return null;
  }

  String? _passwordValidator(String? value, {required bool required}) {
    final raw = value?.trim() ?? '';
    if (!required && raw.isEmpty) {
      return null;
    }
    if (raw.isEmpty) {
      return 'Required';
    }
    if (raw.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(
    String? value, {
    required String password,
    required bool required,
  }) {
    final raw = value?.trim() ?? '';
    if (!required && raw.isEmpty) {
      return null;
    }
    if (raw.isEmpty) {
      return 'Required';
    }
    if (raw != password.trim()) {
      return 'Passwords do not match';
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

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
      initialDate: initialDate ?? now,
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(userFormProvider);
    if (form.joiningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joining date is required.')),
      );
      return;
    }

    final user = form.toUserModel();
    final viewModel = ref.read(userViewModelProvider.notifier);
    final message = form.isEditMode
        ? await viewModel.updateUser(user)
        : await viewModel.addUser(user);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.userManagement);
    }
  }
}

class _ResponsiveUserGrid extends StatelessWidget {
  const _ResponsiveUserGrid({required this.items});

  final List<_UserGridItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = constraints.maxWidth;
        final columns = width >= 1120 ? 3 : (width >= 720 ? 2 : 1);
        final baseWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: _itemWidth(
                  baseWidth: baseWidth,
                  spacing: spacing,
                  columns: columns,
                  span: columns == 1 ? 1 : item.span,
                ),
                child: item.child,
              ),
          ],
        );
      },
    );
  }

  double _itemWidth({
    required double baseWidth,
    required double spacing,
    required int columns,
    required int span,
  }) {
    final safeSpan = span.clamp(1, columns).toDouble();
    return (baseWidth * safeSpan) + (spacing * (safeSpan - 1));
  }
}

class _UserGridItem {
  const _UserGridItem({
    required this.child,
    this.span = 1,
  });

  final Widget child;
  final int span;
}

class _UserTextField extends StatelessWidget {
  const _UserTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.fieldId,
    required this.label,
    required this.value,
    required this.onTap,
    this.validator,
  });

  final String fieldId;
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? Function(DateTime? value)? validator;

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null ? '' : _formatDate(value!);
    return TextFormField(
      key: ValueKey('$fieldId-$displayValue'),
      initialValue: displayValue,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      validator: (_) => validator?.call(value),
      onTap: onTap,
    );
  }
}

class SearchableSelectionField<T> extends StatefulWidget {
  const SearchableSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.validator,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;
  final String? Function(T? value)? validator;

  @override
  State<SearchableSelectionField<T>> createState() =>
      _SearchableSelectionFieldState<T>();
}

class _SearchableSelectionFieldState<T>
    extends State<SearchableSelectionField<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.value;
    _controller = TextEditingController(
      text: initialValue == null ? '' : widget.itemLabel(initialValue),
    );
  }

  @override
  void didUpdateWidget(covariant SearchableSelectionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.value;
    final nextText = nextValue == null ? '' : widget.itemLabel(nextValue);
    if (_controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      validator: (_) => widget.validator?.call(widget.value),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.search),
      ),
      onTap: () async {
        final selected = await showDialog<T>(
          context: context,
          builder: (context) => _SearchSelectionDialog<T>(
            title: widget.label,
            items: widget.items,
            itemLabel: widget.itemLabel,
          ),
        );

        if (selected == null) {
          return;
        }

        widget.onSelected(selected);
      },
    );
  }
}

class _SearchSelectionDialog<T> extends StatefulWidget {
  const _SearchSelectionDialog({
    required this.title,
    required this.items,
    required this.itemLabel,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;

  @override
  State<_SearchSelectionDialog<T>> createState() =>
      _SearchSelectionDialogState<T>();
}

class _SearchSelectionDialogState<T> extends State<_SearchSelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items.where((item) {
      final text = widget.itemLabel(item).toLowerCase();
      return text.contains(_query.trim().toLowerCase());
    }).toList();

    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: math.min(MediaQuery.sizeOf(context).width - 32, 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: items.isEmpty
                  ? const Center(child: Text('No matching options'))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(widget.itemLabel(item)),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
