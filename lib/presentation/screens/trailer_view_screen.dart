import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';
import 'trailer_store.dart';

class TrailerViewScreen extends StatelessWidget {
  const TrailerViewScreen({super.key, required this.trailerCode});

  final String trailerCode;

  @override
  Widget build(BuildContext context) {
    final trailer = TrailerStore.byCode(trailerCode);
    if (trailer == null) {
      return OpsShell(
        title: 'Trailer View',
        currentRoute: RoutePaths.trailerMaster,
        child: Center(
          child: Text('Trailer $trailerCode not found.'),
        ),
      );
    }

    return OpsShell(
      title: 'Trailer View',
      currentRoute: RoutePaths.trailerMaster,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailer.code,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _row('Trailer Type', trailer.type),
                  _row('Capacity', trailer.capacity),
                  _row('Status', trailer.status),
                  _row('Availability', trailer.availability),
                  _row(
                    'Description',
                    trailer.description.trim().isEmpty ? '-' : trailer.description,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go(RoutePaths.trailerMaster),
                child: const Text('Back to Trailer List'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () =>
                    context.go(RoutePaths.editTrailerByCode(trailer.code)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Trailer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
