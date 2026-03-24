import 'package:flutter/material.dart';

/// A custom password field with visibility toggle
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}

/// A custom email field with validation
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// A custom phone field
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.label = 'Phone',
    this.hint = 'Enter your phone number',
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// A custom full name field
class FullNameField extends StatelessWidget {
  const FullNameField({
    super.key,
    required this.controller,
    this.label = 'Full Name',
    this.hint = 'Enter your full name',
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// A role badge widget
class RoleBadge extends StatelessWidget {
  const RoleBadge({
    super.key,
    required this.role,
    this.size = RoleBadgeSize.medium,
  });

  final String role;
  final RoleBadgeSize size;

  Color _getRoleColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (role.toLowerCase()) {
      case 'admin':
        return colorScheme.error;
      case 'dispatcher':
      case 'operations manager':
        return colorScheme.primary;
      case 'driver':
        return colorScheme.tertiary;
      case 'compliance':
      case 'compliance officer':
        return colorScheme.secondary;
      case 'accountant':
        return colorScheme.primary.withOpacity(0.7);
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final roleColor = _getRoleColor(context);
    final textTheme = Theme.of(context).textTheme;

    final (padding, fontSize) = switch (size) {
      RoleBadgeSize.small => (const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 12.0),
      RoleBadgeSize.medium => (const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 14.0),
      RoleBadgeSize.large => (const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 16.0),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.15),
        border: Border.all(color: roleColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: textTheme.labelSmall?.copyWith(
          color: roleColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum RoleBadgeSize { small, medium, large }

/// A user avatar widget
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? colorScheme.primaryContainer,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                initials ?? '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            )
          : null,
    );
  }
}
