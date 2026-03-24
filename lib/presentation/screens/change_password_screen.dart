import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/ops_shell.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _passwordChanged = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _passwordChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OpsShell(
      title: 'Change Password',
      currentRoute: RoutePaths.changePassword,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_passwordChanged) ...[
                        Text(
                          'Update Your Password',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For your security, please enter your current password and a new password.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Current Password
                        PasswordField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                        // New Password
                        PasswordField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          hint: 'At least 8 characters',
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password
                        PasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        // Password Requirements
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Requirements',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _PasswordRequirement(
                                text: 'At least 8 characters',
                                isMet: _newPasswordController.text.length >= 8,
                              ),
                              const SizedBox(height: 8),
                              _PasswordRequirement(
                                text: 'Contains uppercase letter',
                                isMet: _newPasswordController.text.contains(RegExp(r'[A-Z]')),
                              ),
                              const SizedBox(height: 8),
                              _PasswordRequirement(
                                text: 'Contains lowercase letter',
                                isMet: _newPasswordController.text.contains(RegExp(r'[a-z]')),
                              ),
                              const SizedBox(height: 8),
                              _PasswordRequirement(
                                text: 'Contains number',
                                isMet: _newPasswordController.text.contains(RegExp(r'[0-9]')),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Change Password Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleChangePassword,
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                    ),
                                  )
                                : const Text('Change Password'),
                          ),
                        ),
                      ] else ...[
                        // Success Message
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.tertiaryContainer.withOpacity(0.2),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: colorScheme.tertiary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Password Changed Successfully',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your password has been updated. You can now use your new password to login.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => context.go(RoutePaths.userProfile),
                                  child: const Text('Back to Profile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_outlined : Icons.circle_outlined,
          size: 18,
          color: isMet ? colorScheme.tertiary : colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: textTheme.bodySmall?.copyWith(
            color: isMet ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
