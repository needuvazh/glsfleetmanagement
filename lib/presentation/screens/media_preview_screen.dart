import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/media_evidence_viewmodel.dart';
import '../widgets/ops_shell.dart';

class MediaPreviewScreen extends ConsumerWidget {
  const MediaPreviewScreen({super.key, required this.evidenceId});

  final String evidenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaEvidenceProvider).byId(evidenceId);
    if (item == null) {
      return OpsShell(
        title: 'Media Preview',
        currentRoute: RoutePaths.mediaGallery,
        child: const Center(child: Text('Media evidence not found.')),
      );
    }

    return OpsShell(
      title: 'Media Preview',
      currentRoute: RoutePaths.mediaGallery,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _PreviewCanvas(item: item),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _openFullscreenPreview(context, item),
                      icon: const Icon(Icons.open_in_full_outlined),
                      label: const Text('Open Full Preview'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Context',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _pair('File', item.fileName),
                  _pair('Related Record',
                      '${item.linkedModule} • ${item.linkedRecord}'),
                  _pair('Timestamp', _fmtDateTime(item.capturedAt)),
                  _pair('Uploader', item.capturedBy),
                  _pair('Remarks', item.remarks),
                  const SizedBox(height: 8),
                  Text(
                    'Open Linked Records',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.workOrder != null && item.workOrder!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            RoutePaths.workOrderDetailById(item.workOrder!),
                          ),
                          icon: const Icon(Icons.assignment_outlined),
                          label: Text('WO ${item.workOrder}'),
                        ),
                      if (item.inspection != null &&
                          item.inspection!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            RoutePaths.inspectionDetailById(item.inspection!),
                          ),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: Text('Inspection ${item.inspection}'),
                        ),
                      if (item.fleet != null && item.fleet!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            RoutePaths.fleetDetailById(item.fleet!),
                          ),
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: Text('Fleet ${item.fleet}'),
                        ),
                      if (item.driver != null && item.driver!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            RoutePaths.driverDetailById(item.driver!),
                          ),
                          icon: const Icon(Icons.badge_outlined),
                          label: Text('Driver ${item.driver}'),
                        ),
                      if (item.trip != null && item.trip!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push(RoutePaths.tripMonitoring),
                          icon: const Icon(Icons.alt_route_outlined),
                          label: Text('Trip ${item.trip}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linked Audit Records',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  for (final audit in item.linkedAuditRecords)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.history_outlined),
                      title: Text(audit),
                    ),
                  if (item.linkedAuditRecords.isEmpty)
                    const Text('No linked audit records found.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreenPreview(BuildContext context, MediaEvidenceItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(item.fileName),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: _PreviewCanvas(item: item, large: true),
            ),
          ),
        );
      },
    );
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}

class _PreviewCanvas extends StatelessWidget {
  const _PreviewCanvas({required this.item, this.large = false});

  final MediaEvidenceItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final height = large ? 520.0 : 280.0;

    if (item.type == MediaEvidenceType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          width: double.infinity,
          color: const Color(0xFFE8F1FB),
          child: Image.asset(
            'assets/images/gls_logo.jpg',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 52),
            ),
          ),
        ),
      );
    }

    if (item.type == MediaEvidenceType.video) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF111827),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill_rounded,
                color: Colors.white, size: 72),
            const SizedBox(height: 10),
            Text(
              'Video Preview • ${item.fileName}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              width: large ? 500 : 260,
              height: 4,
              color: Colors.white24,
              alignment: Alignment.centerLeft,
              child: Container(width: 120, height: 4, color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF3F5F8),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insert_drive_file_outlined),
              SizedBox(width: 8),
              Text('Document Preview'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.fileName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(item.remarks),
          const SizedBox(height: 16),
          const Text(
            'This panel renders document metadata and contextual notes. Full binary document viewer can be connected to storage service URL when available.',
          ),
        ],
      ),
    );
  }
}
