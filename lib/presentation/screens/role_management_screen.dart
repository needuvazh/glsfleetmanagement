import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() =>
      _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  final _roleController = TextEditingController();

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessControlProvider);

    return OpsShell(
      title: 'Role Module',
      currentRoute: RoutePaths.roleManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.userManagement),
          child: const Text('Next'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OpsSectionCard(
            title: 'Create Role',
            subtitle: 'Manage role definitions for user assignment',
            icon: Icons.admin_panel_settings_outlined,
            accent: const Color(0xFF2563EB),
            child: Column(
              children: [
                TextField(
                  controller: _roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role Name',
                    hintText: 'Example: Dispatcher',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      final message = ref
                          .read(accessControlProvider.notifier)
                          .addRole(_roleController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      if (message.startsWith('Role created')) {
                        _roleController.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Role'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Available Roles',
            subtitle: 'Default and custom roles visible in User module',
            icon: Icons.badge_outlined,
            accent: const Color(0xFF16A34A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                columns: const [
                  DataColumn(label: Text('Role Name')),
                  DataColumn(label: Text('Type')),
                ],
                rows: [
                  for (final role in state.roles)
                    DataRow(
                      cells: [
                        DataCell(Text(role.name)),
                        DataCell(Text(role.systemRole ? 'System' : 'Custom')),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
