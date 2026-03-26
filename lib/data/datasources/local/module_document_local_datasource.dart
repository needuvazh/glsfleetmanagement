import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/module_document_model.dart';
import '../../../domain/entities/module_document.dart';

abstract class ModuleDocumentLocalDataSource {
  Future<List<ModuleDocument>> loadDocuments();
  Future<void> saveDocuments(List<ModuleDocument> items);
}

class ModuleDocumentLocalDataSourceImpl
    implements ModuleDocumentLocalDataSource {
  ModuleDocumentLocalDataSourceImpl();

  static const _cacheKey = 'compliance_document_master_records_v1';
  List<ModuleDocument>? _cache;

  Future<void> _ensureInitialized() async {
    if (_cache != null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = ModuleDocumentModel.decodeList(raw);
        _cache = decoded.isEmpty ? _seedDocuments() : decoded;
      } catch (_) {
        _cache = _seedDocuments();
      }
    } else {
      _cache = _seedDocuments();
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = ModuleDocumentModel.encodeList(_cache ?? const []);
    await prefs.setString(_cacheKey, payload);
  }

  @override
  Future<List<ModuleDocument>> loadDocuments() async {
    await _ensureInitialized();
    if (_cache!.isEmpty) {
      _cache = _seedDocuments();
      await _persist();
    }
    return List<ModuleDocument>.from(_cache!);
  }

  @override
  Future<void> saveDocuments(List<ModuleDocument> items) async {
    await _ensureInitialized();
    _cache = List<ModuleDocument>.from(items);
    await _persist();
  }

  List<ModuleDocument> _seedDocuments() {
    final data = jsonDecode(_seedJson) as List<dynamic>;
    return data
        .map((entry) =>
            ModuleDocumentModel.fromMap(entry as Map<String, dynamic>))
        .toList();
  }
}

const String _seedJson = '''
[
  {
    "id": "CDM-001",
    "documentCode": "DRV-LIC",
    "documentName": "Driver License",
    "description": "Valid driver license is required before assigning or dispatching trips.",
    "applicableTo": "Driver",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": true,
    "checkAtDeliveryClosure": false,
    "missingAction": "Hard Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-002",
    "documentCode": "FLT-INS",
    "documentName": "Vehicle Insurance",
    "description": "Insurance should remain valid for fleet dispatch readiness.",
    "applicableTo": "Fleet",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 45,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-003",
    "documentCode": "CUS-POD",
    "documentName": "POD Required",
    "description": "Customer contract requires POD submission during delivery closure.",
    "applicableTo": "Customer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": true,
    "missingAction": "Hard Block",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-004",
    "documentCode": "CUS-DN",
    "documentName": "DN Required",
    "description": "Delivery note must be captured for selected customer contracts.",
    "applicableTo": "Customer",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": true,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-005",
    "documentCode": "CRG-HAZ",
    "documentName": "Hazardous Permit",
    "description": "Hazardous cargo requires permit validation before dispatch.",
    "applicableTo": "Cargo",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 15,
    "checkAtAssignment": true,
    "checkAtInspection": true,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Hard Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  }
]
''';
