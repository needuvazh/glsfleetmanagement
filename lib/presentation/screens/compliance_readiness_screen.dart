import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class ComplianceReadinessScreen extends ConsumerStatefulWidget {
  const ComplianceReadinessScreen({super.key, this.workOrderId});

  final String? workOrderId;

  @override
  ConsumerState<ComplianceReadinessScreen> createState() => _ComplianceReadinessScreenState();
}

class _ComplianceReadinessScreenState extends ConsumerState<ComplianceReadinessScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Compliance Readiness',
      currentRoute: RoutePaths.complianceReadiness,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          // If workOrderId is provided, focus on that specific order.
          // Otherwise, show a general registry (for this demo, we'll use a placeholder or the last assigned order).
          final orderId = widget.workOrderId ?? data.assignedOrderId;
          final order = data.workOrders.firstWhere(
            (o) => o.woId == orderId,
            orElse: () => data.workOrders.first,
          );

          final vehicle = data.vehicles.where((v) => v.vehicleNo == order.assignedVehicleNo).firstOrNull;
          final driver = data.drivers.where((d) => d.driverId == order.assignedDriverId).firstOrNull;

          List<_ReadinessItem> fleetDocs = [];
          if (vehicle != null) {
            fleetDocs = [
              _ReadinessItem('Vehicle Registration', '15/05/2026', 'Valid', 'Hard-block'),
              _ReadinessItem('Insurance Policy', '20/12/2026', 'Valid', 'None'),
              _ReadinessItem('Road Worthiness', '01/04/2026', vehicle.status.toLowerCase() == 'maintenance' ? 'Expired' : 'Valid', 'Hard-block'),
            ];
          }

          List<_ReadinessItem> driverDocs = [];
          if (driver != null) {
            final licStatus = driver.licenseValid ? 'Valid' : 'Expired';
            driverDocs = [
              _ReadinessItem('Driving License', driver.expiryDate, licStatus, 'Hard-block'),
              _ReadinessItem('Medical Fitness', '15/08/2026', driver.medicalFitnessNote.contains('Fit') ? 'Valid' : 'Valid', 'None'),
              _ReadinessItem('DDC Training', '-', driver.defensiveDrivingStatus, 'Soft-block'),
            ];
          }

          List<_ReadinessItem> trackingDocs = [];
          if (vehicle != null) {
             trackingDocs = [
              _ReadinessItem('IVMS Connectivity', '-', vehicle.ivmsDeviceId.isNotEmpty ? 'Active' : 'Offline', 'None'),
              if (driver != null) _ReadinessItem('DFMS Calibration', '-', driver.dfmsDeviceId.isNotEmpty ? 'Active' : 'Offline', 'None'),
            ];
          }

          List<_ReadinessItem> customerDocs = [];
          if (driver != null) {
            customerDocs = [
              _ReadinessItem('PDO Safety Induction', '-', driver.pdoPassportStatus, 'Hard-block'),
              _ReadinessItem('H2S Training', '-', driver.h2sStatus, 'Hard-block'),
            ];
          }

          final allItems = [...fleetDocs, ...driverDocs, ...trackingDocs, ...customerDocs];
          int readyCount = 0;
          int warningCount = 0;
          int blockedCount = 0;

          for (var item in allItems) {
            if (item.status == 'Valid' || item.status == 'Active' || item.status == 'Not Required') readyCount++;
            else if (item.status == 'Expiring Soon') warningCount++;
            else if (item.status == 'Expired' || item.status == 'Offline') {
               if (item.blocking == 'Hard-block') blockedCount++;
               else warningCount++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(order),
                const SizedBox(height: 24),
                _buildRagSummary(readyCount, warningCount, blockedCount),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Fleet Documents',
                  icon: Icons.local_shipping_outlined,
                  items: fleetDocs,
                ),
                if (order.assignedTrailerId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Trailer Documents',
                    icon: Icons.rv_hookup_outlined,
                    items: [
                      _ReadinessItem('Trailer Permit', '10/10/2026', 'Valid', 'Hard-block'),
                      _ReadinessItem('Brake Test Cert', '15/09/2026', 'Valid', 'Hard-block'),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Driver Documents',
                  icon: Icons.person_outline,
                  items: driverDocs,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Tracking / IVMS / DFMS',
                  icon: Icons.gps_fixed_outlined,
                  items: trackingDocs,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Customer-specific Rules',
                  icon: Icons.gavel_outlined,
                  items: customerDocs,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(WorkOrderFlowItem order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Readiness Tracker: ${order.woId}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Customer: ${order.customer} | Route: ${order.route}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRagSummary(int ready, int warning, int blocked) {
    return Row(
      children: [
        _RagCard('READY', ready.toString(), Colors.green, Icons.check_circle_outline),
        const SizedBox(width: 16),
        _RagCard('WARNING', warning.toString(), Colors.orange, Icons.warning_amber_outlined),
        const SizedBox(width: 16),
        _RagCard('BLOCKED', blocked.toString(), Colors.red, Icons.block_outlined),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<_ReadinessItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    String status = 'Green';
    for (var item in items) {
      if (item.status == 'Expired' || item.status == 'Offline') {
         if (item.blocking == 'Hard-block') status = 'Red';
         else if (status != 'Red') status = 'Amber';
      } else if (item.status == 'Expiring Soon' && status != 'Red') {
         status = 'Amber';
      }
    }

    final statusColor = status == 'Green' ? Colors.green : (status == 'Amber' ? Colors.orange : Colors.red);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: statusColor),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.2),
                4: FixedColumnWidth(120),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('Document Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Blocking Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                for (final item in items)
                  TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.name, style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.expiry, style: const TextStyle(fontSize: 13))),
                      Padding(padding: const EdgeInsets.all(8), child: _statusLabel(item.status)),
                      Padding(padding: const EdgeInsets.all(8), child: _blockingLabel(item.blocking)),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 18),
                              onPressed: () {},
                              tooltip: 'Recheck',
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: () {},
                              tooltip: 'Open Master',
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_box_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Mark Cleared',
                            ),
                          ],
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

  Widget _statusLabel(String status) {
    Color color = Colors.grey;
    if (status == 'Valid' || status == 'Active' || status == 'Not Required') color = Colors.green;
    if (status == 'Expiring Soon') color = Colors.orange;
    if (status == 'Expired' || status == 'Offline') color = Colors.red;

    return Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

  Widget _blockingLabel(String type) {
    Color color = Colors.grey;
    if (type == 'Hard-block') color = Colors.red;
    if (type == 'Soft-block') color = Colors.orange;

    return Text(
      type,
      style: TextStyle(color: color, fontWeight: FontWeight.normal, fontSize: 12),
    );
  }
}

class _RagCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;

  const _RagCard(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.7), letterSpacing: 1.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessItem {
  final String name;
  final String expiry;
  final String status;
  final String blocking;

  _ReadinessItem(this.name, this.expiry, this.status, this.blocking);
}
