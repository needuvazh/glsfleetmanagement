import 'package:flutter/material.dart';

class FlowStepperCard extends StatelessWidget {
  const FlowStepperCard({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const steps = [
    'Feasibility Check',
    'Quotation Creation',
    'Customer Approval',
    'Order Creation',
    'Fleet + Driver Assignment',
    'Compliance Validation',
    'Journey Plan (JMP)',
    'Pre-Trip Inspection',
    'Trip Execution',
    'Delivery (POD)',
    'Documents Upload',
    'Closure',
    'Invoice',
    'Operations Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E5FB)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F9FF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / steps.length,
                minHeight: 10,
                color: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFFE8EFFB),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < steps.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= currentStep
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFD7DFEE),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i <= currentStep
                                  ? Colors.white
                                  : const Color(0xFF4D5A70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontWeight: i == currentStep
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
