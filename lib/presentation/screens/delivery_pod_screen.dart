import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class DeliveryPodScreen extends StatefulWidget {
  const DeliveryPodScreen({super.key});

  @override
  State<DeliveryPodScreen> createState() => _DeliveryPodScreenState();
}

class _DeliveryPodScreenState extends State<DeliveryPodScreen> {
  final _arrival = TextEditingController();
  final _receiver = TextEditingController();

  @override
  void dispose() {
    _arrival.dispose();
    _receiver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: 'Delivery & POD',
      currentRoute: RoutePaths.deliveryPod,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.documentSubmission),
          child: const Text('Next'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlowStepperCard(currentStep: 9),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Delivery Confirmation',
            subtitle: 'Capture POD details and proof uploads',
            icon: Icons.inventory_2_outlined,
            accent: const Color(0xFF0EA5E9),
            child: Column(
                children: [
                  TextField(
                    controller: _arrival,
                    decoration: const InputDecoration(labelText: 'Arrival Time'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _receiver,
                    decoration: const InputDecoration(labelText: 'Receiver Name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signature upload (mock)')),
                          ),
                          icon: const Icon(Icons.draw_outlined),
                          label: const Text('Upload Signature'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload (mock)')),
                          ),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Upload Photo'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
