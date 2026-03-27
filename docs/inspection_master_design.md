# Inspection Master Design (Bundle-Driven)

## Core Principle
- The pre-trip screen is a **dynamic workspace** assembled from master configuration.
- The renderer starts from **Inspection Bundle**, not a hardcoded inspection type.

## Hierarchy
1. `InspectionBundleMaster`
2. `BundleInspectionTypeMapping`
3. `InspectionTemplateMasterV2`
4. `TemplateSectionMasterV2`
5. `TemplateItemMasterV2`
6. Rule masters (applicability, validation, result, media, approval)

## Master Responsibilities
- **Bundle**: operational grouping (e.g., `DISPATCH_READY`) for one-screen execution.
- **Inspection Type**: business families (pre-departure, load security, compliance, etc.).
- **Mapping**: order, mandatory status, inclusion mode.
- **Template**: context-specific variant (client, vehicle, trailer, cargo, route) with versioning.
- **Section**: UI grouping for cards/tabs and summary progress.
- **Item**: field-level checklist controls, severity, mandatory/evidence/blocker behavior.

## Rule Responsibilities
- **Applicability**: decides what appears for runtime context.
- **Validation**: enforces save/submit/dispatch/approval constraints.
- **Result Logic**: computes status/result from rule outcomes.
- **Media Requirement**: defines evidence type and count requirements.
- **Approval Matrix**: assigns approver/escalation and override policy.

## UI Mapping (One Screen)
- Bundle -> sections in display order.
- Section -> checklist group card.
- Item -> row control by `inputType`.
- Severity -> badge/highlight style.
- Media rules -> photo/video controls and minimum counts.
- Validation + result rules -> inline errors and overall state.

## Dispatch Readiness Contract
- Inspection engine outputs:
  - `overallResult`
  - `status`
  - `dispatchBlocked`
  - `approvalRequired / approvalStatus`
  - `blockerReasons`
- Dispatch should consume this contract instead of traversing raw item results.

## Versioning Policy
- Never overwrite published templates.
- Publish new version with effective dates.
- Keep transaction linkage to exact template version used.
