import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/work_order.dart';

class WorkOrderDraft {
  const WorkOrderDraft({
    this.workOrderNumber = '',
    this.enquiryNumber = '',
    this.customer = '',
    this.remarks = '',
    this.cargoType = '',
    this.quantity = '',
    this.weight = '',
    this.loadType = '',
    this.specialHandlingNotes = '',
    this.pickupLocation = '',
    this.deliveryLocation = '',
    this.stopPoints = '',
    this.routeNotes = '',
    this.requestedDate,
    this.plannedDispatchDate,
    this.plannedDeliveryDate,
    this.podRequired = true,
    this.dnRequired = true,
    this.specialCustomerDocuments = '',
    this.title = '',
    this.vehicleId = '',
    this.journeyPlanId,
    this.priority = WorkOrderPriority.medium,
  });

  final String workOrderNumber;
  final String enquiryNumber;
  final String customer;
  final String remarks;
  final String cargoType;
  final String quantity;
  final String weight;
  final String loadType;
  final String specialHandlingNotes;
  final String pickupLocation;
  final String deliveryLocation;
  final String stopPoints;
  final String routeNotes;
  final DateTime? requestedDate;
  final DateTime? plannedDispatchDate;
  final DateTime? plannedDeliveryDate;
  final bool podRequired;
  final bool dnRequired;
  final String specialCustomerDocuments;
  final String title;
  final String vehicleId;
  final String? journeyPlanId;
  final WorkOrderPriority priority;

  bool get hasContent =>
      workOrderNumber.trim().isNotEmpty ||
      enquiryNumber.trim().isNotEmpty ||
      customer.trim().isNotEmpty ||
      pickupLocation.trim().isNotEmpty ||
      deliveryLocation.trim().isNotEmpty ||
      title.trim().isNotEmpty ||
      vehicleId.trim().isNotEmpty ||
      journeyPlanId != null;

  WorkOrderDraft copyWith({
    String? workOrderNumber,
    String? enquiryNumber,
    String? customer,
    String? remarks,
    String? cargoType,
    String? quantity,
    String? weight,
    String? loadType,
    String? specialHandlingNotes,
    String? pickupLocation,
    String? deliveryLocation,
    String? stopPoints,
    String? routeNotes,
    DateTime? requestedDate,
    DateTime? plannedDispatchDate,
    DateTime? plannedDeliveryDate,
    bool? podRequired,
    bool? dnRequired,
    String? specialCustomerDocuments,
    String? title,
    String? vehicleId,
    String? journeyPlanId,
    bool clearJourneyPlanId = false,
    WorkOrderPriority? priority,
  }) {
    return WorkOrderDraft(
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      enquiryNumber: enquiryNumber ?? this.enquiryNumber,
      customer: customer ?? this.customer,
      remarks: remarks ?? this.remarks,
      cargoType: cargoType ?? this.cargoType,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      loadType: loadType ?? this.loadType,
      specialHandlingNotes: specialHandlingNotes ?? this.specialHandlingNotes,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      stopPoints: stopPoints ?? this.stopPoints,
      routeNotes: routeNotes ?? this.routeNotes,
      requestedDate: requestedDate ?? this.requestedDate,
      plannedDispatchDate: plannedDispatchDate ?? this.plannedDispatchDate,
      plannedDeliveryDate: plannedDeliveryDate ?? this.plannedDeliveryDate,
      podRequired: podRequired ?? this.podRequired,
      dnRequired: dnRequired ?? this.dnRequired,
      specialCustomerDocuments:
          specialCustomerDocuments ?? this.specialCustomerDocuments,
      title: title ?? this.title,
      vehicleId: vehicleId ?? this.vehicleId,
      journeyPlanId:
          clearJourneyPlanId ? null : (journeyPlanId ?? this.journeyPlanId),
      priority: priority ?? this.priority,
    );
  }
}

final workOrderDraftProvider =
    NotifierProvider<WorkOrderDraftNotifier, WorkOrderDraft>(
  WorkOrderDraftNotifier.new,
);

class WorkOrderDraftNotifier extends Notifier<WorkOrderDraft> {
  static const _storageKey = 'work_order_draft_v1';
  bool _loaded = false;

  @override
  WorkOrderDraft build() {
    if (!_loaded) {
      _loaded = true;
      _restoreDraft();
    }
    return const WorkOrderDraft();
  }

  Future<void> saveDraft(WorkOrderDraft draft) async {
    state = draft;
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'workOrderNumber': draft.workOrderNumber,
      'enquiryNumber': draft.enquiryNumber,
      'customer': draft.customer,
      'remarks': draft.remarks,
      'cargoType': draft.cargoType,
      'quantity': draft.quantity,
      'weight': draft.weight,
      'loadType': draft.loadType,
      'specialHandlingNotes': draft.specialHandlingNotes,
      'pickupLocation': draft.pickupLocation,
      'deliveryLocation': draft.deliveryLocation,
      'stopPoints': draft.stopPoints,
      'routeNotes': draft.routeNotes,
      'requestedDate': draft.requestedDate?.toIso8601String(),
      'plannedDispatchDate': draft.plannedDispatchDate?.toIso8601String(),
      'plannedDeliveryDate': draft.plannedDeliveryDate?.toIso8601String(),
      'podRequired': draft.podRequired,
      'dnRequired': draft.dnRequired,
      'specialCustomerDocuments': draft.specialCustomerDocuments,
      'title': draft.title,
      'vehicleId': draft.vehicleId,
      'journeyPlanId': draft.journeyPlanId,
      'priority': draft.priority.name,
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  Future<void> clearDraft() async {
    state = const WorkOrderDraft();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final priorityName =
          map['priority'] as String? ?? WorkOrderPriority.medium.name;
      final priority = WorkOrderPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => WorkOrderPriority.medium,
      );

      state = WorkOrderDraft(
        workOrderNumber: map['workOrderNumber'] as String? ?? '',
        enquiryNumber: map['enquiryNumber'] as String? ?? '',
        customer: map['customer'] as String? ?? '',
        remarks: map['remarks'] as String? ?? '',
        cargoType: map['cargoType'] as String? ?? '',
        quantity: map['quantity'] as String? ?? '',
        weight: map['weight'] as String? ?? '',
        loadType: map['loadType'] as String? ?? '',
        specialHandlingNotes: map['specialHandlingNotes'] as String? ?? '',
        pickupLocation: map['pickupLocation'] as String? ?? '',
        deliveryLocation: map['deliveryLocation'] as String? ?? '',
        stopPoints: map['stopPoints'] as String? ?? '',
        routeNotes: map['routeNotes'] as String? ?? '',
        requestedDate: _parseDate(map['requestedDate'] as String?),
        plannedDispatchDate: _parseDate(map['plannedDispatchDate'] as String?),
        plannedDeliveryDate: _parseDate(map['plannedDeliveryDate'] as String?),
        podRequired: map['podRequired'] as bool? ?? true,
        dnRequired: map['dnRequired'] as bool? ?? true,
        specialCustomerDocuments:
            map['specialCustomerDocuments'] as String? ?? '',
        title: map['title'] as String? ?? '',
        vehicleId: map['vehicleId'] as String? ?? '',
        journeyPlanId: map['journeyPlanId'] as String?,
        priority: priority,
      );
    } catch (_) {
      state = const WorkOrderDraft();
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
