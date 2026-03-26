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
        _cache = decoded.isEmpty ? _seedDocuments() : _mergeWithSeed(decoded);
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

  List<ModuleDocument> _mergeWithSeed(List<ModuleDocument> source) {
    final merged = <ModuleDocument>[...source];
    final seeds = _seedDocuments();
    for (final seed in seeds) {
      final exists = merged.any(
        (item) =>
            item.documentCode.toLowerCase() == seed.documentCode.toLowerCase() &&
            item.applicableTo.toLowerCase() == seed.applicableTo.toLowerCase(),
      );
      if (!exists) {
        merged.add(seed);
      }
    }
    return merged;
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
  },
  {
    "id": "CDM-006",
    "documentCode": "TRL-MUL",
    "documentName": "Trailer Mulkiya",
    "description": "Trailer Mulkiya must be valid for trailer assignment and dispatch.",
    "applicableTo": "Trailer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": true,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Hard Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-007",
    "documentCode": "TRL-KPC",
    "documentName": "King Pin Certificate",
    "description": "King Pin certificate is mandatory for trailer safety compliance.",
    "applicableTo": "Trailer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": true,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Hard Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-008",
    "documentCode": "TRL-RAS",
    "documentName": "Trailer RAS/Fitness",
    "description": "Trailer RAS/Fitness should be compliant for road readiness.",
    "applicableTo": "Trailer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 25,
    "checkAtAssignment": true,
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
    "id": "CDM-009",
    "documentCode": "TRL-INS",
    "documentName": "Trailer Insurance",
    "description": "Trailer insurance should remain valid for operations.",
    "applicableTo": "Trailer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-010",
    "documentCode": "VTP-TPL",
    "documentName": "Type Compliance Template",
    "description": "Vehicle type compliance template should be attached for each active type.",
    "applicableTo": "Vehicle Types",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-011",
    "documentCode": "VEN-TL",
    "documentName": "Trade License",
    "description": "Vendor trade license must be valid.",
    "applicableTo": "Vendor",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 45,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-012",
    "documentCode": "VEN-VAT",
    "documentName": "VAT/Tax Certificate",
    "description": "Vendor VAT/tax certificate for billing compliance.",
    "applicableTo": "Vendor",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": true,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-013",
    "documentCode": "VEN-INS",
    "documentName": "Vendor Insurance",
    "description": "Vendor insurance policy for contracted operations.",
    "applicableTo": "Vendor",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-014",
    "documentCode": "VEN-CON",
    "documentName": "Vendor Contract",
    "description": "Signed vendor contract for service engagement.",
    "applicableTo": "Vendor",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 60,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-015",
    "documentCode": "VEN-HSE",
    "documentName": "HSE Approval",
    "description": "Vendor HSE approval and safety compliance status.",
    "applicableTo": "Vendor",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-016",
    "documentCode": "DRV-IDP",
    "documentName": "Driver ID/Passport",
    "description": "Driver identity document for onboarding and audits.",
    "applicableTo": "Driver",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": true,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-017",
    "documentCode": "DRV-MED",
    "documentName": "Medical Certificate",
    "description": "Driver medical fitness certificate.",
    "applicableTo": "Driver",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 20,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-018",
    "documentCode": "DRV-PDO",
    "documentName": "PDO Pass",
    "description": "PDO pass requirement for PDO jobs.",
    "applicableTo": "Driver",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-019",
    "documentCode": "DRV-TRN",
    "documentName": "Training Certificate",
    "description": "Driver training evidence (H2S/defensive/etc).",
    "applicableTo": "Driver",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-020",
    "documentCode": "CUS-CON",
    "documentName": "Customer Contract",
    "description": "Customer contract and agreed terms.",
    "applicableTo": "Customer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 45,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-021",
    "documentCode": "CUS-POF",
    "documentName": "PO Format",
    "description": "Customer purchase order format reference.",
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
    "id": "CDM-022",
    "documentCode": "CUS-BTX",
    "documentName": "Billing/Tax Documents",
    "description": "Customer billing and tax documents.",
    "applicableTo": "Customer",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": true,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-023",
    "documentCode": "CUS-SLA",
    "documentName": "SLA/Credit Approval",
    "description": "Customer SLA and credit approval documents.",
    "applicableTo": "Customer",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 60,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-024",
    "documentCode": "CRG-MSD",
    "documentName": "MSDS",
    "description": "Material Safety Data Sheet for cargo.",
    "applicableTo": "Cargo",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 30,
    "checkAtAssignment": true,
    "checkAtInspection": true,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-025",
    "documentCode": "CRG-SOP",
    "documentName": "Handling SOP",
    "description": "Cargo handling SOP and method statement.",
    "applicableTo": "Cargo",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-026",
    "documentCode": "CRG-PCK",
    "documentName": "Packing Certificate",
    "description": "Packing certificate for cargo quality and safety assurance.",
    "applicableTo": "Cargo",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-027",
    "documentCode": "RTE-PRM",
    "documentName": "Route Permit",
    "description": "Route permit for restricted roads/areas.",
    "applicableTo": "Route",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 20,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Hard Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": false
  },
  {
    "id": "CDM-028",
    "documentCode": "RTE-RSK",
    "documentName": "Route Risk Assessment",
    "description": "Latest route risk assessment document.",
    "applicableTo": "Route",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 15,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": true,
    "checkAtDeliveryClosure": false,
    "missingAction": "Soft Block",
    "expiredAction": "Hard Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-029",
    "documentCode": "RTE-AUT",
    "documentName": "Authority Approval",
    "description": "Customer/authority approval for special route usage.",
    "applicableTo": "Route",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 20,
    "checkAtAssignment": true,
    "checkAtInspection": false,
    "checkAtDispatch": true,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-030",
    "documentCode": "INS-SOP",
    "documentName": "Checklist SOP",
    "description": "SOP attachment for inspection checklist template.",
    "applicableTo": "Inspection Template",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-034",
    "documentCode": "INS-RFM",
    "documentName": "Reference Form",
    "description": "Reference form attachment for inspection template usage.",
    "applicableTo": "Inspection Template",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-031",
    "documentCode": "CMP-POL",
    "documentName": "Policy Document",
    "description": "Compliance policy master document.",
    "applicableTo": "Compliance Master",
    "status": "Active",
    "mandatory": true,
    "hasExpiry": true,
    "alertBeforeDays": 60,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Soft Block",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-032",
    "documentCode": "CMP-WAV",
    "documentName": "Waiver Template",
    "description": "Waiver templates and exception approval forms.",
    "applicableTo": "Compliance Master",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 60,
    "checkAtAssignment": false,
    "checkAtInspection": false,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-033",
    "documentCode": "CMP-CIR",
    "documentName": "Authority Circular",
    "description": "Government/client authority circular references.",
    "applicableTo": "Compliance Master",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": true,
    "alertBeforeDays": 90,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  },
  {
    "id": "CDM-035",
    "documentCode": "VTP-MTX",
    "documentName": "Type Compliance Matrix",
    "description": "Per vehicle type compliance matrix and mandatory document mapping.",
    "applicableTo": "Vehicle Types",
    "status": "Active",
    "mandatory": false,
    "hasExpiry": false,
    "alertBeforeDays": 0,
    "checkAtAssignment": false,
    "checkAtInspection": true,
    "checkAtDispatch": false,
    "checkAtTripStart": false,
    "checkAtDeliveryClosure": false,
    "missingAction": "Warning",
    "expiredAction": "Ignore",
    "uploadRequired": true,
    "overrideAllowed": true
  }
]
''';
