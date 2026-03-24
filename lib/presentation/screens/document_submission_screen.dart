import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class DocumentSubmissionScreen extends StatefulWidget {
  const DocumentSubmissionScreen({super.key});

  @override
  State<DocumentSubmissionScreen> createState() => _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState extends State<DocumentSubmissionScreen> {
  final _docs = {
    'DN (Delivery Note)': false,
    'POD': false,
    'Trip Sheet': false,
    'Fuel Log': false,
  };

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: 'Document Submission',
      currentRoute: RoutePaths.documentSubmission,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.closure),
          child: const Text('Next'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlowStepperCard(currentStep: 10),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Document Upload',
            subtitle: 'DN, POD, trip sheet and fuel log submission',
            icon: Icons.upload_file_outlined,
            accent: const Color(0xFF2563EB),
            child: Column(
                children: [
                  for (final entry in _docs.entries)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: entry.value,
                      title: Text(entry.key),
                      secondary: const Icon(Icons.upload_file_outlined),
                      onChanged: (value) {
                        setState(() {
                          _docs[entry.key] = value ?? false;
                        });
                      },
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        final uploaded = _docs.values.where((v) => v).length;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$uploaded document(s) uploaded')), 
                        );
                      },
                      child: const Text('Submit Documents'),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
