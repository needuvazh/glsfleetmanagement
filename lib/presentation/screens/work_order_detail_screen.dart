import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';

class WorkOrderDetailScreen extends StatefulWidget {
  const WorkOrderDetailScreen({
    super.key,
    required this.workOrderId,
    this.initialTab,
  });

  final String workOrderId;
  final String? initialTab;

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final _WorkOrderDetailData _data;

  static const _tabOrder = [
    'summary',
    'assignment',
    'inspection',
    'trip',
    'documents',
    'history',
  ];

  @override
  void initState() {
    super.initState();
    _data = _WorkOrderDetailData.mock(widget.workOrderId);
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: _resolveInitialTab(widget.initialTab),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return OpsShell(
      title: 'Work Order Detail',
      currentRoute: RoutePaths.workOrders,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      _headlineChip('WO Number', _data.woNumber),
                      _headlineChip('Customer', _data.customer),
                      _headlineChip(
                          'Route', '${_data.origin} -> ${_data.destination}'),
                      _headlineChip('Priority', _data.priority),
                      _headlineChip('Current Status', _data.currentStatus),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Quick Actions', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _notify('Edit Work Order action queued.'),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Work Order'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(RoutePaths.assignments),
                        icon: const Icon(Icons.assignment_ind_outlined),
                        label: const Text('Assign Resources'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.go(RoutePaths.complianceInspection),
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Create Inspection'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.go(RoutePaths.journeyManagement),
                        icon: const Icon(Icons.alt_route_outlined),
                        label: const Text('Create Journey Plan'),
                      ),
                      FilledButton.icon(
                        onPressed: () => context.go(RoutePaths.tripExecution),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Dispatch'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _notify('Marked complete and logged in history.'),
                        icon: const Icon(Icons.task_alt_outlined),
                        label: const Text('Mark Complete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Assignment'),
              Tab(text: 'Inspection'),
              Tab(text: 'Trip'),
              Tab(text: 'Documents'),
              Tab(text: 'History'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SummaryTab(data: _data),
                _AssignmentTab(data: _data),
                _InspectionTab(
                  data: _data,
                  onOpenInspection: () =>
                      context.go(RoutePaths.complianceInspection),
                ),
                _TripTab(data: _data),
                _DocumentsTab(data: _data),
                _HistoryTab(data: _data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headlineChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  int _resolveInitialTab(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }
    final normalized = value.trim().toLowerCase();
    final index = _tabOrder.indexOf(normalized);
    return index < 0 ? 0 : index;
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.data});

  final _WorkOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Work Order Information',
          rows: [
            _Pair('WO Number', data.woNumber),
            _Pair('Enquiry/Reference', data.enquiryReference),
            _Pair('Customer', data.customer),
            _Pair('Priority', data.priority),
            _Pair('Current Overall Status', data.currentStatus),
          ],
        ),
        _InfoCard(
          title: 'Cargo Details',
          rows: [
            _Pair('Cargo Type', data.cargoType),
            _Pair('Quantity', data.quantity),
            _Pair('Weight', data.weight),
            _Pair('Load Type', data.loadType),
            _Pair('Special Handling', data.specialHandling),
          ],
        ),
        _InfoCard(
          title: 'Route Details',
          rows: [
            _Pair('Origin', data.origin),
            _Pair('Destination', data.destination),
            _Pair('Stop Points', data.stopPoints),
            _Pair('Route Notes', data.routeNotes),
          ],
        ),
        _InfoCard(
          title: 'Planning Details',
          rows: [
            _Pair('Requested Date', data.requestedDate),
            _Pair('Planned Dispatch Date', data.plannedDispatchDate),
            _Pair('Planned Delivery Date', data.plannedDeliveryDate),
          ],
        ),
      ],
    );
  }
}

class _AssignmentTab extends StatelessWidget {
  const _AssignmentTab({required this.data});

  final _WorkOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Assignment Details',
          rows: [
            _Pair('Fleet Assigned', data.assignedFleet),
            _Pair('Trailer Assigned', data.assignedTrailer),
            _Pair('Driver Assigned', data.assignedDriver),
            _Pair('Assignment Remarks', data.assignmentRemarks),
            _Pair('Validation Result', data.assignmentValidation),
          ],
        ),
      ],
    );
  }
}

class _InspectionTab extends StatelessWidget {
  const _InspectionTab({required this.data, required this.onOpenInspection});

  final _WorkOrderDetailData data;
  final VoidCallback onOpenInspection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Inspection Status',
          rows: [
            _Pair('Inspection Required', data.inspectionRequired),
            _Pair('Latest Inspection Result', data.latestInspectionResult),
            _Pair('Failed Items Summary', data.failedItemsSummary),
            _Pair('Inspection Media Count', data.inspectionMediaCount),
          ],
          footer: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onOpenInspection,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open Inspection Detail'),
            ),
          ),
        ),
      ],
    );
  }
}

class _TripTab extends StatelessWidget {
  const _TripTab({required this.data});

