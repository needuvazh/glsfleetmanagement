import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/vendor_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  const VendorFormScreen({super.key, this.editVendorId});

  final String? editVendorId;

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(vendorViewModelProvider);
    final formState = ref.watch(vendorFormProvider);

    return OpsShell(
      title: formState.isEditMode ? 'Edit Vendor' : 'Create Vendor',
      currentRoute: RoutePaths.vendorMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vendorMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          VendorModel? editVendor;
          if (widget.editVendorId != null) {
            for (final vendor in data.vendors) {
              if (vendor.vendorId == widget.editVendorId) {
                editVendor = vendor;
                break;
              }
            }
          }

          if (!formState.initialized) {
            Future.microtask(
              () => ref.read(vendorFormProvider.notifier).initialize(editVendor),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final form = ref.watch(vendorFormProvider);
          final notifier = ref.read(vendorFormProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: form.isEditMode ? 'Edit Vendor' : 'Create Vendor',
                subtitle: 'Maintain vendor data for quotation and order flows',
                icon: Icons.edit_note_outlined,
                accent: const Color(0xFF2563EB),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: form.vendorName,
                        decoration: const InputDecoration(labelText: 'Vendor Name *'),
                        validator: _required,
                        onChanged: notifier.setVendorName,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: form.companyName,
                        decoration: const InputDecoration(labelText: 'Company Name'),
                        onChanged: notifier.setCompanyName,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: form.contactNumber,
                        decoration: const InputDecoration(labelText: 'Contact Number *'),
                        validator: _validateContact,
                        onChanged: notifier.setContactNumber,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: form.email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: _validateEmail,
                        onChanged: notifier.setEmail,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: form.address,
                        decoration: const InputDecoration(labelText: 'Address'),
                        maxLines: 3,
                        onChanged: notifier.setAddress,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<VendorType>(
                        value: form.vendorType,
                        decoration: const InputDecoration(labelText: 'Vendor Type'),
                        items: [
                          for (final item in VendorType.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            notifier.setVendorType(value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<VendorServiceType>(
                        value: form.serviceType,
                        decoration: const InputDecoration(labelText: 'Service Type'),
                        items: [
                          for (final item in VendorServiceType.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            notifier.setServiceType(value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<VendorStatus>(
                        value: form.status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: [
                          for (final item in VendorStatus.values)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            notifier.setStatus(value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(RoutePaths.vendorMaster),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () => _submit(context),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(clean)) {
      return 'Invalid contact number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final form = ref.read(vendorFormProvider);
    final vendor = form.toVendorModel();
    final notifier = ref.read(vendorViewModelProvider.notifier);
    final message = form.isEditMode
        ? await notifier.updateVendor(vendor)
        : await notifier.addVendor(vendor);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (message.contains('successfully')) {
      context.go(RoutePaths.vendorMaster);
    }
  }
}
