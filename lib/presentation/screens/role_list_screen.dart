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
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final roles = data.filteredRoles;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Role Search',
                  subtitle: 'Search and manage roles from one place',
                  icon: Icons.search_outlined,
                  accent: const Color(0xFF2563EB),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText: 'Search by role name',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(roleViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () => context.go(RoutePaths.roleForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Role'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: data.searchQuery,
                                decoration: const InputDecoration(
                                  labelText: 'Search by role name',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: ref
                                    .read(roleViewModelProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () => context.go(RoutePaths.roleForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Role'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Role List',
                    subtitle:
                        'Enterprise role definitions with status and permissions',
                    icon: Icons.admin_panel_settings_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: roles.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('No roles found.'),
                          )
                        : (isMobile
                            ? _MobileRoleList(roles: roles)
                            : _DesktopRoleTable(roles: roles)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DesktopRoleTable extends StatefulWidget {
  const _DesktopRoleTable({required this.roles});

  final List<RoleModel> roles;

  @override
  State<_DesktopRoleTable> createState() => _DesktopRoleTableState();
}

class _DesktopRoleTableState extends State<_DesktopRoleTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _horizontalController,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                horizontalMargin: 14,
                columnSpacing: 20,
                dataRowMinHeight: 62,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('Role Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final role in widget.roles)
                    DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              role.roleName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
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
                          SizedBox(
                            width: 168,
                            child: Row(
                              children: [
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context
                                      .go(RoutePaths.roleViewById(role.roleId)),
                                  child: const Text('View'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context.go(
                                      '${RoutePaths.roleForm}?id=${role.roleId}'),
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileRoleList extends StatelessWidget {
  const _MobileRoleList({required this.roles});

  final List<RoleModel> roles;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