  final _WorkOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Trip Tracking',
          rows: [
            _Pair('Trip Start Status', data.tripStartStatus),
            _Pair('Latest Milestone', data.latestMilestone),
            _Pair('Delay Flag', data.delayFlag),
            _Pair('Destination Status', data.destinationStatus),
          ],
        ),
      ],
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.data});

  final _WorkOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Documents and Media',
          rows: [
            _Pair('Uploaded Documents', data.uploadedDocuments),
            _Pair('Media Files', data.mediaFiles),
            _Pair('POD Status', data.podStatus),
            _Pair('DN Status', data.dnStatus),
          ],
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.data});

  final _WorkOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Full Audit Timeline',
          rows: [
            _Pair('Status Changes', data.statusChanges),
            _Pair('Assignment Events', data.assignmentEvents),
            _Pair('Inspection Submission History', data.inspectionHistory),
            _Pair('Media Upload History', data.mediaUploadHistory),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows, this.footer});

  final String title;
  final List<_Pair> rows;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 210,
                      child: Text(
                        row.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
            if (footer != null) ...[
              const SizedBox(height: 8),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Pair {
  const _Pair(this.label, this.value);

  final String label;
  final String value;
}

class _WorkOrderDetailData {
  const _WorkOrderDetailData({
    required this.woNumber,
    required this.enquiryReference,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.priority,
    required this.currentStatus,
    required this.cargoType,
    required this.quantity,
    required this.weight,
    required this.loadType,
    required this.specialHandling,
    required this.stopPoints,
    required this.routeNotes,
    required this.requestedDate,
    required this.plannedDispatchDate,
    required this.plannedDeliveryDate,
    required this.assignedFleet,
    required this.assignedTrailer,
    required this.assignedDriver,
    required this.assignmentRemarks,
    required this.assignmentValidation,
    required this.inspectionRequired,
    required this.latestInspectionResult,
    required this.failedItemsSummary,
    required this.inspectionMediaCount,
    required this.tripStartStatus,
    required this.latestMilestone,
    required this.delayFlag,
    required this.destinationStatus,
    required this.uploadedDocuments,
    required this.mediaFiles,
    required this.podStatus,
    required this.dnStatus,
    required this.statusChanges,
    required this.assignmentEvents,
    required this.inspectionHistory,
    required this.mediaUploadHistory,
  });

  final String woNumber;
  final String enquiryReference;
  final String customer;
  final String origin;
  final String destination;
  final String priority;
  final String currentStatus;
  final String cargoType;
  final String quantity;
  final String weight;
  final String loadType;
  final String specialHandling;
  final String stopPoints;
  final String routeNotes;
  final String requestedDate;
  final String plannedDispatchDate;
  final String plannedDeliveryDate;
  final String assignedFleet;
  final String assignedTrailer;
  final String assignedDriver;
  final String assignmentRemarks;
  final String assignmentValidation;
  final String inspectionRequired;
  final String latestInspectionResult;
  final String failedItemsSummary;
  final String inspectionMediaCount;
  final String tripStartStatus;
  final String latestMilestone;
  final String delayFlag;
  final String destinationStatus;
  final String uploadedDocuments;
  final String mediaFiles;
  final String podStatus;
  final String dnStatus;
  final String statusChanges;
  final String assignmentEvents;
  final String inspectionHistory;
  final String mediaUploadHistory;

  factory _WorkOrderDetailData.mock(String workOrderId) {
    return _WorkOrderDetailData(
      woNumber: workOrderId,
      enquiryReference: 'ENQ-1022',
      customer: 'Oman Refining',
      origin: 'Muscat Terminal',
      destination: 'Salalah Zone',
      priority: 'High',
      currentStatus: 'In Progress',
      cargoType: 'Fuel Additives',
      quantity: '32 Drums',
      weight: '9.5 T',
      loadType: 'Hazmat Sealed',
      specialHandling: 'Temperature check at loading and offload points.',
      stopPoints: 'Nizwa Checkpoint, Adam Fuel Point',
      routeNotes: 'Avoid mountain bypass after 21:00.',
      requestedDate: '25/03/2026',
      plannedDispatchDate: '26/03/2026',
      plannedDeliveryDate: '27/03/2026',
      assignedFleet: 'TRK-309',
      assignedTrailer: 'TRL-88',
      assignedDriver: 'Majid Ali',
      assignmentRemarks: 'Assigned after license and insurance verification.',
      assignmentValidation:
          'Allowed: fleet available, driver valid, docs complete.',
      inspectionRequired: 'Yes',
      latestInspectionResult: 'Failed (1 critical item)',
      failedItemsSummary: 'Rear brake wear exceeds threshold.',
      inspectionMediaCount: '6 files',
      tripStartStatus: 'Started',
      latestMilestone: 'Reached Adam Fuel Point',
      delayFlag: 'Yes (42 min)',
      destinationStatus: 'En route',
      uploadedDocuments: 'WO PDF, Invoice Draft, Customer SOP',
      mediaFiles: '5 images, 1 short video',
      podStatus: 'Pending',
      dnStatus: 'Uploaded',
      statusChanges:
          'Open -> Assigned -> Inspection Failed -> Revalidated -> Dispatched',
      assignmentEvents:
          'Vehicle reassigned once due to preventive maintenance slot.',
      inspectionHistory:
          'Pre-trip failed at 09:20, corrected and rechecked at 10:05.',
      mediaUploadHistory: 'Loading bay images uploaded by supervisor at 10:20.',
    );
  }
}
