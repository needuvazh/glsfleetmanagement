import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/access_control_viewmodel.dart';
import '../viewmodels/module_document_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class DocumentManagementScreen extends ConsumerStatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  ConsumerState<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState
    extends ConsumerState<DocumentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentNameController = TextEditingController();

  String? _selectedUserRole;
  String? _selectedDocumentType;

  @override
  void dispose() {
    _documentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moduleDocumentViewModelProvider);
    final accessState = ref.watch(accessControlProvider);
    final availableRoles = accessState.roles.map((role) => role.name).toList();

    return OpsShell(
      title: 'Document Module',
      currentRoute: RoutePaths.documentManagement,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          if (availableRoles.isNotEmpty &&
              (_selectedUserRole == null ||
                  !availableRoles.contains(_selectedUserRole))) {
            _selectedUserRole = availableRoles.first;
          }
          _selectedDocumentType ??= ModuleDocumentViewModel.documentTypes.first;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpsSectionCard(
                  title: 'Create Document',
                  subtitle:
                      'Add document details based on role for reuse in later screens',
                  icon: Icons.note_add_outlined,
                  accent: const Color(0xFF2563EB),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _documentNameController,
                          decoration: const InputDecoration(
                            labelText: 'Document Name',
                            hintText: 'Example: Driver License Copy',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedDocumentType,
                          decoration:
                              const InputDecoration(labelText: 'Document Type'),
                          items: [
                            for (final item
                                in ModuleDocumentViewModel.documentTypes)
                              DropdownMenuItem(value: item, child: Text(item)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDocumentType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedUserRole,
                          decoration:
                              const InputDecoration(labelText: 'User Role'),
                          items: [
                            for (final role in availableRoles)
                              DropdownMenuItem(value: role, child: Text(role)),
                          ],
                          onChanged: availableRoles.isEmpty
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _selectedUserRole = value);
                                  }
                                },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (availableRoles.isEmpty)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No roles available. Create roles in Role Module first.',
                            ),
                          ),
                        if (availableRoles.isNotEmpty)
                          const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: availableRoles.isEmpty
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final message = await ref
                                        .read(moduleDocumentViewModelProvider
                                            .notifier)
                                        .addDocument(
                                          documentName:
                                              _documentNameController.text,
                                          userRole: _selectedUserRole ?? '',
                                          documentType:
                                              _selectedDocumentType ?? '',
                                        );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );

                                    if (message
                                        .startsWith('Document created')) {
                                      _documentNameController.clear();
                                    }
                                  },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Document'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: OpsSectionCard(
                    title: 'Document List',
                    subtitle: 'Saved role-based document definitions',
                    icon: Icons.folder_open_outlined,
                    accent: const Color(0xFF16A34A),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: data.query,
                          decoration: const InputDecoration(
                            labelText: 'Search by id/name/type/role',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: ref
                              .read(moduleDocumentViewModelProvider.notifier)
                              .setQuery,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: data.roleFilter,
                          decoration: const InputDecoration(
                              labelText: 'User Role Filter'),
                          items: [
                            const DropdownMenuItem(
                              value: 'All',
                              child: Text('All'),
                            ),
                            for (final role in availableRoles)
                              DropdownMenuItem(value: role, child: Text(role)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(
                                      moduleDocumentViewModelProvider.notifier)
                                  .setRoleFilter(value);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        if (data.filteredItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                                'No documents found for selected filters.'),
                          )
                        else
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                          const Color(0xFFEFF4FF)),
                                      columns: const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(
                                            label: Text('Document Name')),
                                        DataColumn(
                                            label: Text('Document Type')),
                                        DataColumn(label: Text('User Role')),
                                        DataColumn(label: Text('Delete')),
                                      ],
                                      rows: [
                                        for (final item in data.filteredItems)
                                          DataRow(
                                            cells: [
                                              DataCell(Text(item.id)),
                                              DataCell(Text(item.documentName)),
                                              DataCell(Text(item.documentType)),
                                              DataCell(Text(item.targetType)),
                                              DataCell(
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_outline),
                                                  onPressed: () async {
                                                    final message = await ref
                                                        .read(
                                                            moduleDocumentViewModelProvider
                                                                .notifier)
                                                        .deleteDocument(
                                                            item.id);
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content:
                                                              Text(message)),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
