import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/role_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/role_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RoleListScreen extends ConsumerWidget {
  const RoleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Role Module',
      currentRoute: RoutePaths.roleManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.roleForm),
          child: const Text('Create Role'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final roles = data.filteredRoles;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search Roles',
                subtitle: 'Search by role name',
                icon: Icons.search_outlined,
                accent: const Color(0xFF2563EB),
                child: TextFormField(
                  initialValue: data.searchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search by role name',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged:
                      ref.read(roleViewModelProvider.notifier).setSearchQuery,
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'Role List',
                subtitle:
                    'Enterprise role definitions with status and permissions',
                icon: Icons.admin_panel_settings_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.roleForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Role'),
                ),
                child: roles.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('No roles found.'),
                      )
                    : (isMobile
                        ? _MobileRoleList(roles: roles)
                        : _DesktopRoleTable(roles: roles)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopRoleTable extends StatelessWidget {
  const _DesktopRoleTable({required this.roles});

  final List<RoleModel> roles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
        columns: const [
          DataColumn(label: Text('Role Name')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final role in roles)
            DataRow(
              cells: [
                DataCell(Text(role.roleName)),
                DataCell(
                  SizedBox(
                    width: 320,
                    child: Text(
                      role.description.isEmpty ? '-' : role.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  OpsPill(
                    label: role.status.label,
                    color: role.status == RoleStatusType.active
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.go(RoutePaths.roleViewById(role.roleId)),
                        child: const Text('View'),
                      ),
                      TextButton(
                        onPressed: () => context
                            .go('${RoutePaths.roleForm}?id=${role.roleId}'),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileRoleList extends StatelessWidget {
  const _MobileRoleList({required this.roles});

  final List<RoleModel> roles;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final role = roles[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFDCE6F7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role.roleName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(role.description.isEmpty ? '-' : role.description),
              const SizedBox(height: 8),
              OpsPill(
                label: role.status.label,
                color: role.status == RoleStatusType.active
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go(RoutePaths.roleViewById(role.roleId)),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        context.go('${RoutePaths.roleForm}?id=${role.roleId}'),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
