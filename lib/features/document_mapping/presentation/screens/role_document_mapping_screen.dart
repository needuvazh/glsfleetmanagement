import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/ops_shell.dart';
import '../../../../presentation/widgets/ops_ui.dart';
import '../../../../routes/route_paths.dart';
import '../providers/role_document_mapping_provider.dart';

class RoleDocumentMappingScreen extends ConsumerWidget {
  const RoleDocumentMappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleDocumentMappingProvider);

    return OpsShell(
      title: 'Role Document Mapping',
      currentRoute: RoutePaths.documentManagement,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Assign Documents By Role',
                subtitle:
                    'Select a role, review mapped documents, and save mock assignments for later upload flows',
                icon: Icons.assignment_turned_in_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: data.selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Select Role',
                      ),
                      items: [
                        for (final role in data.roles)
                          DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        ref
                            .read(roleDocumentMappingProvider.notifier)
                            .selectRole(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mapped Documents',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (data.selectedDocumentsInDisplayOrder.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFD9E2EC)),
                        ),
                        child: const Text('No documents mapped.'),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final document
                              in data.selectedDocumentsInDisplayOrder)
                            OpsPill(
                              label: document,
                              color: const Color(0xFF2563EB),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Available Documents',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD9E5FB)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          for (int index = 0;
                              index < data.allDocuments.length;
                              index++) ...[
                            CheckboxListTile(
                              value: data.selectedDocuments
                                  .contains(data.allDocuments[index]),
                              title: Text(data.allDocuments[index]),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (_) {
                                ref
                                    .read(roleDocumentMappingProvider.notifier)
                                    .toggleDocument(data.allDocuments[index]);
                              },
                            ),
                            if (index != data.allDocuments.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (data.isSaving) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 12),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: data.isSaving
                            ? null
                            : () async {
                                final message = await ref
                                    .read(roleDocumentMappingProvider.notifier)
                                    .saveMapping();
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                        icon: data.isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(data.isSaving ? 'Saving...' : 'Save Mapping'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Current Mock Mapping',
                subtitle:
                    'This in-memory map can be reused by later upload screens for role-based document dropdowns',
                icon: Icons.account_tree_outlined,
                accent: const Color(0xFF16A34A),
                child: Column(
                  children: [
                    for (int index = 0; index < data.roles.length; index++) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF8FBFF),
                          border: Border.all(color: const Color(0xFFD9E5FB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                data.roles[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.documentsForRole(data.roles[index]).isEmpty
                                    ? 'No documents mapped'
                                    : data
                                        .documentsForRole(data.roles[index])
                                        .join(', '),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != data.roles.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
