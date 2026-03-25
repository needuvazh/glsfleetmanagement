import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/role_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/role_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  const RoleFormScreen({super.key, this.editRoleId});

  final String? editRoleId;

  @override
  ConsumerState<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(roleViewModelProvider);
    final formState = ref.watch(roleFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Role' : 'Create Role',
      currentRoute: RoutePaths.roleManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.roleManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          RoleModel? editRole;
          if (widget.editRoleId != null) {
            for (final role in data.roles) {
              if (role.roleId == widget.editRoleId) {
                editRole = role;
                break;
              }
            }
          }

          if (widget.editRoleId != null && editRole == null) {
            return const Center(child: Text('Role not found.'));
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref.read(roleFormProvider.notifier).initialize(editRole),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(roleFormProvider);
          final notifier = ref.read(roleFormProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode ? 'Update Role' : 'Create Role',
                subtitle:
                    'Define role details and module-level permissions in one responsive form.',
                icon: Icons.security_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.isEditMode) ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OpsPill(
                              label: 'Role ID: ${form.originalRoleId}',
                              color: const Color(0xFF2563EB),
                            ),
                            OpsPill(
                              label: form.status.label,
                              color: form.status == RoleStatusType.active
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      _sectionTitle(context, 'Role Details'),
                      _ResponsiveRoleGrid(
                        items: [
                          _RoleGridItem(
                            child: _RoleTextField(
                              key: const ValueKey('roleName'),
                              label: 'Role Name',
                              initialValue: form.roleName,
                              onChanged: notifier.setRoleName,
                              validator: _required,
                            ),
                          ),
                          _RoleGridItem(
                            child: DropdownButtonFormField<RoleStatusType>(
                              key: const ValueKey('roleStatus'),
                              initialValue: form.status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: [
                                for (final item in RoleStatusType.values)
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
                          _RoleGridItem(
                            span: 2,
                            child: _RoleTextField(
                              key: const ValueKey('roleDescription'),
                              label: 'Description',
                              initialValue: form.description,
                              onChanged: notifier.setDescription,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(context, 'Permissions'),
                      _PermissionModuleGrid(
                        permissions: form.permissions,
                        onToggle: notifier.togglePermission,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () =>
                                context.go(RoutePaths.roleManagement),
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
            ],
          );
        },
      ),
    );
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(roleFormProvider);
    final role = form.toRoleModel();
    final viewModel = ref.read(roleViewModelProvider.notifier);
    final message = form.isEditMode
        ? await viewModel.updateRole(role)
        : await viewModel.addRole(role);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.roleManagement);
    }
  }
}

class _ResponsiveRoleGrid extends StatelessWidget {
  const _ResponsiveRoleGrid({required this.items});

  final List<_RoleGridItem> items;

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

class _RoleGridItem {
  const _RoleGridItem({
    required this.child,
    this.span = 1,
  });

  final Widget child;
  final int span;
}

class _RoleTextField extends StatelessWidget {
  const _RoleTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _PermissionModuleGrid extends StatelessWidget {
  const _PermissionModuleGrid({
    required this.permissions,
    required this.onToggle,
  });

  final List<RolePermission> permissions;
  final void Function(
    RoleModuleType module,
    PermissionAction action,
    bool enabled,
  ) onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = constraints.maxWidth;
        final columns = width >= 1120 ? 3 : (width >= 720 ? 2 : 1);
        final cardWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final permission in permissions)
              SizedBox(
                width: cardWidth,
                child: _PermissionCard(
                  permission: permission,
                  onToggle: onToggle,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.permission,
    required this.onToggle,
  });

  final RolePermission permission;
  final void Function(
    RoleModuleType module,
    PermissionAction action,
    bool enabled,
  ) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            permission.module.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PermissionCheck(
                label: PermissionAction.view.label,
                value: permission.canView,
                onChanged: (value) => onToggle(
                  permission.module,
                  PermissionAction.view,
                  value,
                ),
              ),
              _PermissionCheck(
                label: PermissionAction.create.label,
                value: permission.canCreate,
                onChanged: (value) => onToggle(
                  permission.module,
                  PermissionAction.create,
                  value,
                ),
              ),
              _PermissionCheck(
                label: PermissionAction.edit.label,
                value: permission.canEdit,
                onChanged: (value) => onToggle(
                  permission.module,
                  PermissionAction.edit,
                  value,
                ),
              ),
              _PermissionCheck(
                label: PermissionAction.delete.label,
                value: permission.canDelete,
                onChanged: (value) => onToggle(
                  permission.module,
                  PermissionAction.delete,
                  value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionCheck extends StatelessWidget {
  const _PermissionCheck({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }
}
