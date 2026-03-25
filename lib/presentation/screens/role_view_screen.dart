import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/role_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/role_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RoleViewScreen extends ConsumerWidget {
  const RoleViewScreen({super.key, required this.roleId});

  final String roleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleViewModelProvider);

    return OpsShell(
      title: 'Role Details',
      currentRoute: RoutePaths.roleManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.roleManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          RoleModel? role;
          for (final item in data.roles) {
            if (item.roleId == roleId) {
              role = item;
              break;
            }
          }

          if (role == null) {
            return const Center(child: Text('Role not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: role.roleName,
                subtitle: 'Read-only role profile',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Role Details'),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _DetailTile(label: 'Role Name', value: role.roleName),
                        _DetailTile(
                          label: 'Description',
                          value: role.description,
                          wide: true,
                        ),
                        _DetailTile(
                          label: 'Status',
                          value: role.status.label,
                          color: role.status == RoleStatusType.active
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Permissions'),
                    _PermissionViewGrid(permissions: role.permissions),
                  ],
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
}

class _PermissionViewGrid extends StatelessWidget {
  const _PermissionViewGrid({required this.permissions});

  final List<RolePermission> permissions;

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
                child: _PermissionViewCard(permission: permission),
              ),
          ],
        );
      },
    );
  }
}

class _PermissionViewCard extends StatelessWidget {
  const _PermissionViewCard({required this.permission});

  final RolePermission permission;

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
              _PermissionPill(
                label: PermissionAction.view.label,
                enabled: permission.canView,
              ),
              _PermissionPill(
                label: PermissionAction.create.label,
                enabled: permission.canCreate,
              ),
              _PermissionPill(
                label: PermissionAction.edit.label,
                enabled: permission.canEdit,
              ),
              _PermissionPill(
                label: PermissionAction.delete.label,
                enabled: permission.canDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionPill extends StatelessWidget {
  const _PermissionPill({
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OpsPill(
      label: '$label: ${enabled ? 'Yes' : 'No'}',
      color: enabled ? const Color(0xFF16A34A) : const Color(0xFF64748B),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 64;
    final width = (wide ? 520.0 : 250.0).clamp(180.0, maxWidth);
    return Container(
      width: width,
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
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
