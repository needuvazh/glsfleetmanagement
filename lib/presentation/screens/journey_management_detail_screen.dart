import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class JourneyManagementDetailScreen extends ConsumerStatefulWidget {
  const JourneyManagementDetailScreen({
    super.key, 
    required this.jmpId,
    this.initialWoId,
  });

  final String jmpId;
  final String? initialWoId;

  @override
  ConsumerState<JourneyManagementDetailScreen> createState() => _JourneyManagementDetailScreenState();
}

class _JourneyManagementDetailScreenState extends ConsumerState<JourneyManagementDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedWoId;
  String? _selectedRouteId;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TextEditingController _stopsController;
  late TextEditingController _durationController;
  late TextEditingController _restPointsController;
  late TextEditingController _commPlanController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _instructionsController;

  String _riskLevel = 'Low';
  String _status = 'Draft';
  bool _isNew = false;
  bool _hasInitializedFromLink = false;
  JourneyManagementPlan? _existingPlan;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();
    _stopsController = TextEditingController();
    _durationController = TextEditingController();
    _restPointsController = TextEditingController();
    _commPlanController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _instructionsController = TextEditingController();
    
    _isNew = widget.jmpId == 'new';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNew && _existingPlan == null) {
      final state = ref.read(logisticsViewModelProvider).valueOrNull;
      if (state != null) {
        final plan = state.journeyPlans.where((p) => p.jmpId == widget.jmpId).firstOrNull;
        if (plan != null) {
          _existingPlan = plan;
          _selectedWoId = plan.woId;
          // Try to derive the routeId if possible from the WO, since it's saved as raw text
          final wo = state.workOrders.where((w) => w.woId == plan.woId).firstOrNull;
          if (wo != null && wo.routeMasterId.isNotEmpty) {
            final exists = state.journeyMaster.any((jm) => jm.journeyId == wo.routeMasterId);
            _selectedRouteId = exists ? wo.routeMasterId : null;
          }
          _originController.text = plan.routeOrigin;
          _destinationController.text = plan.routeDestination;
          _stopsController.text = plan.routeStops.join(', ');
          _durationController.text = plan.estimatedDuration;
          _restPointsController.text = plan.restPoints.join(', ');
          _commPlanController.text = plan.communicationPlan;
          _emergencyContactController.text = plan.emergencyContact;
          _instructionsController.text = plan.specialInstructions;
          _riskLevel = plan.riskLevel;
          _status = plan.status;
        }
      }
    }
  }

  void _populateFromWorkOrder(String woId) {
    final state = ref.read(logisticsViewModelProvider).valueOrNull;
    if (state == null) return;
    
    final wo = state.workOrders.where((w) => w.woId == woId).firstOrNull;
    if (wo == null) return;
    
    final routeExists = state.journeyMaster.any((jm) => jm.journeyId == wo.routeMasterId);
    if (wo.routeMasterId.isNotEmpty && routeExists) {
      _selectedRouteId = wo.routeMasterId;
      _populateFromRouteMaster(wo.routeMasterId, state);
    } else {
      _selectedRouteId = null;
      final split = wo.route.split('->');
      _originController.text = split.isNotEmpty ? split.first.trim() : '';
      _destinationController.text = split.length > 1 ? split.last.trim() : '';
    }

    final validRisks = ['Low', 'Medium', 'High'];
    if (validRisks.contains(wo.routeRiskLevel)) {
      _riskLevel = wo.routeRiskLevel;
    }
  }

  void _populateFromRouteMaster(String routeId, LogisticsUiState state) {
    final routeMaster = state.journeyMaster.where((jm) => jm.journeyId == routeId).firstOrNull;
    if (routeMaster != null) {
      _originController.text = routeMaster.origin;
      _destinationController.text = routeMaster.destination;
      _stopsController.text = routeMaster.stops.join(', ');
      _restPointsController.text = routeMaster.restPoints.join(', ');
      if (_durationController.text.isEmpty) {
        _durationController.text = '12 hrs'; 
      }
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _stopsController.dispose();
    _durationController.dispose();
    _restPointsController.dispose();
    _commPlanController.dispose();
    _emergencyContactController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save(String targetStatus) {
    if (!_formKey.currentState!.validate()) return;

    final newPlan = JourneyManagementPlan(
      jmpId: _isNew ? 'JMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}' : widget.jmpId,
      woId: _selectedWoId ?? '',
      status: targetStatus,
      routeOrigin: _originController.text.trim(),
      routeDestination: _destinationController.text.trim(),
      routeStops: _stopsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      estimatedDuration: _durationController.text.trim(),
      restPoints: _restPointsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      communicationPlan: _commPlanController.text.trim(),
      riskLevel: _riskLevel,
      emergencyContact: _emergencyContactController.text.trim(),
      specialInstructions: _instructionsController.text.trim(),
      createdAt: _existingPlan?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final msg = ref.read(logisticsViewModelProvider.notifier).saveJourneyPlan(newPlan);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    context.pop();
  }

  void _updateStatusOnly(String newStatus) {
    final msg = ref.read(logisticsViewModelProvider.notifier).updateJourneyPlanStatus(widget.jmpId, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() => _status = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider).valueOrNull;
    
    // Auto-populate initial WO if state is ready and it hasn't been done yet
    if (state != null && _isNew && !_hasInitializedFromLink && widget.initialWoId != null) {
      _hasInitializedFromLink = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final woExists = state.workOrders.any((wo) => wo.woId == widget.initialWoId);
          if (woExists) {
            setState(() {
              _selectedWoId = widget.initialWoId;
              _populateFromWorkOrder(widget.initialWoId!);
            });
          }
        }
      });
    }

    return OpsShell(
      title: _isNew ? 'Create Journey Plan' : 'JMP Details: ${widget.jmpId}',
      currentRoute: RoutePaths.journeyManagement,
      actions: const [], // Actions moved to bottom
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 16),
              _buildRouteSection(),
              const SizedBox(height: 16),
              _buildTravelPlanSection(),
              const SizedBox(height: 16),
              _buildRiskSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade600),
            onPressed: () => _save('Draft'),
            icon: const Icon(Icons.drafts),
            label: const Text('Save as Draft'),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade600),
            onPressed: () => _save('Ready'),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Submit'),
          ),
          if (!_isNew) ...[
            const SizedBox(width: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _updateStatusOnly('Approved'),
              icon: const Icon(Icons.thumb_up),
              label: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return OpsSectionCard(
      title: 'Context',
      icon: Icons.info_outline,
      accent: Colors.grey.shade700,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_status, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(logisticsViewModelProvider).valueOrNull;
              final workOrders = state?.workOrders ?? [];
              
              if (workOrders.isEmpty) {
                return const Text('No active Work Orders found.');
              }
              
              return DropdownButtonFormField<String>(
                value: _selectedWoId,
                decoration: const InputDecoration(labelText: 'Linked Work Order ID', border: OutlineInputBorder()),
                items: workOrders.map((wo) {
                  return DropdownMenuItem(
                    value: wo.woId,
                    child: Text('${wo.woId} - ${wo.route}'),
                  );
                }).toList(),
                onChanged: _isNew 
                  ? (val) {
                      if (val != null) {
                        setState(() {
                          _selectedWoId = val;
                          _populateFromWorkOrder(val);
                        });
                      }
                    }
                  : null, // Disable changing linked WO on existing plans
                validator: (val) => val == null || val.isEmpty ? 'Work Order is required' : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return OpsSectionCard(
      title: 'Route Details',
      icon: Icons.map_outlined,
      accent: Colors.indigo,
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(logisticsViewModelProvider).valueOrNull;
              final routes = state?.journeyMaster ?? [];
              
              if (routes.isEmpty) {
                return const Text('No Route Master data available.');
              }
              
              return DropdownButtonFormField<String>(
                value: _selectedRouteId,
                decoration: const InputDecoration(labelText: 'Select Route Master Profile', border: OutlineInputBorder()),
                items: routes.map((rm) {
                  return DropdownMenuItem(
                    value: rm.journeyId,
                    child: Text('${rm.journeyId} (${rm.origin} -> ${rm.destination})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && state != null) {
                    setState(() {
                      _selectedRouteId = val;
                      _populateFromRouteMaster(val, state);
                    });
                  }
                },
                validator: (val) => val == null || val.isEmpty ? 'Route Details selection is required' : null,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _originController,
                  decoration: const InputDecoration(labelText: 'Start Point', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _stopsController,
            decoration: const InputDecoration(labelText: 'Stop Points (Comma separated)', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelPlanSection() {
    return OpsSectionCard(
      title: 'Travel Plan',
      icon: Icons.schedule_outlined,
      accent: Colors.blue,
      child: Column(
        children: [
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Estimated Duration (e.g., 8 hrs)', border: OutlineInputBorder()),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _restPointsController,
            decoration: const InputDecoration(labelText: 'Rest Areas & Accommodations', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commPlanController,
            decoration: const InputDecoration(labelText: 'Communication Plan', hintText: 'e.g., Call base every 4 hours.', border: OutlineInputBorder(), alignLabelWithHint: true),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSection() {
    return OpsSectionCard(
      title: 'Risk Assessment',
      icon: Icons.warning_amber_outlined,
      accent: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _riskLevel,
            decoration: const InputDecoration(labelText: 'Risk Level', border: OutlineInputBorder()),
            items: ['Low', 'Medium', 'High'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) => setState(() => _riskLevel = val!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emergencyContactController,
            decoration: const InputDecoration(labelText: 'Emergency Contact', border: OutlineInputBorder()),
            validator: (val) {
              if ((_riskLevel == 'Medium' || _riskLevel == 'High') && (val == null || val.trim().isEmpty)) {
                return 'Required for Medium/High risk trips';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instructionsController,
            decoration: const InputDecoration(labelText: 'Special Instructions', border: OutlineInputBorder(), alignLabelWithHint: true),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
