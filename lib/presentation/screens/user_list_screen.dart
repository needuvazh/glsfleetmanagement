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
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final users = data.filteredUsers;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'User Search',
                  subtitle: 'Filter by first name, last name, or phone number',
                  icon: Icons.search_outlined,
                  accent: const Color(0xFF2563EB),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText: 'Search by name / phone',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(userViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () => context.go(RoutePaths.userForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create User'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: data.searchQuery,
                                decoration: const InputDecoration(
                                  labelText: 'Search by name / phone',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: ref
                                    .read(userViewModelProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () => context.go(RoutePaths.userForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create User'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'User List',
                    subtitle:
                        'Enterprise user directory with list-first workflow',
                    icon: Icons.manage_accounts_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: users.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('No users found.'),
                          )
                        : (isMobile
                            ? _MobileUserList(users: users)
                            : _DesktopUserTable(users: users)),
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

class _DesktopUserTable extends StatefulWidget {
  const _DesktopUserTable({required this.users});

  final List<UserModel> users;

  @override
  State<_DesktopUserTable> createState() => _DesktopUserTableState();
}

class _DesktopUserTableState extends State<_DesktopUserTable> {
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
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Last Name')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final user in widget.users)
                    DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              user.firstName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              user.lastName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(user.role.label)),
                        DataCell(Text(user.fullPhone)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          OpsPill(
                            label: user.status.label,
                            color: user.status == UserStatusType.active
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
                                      .go(RoutePaths.userViewById(user.userId)),
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
                                    '${RoutePaths.userForm}?id=${user.userId}',
                                  ),
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

class _MobileUserList extends StatelessWidget {
  const _MobileUserList({required this.users});

  final List<UserModel> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
