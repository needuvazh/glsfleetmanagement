import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';

class ModuleDocumentUploadSection extends ConsumerStatefulWidget {
  const ModuleDocumentUploadSection({
    super.key,
    required this.moduleName,
    this.title = 'Document Uploads',
    this.subtitle,
    this.fileTypeOverrides,
    this.additionalFileTypes,
    this.mandatoryByTypeOverrides,
    this.defaultFileType,
  });

  final String moduleName;
  final String title;
  final String? subtitle;
  final List<String>? fileTypeOverrides;
  final List<String>? additionalFileTypes;
  final Map<String, bool>? mandatoryByTypeOverrides;
  final String? defaultFileType;

  @override
  ConsumerState<ModuleDocumentUploadSection> createState() =>
      _ModuleDocumentUploadSectionState();
}

class _ModuleDocumentUploadSectionState
    extends ConsumerState<ModuleDocumentUploadSection> {
  final ScrollController _horizontalController = ScrollController();
  final List<_UploadRow> _rows = [];

  @override
  void dispose() {
    _horizontalController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moduleState = ref.watch(moduleDocumentViewModelProvider).valueOrNull;
    final authState = ref.watch(authViewModelProvider).valueOrNull;
    final roleName = (authState?.userRole ?? '').toLowerCase();
    final isPrivileged =
        roleName.contains('admin') || roleName.contains('compliance');

    final normalizedModule = _normalizeModule(widget.moduleName);
    final rules = (moduleState?.items ?? const [])
        .where(
          (item) =>
              item.status.toLowerCase() == 'active' &&
              _normalizeModule(item.applicableTo) == normalizedModule,
        )
        .toList();
    final visibleRules =
        isPrivileged ? rules : rules.where((item) => item.mandatory).toList();

    final configuredFileTypes = visibleRules
        .map((item) => item.documentName.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final mandatoryByType = <String, bool>{
      for (final rule in rules) rule.documentName.trim(): rule.mandatory,
    };
    final fileTypes = widget.fileTypeOverrides == null ||
            widget.fileTypeOverrides!.isEmpty
        ? configuredFileTypes
        : List<String>.from(widget.fileTypeOverrides!);
    if (widget.additionalFileTypes != null &&
        widget.additionalFileTypes!.isNotEmpty) {
      fileTypes.addAll(widget.additionalFileTypes!);
      fileTypes
        ..removeWhere((item) => item.trim().isEmpty)
        ..sort();
      final deduped = fileTypes.toSet().toList()..sort();
      fileTypes
        ..clear()
        ..addAll(deduped);
    }
    if (widget.mandatoryByTypeOverrides != null) {
      mandatoryByType.addAll(widget.mandatoryByTypeOverrides!);
    }

    _syncRows(
      fileTypes,
      mandatoryByType,
      defaultFileType: widget.defaultFileType,
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE6F7)),
        color: const Color(0xFFF8FAFC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Text(
                        widget.fileTypeOverrides != null &&
                                widget.fileTypeOverrides!.isNotEmpty
                            ? 'Configured file types for ${widget.moduleName}'
                            : (isPrivileged
                                ? 'File types from Compliance Master (${widget.moduleName})'
                                : 'Role filtered: mandatory file types for ${widget.moduleName}'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: fileTypes.isEmpty
                    ? null
                    : () {
                        setState(() {
                          final first = widget.defaultFileType != null &&
                                  fileTypes.contains(widget.defaultFileType)
                              ? widget.defaultFileType!
                              : fileTypes.first;
                          _rows.add(
                            _UploadRow(
                              fileType: first,
                              mandatory: mandatoryByType[first] ?? false,
                            ),
                          );
                        });
                      },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (fileTypes.isEmpty)
            const Text('No active compliance document types configured for this module.')
          else if (_rows.isEmpty)
            const Text('No files added yet. Click Add.')
          else
            Scrollbar(
              thumbVisibility: true,
              controller: _horizontalController,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 10,
                  columnSpacing: 18,
                  headingRowHeight: 46,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('File Type')),
                    DataColumn(label: Text('Required')),
                    DataColumn(label: Text('File Name')),
                    DataColumn(label: Text('Uploaded At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (var i = 0; i < _rows.length; i++)
                      _buildRow(
                        index: i,
                        row: _rows[i],
                        fileTypes: fileTypes,
                        mandatoryByType: mandatoryByType,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildRow({
    required int index,
    required _UploadRow row,
    required List<String> fileTypes,
    required Map<String, bool> mandatoryByType,
  }) {
    final selected =
        fileTypes.contains(row.fileType) ? row.fileType : fileTypes.first;

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Type',
              ),
              items: [
                for (final type in fileTypes)
                  DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    row.fileType = value;
                    row.mandatory = mandatoryByType[value] ?? false;
                  });
                }
              },
            ),
          ),
        ),
        DataCell(Text(row.mandatory ? 'Yes' : 'No')),
        DataCell(
          SizedBox(
            width: 260,
            child: TextFormField(
              controller: row.fileNameController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'File name',
              ),
            ),
          ),
        ),
        DataCell(Text(row.uploadedAtLabel)),
        DataCell(
          SizedBox(
            width: 110,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Mock upload',
                  onPressed: () {
                    final now = DateTime.now();
                    final stamp =
                        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
                    setState(() {
                      row.fileNameController.text =
                          '${row.fileType.replaceAll(' ', '_').toLowerCase()}_$stamp.pdf';
                      row.uploadedAt = now;
                    });
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                ),
                IconButton(
                  tooltip: 'Remove row',
                  onPressed: () {
                    setState(() {
                      _rows.removeAt(index).dispose();
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _syncRows(
    List<String> fileTypes,
    Map<String, bool> mandatoryByType, {
    String? defaultFileType,
  }) {
    if (fileTypes.isEmpty) {
      for (final row in _rows) {
        row.dispose();
      }
      _rows.clear();
      return;
    }
    final fallbackType =
        defaultFileType != null && fileTypes.contains(defaultFileType)
            ? defaultFileType
            : fileTypes.first;
    for (final row in _rows) {
      if (!fileTypes.contains(row.fileType)) {
        row.fileType = fallbackType;
      }
      row.mandatory = mandatoryByType[row.fileType] ?? false;
    }
  }

  String _normalizeModule(String value) {
    final alnum = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (alnum.endsWith('s') && alnum.length > 1) {
      return alnum.substring(0, alnum.length - 1);
    }
    return alnum;
  }
}

class _UploadRow {
  _UploadRow({
    required this.fileType,
    required this.mandatory,
  }) : fileNameController = TextEditingController();

  String fileType;
  bool mandatory;
  final TextEditingController fileNameController;
  DateTime? uploadedAt;

  String get uploadedAtLabel {
    if (uploadedAt == null) {
      return '-';
    }
    final d = uploadedAt!.day.toString().padLeft(2, '0');
    final m = uploadedAt!.month.toString().padLeft(2, '0');
    return '$d/$m/${uploadedAt!.year}';
  }

  void dispose() {
    fileNameController.dispose();
  }
}
