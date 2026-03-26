import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../widgets/module_document_upload_section.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';
import 'trailer_store.dart';

class TrailerFormScreen extends StatefulWidget {
  const TrailerFormScreen({super.key, this.editCode});

  final String? editCode;

  @override
  State<TrailerFormScreen> createState() => _TrailerFormScreenState();
}

class _TrailerFormScreenState extends State<TrailerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _status = 'Active';
  String _availability = 'Available';
  bool _initialized = false;

  bool get _isEdit => widget.editCode != null && widget.editCode!.trim().isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final existing = _isEdit ? TrailerStore.byCode(widget.editCode!) : null;
    if (existing != null) {
      _codeController.text = existing.code;
      _typeController.text = existing.type;
      _capacityController.text = existing.capacity;
      _descriptionController.text = existing.description;
      _status = existing.status;
      _availability = existing.availability;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: _isEdit ? 'Edit Trailer' : 'Create Trailer',
      currentRoute: RoutePaths.trailerMaster,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: OpsSectionCard(
          title: _isEdit ? 'Update Trailer Details' : 'Create New Trailer',
          subtitle: 'Maintain trailer master records for dispatch and assignment',
          icon: _isEdit ? Icons.edit_outlined : Icons.add_box_outlined,
          accent: const Color(0xFF2563EB),
          trailing: TextButton.icon(
            onPressed: () => context.go(RoutePaths.trailerMaster),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    if (compact) {
                      return Column(
                        children: [
                          _text(_codeController, 'Trailer Code *',
                              enabled: !_isEdit),
                          const SizedBox(height: 10),
                          _text(_typeController, 'Trailer Type *'),
                          const SizedBox(height: 10),
                          _text(_capacityController, 'Capacity *'),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _text(
                            _codeController,
                            'Trailer Code *',
                            enabled: !_isEdit,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _text(_typeController, 'Trailer Type *')),
                        const SizedBox(width: 10),
                        Expanded(child: _text(_capacityController, 'Capacity *')),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    if (compact) {
                      return Column(
                        children: [
                          _statusDrop(),
                          const SizedBox(height: 10),
                          _availabilityDrop(),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _statusDrop()),
                        const SizedBox(width: 10),
                        Expanded(child: _availabilityDrop()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 3,
                ),
                const ModuleDocumentUploadSection(
                  moduleName: 'Trailer',
                  title: 'Trailer Document Uploads',
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                    label: Text(_isEdit ? 'Save Trailer' : 'Create Trailer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _statusDrop() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: const InputDecoration(labelText: 'Status'),
      items: const [
        DropdownMenuItem(value: 'Active', child: Text('Active')),
        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _status = value);
        }
      },
    );
  }

  Widget _availabilityDrop() {
    return DropdownButtonFormField<String>(
      value: _availability,
      decoration: const InputDecoration(labelText: 'Availability'),
      items: const [
        DropdownMenuItem(value: 'Available', child: Text('Available')),
        DropdownMenuItem(value: 'Assigned', child: Text('Assigned')),
        DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _availability = value);
        }
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final record = TrailerRecord(
      code: _codeController.text.trim(),
      type: _typeController.text.trim(),
      capacity: _capacityController.text.trim(),
      status: _status,
      availability: _availability,
      description: _descriptionController.text.trim(),
    );
    final message = TrailerStore.upsert(
      record,
      originalCode: _isEdit ? widget.editCode : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.trailerMaster);
    }
  }
}
