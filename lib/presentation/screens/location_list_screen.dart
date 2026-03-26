import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/location_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class LocationListScreen extends ConsumerWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Location Master',
      currentRoute: RoutePaths.locationMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.locationForm),
          child: const Text('Create Location'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredLocations;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Search',
                subtitle: 'Search by location name or code',
                icon: Icons.search,
                accent: const Color(0xFF2563EB),
                child: TextFormField(
                  initialValue: data.searchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Location Name / Code',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ref
                      .read(locationViewModelProvider.notifier)
                      .setSearchQuery,
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Location List',
                subtitle: 'Master data for routes and trip planning',
                icon: Icons.location_on_outlined,
                accent: const Color(0xFF16A34A),
                trailing: FilledButton.icon(
                  onPressed: () => context.go(RoutePaths.locationForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Location'),
                ),
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No locations found.'),
                      )
                    : (isMobile
                        ? _MobileLocationList(items: items)
                        : _DesktopLocationTable(items: items)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DesktopLocationTable extends StatelessWidget {
  const _DesktopLocationTable({required this.items});

  final List<LocationModel> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
        columns: const [
          DataColumn(label: Text('Location Name')),
          DataColumn(label: Text('Location Code')),
          DataColumn(label: Text('Latitude')),
          DataColumn(label: Text('Longitude')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final location in items)
            DataRow(
              cells: [
                DataCell(Text(location.locationName)),
                DataCell(Text(location.locationCode)),
                DataCell(Text(_formatCoordinate(location.latitude))),
                DataCell(Text(_formatCoordinate(location.longitude))),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go(
                          RoutePaths.locationViewByCode(location.locationCode),
                        ),
                        child: const Text('View'),
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '${RoutePaths.locationForm}?code=${location.locationCode}',
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MobileLocationList extends StatelessWidget {
  const _MobileLocationList({required this.items});

  final List<LocationModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final location = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFDCE6F7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.locationName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('Code: ${location.locationCode}'),
              Text('Latitude: ${_formatCoordinate(location.latitude)}'),
              Text('Longitude: ${_formatCoordinate(location.longitude)}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(
                      RoutePaths.locationViewByCode(location.locationCode),
                    ),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.go(
                      '${RoutePaths.locationForm}?code=${location.locationCode}',
                    ),
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

String _formatCoordinate(double value) => value.toStringAsFixed(4);
