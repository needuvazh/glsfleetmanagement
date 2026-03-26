import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';

class TrailerViewScreen extends StatelessWidget {
  const TrailerViewScreen({super.key, required this.trailerCode});

  final String trailerCode;

  @override
  Widget build(BuildContext context) {
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
                    trailerCode,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text('Trailer details page is ready for master data integration.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go(RoutePaths.trailerMaster),
              child: const Text('Back to Trailer List'),
            ),
          ),
        ],
      ),
    );
  }
}
