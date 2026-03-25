import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter username and password'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authViewModelProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );

    setState(() => _isLoading = false);

    final authState = ref.read(authViewModelProvider).valueOrNull;
    if (authState?.isAuthenticated ?? false) {
      context.go(RoutePaths.home);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState?.error ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 900;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorScheme.brightness == Brightness.light
                ? [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFECFDF5),
                    const Color(0xFFF0FDF4),
                  ]
                : [
                    const Color(0xFF0F1419),
                    const Color(0xFF0F1729),
                    const Color(0xFF1A1F2E),
                  ],
          ),
        ),
        child: SafeArea(
          child: _buildAuthOnlyLayout(
            context,
            textTheme,
            colorScheme,
            isCompact,
            isMobile,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOnlyLayout(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isCompact,
    bool isMobile,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _formSlideAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : (isCompact ? 40 : 48),
              vertical: isMobile ? 32 : 48,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: _buildLoginForm(context, textTheme, colorScheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Left brand panel
        Expanded(
          flex: 5,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBrandPanel(context, textTheme, colorScheme, false),
            ),
          ),
        ),
        // Right login panel
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _formSlideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _buildLoginForm(context, textTheme, colorScheme),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 40,
          vertical: isMobile ? 32 : 48,
        ),
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child:
                    _buildBrandPanel(context, textTheme, colorScheme, isMobile),
              ),
            ),
            SizedBox(height: isMobile ? 32 : 48),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _formSlideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _buildLoginForm(context, textTheme, colorScheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandPanel(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Logo
          _GLSLogo(isMobile: isMobile),
          SizedBox(height: isMobile ? 24 : 40),
          // Title
          Text(
            'GLS-IMS',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Integrated Management System',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 48),
            // Feature highlights
            _FeatureItem(
              icon: Icons.local_shipping_rounded,
              title: 'Fleet Management',
              subtitle: 'Track and manage your entire fleet',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            _FeatureItem(
              icon: Icons.analytics_rounded,
              title: 'Real-time Analytics',
              subtitle: 'Data-driven insights for better decisions',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            _FeatureItem(
              icon: Icons.security_rounded,
              title: 'Compliance Tracking',
              subtitle: 'Stay compliant with automated monitoring',
              colorScheme: colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: _GLSLogo(isMobile: false),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome back',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your dashboard',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Username field
          _AnimatedTextField(
            controller: _usernameController,
            label: 'Username',
            hint: 'Enter your username',
            prefixIcon: Icons.person_outline_rounded,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          // Password field
          _AnimatedTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          // Remember me & Forgot password
          Row(
            children: [
              // Remember me checkbox
              InkWell(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _rememberMe
                                ? colorScheme.primary
                                : colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                        child: _rememberMe
                            ? Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: colorScheme.onPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Remember me',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(RoutePaths.forgotPassword),
                child: Text(
                  'Forgot password?',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Login button
          _AnimatedLoginButton(
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 28),
          // Demo credentials
          _DemoCredentialsSection(
              colorScheme: colorScheme, textTheme: textTheme),
        ],
      ),
    );
  }
}

// GLS Logo Widget
class _GLSLogo extends StatelessWidget {
  final bool isMobile;

  const _GLSLogo({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 150.0 : 220.0;
    final width = isMobile ? 150.0 : 320.0;
    final height = isMobile ? 150.0 : 220.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/gls_logo.jpg',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _FallbackLogo(size: size);
        },
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final double size;

  const _FallbackLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const green = Color(0xFF10B981);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_right, color: Colors.white, size: 18),
                Icon(Icons.chevron_right, color: Colors.white, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'GLS',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Animated Text Field
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Widget? suffixIcon;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Icon(widget.prefixIcon, size: 22),
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}

// Animated Login Button
class _AnimatedLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _AnimatedLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<_AnimatedLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (!widget.isLoading) {
          widget.onPressed();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [
                      colorScheme.primary.withOpacity(0.6),
                      colorScheme.primary.withOpacity(0.6),
                    ]
                  : [
                      colorScheme.primary,
                      colorScheme.primary.withGreen(
                          (colorScheme.primary.green * 0.85).toInt()),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Demo Credentials Section
class _DemoCredentialsSection extends StatefulWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _DemoCredentialsSection({
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<_DemoCredentialsSection> createState() =>
      _DemoCredentialsSectionState();
}

class _DemoCredentialsSectionState extends State<_DemoCredentialsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: widget.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demo Credentials',
                      style: widget.textTheme.labelLarge?.copyWith(
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(color: widget.colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  _DemoCredentialRow(
                    role: 'Admin',
                    username: 'admin',
                    color: const Color(0xFFEF4444),
                    colorScheme: widget.colorScheme,
                  ),
                  _DemoCredentialRow(
                    role: 'Dispatcher',
                    username: 'dispatcher',
                    color: const Color(0xFF10B981),
                    colorScheme: widget.colorScheme,
                  ),
                  _DemoCredentialRow(
                    role: 'Driver',
                    username: 'driver',
                    color: const Color(0xFF6366F1),
                    colorScheme: widget.colorScheme,
                  ),
                  _DemoCredentialRow(
                    role: 'Compliance',
                    username: 'compliance',
                    color: const Color(0xFFD4AF37),
                    colorScheme: widget.colorScheme,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Password: any value',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
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

class _DemoCredentialRow extends StatelessWidget {
  final String role;
  final String username;
  final Color color;
  final ColorScheme colorScheme;

  const _DemoCredentialRow({
    required this.role,
    required this.username,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              username,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
