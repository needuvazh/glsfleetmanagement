// ============================================================
// GLS Fleet Management — Domain Types
// Architecture: Component → Zustand Store → Repository → localStorage
// ============================================================

// --- Dashboard ---
export interface DashboardKpis {
  totalVehicles: number;
  activeVehicles: number;
  inMaintenance: number;
  criticalAlerts: number;
  avgFuelConsumptionLPer100km: number;
}

export interface MileagePoint {
  day: string;
  value: number;
}

export interface StatusShare {
  status: string;
  value: number;
}

export interface DashboardData {
  kpis: DashboardKpis;
  weeklyMileageKm: MileagePoint[];
  vehicleStatusShare: StatusShare[];
}

// --- Fleet ---
export interface FleetVehicle {
  id: string;
  vehicleNumber: string;
  type: string;
  status: 'Active' | 'Maintenance' | 'Idle' | 'On Trip' | string;
  driver: string;
  fuelLevel: number;
  odometerKm: number;
  lastServiceDate: string;
  location: { lat: number; lng: number };
}

// --- Drivers ---
export interface Driver {
  driverId: string;
  name: string;
  licenseNo: string;
  expiryDate: string;
  phone: string;
  experience: number;
  dfmsDeviceId: string;
  status: 'Available' | 'On Duty' | 'Rest' | string;
}

// --- Customers ---
export interface Customer {
  id: string;
  name: string;
  type: 'PDO' | 'Non-PDO' | string;
}

// --- Customer Requests ---
export interface CustomerRequest {
  customerName: string;
  contact: string;
  cargoType: string;
  weightVolume: string;
  pickup: string;
  delivery: string;
  date: string;
}

// --- Quotations ---
export interface Quotation {
  slNo: number;
  date: string;
  quoteRef: string;
  salesPerson: string;
  customer: string;
  customerContact: string;
  workDescription: string;
  noOfTrips: number;
  kilometer: number;
  rate: number;
  amount: number;
  approved: boolean;
}

// --- Work Orders (Flow) ---
export interface WorkOrderFlow {
  woId: string;
  customer: string;
  route: string;
  cargo: string;
  status: string;
}

// --- Work Orders (Legacy) ---
export interface WorkOrder {
  woId: string;
  requestId: string;
  client: string;
  route: string;
  vehicleNumber: string;
  status: string;
}

// --- Requests ---
export interface TransportRequest {
  requestId: string;
  clientId: string;
  clientName: string;
  clientType: string;
  cargo: string;
  pickup: string;
  drop: string;
  weight: number;
  status: string;
}

// --- Journey Plans ---
export interface JourneyPlan {
  id: string;
  planName: string;
  origin: string;
  destination: string;
  distance: number;
  estimatedTime: number;
  stops: string[];
  fuelEstimate: number;
}

// --- Journey Master ---
export interface JourneyMaster {
  journeyId: string;
  planName: string;
  origin: string;
  destination: string;
  stops: string[];
  restPoints: string[];
}

// --- Journey ---
export interface Journey {
  journeyId: string;
  woId: string;
  vehicle: string;
  driver: string;
  route: string[];
  status: string;
}

// --- Compliance ---
export interface ComplianceRecord {
  vehicleId: string;
  registrationExpiry: string;
  insuranceExpiry: string;
  inspectionDue: string;
  complianceStatus: 'Compliant' | 'Expiring Soon' | 'Overdue' | string;
}

// --- Alerts ---
export interface Alert {
  id: string;
  vehicleId: string;
  type: string;
  severity: 'High' | 'Medium' | 'Low' | string;
  message: string;
  timestamp: string;
  isRead: boolean;
}

// --- Delivery ---
export interface Delivery {
  deliveryId: string;
  woId: string;
  status: string;
  receiver: string;
  location: string;
}

// --- Invoices ---
export interface Invoice {
  invoiceId: string;
  woId: string;
  client: string;
  amount: number;
  paymentTerms: string;
}

// --- IVMS Data ---
export interface IvmsData {
  vehicleId: string;
  location: { lat: number; lng: number };
  speed: number;
  fuelLevel: number;
  distanceCovered: number;
  status: string;
}

// --- DFMS Data ---
export interface DfmsData {
  driverId: string;
  fatigueLevel: string;
  eyeClosureRate: number;
  drivingHours: number;
  alert: string;
}

// --- Vehicle Types ---
export interface VehicleTypeDocumentRequirement {
  documentName: string;
  mandatory: boolean;
  validityValue: number;
  validityUnit: string;
  applicableFor: string;
}

export interface VehicleType {
  name: string;
  code: string;
  category: string;
  vehicleClass: string;
  ownershipTypes: string[];
  vendorRequired: boolean;
  loadType: string;
  transportType: string;
  maxTripsPerDay: number;
  allowMultiDayJourney: boolean;
  allowMultipleStops: boolean;
  maxStopsAllowed: number;
  requireRoutePlanApproval: boolean;
  isHazardous: boolean;
  requiresSafetyCompliance: boolean;
  temperatureControlled: boolean;
  requiresEscortVehicle: boolean;
  defaultCapacity: number;
  capacityUnit: string;
  features: string[];
  requiresInsurance: boolean;
  requiresPermit: boolean;
  requiresFitness: boolean;
  requiresPollution: boolean;
  complianceMode: string;
  documentRequirements: VehicleTypeDocumentRequirement[];
  status?: string;
  isDefaultType?: boolean;
}

// --- Module Documents ---
export interface ModuleDocument {
  id: string;
  documentName: string;
  targetType: string;
  documentType: string;
}

// --- Vehicles (Simple) ---
export interface Vehicle {
  vehicleNumber: string;
  vehicleClass: string;
  status: string;
}

// --- Roles ---
export interface Role {
  name: string;
  systemRole: boolean;
}

// --- Users ---
export interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'Active' | 'Inactive' | string;
  joinDate: string;
}

// --- Location Master ---
export interface Location {
  code: string;
  name: string;
  type: string;
  region: string;
  lat: number;
  lng: number;
  status: 'Active' | 'Inactive' | string;
}

// --- Route Master ---
export interface RouteMaster {
  id: string;
  name: string;
  origin: string;
  destination: string;
  distance: number;
  estimatedTime: number;
  stops: string[];
  status: 'Active' | 'Inactive' | string;
}

// --- Flow Steps ---
export const FLOW_STEPS = [
  'Feasibility Check',
  'Quotation Creation',
  'Customer Approval',
  'Order Creation',
  'Fleet + Driver Assignment',
  'Compliance Validation',
  'Journey Plan (JMP)',
  'Pre-Trip Inspection',
  'Trip Execution',
  'Delivery (POD)',
  'Documents Upload',
  'Closure',
  'Invoice',
  'Operations Report',
] as const;

export type FlowStep = (typeof FLOW_STEPS)[number];
