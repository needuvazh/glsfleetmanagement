import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/tracking_point.dart';
import '../viewmodels/tracking_viewmodel.dart';
import '../widgets/tracking_vehicle_card.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: ref.read(trackingViewModelProvider.notifier).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: trackingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _TrackingError(
          message: error.toString(),
          onRetry: ref.read(trackingViewModelProvider.notifier).refresh,
        ),
        data: (state) {
          final items = state.filteredItems;
          if (items.isEmpty) {
            return const Center(child: Text('No tracked vehicles found'));
          }

          final selected = state.selected ?? items.first;
          final isMobile = Responsive.isMobile(context);

          return isMobile
              ? _TrackingMobileLayout(state: state, selected: selected)
              : _TrackingDesktopLayout(state: state, selected: selected);
        },
      ),
    );
  }
}

class _TrackingMobileLayout extends ConsumerWidget {
  const _TrackingMobileLayout({required this.state, required this.selected});

  final TrackingUiState state;
  final TrackingPoint selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _TrackingToolbar(state: state),
        SizedBox(
          height: 320,
          child: _TrackingMap(state: state, selected: selected),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: ref.read(trackingViewModelProvider.notifier).refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: state.filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = state.filteredItems[index];
                return TrackingVehicleCard(
                  point: item,
                  isSelected: selected.id == item.id,
                  onTap: () =>
                      ref.read(trackingViewModelProvider.notifier).setSelected(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingDesktopLayout extends ConsumerWidget {
  const _TrackingDesktopLayout({required this.state, required this.selected});

  final TrackingUiState state;
  final TrackingPoint selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _TrackingToolbar(state: state),
              Expanded(child: _TrackingMap(state: state, selected: selected)),
            ],
          ),
        ),
        SizedBox(
          width: 380,
          child: RefreshIndicator(
            onRefresh: ref.read(trackingViewModelProvider.notifier).refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = state.filteredItems[index];
                return TrackingVehicleCard(
                  point: item,
                  isSelected: selected.id == item.id,
                  onTap: () =>
                      ref.read(trackingViewModelProvider.notifier).setSelected(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingToolbar extends ConsumerWidget {
  const _TrackingToolbar({required this.state});

  final TrackingUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: ref.read(trackingViewModelProvider.notifier).setQuery,
            decoration: const InputDecoration(
              hintText: 'Search by vehicle, driver, status...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: TrackingFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = TrackingFilter.values[index];
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: state.filter == filter,
                  onSelected: (_) =>
                      ref.read(trackingViewModelProvider.notifier).setFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Vehicles ${state.filteredItems.length}'),
              const Spacer(),
              Text(
                'Updated ${_formatTime(state.lastUpdated)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _TrackingMap extends ConsumerWidget {
  const _TrackingMap({required this.state, required this.selected});

  final TrackingUiState state;
  final TrackingPoint selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = state.filteredItems.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude, item.longitude),
        infoWindow: InfoWindow(
          title: item.vehicleNumber,
          snippet: '${item.driver} • ${item.speedKph.toStringAsFixed(0)} km/h',
        ),
        onTap: () => ref.read(trackingViewModelProvider.notifier).setSelected(item.id),
      );
    }).toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GoogleMap(
          mapToolbarEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(selected.latitude, selected.longitude),
            zoom: 8,
          ),
          markers: markers,
          onTap: (_) => ref
              .read(trackingViewModelProvider.notifier)
              .setSelected(selected.id),
        ),
      ),
    );
  }
}

class _TrackingError extends StatelessWidget {
  const _TrackingError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
