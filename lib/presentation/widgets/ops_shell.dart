import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_mode_viewmodel.dart';

// Provider for sidebar collapsed state
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

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

  static const Map<String, String> _routeDisplayNames = {
    RoutePaths.home: 'Dashboard',
    RoutePaths.dashboard: 'Dashboard',
    RoutePaths.workOrders: 'Work Orders',
    RoutePaths.workOrderFlow: 'Work Order Flow',
    RoutePaths.customerManagement: 'Customer Management',
    RoutePaths.customerForm: 'Customer Management',
    RoutePaths.customerView: 'Customer Management',
    RoutePaths.customerRequest: 'Enquiry',
    RoutePaths.enquiryDetails: 'Enquiry Details',
    RoutePaths.feasibilityQuotation: 'Feasibility Review',
    RoutePaths.quotation: 'Quotation',
    RoutePaths.orderDecision: 'Order Decision',
    RoutePaths.woDelegation: 'WO Delegation',
    RoutePaths.fleetManagement: 'Fleet Master',
    RoutePaths.driverManagement: 'Driver Master',
    RoutePaths.complianceInspection: 'Compliance Inspection',
    RoutePaths.complianceDashboard: 'Compliance Dashboard',
    RoutePaths.dispatchReadiness: 'Compliance Readiness',
    RoutePaths.inspections: 'Pre-Trip Inspection',
    RoutePaths.inspectionTemplates: 'Inspection Template Master',
    RoutePaths.inspectionFailedQueue: 'Failed Inspections',
    RoutePaths.inspectionCalendar: 'Inspection Calendar',
    RoutePaths.mediaGallery: 'Media Gallery',
    RoutePaths.journeyManagement: 'Journey Management Plan',
    RoutePaths.tripMonitoring: 'Trip Progress',
    RoutePaths.tripExecution: 'Trip Execution',
    RoutePaths.deliveryPod: 'Delivery Completion',
    RoutePaths.documentSubmission: 'Document Submission',
    RoutePaths.closure: 'Closure',
    RoutePaths.invoice: 'Invoices',
    RoutePaths.reports: 'Reports',
    RoutePaths.assignments: 'Fleet Assignment',
    RoutePaths.alerts: 'Alerts',
    RoutePaths.roleManagement: 'Role Management',
    RoutePaths.userManagement: 'User Management',
    RoutePaths.vehicleTypes: 'Vehicle Types',
    RoutePaths.vendorMaster: 'Vendor Master',
    RoutePaths.documentManagement: 'Compliance Master',
    RoutePaths.locationMaster: 'Location Master',
    RoutePaths.routeLocationMaster: 'Route Master',
    RoutePaths.cargoMaster: 'Cargo Master',
    RoutePaths.roleDocumentMapping: 'Role Document Mapping',
    RoutePaths.userProfile: 'User Profile',
    RoutePaths.changePassword: 'Change Password',
    RoutePaths.dispatch: 'Dispatch',
    RoutePaths.tripDocumentVerification: 'Trip Document Verification',
    RoutePaths.finalApproval: 'Final Approval',
    RoutePaths.financeHandoff: 'Finance Handoff',
    RoutePaths.executionEvidence: 'Execution Evidence',
    RoutePaths.podDnUploads: 'POD / DN Uploads',
    RoutePaths.tripDocuments: 'Trip Documents',
    RoutePaths.photosVideos: 'Photos / Videos',
    RoutePaths.auditTrail: 'Audit Trail',
    RoutePaths.statusTimeline: 'Status Timeline',
    RoutePaths.trailerMaster: 'Trailer Master',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Responsive.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, ref, isDesktop, isCollapsed),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: colorScheme.surface,
              child: SafeArea(
                  child:
                      _Sidebar(currentRoute: currentRoute, isCollapsed: false)),
            ),
      body: Stack(
        children: [
          // Decorative background
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(
                size: 220,
                color: colorScheme.primaryContainer.withValues(alpha: 0.3)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _GlowBlob(
                size: 260,
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3)),
          ),
          isDesktop
              ? Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isCollapsed ? 80 : 280,
                      child: _Sidebar(
                          currentRoute: currentRoute, isCollapsed: isCollapsed),
                    ),
                    VerticalDivider(
                        width: 1, color: colorScheme.outlineVariant),
                    Expanded(child: _buildContentPanel(context)),
                  ],
                )
              : _buildContentPanel(context),
        ],
      ),
    );
  }

  Widget _buildContentPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final breadcrumbs = _breadcrumbsForPage();

    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < breadcrumbs.length; i++) ...[
                        Text(
                          breadcrumbs[i],
                          style: textTheme.labelMedium?.copyWith(
                            color: i == breadcrumbs.length - 1
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: i == breadcrumbs.length - 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (i < breadcrumbs.length - 1)
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Spacer(),
                        Flexible(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: actions,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  List<String> _breadcrumbsForPage() {
    final routeLabel = _routeLabel(currentRoute);
    final crumbs = <String>['Dashboard'];

    if (routeLabel.isNotEmpty && routeLabel != 'Dashboard') {
      crumbs.add(routeLabel);
    }
    if (title != routeLabel && title != 'Dashboard') {
      crumbs.add(title);
    } else if (crumbs.length == 1 && title != 'Dashboard') {
      crumbs.add(title);
    }

    return crumbs;
  }

  String _routeLabel(String route) {
    final normalizedRoute =
        route.split('?').first.replaceAll(RegExp(r'/+$'), '');
    final exactMatch =
        _routeDisplayNames[normalizedRoute.isEmpty ? '/' : normalizedRoute];
    if (exactMatch != null) {
      return exactMatch;
    }

    final partialMatch = _routeDisplayNames.entries
        .where((entry) =>
            entry.key != '/' && normalizedRoute.startsWith('${entry.key}/'))
        .map((entry) => entry.value)
        .cast<String?>()
        .firstWhere((value) => value != null, orElse: () => null);
    if (partialMatch != null) {
      return partialMatch;
    }

    final segments = normalizedRoute
        .split('/')
        .where((segment) => segment.isNotEmpty && !segment.startsWith(':'))
        .toList();
    if (segments.isEmpty) {
      return 'Dashboard';
    }

    final slug = segments.last;
    return slug
        .split(RegExp(r'[-_]'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, bool isDesktop, bool isCollapsed) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: isDesktop
          ? IconButton(
              tooltip: isCollapsed ? 'Expand Menu' : 'Collapse Menu',
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isCollapsed ? 0.5 : 0,
                child: const Icon(Icons.menu_open_rounded),
              ),
              onPressed: () {
                ref.read(sidebarCollapsedProvider.notifier).state =
                    !isCollapsed;
              },
            )
          : null,
      title: const _TopBarLogo(),
      actions: [
        // Theme toggle
        IconButton(
          tooltip: 'Toggle Theme',
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
        // User Profile Menu
        _UserProfileMenu(),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _TopBarLogo extends StatelessWidget {
  const _TopBarLogo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/gls_logo.jpg',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: colorScheme.primaryContainer,
          alignment: Alignment.center,
          child: Text(
            'GLS',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authViewModelProvider).valueOrNull;
    final userName = authState?.userName ?? 'User';
    final userRole = authState?.userRole ?? 'Guest';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  userRole,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.person_outline_rounded, color: colorScheme.primary),
            title: const Text('My Profile'),
            subtitle: const Text('View and edit profile'),
          ),
        ),
        PopupMenuItem(
          value: 'password',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.lock_outline_rounded, color: colorScheme.secondary),
            title: const Text('Change Password'),
            subtitle: const Text('Update your password'),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: colorScheme.error),
            title: Text('Logout', style: TextStyle(color: colorScheme.error)),
            subtitle: const Text('Sign out of your account'),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.push(RoutePaths.userProfile);
            break;
          case 'password':
            context.push(RoutePaths.changePassword);
            break;
          case 'logout':
            _showLogoutDialog(context, ref);
            break;
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authViewModelProvider.notifier).logout();
              context.go(RoutePaths.login);
            },
            child: const Text('Logout'),
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

class _Sidebar extends StatefulWidget {
  const _Sidebar({required this.currentRoute, required this.isCollapsed});

  final String currentRoute;
  final bool isCollapsed;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  late final Set<String> _expandedMenus;

  @override
  void initState() {
    super.initState();
    _expandedMenus = {
      'Customer',
      'Inspections',
      'Compliance',
      'User Access',
      'Master'
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final groups = [
      _MenuGroup(
        'DASHBOARD',
        const [
          _OpsMenuItem('Dashboard', Icons.dashboard_outlined, route: RoutePaths.home),
        ],
      ),
      _MenuGroup(
        'TRANSACTIONS',
        const [
          _OpsMenuItem('Enquiry', Icons.request_page_outlined, route: RoutePaths.customerRequest),
          _OpsMenuItem('Feasibility Review', Icons.price_check_outlined, route: RoutePaths.feasibilityQuotation),
          _OpsMenuItem('Quotation', Icons.request_quote_outlined, route: RoutePaths.quotation),
          _OpsMenuItem('Order Decision', Icons.gavel_outlined, route: RoutePaths.orderDecision),
          _OpsMenuItem('Work Order', Icons.assignment_outlined, route: RoutePaths.workOrders),
          _OpsMenuItem('WO Delegation', Icons.assignment_ind_outlined, route: RoutePaths.woDelegation),
        ],
      ),
      _MenuGroup(
        'OPERATIONS',
        const [
          _OpsMenuItem('Fleet Assignment', Icons.local_shipping_outlined, route: RoutePaths.assignments),
          _OpsMenuItem('Compliance Readiness', Icons.shield_outlined, route: RoutePaths.dispatchReadiness),
          _OpsMenuItem('Journey Management Plan', Icons.alt_route_outlined, route: RoutePaths.journeyManagement),
          _OpsMenuItem('Pre-Trip Inspection', Icons.fact_check_outlined, route: RoutePaths.inspections),
          _OpsMenuItem('Dispatch', Icons.play_circle_outline, route: RoutePaths.dispatch),
          _OpsMenuItem('Delivery Completion', Icons.inventory_2_outlined, route: RoutePaths.deliveryPod),
          _OpsMenuItem('Trip Document Verification', Icons.verified_outlined, route: RoutePaths.tripDocumentVerification),
          _OpsMenuItem('Final Approval', Icons.thumb_up_outlined, route: RoutePaths.finalApproval),
          _OpsMenuItem('Finance Handoff', Icons.monetization_on_outlined, route: RoutePaths.financeHandoff),
        ],
      ),
      _MenuGroup(
        'MONITORING',
        const [
          _OpsMenuItem('Trip Progress', Icons.map_outlined, route: RoutePaths.tripMonitoring),
          _OpsMenuItem('Execution Evidence', Icons.fact_check_outlined, route: RoutePaths.executionEvidence),
        ],
      ),
      _MenuGroup(
        'DOCUMENTS & MEDIA',
        const [
          _OpsMenuItem('POD / DN Uploads', Icons.upload_file_outlined, route: RoutePaths.podDnUploads),
          _OpsMenuItem('Trip Documents', Icons.folder_open_outlined, route: RoutePaths.tripDocuments),
          _OpsMenuItem('Photos / Videos', Icons.photo_camera_outlined, route: RoutePaths.photosVideos),
        ],
      ),
      _MenuGroup(
        'AUDIT & HISTORY',
        const [
          _OpsMenuItem('Audit Trail', Icons.history_outlined, route: RoutePaths.auditTrail),
          _OpsMenuItem('Status Timeline', Icons.timeline_outlined, route: RoutePaths.statusTimeline),
        ],
      ),
      _MenuGroup(
        'MASTERS',
        const [
          _OpsMenuItem('Customer', Icons.business_outlined, route: RoutePaths.customerManagement),
          _OpsMenuItem('Cargo', Icons.inventory_2_outlined, route: RoutePaths.cargoMaster),
          _OpsMenuItem('Route', Icons.alt_route_outlined, route: RoutePaths.routeLocationMaster),
          _OpsMenuItem('Fleet', Icons.local_shipping_outlined, route: RoutePaths.fleetManagement),
          _OpsMenuItem('Trailer', Icons.rv_hookup_outlined, route: RoutePaths.trailerMaster),
          _OpsMenuItem('Driver', Icons.badge_outlined, route: RoutePaths.driverManagement),
          _OpsMenuItem('Inspection Template', Icons.fact_check_outlined, route: RoutePaths.inspectionTemplates),
        ],
      ),
    ];

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(widget.isCollapsed ? 12 : 16),
            child: Container(
              padding: EdgeInsets.all(widget.isCollapsed ? 8 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isCollapsed
                  ? Icon(
                      Icons.menu_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 28,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Greenfield Logistics',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Services LLC',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.isCollapsed ? 8 : 16, vertical: 8),
              children: [
                for (final group in groups) ...[
                  if (!widget.isCollapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Text(
                        group.title,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                  for (final item in group.items) ...[
                    if (item.hasChildren && !widget.isCollapsed) ...[
                      _ParentMenuTile(
                        item: item,
                        selected: _isParentSelected(item),
                        expanded: _isMenuExpanded(item),
                        onTap: () => _toggleMenu(item.label),
                      ),
                      if (_isMenuExpanded(item))
                        for (final child in item.children)
                          _MenuTile(
                            item: child,
                            selected: widget.currentRoute == child.route,
                            isCollapsed: widget.isCollapsed,
                            isChild: true,
                          ),
                    ] else if (item.hasChildren && widget.isCollapsed) ...[
                      for (final child in item.children)
                        _MenuTile(
                          item: child,
                          selected: widget.currentRoute == child.route,
                          isCollapsed: widget.isCollapsed,
                        ),
                    ] else
                      _MenuTile(
                        item: item,
                        selected: widget.currentRoute == item.route,
                        isCollapsed: widget.isCollapsed,
                      ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isParentSelected(_OpsMenuItem item) {
    return item.children.any((child) => child.route == widget.currentRoute);
  }

  bool _isMenuExpanded(_OpsMenuItem item) {
    return _expandedMenus.contains(item.label) || _isParentSelected(item);
  }

  void _toggleMenu(String label) {
    setState(() {
      if (_expandedMenus.contains(label)) {
        _expandedMenus.remove(label);
      } else {
        _expandedMenus.add(label);
      }
    });
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.selected,
    required this.isCollapsed,
    this.isChild = false,
  });

  final _OpsMenuItem item;
  final bool selected;
  final bool isCollapsed;
  final bool isChild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        border: selected
            ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).maybePop();
            if (item.route != null) {
              context.go(item.route!);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed
                  ? 12
                  : isChild
                      ? 26
                      : 14,
              vertical: isCollapsed ? 14 : 12,
            ),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        item.icon,
                        size: isChild ? 18 : 20,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontWeight: selected
                                ? FontWeight.w600
                                : (isChild ? FontWeight.w400 : FontWeight.w500),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: tile,
      );
    }
    return tile;
  }
}

class _ParentMenuTile extends StatelessWidget {
  const _ParentMenuTile({
    required this.item,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _OpsMenuItem item;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 180),
                  turns: expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpsMenuItem {
  const _OpsMenuItem(
    this.label,
    this.icon, {
    this.route,
    this.children = const [],
  });

  final String label;
  final IconData icon;
  final String? route;
  final List<_OpsMenuItem> children;

  bool get hasChildren => children.isNotEmpty;
}

class _MenuGroup {
  const _MenuGroup(this.title, this.items);

  final String title;
  final List<_OpsMenuItem> items;
}
