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
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final items = data.filteredLocations;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Location Search',
                  subtitle: 'Search and manage locations from one place',
                  icon: Icons.search,
                  accent: const Color(0xFF2563EB),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: data.searchQuery,
                              decoration: const InputDecoration(
                                labelText: 'Location Name / Code',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: ref
                                  .read(locationViewModelProvider.notifier)
                                  .setSearchQuery,
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.locationForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Location'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
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
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.go(RoutePaths.locationForm),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Location'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Location List',
                    subtitle: 'Master data for routes and trip planning',
                    icon: Icons.location_on_outlined,
                    accent: const Color(0xFF16A34A),
                    expandChild: true,
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No locations found.'),
                          )
                        : (isMobile
                            ? _MobileLocationList(items: items)
                            : _DesktopLocationTable(items: items)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DesktopLocationTable extends StatefulWidget {
  const _DesktopLocationTable({required this.items});

  final List<LocationModel> items;

  @override
  State<_DesktopLocationTable> createState() => _DesktopLocationTableState();
}

class _DesktopLocationTableState extends State<_DesktopLocationTable> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _horizontalController,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                horizontalMargin: 14,
                columnSpacing: 20,
                dataRowMinHeight: 62,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('Location Name')),
                  DataColumn(label: Text('Location Code')),
                  DataColumn(label: Text('Latitude')),
                  DataColumn(label: Text('Longitude')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final location in widget.items)
                    DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              location.locationName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(location.locationCode)),
                        DataCell(Text(_formatCoordinate(location.latitude))),
                        DataCell(Text(_formatCoordinate(location.longitude))),
                        DataCell(
                          SizedBox(
                            width: 168,
                            child: Row(
                              children: [
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context.go(
                                    RoutePaths.locationViewByCode(
                                        location.locationCode),
                                  ),
                                  child: const Text('View'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onPressed: () => context.go(
                                    '${RoutePaths.locationForm}?code=${location.locationCode}',
                                  ),
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileLocationList extends StatelessWidget {
  const _MobileLocationList({required this.items});

  final List<LocationModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
