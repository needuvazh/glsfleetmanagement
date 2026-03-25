import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/user_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'User Module',
      currentRoute: RoutePaths.userManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.userForm),
          child: const Text('Create User'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final users = data.filteredUsers;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search Users',
                subtitle: 'Filter by first name, last name, or phone number',
                icon: Icons.search_outlined,
                accent: const Color(0xFF2563EB),
                child: TextFormField(
                  initialValue: data.searchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search by name / phone',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged:
                      ref.read(userViewModelProvider.notifier).setSearchQuery,
                ),
              ),
              const SizedBox(height: 16),
              OpsSectionCard(
                title: 'User List',
                subtitle: 'Enterprise user directory with list-first workflow',
                icon: Icons.manage_accounts_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.userForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Create User'),
                ),
                child: users.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('No users found.'),
                      )
                    : (isMobile
                        ? _MobileUserList(users: users)
                        : _DesktopUserTable(users: users)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopUserTable extends StatelessWidget {
  const _DesktopUserTable({required this.users});

  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
        columns: const [
          DataColumn(label: Text('First Name')),
          DataColumn(label: Text('Last Name')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final user in users)
            DataRow(
              cells: [
                DataCell(Text(user.firstName)),
                DataCell(Text(user.lastName)),
                DataCell(Text(user.role.label)),
                DataCell(Text(user.fullPhone)),
                DataCell(Text(user.email)),
                DataCell(
                  OpsPill(
                    label: user.status.label,
                    color: user.status == UserStatusType.active
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.go(RoutePaths.userViewById(user.userId)),
                        child: const Text('View'),
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '${RoutePaths.userForm}?id=${user.userId}',
                        ),
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

class _MobileUserList extends StatelessWidget {
  const _MobileUserList({required this.users});

  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
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
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('Role: ${user.role.label}'),
              Text('Phone: ${user.fullPhone}'),
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              OpsPill(
                label: user.status.label,
                color: user.status == UserStatusType.active
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.go(RoutePaths.userViewById(user.userId)),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        context.go('${RoutePaths.userForm}?id=${user.userId}'),
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
