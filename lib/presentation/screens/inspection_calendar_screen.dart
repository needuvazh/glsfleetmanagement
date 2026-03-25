import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionCalendarScreen extends ConsumerStatefulWidget {
  const InspectionCalendarScreen({super.key});

  @override
  ConsumerState<InspectionCalendarScreen> createState() =>
      _InspectionCalendarScreenState();
}

class _InspectionCalendarScreenState
    extends ConsumerState<InspectionCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _segment = 'Upcoming';
  String _fleetFilter = 'All';
  String _driverFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionViewModelProvider);
    final items = state.items;
    final dueRows = items
        .map((item) => _DueRow(item: item, dueDate: _dueDate(item)))
        .toList();

    final fleetOptions = [
      'All',
      ...{for (final i in items) i.fleet}.toList()..sort()
    ];
    final driverOptions = [
      'All',
      ...{for (final i in items) i.driver}.toList()..sort()
    ];

    final selectedDayRows =
        dueRows.where((row) => _sameDay(row.dueDate, _selectedDate)).toList();

    final filteredListRows = dueRows.where((row) {
      if (_fleetFilter != 'All' && row.item.fleet != _fleetFilter) {
        return false;
      }
      if (_driverFilter != 'All' && row.item.driver != _driverFilter) {
        return false;
      }

      final now = DateTime.now();
      final due =
          DateTime(row.dueDate.year, row.dueDate.month, row.dueDate.day);
      final today = DateTime(now.year, now.month, now.day);

      switch (_segment) {
        case 'Overdue':
          return due.isBefore(today);
        case 'Today':
          return _sameDay(due, today);
        case 'Upcoming':
          return due.isAfter(today);
        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return OpsShell(
      title: 'Inspection Calendar / Due',
      currentRoute: RoutePaths.inspectionCalendar,
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule next inspection placeholder.'),
              ),
            );
          },
          icon: const Icon(Icons.event_available_outlined),
          label: const Text('Schedule Next (Placeholder)'),
        ),
        const SizedBox(width: 8),
      ],
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Calendar View'),
                Tab(text: 'List View'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CalendarDatePicker(
                            initialDate: _selectedDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 2)),
                            onDateChanged: (value) {
                              setState(() => _selectedDate = value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: selectedDayRows.isEmpty
                                ? const Center(
                                    child: Text(
                                        'No inspections due for selected date.'),
                                  )
                                : ListView.builder(
                                    itemCount: selectedDayRows.length,
                                    itemBuilder: (context, index) {
                                      final row = selectedDayRows[index];
                                      return ListTile(
                                        leading: const Icon(
                                            Icons.fact_check_outlined),
                                        title: Text(
                                          '${row.item.inspectionId} • ${row.item.workOrder}',
                                        ),
                                        subtitle: Text(
                                          '${row.item.fleet} • ${row.item.driver}',
                                        ),
                                        trailing:
                                            Text(_segmentLabel(row.dueDate)),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _Drop(
                                label: 'Segment',
                                value: _segment,
                                options: const [
                                  'Upcoming',
                                  'Overdue',
                                  'Today',
                                ],
                                onChanged: (v) => setState(() => _segment = v),
                              ),
                              _Drop(
                                label: 'Fleet',
                                value: _fleetFilter,
                                options: fleetOptions,
                                onChanged: (v) =>
                                    setState(() => _fleetFilter = v),
                              ),
                              _Drop(
                                label: 'Driver',
                                value: _driverFilter,
                                options: driverOptions,
                                onChanged: (v) =>
                                    setState(() => _driverFilter = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Card(
                          child: filteredListRows.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No inspection due records for selected filters.',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredListRows.length,
                                  itemBuilder: (context, index) {
                                    final row = filteredListRows[index];
                                    return ListTile(
                                      leading:
                                          const Icon(Icons.schedule_outlined),
                                      title: Text(
                                        '${row.item.inspectionId} • ${row.item.workOrder}',
                                      ),
                                      subtitle: Text(
                                        '${row.item.fleet} • ${row.item.driver} • Due ${_fmtDate(row.dueDate)}',
                                      ),
                                      trailing:
                                          Text(_segmentLabel(row.dueDate)),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _dueDate(InspectionRecord item) {
    if (item.nextInspectionDate != null) {
      return item.nextInspectionDate!;
    }
    return item.inspectedAt.add(const Duration(days: 30));
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _segmentLabel(DateTime dueDate) {
    final now = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    if (due.isBefore(today)) {
      return 'Overdue';
    }
    if (_sameDay(due, today)) {
      return 'Today';
    }
    return 'Upcoming';
  }

  String _fmtDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }
}

class _Drop extends StatelessWidget {
  const _Drop({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _DueRow {
  const _DueRow({required this.item, required this.dueDate});

  final InspectionRecord item;
  final DateTime dueDate;
}
