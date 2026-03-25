import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/user_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/user_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class UserViewScreen extends ConsumerWidget {
  const UserViewScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userViewModelProvider);

    return OpsShell(
      title: 'User Details',
      currentRoute: RoutePaths.userManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.userManagement),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          UserModel? user;
          for (final item in data.users) {
            if (item.userId == userId) {
              user = item;
              break;
            }
          }

          if (user == null) {
            return const Center(child: Text('User not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: user.fullName,
                subtitle: 'Read-only user profile',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Work Information'),
                    _DetailGrid(
                      items: [
                        _DetailItem(label: 'Role', value: user.role.label),
                        _DetailItem(
                          label: 'Department',
                          value: user.department.label,
                        ),
                        _DetailItem(
                            label: 'Employee ID', value: user.employeeId),
                        _DetailItem(
                          label: 'Joining Date',
                          value: user.joiningDateLabel,
                        ),
                        _DetailItem(
                          label: 'Status',
                          value: user.status.label,
                          color: user.status == UserStatusType.active
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Personal Information'),
                    _DetailGrid(items: _buildPersonalItems(user)),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Contact Information'),
                    _DetailGrid(items: _buildContactItems(user)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_DetailItem> _buildPersonalItems(UserModel user) {
    final items = <_DetailItem>[
      _DetailItem(label: 'First Name', value: user.firstName),
      _DetailItem(label: 'Last Name', value: user.lastName),
    ];

    if (user.role == UserRoleType.driver) {
      items.addAll([
        _DetailItem(label: 'License Number', value: user.licenseNumber),
        _DetailItem(
          label: 'License Expiry Date',
          value: user.licenseExpiryDateLabel,
        ),
      ]);
    }

    return items;
  }

  List<_DetailItem> _buildContactItems(UserModel user) {
    final items = <_DetailItem>[
      _DetailItem(label: 'Country Code', value: user.countryCode.label),
      _DetailItem(label: 'Phone', value: user.fullPhone),
    ];

    switch (user.role) {
      case UserRoleType.admin:
        items.addAll([
          _DetailItem(label: 'Email', value: user.email),
          _DetailItem(label: 'Address', value: user.address, wide: true),
        ]);
        break;
      case UserRoleType.driver:
        items.add(
          _DetailItem(
            label: 'Alternate Number',
            value: user.alternateNumber.isEmpty
                ? '-'
                : '${user.countryCode.label} ${user.alternateNumber}',
          ),
        );
        break;
      case UserRoleType.dispatcher:
        items.add(_DetailItem(label: 'Email', value: user.email));
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
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.items});

  final List<_DetailItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final item in items)
          _DetailTile(
            label: item.label,
            value: item.value,
            color: item.color,
            wide: item.wide,
          ),
      ],
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.label,
    required this.value,
    this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool wide;
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
