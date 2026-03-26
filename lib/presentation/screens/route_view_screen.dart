import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/route_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class RouteViewScreen extends ConsumerWidget {
  const RouteViewScreen({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeViewModelProvider);
    final logistics = ref.watch(logisticsViewModelProvider).valueOrNull;

    return OpsShell(
      title: 'Route Details',
      currentRoute: RoutePaths.routeLocationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.routeLocationMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          RouteLocationModel? route;
          for (final entry in data.routes) {
            if (entry.routeId == routeId) {
              route = entry;
              break;
            }
          }

          if (route == null) {
            return const Center(child: Text('Route not found.'));
          }

          final activeUsage = _activeWorkOrders(route, logistics);
          final delayedUsage = _delayedTrips(route, logistics);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!route.isSelectableForNewOperations)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    'Route is not selectable for new operations. ${route.restrictionReason}',
                  ),
                ),
              OpsSectionCard(
                title: route.routeName,
                subtitle: '${route.routeCode} • ${route.region}',
                icon: Icons.alt_route_outlined,
                accent: const Color(0xFF0EA5E9),
                child: _RouteSummaryGrid(
                    route: route,
                    activeUsage: activeUsage,
                    delayedUsage: delayedUsage),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Travel Planning',
                subtitle: 'Standard ETA windows, stops and route pattern',
                icon: Icons.schedule,
                accent: const Color(0xFF2563EB),
                child: _PlanningSection(route: route),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Risk & Safety',
                subtitle: 'Risk profile, restrictions and instructions',
                icon: Icons.warning_amber_outlined,
                accent: const Color(0xFFEA580C),
                child: _RiskSection(route: route),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Operational Rules',
                subtitle: 'Assignment and handling preferences',
                icon: Icons.settings_suggest_outlined,
                accent: const Color(0xFF16A34A),
                child: _RulesSection(route: route),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Compliance',
                subtitle: 'Permits, documents and authority controls',
                icon: Icons.gpp_good_outlined,
                accent: const Color(0xFF9333EA),
                child: _ComplianceSection(route: route),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteSummaryGrid extends StatelessWidget {
  const _RouteSummaryGrid({
    required this.route,
    required this.activeUsage,
    required this.delayedUsage,
  });

  final RouteLocationModel route;
  final int activeUsage;
  final int delayedUsage;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.isDesktop(context)
        ? 3
        : (Responsive.isTablet(context) ? 2 : 1);
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _tile(itemWidth, 'Origin', route.startLocation.locationName),
            _tile(itemWidth, 'Destination', route.endLocation.locationName),
            _tile(itemWidth, 'Distance',
                '${route.distanceKm.toStringAsFixed(1)} km'),
            _tile(itemWidth, 'ETA', route.estimatedTime),
            _tile(itemWidth, 'Risk', route.riskLevel.label),
            _tile(itemWidth, 'Status', route.status.label),
            _tile(itemWidth, 'Active Work Orders', '$activeUsage'),
            _tile(itemWidth, 'Delayed Trips', '$delayedUsage'),
            _tile(itemWidth, 'Customer Specific',
                route.customerSpecific ? 'Yes' : 'No'),
          ],
        );
      },
    );
  }

  Widget _tile(double width, String label, String value) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(value),
      ),
    );
  }
}

class _PlanningSection extends StatelessWidget {
  const _PlanningSection({required this.route});

  final RouteLocationModel route;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expected Stops: ${route.expectedStops}'),
        Text('Start Window: ${route.standardStartWindow}'),
        Text('Delivery Window: ${route.standardDeliveryWindow}'),
        Text('Rest Points: ${route.standardRestPoints.join(', ')}'),
        const SizedBox(height: 8),
        if (route.stopPoints.isEmpty)
          const Text('No intermediate stops configured.')
        else
          Column(
            children: [
              for (int i = 0; i < route.stopPoints.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text('${i + 1}.'),
                  title: Text(route.stopPoints[i].location.locationName),
                  subtitle: Text(
                    '${route.stopPoints[i].type.label}${route.stopPoints[i].note.trim().isEmpty ? '' : ' • ${route.stopPoints[i].note}'}',
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _RiskSection extends StatelessWidget {
  const _RiskSection({required this.route});

  final RouteLocationModel route;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risk Level: ${route.riskLevel.label}'),
        Text(
            'Night Driving Allowed: ${route.nightDrivingAllowed ? 'Yes' : 'No'}'),
        Text('Weather Sensitive: ${route.weatherSensitive ? 'Yes' : 'No'}'),
        Text(
            'Restricted Segments: ${route.restrictedSegments.isEmpty ? '-' : route.restrictedSegments}'),
        Text(
            'Route Notes: ${route.routeNotes.isEmpty ? '-' : route.routeNotes}'),
      ],
    );
  }
}

class _RulesSection extends StatelessWidget {
  const _RulesSection({required this.route});

  final RouteLocationModel route;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Preferred Vehicle Type: ${route.preferredVehicleType.isEmpty ? '-' : route.preferredVehicleType}'),
        Text(
            'Trailer Preference: ${route.trailerTypePreference.isEmpty ? '-' : route.trailerTypePreference}'),
        Text('Escort Required: ${route.escortRequired ? 'Yes' : 'No'}'),
        Text(
            'Alternate Route Available: ${route.alternateRouteAvailable ? 'Yes' : 'No'}'),
        Text(
            'Special Handling: ${route.specialHandlingNotes.isEmpty ? '-' : route.specialHandlingNotes}'),
      ],
    );
  }
}

class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection({required this.route});

  final RouteLocationModel route;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Special Compliance Required: ${route.specialComplianceRequired ? 'Yes' : 'No'}'),
        Text(
            'Safety Instructions: ${route.safetyInstructions.isEmpty ? '-' : route.safetyInstructions}'),
        Text(
            'Authority Restrictions: ${route.customerAuthorityRestrictions.isEmpty ? '-' : route.customerAuthorityRestrictions}'),
        Text(
            'Permit Requirement: ${route.permitRequirement.isEmpty ? '-' : route.permitRequirement}'),
        Text(
            'Required Documents: ${route.requiredDocuments.isEmpty ? '-' : route.requiredDocuments.join(', ')}'),
      ],
    );
  }
}

int _activeWorkOrders(RouteLocationModel route, LogisticsUiState? logistics) {
  if (logistics == null) {
    return 0;
  }
  var count = 0;
  for (final item in logistics.workOrders) {
    final routeText = item.route.toLowerCase();
    if (!item.status.toLowerCase().contains('complete') &&
        _matchesRoute(route, routeText)) {
      count += 1;
    }
  }
  return count;
}

int _delayedTrips(RouteLocationModel route, LogisticsUiState? logistics) {
  if (logistics == null) {
    return 0;
  }
  var count = 0;
  for (final item in logistics.workOrders) {
    final routeText = item.route.toLowerCase();
    if (item.status.toLowerCase().contains('delay') &&
        _matchesRoute(route, routeText)) {
      count += 1;
    }
  }
  return count;
}

bool _matchesRoute(RouteLocationModel route, String routeText) {
  return routeText.contains(route.routeCode.toLowerCase()) ||
      routeText.contains(route.routeName.toLowerCase()) ||
      (routeText.contains(route.startLocation.locationName.toLowerCase()) &&
          routeText.contains(route.endLocation.locationName.toLowerCase()));
}
