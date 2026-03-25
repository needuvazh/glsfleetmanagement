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

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFEFF5FF)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(
                useLiveApi ? Icons.cloud_done_outlined : Icons.dataset_outlined,
                size: 16,
              ),
              label: Text(useLiveApi ? 'Live API' : 'Mock JSON'),
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
          : Drawer(child: SafeArea(child: _Sidebar(currentRoute))),
      body: Stack(
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(size: 220, color: Color(0xFFDBEAFE)),
          ),
          const Positioned(
            bottom: -100,
            left: -70,
            child: _GlowBlob(size: 260, color: Color(0xFFE0F2FE)),
          ),
          isDesktop
              ? Row(
                  children: [
                    SizedBox(width: 280, child: _Sidebar(currentRoute)),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: child,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
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
        color: color.withValues(alpha: 0.45),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar(this.currentRoute);

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
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
          _OpsMenuItem('Location Master', Icons.location_on_outlined,
              RoutePaths.locationMaster),
          _OpsMenuItem('Route Location Master', Icons.alt_route_outlined,
              RoutePaths.routeLocationMaster),
        ],
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFE), Color(0xFFF1F5FC)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD9E5FB)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE9F2FF), Color(0xFFF7FAFF)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: const Color(0xFFDCEBFF),
                      ),
                      child: const Icon(Icons.hub_outlined),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'GLS-IMS',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Transport Fleet Logistics Platform'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final group in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Text(
                group.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.9,
                  color: Color(0xFF687385),
                ),
              ),
            ),
            for (final item in group.items)
              _MenuTile(item: item, selected: currentRoute == item.route),
            const SizedBox(height: 6),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: selected ? const Color(0xFFE6EEFF) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFFC7D8FB) : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(item.icon, size: 20),
        title: Text(item.label),
        trailing:
            selected ? const Icon(Icons.chevron_right_rounded, size: 18) : null,
        onTap: () {
          Navigator.of(context).maybePop();
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
