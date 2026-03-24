import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class ClosureScreen extends StatefulWidget {
  const ClosureScreen({super.key});

  @override
  State<ClosureScreen> createState() => _ClosureScreenState();
}

class _ClosureScreenState extends State<ClosureScreen> {
  final _distance = TextEditingController(text: '350');
  final _fuelAvg = TextEditingController(text: '5.8');
  String _complianceStatus = 'Passed';
  bool _managerApproval = false;

  @override
  void dispose() {
    _distance.dispose();
    _fuelAvg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: 'Closure',
      currentRoute: RoutePaths.closure,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.invoice),
          child: const Text('Next'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlowStepperCard(currentStep: 11),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Trip Closure Summary',
            subtitle: 'Distance, fuel average, compliance and approval',
            icon: Icons.task_alt_outlined,
            accent: const Color(0xFF16A34A),
            child: Column(
                children: [
                  TextField(
                    controller: _distance,
                    decoration: const InputDecoration(labelText: 'Distance Covered (km)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fuelAvg,
                    decoration: const InputDecoration(labelText: 'Fuel Average (km/l)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _complianceStatus,
                    items: const [
                      DropdownMenuItem(value: 'Passed', child: Text('Compliance Passed')),
                      DropdownMenuItem(value: 'Pending', child: Text('Compliance Pending')),
                      DropdownMenuItem(value: 'Failed', child: Text('Compliance Failed')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _complianceStatus = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Compliance Status'),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _managerApproval,
                    onChanged: (value) => setState(() => _managerApproval = value ?? false),
                    title: const Text('Manager Approval'),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
