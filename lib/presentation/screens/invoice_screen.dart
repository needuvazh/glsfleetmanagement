import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  final _base = TextEditingController(text: '12000');
  final _extra = TextEditingController(text: '1800');
  final _tax = TextEditingController(text: '18');

  @override
  void dispose() {
    _base.dispose();
    _extra.dispose();
    _tax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(logisticsViewModelProvider).valueOrNull;
    final base = double.tryParse(_base.text) ?? 0;
    final extra = double.tryParse(_extra.text) ?? 0;
    final taxRate = (double.tryParse(_tax.text) ?? 0) / 100;
    final total = (base + extra) * (1 + taxRate);

    return OpsShell(
      title: 'Invoice',
      currentRoute: RoutePaths.invoice,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FlowStepperCard(currentStep: 12),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Invoice Builder',
            subtitle: 'Base cost, extras, tax and final invoice total',
            icon: Icons.receipt_long_outlined,
            accent: const Color(0xFF7C3AED),
            child: Column(
                children: [
                  TextField(
                    controller: _base,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Base Cost'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _extra,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Extra Charges'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _tax,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Tax %'),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  _row('Base Cost', base),
                  _row('Extra Charges', extra),
                  _row('Tax', (base + extra) * taxRate),
                  const Divider(),
                  _row('Final Amount', total, bold: true),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invoice generated successfully')), 
                      ),
                      child: const Text('Generate Invoice'),
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 12),
          OpsSectionCard(
            title: 'Operations Report',
            subtitle: 'Customer, vehicle, trips, sales, cost and profit',
            icon: Icons.table_chart_outlined,
            accent: const Color(0xFF16A34A),
            child: flow == null
                ? const Text('No report data available.')
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                      columns: const [
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Vehicle')),
                        DataColumn(label: Text('Trips')),
                        DataColumn(label: Text('Sales')),
                        DataColumn(label: Text('Cost')),
                        DataColumn(label: Text('Profit')),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            DataCell(Text(flow.workOrders.isEmpty
                                ? '-'
                                : flow.workOrders.first.customer)),
                            DataCell(Text(flow.assignedVehicleNo ?? '-')),
                            DataCell(Text('${flow.workOrders.length}')),
                            DataCell(Text(flow.customerRate.toStringAsFixed(2))),
                            DataCell(Text(flow.totalCost.toStringAsFixed(2))),
                            DataCell(Text(flow.profit.toStringAsFixed(2))),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
