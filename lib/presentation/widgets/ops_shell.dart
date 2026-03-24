import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/data_source_mode_provider.dart';
import '../../core/utils/responsive.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/theme_mode_viewmodel.dart';

class OpsShell extends ConsumerWidget {
  const OpsShell({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String currentRoute;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    final isDesktop = Responsive.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(
                useLiveApi ? Icons.cloud_done_outlined : Icons.dataset_outlined,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              label: Text(useLiveApi ? 'Live API' : 'Mock JSON'),
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
              backgroundColor: colorScheme.primaryContainer,
              onPressed: () => ref.read(useLiveApiProvider.notifier).toggle(),
            ),
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          ...actions,
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: colorScheme.surface,
              child: SafeArea(child: _Sidebar(currentRoute)),
            ),
      body: Stack(
        children: [
          // Decorative background blobs (can be replaced with more subtle design)
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(size: 220, color: colorScheme.primaryContainer.withOpacity(0.4)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _GlowBlob(size: 260, color: colorScheme.secondaryContainer.withOpacity(0.4)),
          ),
          isDesktop
              ? Row(
                  children: [
                    SizedBox(width: 280, child: _Sidebar(currentRoute)),
                    VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar(this.currentRoute);

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final groups = [
      _MenuGroup(
        'OPERATIONS',
        const [
          _OpsMenuItem('Dashboard', Icons.dashboard_outlined, RoutePaths.home),
          _OpsMenuItem('Customer Request', Icons.request_page_outlined,
              RoutePaths.customerRequest),
          _OpsMenuItem('Feasibility & Quotation', Icons.price_check_outlined,
              RoutePaths.feasibilityQuotation),
          _OpsMenuItem('Work Order', Icons.assignment_outlined,
              RoutePaths.workOrderFlow),
          _OpsMenuItem('Fleet Management', Icons.local_shipping_outlined,
              RoutePaths.fleetManagement),
          _OpsMenuItem('Driver Management', Icons.badge_outlined,
              RoutePaths.driverManagement),
        ],
      ),
      _MenuGroup(
        'SAFETY & COMPLIANCE',
        const [
          _OpsMenuItem('Compliance & Inspection', Icons.verified_user_outlined,
              RoutePaths.complianceInspection),
          _OpsMenuItem('Journey Management', Icons.alt_route_outlined,
              RoutePaths.journeyManagement),
          _OpsMenuItem(
              'Trip Execution', Icons.map_outlined, RoutePaths.tripExecution),
        ],
      ),
      _MenuGroup(
        'DELIVERY & FINANCE',
        const [
          _OpsMenuItem('Delivery & POD', Icons.inventory_2_outlined,
              RoutePaths.deliveryPod),
          _OpsMenuItem('Document Submission', Icons.upload_file_outlined,
              RoutePaths.documentSubmission),
          _OpsMenuItem('Closure', Icons.task_alt_outlined, RoutePaths.closure),
          _OpsMenuItem(
              'Invoice', Icons.receipt_long_outlined, RoutePaths.invoice),
        ],
      ),
      _MenuGroup(
        'USER ACCESS',
        const [
          _OpsMenuItem('Role Module', Icons.security_outlined,
              RoutePaths.roleManagement),
          _OpsMenuItem('User Module', Icons.manage_accounts_outlined,
              RoutePaths.userManagement),
          _OpsMenuItem('Vehicle Master Module', Icons.local_shipping_outlined,
              RoutePaths.transportManagement),
          _OpsMenuItem('Vehicle Types', Icons.directions_car_outlined,
              RoutePaths.vehicleTypes),
          _OpsMenuItem('Document Module', Icons.folder_copy_outlined,
              RoutePaths.documentManagement),
        ],
      ),
    ];

    return Container(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo and App Title Section
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.primaryContainer.withOpacity(0.2),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Placeholder for Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorScheme.primary,
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'GLS-IMS',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Transport Fleet Logistics Platform',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Menu Items
          for (final group in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Text(
                group.title,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            for (final item in group.items)
              _MenuTile(item: item, selected: currentRoute == item.route),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.selected});

  final _OpsMenuItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        border: selected ? Border.all(color: colorScheme.primary.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(item.icon, size: 20, color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant),
        title: Text(item.label, style: textTheme.bodyMedium?.copyWith(
          color: selected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
        trailing: selected ? Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.primary) : null,
        onTap: () {
          Navigator.of(context).maybePop(); // Close drawer if open
          context.go(item.route);
        },
      ),
    );
  }
}

class _OpsMenuItem {
  const _OpsMenuItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _MenuGroup {
  const _MenuGroup(this.title, this.items);

  final String title;
  final List<_OpsMenuItem> items;
}
