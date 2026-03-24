import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ops_shell.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(authViewModelProvider).valueOrNull?.user;
    if (user != null && _fullNameController.text.isEmpty) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
  }

  void _handleSaveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    setState(() => _isEditing = false);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
              Navigator.pop(context);
              context.go(RoutePaths.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider).valueOrNull;
    final user = authState?.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    return OpsShell(
      title: 'User Profile',
      currentRoute: RoutePaths.userProfile,
      actions: [
        TextButton(
          onPressed: _handleLogout,
          child: const Text('Logout'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  UserAvatar(
                    initials: user.fullName.split(' ').map((e) => e[0]).join(),
                    size: 100,
                    backgroundColor: colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RoleBadge(role: user.role.displayName, size: RoleBadgeSize.medium),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Profile Information Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Information',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _isEditing = !_isEditing),
                        icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                        label: Text(_isEditing ? 'Cancel' : 'Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    _ProfileInfoTile(
                      label: 'Username',
                      value: user.username,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoTile(
                      label: 'Email',
                      value: user.email,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoTile(
                      label: 'Phone',
                      value: user.phone,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoTile(
                      label: 'User ID',
                      value: user.userId,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoTile(
                      label: 'Member Since',
                      value: _formatDate(user.createdAt),
                      icon: Icons.calendar_today_outlined,
                    ),
                    if (user.lastLogin != null) ...[
                      const SizedBox(height: 12),
                      _ProfileInfoTile(
                        label: 'Last Login',
                        value: _formatDate(user.lastLogin!),
                        icon: Icons.login_outlined,
                      ),
                    ],
                  ] else ...[
                    FullNameField(
                      controller: _fullNameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    EmailField(
                      controller: _emailController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    PhoneField(
                      controller: _phoneController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSaveChanges,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Security Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: colorScheme.primary),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your password regularly'),
                    trailing: const Icon(Icons.chevron_right_outlined),
                    onTap: () => context.go(RoutePaths.changePassword),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.shield_outlined, color: colorScheme.secondary),
                    title: const Text('Two-Factor Authentication'),
                    subtitle: const Text('Add an extra layer of security'),
                    trailing: Switch(
                      value: false,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Danger Zone
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
