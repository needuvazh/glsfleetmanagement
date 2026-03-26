import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/oman_fleet_master.dart';
import '../../core/utils/responsive.dart';
import '../../domain/cargo_model.dart';
import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
import '../viewmodels/route_viewmodel.dart';
import '../viewmodels/vehicle_type_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CargoFormScreen extends ConsumerStatefulWidget {
  const CargoFormScreen({super.key, this.editCargoCode});

  final String? editCargoCode;

  @override
  ConsumerState<CargoFormScreen> createState() => _CargoFormScreenState();
}

class _CargoFormScreenState extends ConsumerState<CargoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cargoCode = TextEditingController();
  final _cargoName = TextEditingController();
  final _category = TextEditingController();
  final _subcategory = TextEditingController();
  final _weightRange = TextEditingController();
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _sizeClass = TextEditingController();
  final _riskNotes = TextEditingController();
  final _preferredVehicleType = TextEditingController();
  final _preferredTrailerType = TextEditingController();
  final _loadingMethod = TextEditingController();
  final _unloadingMethod = TextEditingController();
  final _specialEquipment = TextEditingController();
  final _handlingInstructions = TextEditingController();
  final _requiredCertifications = TextEditingController();
  final _requiredPermits = TextEditingController();
  final _customerRestrictions = TextEditingController();
  final _complianceNotes = TextEditingController();
  final _inspectionTemplate = TextEditingController();
  final _inspectionNotes = TextEditingController();
  final _restrictionReason = TextEditingController();

  CargoStatus _status = CargoStatus.active;
  CargoRiskLevel _riskLevel = CargoRiskLevel.low;

  bool _oversized = false;
  bool _hazardous = false;
  bool _fragile = false;
  bool _temperatureSensitive = false;
  bool _specialHandlingRequired = false;
  bool _lashingRequired = false;
  bool _escortRequired = false;
  bool _specialComplianceRequired = false;
  bool _authorityApprovalNeeded = false;
  bool _inspectionRequired = true;
  bool _preDispatchInspectionRequired = true;
  bool _inTransitCheckRequired = false;
  bool _postDeliveryCheckRequired = false;
  bool _photoEvidenceMandatory = false;
  bool _videoEvidenceMandatory = false;
  bool _restricted = false;

  bool _hydrated = false;

  bool get _isEdit => widget.editCargoCode != null;

  @override
  void dispose() {
    _cargoCode.dispose();
    _cargoName.dispose();
    _category.dispose();
    _subcategory.dispose();
    _weightRange.dispose();
    _length.dispose();
    _width.dispose();
    _height.dispose();
    _sizeClass.dispose();
    _riskNotes.dispose();
    _preferredVehicleType.dispose();
    _preferredTrailerType.dispose();
    _loadingMethod.dispose();
    _unloadingMethod.dispose();
    _specialEquipment.dispose();
    _handlingInstructions.dispose();
    _requiredCertifications.dispose();
    _requiredPermits.dispose();
    _customerRestrictions.dispose();
    _complianceNotes.dispose();
    _inspectionTemplate.dispose();
    _inspectionNotes.dispose();
    _restrictionReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cargoViewModelProvider);
    final vehicleTypeState = ref.watch(vehicleTypeViewModelProvider).valueOrNull;
    final routeState = ref.watch(routeViewModelProvider).valueOrNull;

    return OpsShell(
      title: _isEdit ? 'Edit Cargo' : 'Create Cargo',
      currentRoute: RoutePaths.cargoMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.cargoMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          if (!_hydrated && _isEdit) {
            final source = ref
                .read(cargoViewModelProvider.notifier)
                .findByCode(widget.editCargoCode);
            if (source != null) {
              _hydrate(source);
            }
            _hydrated = true;
          }
          final categoryOptions = _withCurrent(
            source: data.items
                .map((item) => item.category.trim())
                .where((item) => item.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
            current: _category.text.trim(),
          );
          final subcategoryOptions = _withCurrent(
            source: data.items
                .where(
                  (item) => item.category.trim().toLowerCase() ==
                      _category.text.trim().toLowerCase(),
                )
                .map((item) => item.subcategory.trim())
                .where((item) => item.isNotEmpty)
                .toSet()
                .toList()
              ..sort(),
            current: _subcategory.text.trim(),
          );
          final vehicleSource = vehicleTypeState == null ||
                  vehicleTypeState.items.isEmpty
              ? <String>[...OmanFleetMaster.fleetTypes]
              : vehicleTypeState.items
                  .where((item) => item.status.toLowerCase() == 'active')
                  .map((item) => item.name.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList();
          vehicleSource.sort();
          final vehicleTypeOptions = _withCurrent(
            source: vehicleSource,
            current: _preferredVehicleType.text.trim(),
          );

          final trailerSource = routeState == null || routeState.routes.isEmpty
              ? data.items
                  .map((item) => item.preferredTrailerType.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList()
              : routeState.routes
                  .map((item) => item.trailerTypePreference.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList();
          trailerSource.sort();
          final trailerTypeOptions = _withCurrent(
            source: trailerSource,
            current: _preferredTrailerType.text.trim(),
          );
          final inspectionTemplateOptions = _withCurrent(
            source: [
              for (final item in InspectionType.values) item.label,
            ],
            current: _inspectionTemplate.text.trim(),
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(
                  title: '1. Basic Cargo Identity',
                  subtitle:
                      'Define what the cargo is and whether it is selectable',
                  child: Column(
                    children: [
                      _row(
                        context,
                        TextFormField(
                          controller: _cargoCode,
                          decoration:
                              const InputDecoration(labelText: 'Cargo Code'),
                        ),
                        TextFormField(
                          controller: _cargoName,
                          decoration:
                              const InputDecoration(labelText: 'Cargo Name *'),
                          validator: _required,
                        ),
                        DropdownButtonFormField<String?>(
                          value: _category.text.trim().isEmpty
                              ? null
                              : _category.text.trim(),
                          decoration:
                              const InputDecoration(labelText: 'Category *'),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          items: [
                            for (final item in categoryOptions)
                              DropdownMenuItem<String?>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            final previous = _category.text.trim().toLowerCase();
                            setState(() {
                              _category.text = value ?? '';
                              final next = _category.text.trim().toLowerCase();
                              if (previous != next) {
                                _subcategory.clear();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        DropdownButtonFormField<String?>(
                          value: _subcategory.text.trim().isEmpty
                              ? null
                              : _subcategory.text.trim(),
                          decoration:
                              const InputDecoration(labelText: 'Subcategory'),
                          items: [
                            for (final item in subcategoryOptions)
                              DropdownMenuItem<String?>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _subcategory.text = value ?? '';
                            });
                          },
                        ),
                        DropdownButtonFormField<CargoStatus>(
                          value: _status,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          items: [
                            for (final item in CargoStatus.values)
                              DropdownMenuItem(
                                  value: item, child: Text(item.label)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                        ),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '2. Physical Characteristics',
                  subtitle: 'Dimensions and transport impact factors',
                  child: Column(
                    children: [
                      _row(
                        context,
                        TextFormField(
                          controller: _weightRange,
                          decoration: const InputDecoration(
                              labelText: 'Standard Weight Range'),
                        ),
                        TextFormField(
                          controller: _length,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Length'),
                          validator: _nonNegative,
                        ),
                        TextFormField(
                          controller: _width,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(labelText: 'Width'),
                          validator: _nonNegative,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        TextFormField(
                          controller: _height,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Height'),
                          validator: _nonNegative,
                        ),
                        TextFormField(
                          controller: _sizeClass,
                          decoration: const InputDecoration(
                              labelText: 'Volume / Size Class'),
                        ),
                        SwitchListTile(
                          value: _oversized,
                          onChanged: (value) =>
                              setState(() => _oversized = value),
                          title: const Text('Oversized'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '3. Risk Classification',
                  subtitle: 'Risk level and sensitive handling attributes',
                  child: Column(
                    children: [
                      _row(
                        context,
                        DropdownButtonFormField<CargoRiskLevel>(
                          value: _riskLevel,
                          decoration:
                              const InputDecoration(labelText: 'Risk Level'),
                          items: [
                            for (final level in CargoRiskLevel.values)
                              DropdownMenuItem(
                                  value: level, child: Text(level.label)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _riskLevel = value);
                            }
                          },
                        ),
                        _switch('Hazardous', _hazardous,
                            (value) => setState(() => _hazardous = value)),
                        _switch('Fragile', _fragile,
                            (value) => setState(() => _fragile = value)),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        _switch(
                          'Temperature Sensitive',
                          _temperatureSensitive,
                          (value) =>
                              setState(() => _temperatureSensitive = value),
                        ),
                        _switch(
                          'Special Handling Required',
                          _specialHandlingRequired,
                          (value) =>
                              setState(() => _specialHandlingRequired = value),
                        ),
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _riskNotes,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(labelText: 'Risk Notes'),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '4. Operational Handling Rules',
                  subtitle: 'Vehicle/trailer and loading behavior guidance',
                  child: Column(
                    children: [
                      _row(
                        context,
                        DropdownButtonFormField<String?>(
                          value: _preferredVehicleType.text.trim().isEmpty
                              ? null
                              : _preferredVehicleType.text.trim(),
                          decoration: const InputDecoration(
                              labelText: 'Preferred Vehicle Type (Master)'),
                          items: [
                            for (final item in vehicleTypeOptions)
                              DropdownMenuItem<String?>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _preferredVehicleType.text =
                                (value ?? '').trim());
                          },
                        ),
                        DropdownButtonFormField<String?>(
                          value: _preferredTrailerType.text.trim().isEmpty
                              ? null
                              : _preferredTrailerType.text.trim(),
                          decoration: const InputDecoration(
                              labelText: 'Preferred Trailer Type (Master)'),
                          items: [
                            for (final item in trailerTypeOptions)
                              DropdownMenuItem<String?>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _preferredTrailerType.text =
                                (value ?? '').trim());
                          },
                        ),
                        TextFormField(
                          controller: _loadingMethod,
                          decoration: const InputDecoration(
                              labelText: 'Loading Method'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        TextFormField(
                          controller: _unloadingMethod,
                          decoration: const InputDecoration(
                              labelText: 'Unloading Method'),
                        ),
                        _switch(
                            'Lashing Required',
                            _lashingRequired,
                            (value) =>
                                setState(() => _lashingRequired = value)),
                        _switch('Escort Required', _escortRequired,
                            (value) => setState(() => _escortRequired = value)),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        TextFormField(
                          controller: _specialEquipment,
                          decoration: const InputDecoration(
                              labelText: 'Special Equipment Required'),
                        ),
                        TextFormField(
                          controller: _handlingInstructions,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Handling Instructions'),
                        ),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '5. Compliance Requirements',
                  subtitle: 'Certification, permits and approvals needed',
                  child: Column(
                    children: [
                      _row(
                        context,
                        _switch(
                          'Special Compliance Required',
                          _specialComplianceRequired,
                          (value) => setState(
                              () => _specialComplianceRequired = value),
                        ),
                        _switch(
                          'Authority Approval Needed',
                          _authorityApprovalNeeded,
                          (value) =>
                              setState(() => _authorityApprovalNeeded = value),
                        ),
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        TextFormField(
                          controller: _requiredCertifications,
                          decoration: const InputDecoration(
                            labelText:
                                'Required Certifications (comma-separated)',
                          ),
                        ),
                        TextFormField(
                          controller: _requiredPermits,
                          decoration: const InputDecoration(
                            labelText: 'Required Permits (comma-separated)',
                          ),
                        ),
                        TextFormField(
                          controller: _customerRestrictions,
                          decoration: const InputDecoration(
                            labelText: 'Customer/Industry Restrictions',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _complianceNotes,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: 'Compliance Notes'),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '6. Inspection Requirements',
                  subtitle: 'Template and evidence-heavy inspection behavior',
                  child: Column(
                    children: [
                      _row(
                        context,
                        _switch(
                          'Inspection Required',
                          _inspectionRequired,
                          (value) =>
                              setState(() => _inspectionRequired = value),
                        ),
                        _switch(
                          'Pre-dispatch Inspection',
                          _preDispatchInspectionRequired,
                          (value) => setState(
                              () => _preDispatchInspectionRequired = value),
                        ),
                        _switch(
                          'In-transit Check',
                          _inTransitCheckRequired,
                          (value) =>
                              setState(() => _inTransitCheckRequired = value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        _switch(
                          'Post-delivery Check',
                          _postDeliveryCheckRequired,
                          (value) => setState(
                              () => _postDeliveryCheckRequired = value),
                        ),
                        _switch(
                          'Photo Evidence Mandatory',
                          _photoEvidenceMandatory,
                          (value) =>
                              setState(() => _photoEvidenceMandatory = value),
                        ),
                        _switch(
                          'Video Evidence Mandatory',
                          _videoEvidenceMandatory,
                          (value) =>
                              setState(() => _videoEvidenceMandatory = value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _row(
                        context,
                        DropdownButtonFormField<String?>(
                          value: _inspectionTemplate.text.trim().isEmpty
                              ? null
                              : _inspectionTemplate.text.trim(),
                          decoration: const InputDecoration(
                              labelText: 'Inspection Template Type (Master)'),
                          validator: (value) {
                            if (_inspectionRequired &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Required when inspection is enabled';
                            }
                            return null;
                          },
                          items: [
                            for (final item in inspectionTemplateOptions)
                              DropdownMenuItem<String?>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(
                                () => _inspectionTemplate.text = value ?? '');
                          },
                        ),
                        TextFormField(
                          controller: _inspectionNotes,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Inspection Notes'),
                        ),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _section(
                  title: '7. Control / Status',
                  subtitle:
                      'Restrict cargo for new operations while preserving history',
                  child: Column(
                    children: [
                      _row(
                        context,
                        _switch(
                          'Restricted',
                          _restricted,
                          (value) => setState(() => _restricted = value),
                        ),
                        TextFormField(
                          controller: _restrictionReason,
                          decoration: const InputDecoration(
                              labelText: 'Restriction Reason'),
                          validator: (value) {
                            if (_restricted &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Required when restricted';
                            }
                            return null;
                          },
                        ),
                        const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(RoutePaths.cargoMaster),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: _submit,
                            child: const Text('Save Cargo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _hydrate(CargoModel source) {
    _cargoCode.text = source.cargoCode;
    _cargoName.text = source.cargoName;
    _category.text = source.category;
    _subcategory.text = source.subcategory;
    _weightRange.text = source.standardWeightRange;
    _length.text = source.length?.toString() ?? '';
    _width.text = source.width?.toString() ?? '';
    _height.text = source.height?.toString() ?? '';
    _sizeClass.text = source.volumeSizeClass;
    _riskNotes.text = source.riskNotes;
    _preferredVehicleType.text = source.preferredVehicleType;
    _preferredTrailerType.text = source.preferredTrailerType;
    _loadingMethod.text = source.loadingMethod;
    _unloadingMethod.text = source.unloadingMethod;
    _specialEquipment.text = source.specialEquipmentRequired;
    _handlingInstructions.text = source.handlingInstructions;
    _requiredCertifications.text = source.requiredCertifications.join(', ');
    _requiredPermits.text = source.requiredPermits.join(', ');
    _customerRestrictions.text = source.customerIndustryRestrictions;
    _complianceNotes.text = source.complianceNotes;
    _inspectionTemplate.text = source.inspectionTemplateType;
    _inspectionNotes.text = source.inspectionNotes;
    _restrictionReason.text = source.restrictionReason;
    _status = source.status;
    _riskLevel = source.riskLevel;
    _oversized = source.oversized;
    _hazardous = source.hazardous;
    _fragile = source.fragile;
    _temperatureSensitive = source.temperatureSensitive;
    _specialHandlingRequired = source.specialHandlingRequired;
    _lashingRequired = source.lashingRequired;
    _escortRequired = source.escortRequired;
    _specialComplianceRequired = source.specialComplianceRequired;
    _authorityApprovalNeeded = source.authorityApprovalNeeded;
    _inspectionRequired = source.inspectionRequired;
    _preDispatchInspectionRequired = source.preDispatchInspectionRequired;
    _inTransitCheckRequired = source.inTransitCheckRequired;
    _postDeliveryCheckRequired = source.postDeliveryCheckRequired;
    _photoEvidenceMandatory = source.photoEvidenceMandatory;
    _videoEvidenceMandatory = source.videoEvidenceMandatory;
    _restricted = source.restricted;
  }

  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OpsSectionCard(
        title: title,
        subtitle: subtitle,
        icon: Icons.inventory_2_outlined,
        accent: const Color(0xFF2563EB),
        child: child,
      ),
    );
  }

  Widget _switch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _row(BuildContext context, Widget a, Widget b, Widget c) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          a,
          const SizedBox(height: 10),
          b,
          const SizedBox(height: 10),
          c,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
        const SizedBox(width: 10),
        Expanded(child: c),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _nonNegative(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 'Must be non-negative';
    }
    return null;
  }

  List<String> _splitList(String raw) {
    return raw
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  List<String> _withCurrent({
    required List<String> source,
    required String current,
  }) {
    final cleaned = source
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (current.trim().isNotEmpty && !cleaned.contains(current.trim())) {
      cleaned.insert(0, current.trim());
    }
    return cleaned;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(cargoViewModelProvider.notifier);
    final source = _isEdit ? notifier.findByCode(widget.editCargoCode) : null;
    final now = DateTime.now();

    final payload = CargoModel(
      cargoCode: _cargoCode.text.trim(),
      cargoName: _cargoName.text.trim(),
      category: _category.text.trim(),
      subcategory: _subcategory.text.trim(),
      status: _status,
      standardWeightRange: _weightRange.text.trim(),
      length: double.tryParse(_length.text.trim()),
      width: double.tryParse(_width.text.trim()),
      height: double.tryParse(_height.text.trim()),
      volumeSizeClass: _sizeClass.text.trim(),
      oversized: _oversized,
      riskLevel: _riskLevel,
      hazardous: _hazardous,
      fragile: _fragile,
      temperatureSensitive: _temperatureSensitive,
      specialHandlingRequired: _specialHandlingRequired,
      riskNotes: _riskNotes.text.trim(),
      preferredVehicleType: _preferredVehicleType.text.trim(),
      preferredTrailerType: _preferredTrailerType.text.trim(),
      loadingMethod: _loadingMethod.text.trim(),
      unloadingMethod: _unloadingMethod.text.trim(),
      lashingRequired: _lashingRequired,
      escortRequired: _escortRequired,
      specialEquipmentRequired: _specialEquipment.text.trim(),
      handlingInstructions: _handlingInstructions.text.trim(),
      specialComplianceRequired: _specialComplianceRequired,
      requiredCertifications: _splitList(_requiredCertifications.text),
      requiredPermits: _splitList(_requiredPermits.text),
      authorityApprovalNeeded: _authorityApprovalNeeded,
      customerIndustryRestrictions: _customerRestrictions.text.trim(),
      complianceNotes: _complianceNotes.text.trim(),
      inspectionRequired: _inspectionRequired,
      inspectionTemplateType: _inspectionTemplate.text.trim(),
      preDispatchInspectionRequired: _preDispatchInspectionRequired,
      inTransitCheckRequired: _inTransitCheckRequired,
      postDeliveryCheckRequired: _postDeliveryCheckRequired,
      photoEvidenceMandatory: _photoEvidenceMandatory,
      videoEvidenceMandatory: _videoEvidenceMandatory,
      inspectionNotes: _inspectionNotes.text.trim(),
      restricted: _restricted,
      restrictionReason: _restrictionReason.text.trim(),
      createdAt: source?.createdAt ?? now,
      updatedAt: now,
    );

    final message = _isEdit
        ? await notifier.updateCargo(payload)
        : await notifier.addCargo(payload);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.toLowerCase().contains('successfully')) {
      context.go(RoutePaths.cargoMaster);
    }
  }
}
