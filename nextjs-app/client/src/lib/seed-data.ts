// ============================================================
// Seed Data — Injected into localStorage on first load
// Source: Migrated from Flutter assets/mock/*.json
// ============================================================

import type {
  DashboardData, FleetVehicle, Driver, Customer, CustomerRequest,
  Quotation, WorkOrderFlow, WorkOrder, TransportRequest, JourneyPlan,
  JourneyMaster, Journey, ComplianceRecord, Alert, Delivery, Invoice,
  IvmsData, DfmsData, VehicleType, Vehicle, ModuleDocument, Role, User,
  Location, RouteMaster,
} from '@/types';
import { StorageKeys, getItem, setItem } from './storage';

export const dashboardSeed: DashboardData = {
  kpis: {
    totalVehicles: 128,
    activeVehicles: 109,
    inMaintenance: 11,
    criticalAlerts: 7,
    avgFuelConsumptionLPer100km: 18.6,
  },
  weeklyMileageKm: [
    { day: 'Mon', value: 12840 },
    { day: 'Tue', value: 13110 },
    { day: 'Wed', value: 12620 },
    { day: 'Thu', value: 13870 },
    { day: 'Fri', value: 14240 },
    { day: 'Sat', value: 9780 },
    { day: 'Sun', value: 8450 },
  ],
  vehicleStatusShare: [
    { status: 'Active', value: 109 },
    { status: 'Maintenance', value: 11 },
    { status: 'Idle', value: 8 },
  ],
};

export const fleetSeed: FleetVehicle[] = [
  { id: '8603 BK', vehicleNumber: '8603 BK', type: 'Truck', status: 'Active', driver: 'Arif Khan', fuelLevel: 72, odometerKm: 184520, lastServiceDate: '2026-02-18', location: { lat: 25.2048, lng: 55.2708 } },
  { id: '24567 A', vehicleNumber: '24567 A', type: 'Van', status: 'Maintenance', driver: 'Samir Nadeem', fuelLevel: 34, odometerKm: 121004, lastServiceDate: '2026-01-26', location: { lat: 24.4539, lng: 54.3773 } },
  { id: '99876 M', vehicleNumber: '99876 M', type: 'Bus', status: 'Idle', driver: 'Hassan Ali', fuelLevel: 58, odometerKm: 261882, lastServiceDate: '2026-03-03', location: { lat: 25.2854, lng: 51.531 } },
  { id: '7561 RH', vehicleNumber: '7561 RH', type: 'Trailer', status: 'Active', driver: 'Rashid Noor', fuelLevel: 81, odometerKm: 309877, lastServiceDate: '2026-03-01', location: { lat: 25.3548, lng: 55.4033 } },
  { id: '33442 K', vehicleNumber: '33442 K', type: 'Truck', status: 'Active', driver: 'Faisal Javed', fuelLevel: 66, odometerKm: 212765, lastServiceDate: '2026-02-08', location: { lat: 24.7136, lng: 46.6753 } },
];

export const driversSeed: Driver[] = [
  { driverId: 'DRV001', name: 'Arun Kumar', licenseNo: 'TN-DL-345211', expiryDate: '2027-05-18', phone: '+91-9876543210', experience: 8, dfmsDeviceId: 'DFMS-DRV001', status: 'Available' },
  { driverId: 'DRV002', name: 'Karthik Raj', licenseNo: 'TN-DL-289011', expiryDate: '2026-11-02', phone: '+91-9988776611', experience: 6, dfmsDeviceId: 'DFMS-DRV002', status: 'On Duty' },
  { driverId: 'DRV003', name: 'Siva Prakash', licenseNo: 'TN-DL-742102', expiryDate: '2026-09-15', phone: '+91-9123456780', experience: 4, dfmsDeviceId: 'DFMS-DRV003', status: 'Rest' },
];

export const customersSeed: Customer[] = [
  { id: 'C001', name: 'Shell', type: 'PDO' },
  { id: 'C002', name: 'DHL', type: 'PDO' },
  { id: 'C003', name: 'BSC', type: 'PDO' },
  { id: 'C004', name: 'Agreeko', type: 'PDO' },
  { id: 'C005', name: 'STC', type: 'PDO' },
  { id: 'C006', name: 'GOL', type: 'Non-PDO' },
  { id: 'C007', name: 'Al Madina', type: 'Non-PDO' },
];

export const customerRequestsSeed: CustomerRequest[] = [
  { customerName: 'Mina Al Falah Logistics', contact: '+968-90011122', cargoType: 'Heavy Equipment', weightVolume: '12 Tons', pickup: 'Muscat', delivery: 'Sohar', date: '2026-03-22' },
  { customerName: 'GLS Retail', contact: '+968-90909011', cargoType: 'General Cargo', weightVolume: '8 Tons', pickup: 'Muscat', delivery: 'Nizwa', date: '2026-03-23' },
];

export const quotationsSeed: Quotation[] = [
  { slNo: 1, date: '2026-03-21', quoteRef: 'QTN-2026-001', salesPerson: 'Rahul Menon', customer: 'Mina Al Falah Logistics', customerContact: '+968-90011122', workDescription: 'Heavy Equipment - Muscat to Sohar', noOfTrips: 3, kilometer: 350, rate: 42, amount: 44100, approved: true },
  { slNo: 2, date: '2026-03-22', quoteRef: 'QTN-2026-002', salesPerson: 'Priya Sharma', customer: 'GLS Retail', customerContact: '+968-90909011', workDescription: 'General Cargo - Muscat to Nizwa', noOfTrips: 2, kilometer: 210, rate: 38, amount: 15960, approved: false },
];

export const workOrdersFlowSeed: WorkOrderFlow[] = [
  { woId: 'WO-2025-0892', customer: 'Mina Al Falah Logistics', route: 'Muscat -> Sohar', cargo: 'Heavy Equipment', status: 'Pending Assignment' },
  { woId: 'WO-2025-0891', customer: 'GLS Retail', route: 'Muscat -> Nizwa', cargo: 'General Cargo', status: 'In Transit' },
  { woId: 'WO-2025-0889', customer: 'ChemPro', route: 'Sohar -> Duqm', cargo: 'Hazardous Material', status: 'Delayed' },
];

export const workOrdersSeed: WorkOrder[] = [
  { woId: 'WO001', requestId: 'REQ001', client: 'Shell', route: 'Muscat -> Sohar', vehicleNumber: '8603 BK', status: 'Assigned' },
  { woId: 'WO002', requestId: 'REQ002', client: 'GOL', route: 'Nizwa -> Duqm', vehicleNumber: '24567 A', status: 'Assigned' },
];

export const requestsSeed: TransportRequest[] = [
  { requestId: 'REQ001', clientId: 'C001', clientName: 'Shell', clientType: 'PDO', cargo: 'Oil Equipment', pickup: 'Muscat', drop: 'Sohar', weight: 1200, status: 'Approved' },
  { requestId: 'REQ002', clientId: 'C006', clientName: 'GOL', clientType: 'Non-PDO', cargo: 'General Cargo', pickup: 'Nizwa', drop: 'Duqm', weight: 800, status: 'Approved' },
];

export const journeyPlansSeed: JourneyPlan[] = [
  { id: '1', planName: 'Muscat to Sohar', origin: 'Muscat', destination: 'Sohar', distance: 350, estimatedTime: 6, stops: ['Barka', 'Saham'], fuelEstimate: 40 },
  { id: '2', planName: 'Muscat to Nizwa', origin: 'Muscat', destination: 'Nizwa', distance: 150, estimatedTime: 3.5, stops: ['Barka', 'Bidbid'], fuelEstimate: 18 },
  { id: '3', planName: 'Sohar to Duqm', origin: 'Sohar', destination: 'Duqm', distance: 280, estimatedTime: 5, stops: ['Ibri', 'Adam'], fuelEstimate: 32 },
];

export const journeyMasterSeed: JourneyMaster[] = [
  { journeyId: 'JMP-MCT-SHR', planName: 'Muscat to Sohar', origin: 'Muscat', destination: 'Sohar', stops: ['Barka', 'Saham', 'Sohar Port'], restPoints: ['Barka', 'Saham'] },
  { journeyId: 'JMP-MCT-SLL', planName: 'Muscat to Salalah', origin: 'Muscat', destination: 'Salalah', stops: ['Nizwa', 'Ibri', 'Duqm'], restPoints: ['Nizwa', 'Duqm'] },
];

export const journeysSeed: Journey[] = [
  { journeyId: 'JMP001', woId: 'WO001', vehicle: '8603 BK', driver: 'Arif', route: ['Muscat', 'Barka', 'Sohar'], status: 'In Transit' },
  { journeyId: 'JMP002', woId: 'WO002', vehicle: '24567 A', driver: 'Hamdan', route: ['Nizwa', 'Ibri', 'Duqm'], status: 'Planned' },
];

export const complianceSeed: ComplianceRecord[] = [
  { vehicleId: '8603 BK', registrationExpiry: '2026-08-12', insuranceExpiry: '2026-06-30', inspectionDue: '2026-05-14', complianceStatus: 'Compliant' },
  { vehicleId: '24567 A', registrationExpiry: '2026-04-03', insuranceExpiry: '2026-03-29', inspectionDue: '2026-03-25', complianceStatus: 'Expiring Soon' },
  { vehicleId: '99876 M', registrationExpiry: '2026-02-28', insuranceExpiry: '2026-03-01', inspectionDue: '2026-03-05', complianceStatus: 'Overdue' },
  { vehicleId: '7561 RH', registrationExpiry: '2026-10-16', insuranceExpiry: '2026-09-09', inspectionDue: '2026-08-21', complianceStatus: 'Compliant' },
  { vehicleId: '33442 K', registrationExpiry: '2026-04-19', insuranceExpiry: '2026-05-02', inspectionDue: '2026-04-12', complianceStatus: 'Expiring Soon' },
];

export const alertsSeed: Alert[] = [
  { id: 'AL-6001', vehicleId: '8603 BK', type: 'Overspeed', severity: 'High', message: 'Vehicle exceeded speed limit of 120 km/h on Highway 1.', timestamp: '2026-03-20T08:30:00Z', isRead: false },
  { id: 'AL-6002', vehicleId: '24567 A', type: 'Geofence Breach', severity: 'Medium', message: 'Vehicle moved outside assigned zone.', timestamp: '2026-03-20T11:05:00Z', isRead: true },
  { id: 'AL-6003', vehicleId: '7561 RH', type: 'Engine Fault', severity: 'High', message: 'Coolant temperature above normal range.', timestamp: '2026-03-21T05:14:00Z', isRead: false },
  { id: 'AL-6004', vehicleId: '33442 K', type: 'Harsh Braking', severity: 'Low', message: 'Multiple harsh braking events detected.', timestamp: '2026-03-21T06:40:00Z', isRead: true },
  { id: 'AL-6005', vehicleId: '24567 A', type: 'Fuel Drop', severity: 'Medium', message: 'Fuel level dropped unexpectedly by 12%.', timestamp: '2026-03-21T09:02:00Z', isRead: false },
  { id: 'AL-6006', vehicleId: '8603 BK', type: 'Battery Low', severity: 'Low', message: 'Auxiliary battery voltage below threshold.', timestamp: '2026-03-21T10:25:00Z', isRead: false },
];

export const deliverySeed: Delivery[] = [
  { deliveryId: 'DEL001', woId: 'WO001', status: 'Delivered', receiver: 'Ahmed', location: 'Sohar' },
  { deliveryId: 'DEL002', woId: 'WO002', status: 'Pending', receiver: '', location: 'Duqm' },
];

export const invoicesSeed: Invoice[] = [
  { invoiceId: 'INV001', woId: 'WO001', client: 'Shell', amount: 500, paymentTerms: '30 days' },
  { invoiceId: 'INV002', woId: 'WO002', client: 'GOL', amount: 320, paymentTerms: '45 days' },
];

export const ivmsSeed: IvmsData[] = [
  { vehicleId: '8603 BK', location: { lat: 12.9716, lng: 80.2212 }, speed: 65, fuelLevel: 70, distanceCovered: 120, status: 'Moving' },
  { vehicleId: '24567 A', location: { lat: 12.5123, lng: 79.8877 }, speed: 84, fuelLevel: 46, distanceCovered: 198, status: 'Moving' },
  { vehicleId: '99876 M', location: { lat: 12.2311, lng: 79.4552 }, speed: 0, fuelLevel: 32, distanceCovered: 88, status: 'Stop' },
];

export const dfmsSeed: DfmsData[] = [
  { driverId: 'DRV001', fatigueLevel: 'Medium', eyeClosureRate: 0.45, drivingHours: 6, alert: 'Take Rest' },
  { driverId: 'DRV002', fatigueLevel: 'High', eyeClosureRate: 0.71, drivingHours: 9, alert: 'High Fatigue - Stop at nearest rest point' },
  { driverId: 'DRV003', fatigueLevel: 'Low', eyeClosureRate: 0.22, drivingHours: 3, alert: 'Normal' },
];

export const vehicleTypesSeed: VehicleType[] = [
  {
    name: 'PDO Prime Mover', code: 'VT-PDO-PM', category: 'Heavy Vehicle', vehicleClass: 'XXXL',
    ownershipTypes: ['Company Owned', 'Vendor Owned'], vendorRequired: true, loadType: 'PDO', transportType: 'External',
    maxTripsPerDay: 1, allowMultiDayJourney: true, allowMultipleStops: true, maxStopsAllowed: 4,
    requireRoutePlanApproval: true, isHazardous: true, requiresSafetyCompliance: true, temperatureControlled: false,
    requiresEscortVehicle: true, defaultCapacity: 32000, capacityUnit: 'KG',
    features: ['GPS', 'DFMS', 'IVMS', 'Speed Limiter'],
    requiresInsurance: true, requiresPermit: true, requiresFitness: true, requiresPollution: true,
    complianceMode: 'PDO',
    documentRequirements: [
      { documentName: 'Mulkiya Card', mandatory: true, validityValue: 1, validityUnit: 'Year', applicableFor: 'PDO' },
      { documentName: 'RAS Inspection', mandatory: true, validityValue: 1, validityUnit: 'Year', applicableFor: 'PDO' },
      { documentName: 'IVMS', mandatory: true, validityValue: 1, validityUnit: 'Year', applicableFor: 'PDO' },
    ],
    status: 'Active', isDefaultType: true,
  },
  {
    name: 'Non-PDO Rigid Truck', code: 'VT-NPDO-RT', category: 'Medium Vehicle', vehicleClass: 'XL',
    ownershipTypes: ['Company Owned'], vendorRequired: false, loadType: 'Non-PDO', transportType: 'Internal',
    maxTripsPerDay: 3, allowMultiDayJourney: false, allowMultipleStops: true, maxStopsAllowed: 6,
    requireRoutePlanApproval: false, isHazardous: false, requiresSafetyCompliance: false, temperatureControlled: false,
    requiresEscortVehicle: false, defaultCapacity: 12000, capacityUnit: 'KG',
    features: ['GPS', 'Speed Limiter'],
    requiresInsurance: true, requiresPermit: true, requiresFitness: true, requiresPollution: true,
    complianceMode: 'Standard',
    documentRequirements: [
      { documentName: 'Mulkiya Card', mandatory: true, validityValue: 1, validityUnit: 'Year', applicableFor: 'All' },
    ],
    status: 'Active', isDefaultType: false,
  },
];

export const vehiclesSeed: Vehicle[] = [
  { vehicleNumber: '8603 BK', vehicleClass: 'Dry Movers', status: 'On Trip' },
  { vehicleNumber: '24567 A', vehicleClass: 'Rigid Truck', status: 'On Trip' },
  { vehicleNumber: '99876 M', vehicleClass: 'Container', status: 'Maintenance' },
];

export const moduleDocumentsSeed: ModuleDocument[] = [
  { id: 'DOC-001', documentName: 'Driver License Copy', targetType: 'Driver', documentType: 'PDF' },
  { id: 'DOC-002', documentName: 'Vehicle Insurance Sheet', targetType: 'Transport Manager', documentType: 'XLSX' },
  { id: 'DOC-003', documentName: 'Journey Summary', targetType: 'Journey manager', documentType: 'DOCX' },
];

export const rolesSeed: Role[] = [
  { name: 'Admin', systemRole: true },
  { name: 'Operations Manager', systemRole: true },
  { name: 'Fleet Manager', systemRole: true },
  { name: 'Driver', systemRole: true },
  { name: 'Dispatcher', systemRole: false },
  { name: 'Finance', systemRole: false },
];

export const usersSeed: User[] = [
  { id: 'USR001', name: 'Mohammed Al Balushi', email: 'mohammed@gls.com', role: 'Admin', status: 'Active', joinDate: '2024-01-15' },
  { id: 'USR002', name: 'Fatima Al Rashdi', email: 'fatima@gls.com', role: 'Operations Manager', status: 'Active', joinDate: '2024-03-20' },
  { id: 'USR003', name: 'Ahmed Al Habsi', email: 'ahmed@gls.com', role: 'Fleet Manager', status: 'Active', joinDate: '2024-06-10' },
  { id: 'USR004', name: 'Sara Al Kindi', email: 'sara@gls.com', role: 'Dispatcher', status: 'Inactive', joinDate: '2025-01-05' },
];

export const locationsSeed: Location[] = [
  { code: 'LOC-MCT', name: 'Muscat Hub', type: 'Hub', region: 'Muscat', lat: 23.5880, lng: 58.3829, status: 'Active' },
  { code: 'LOC-SHR', name: 'Sohar Depot', type: 'Depot', region: 'Al Batinah', lat: 24.3461, lng: 56.7075, status: 'Active' },
  { code: 'LOC-NZW', name: 'Nizwa Yard', type: 'Yard', region: 'Ad Dakhiliyah', lat: 22.9333, lng: 57.5333, status: 'Active' },
  { code: 'LOC-DQM', name: 'Duqm Port', type: 'Port', region: 'Al Wusta', lat: 19.6553, lng: 57.7036, status: 'Active' },
];

export const routesSeed: RouteMaster[] = [
  { id: 'RT-001', name: 'Muscat - Sohar Express', origin: 'Muscat', destination: 'Sohar', distance: 350, estimatedTime: 6, stops: ['Barka', 'Saham'], status: 'Active' },
  { id: 'RT-002', name: 'Muscat - Nizwa Route', origin: 'Muscat', destination: 'Nizwa', distance: 150, estimatedTime: 3.5, stops: ['Barka', 'Bidbid'], status: 'Active' },
  { id: 'RT-003', name: 'Sohar - Duqm Corridor', origin: 'Sohar', destination: 'Duqm', distance: 280, estimatedTime: 5, stops: ['Ibri', 'Adam'], status: 'Active' },
];

export function seedIfNeeded(): void {
  const alreadySeeded = getItem<boolean>(StorageKeys.SEEDED);
  if (alreadySeeded) return;

  setItem(StorageKeys.DASHBOARD, dashboardSeed);
  setItem(StorageKeys.FLEET, fleetSeed);
  setItem(StorageKeys.DRIVERS, driversSeed);
  setItem(StorageKeys.CUSTOMERS, customersSeed);
  setItem(StorageKeys.CUSTOMER_REQUESTS, customerRequestsSeed);
  setItem(StorageKeys.QUOTATIONS, quotationsSeed);
  setItem(StorageKeys.WORK_ORDERS_FLOW, workOrdersFlowSeed);
  setItem(StorageKeys.WORK_ORDERS, workOrdersSeed);
  setItem(StorageKeys.REQUESTS, requestsSeed);
  setItem(StorageKeys.JOURNEY_PLANS, journeyPlansSeed);
  setItem(StorageKeys.JOURNEY_MASTER, journeyMasterSeed);
  setItem(StorageKeys.JOURNEYS, journeysSeed);
  setItem(StorageKeys.COMPLIANCE, complianceSeed);
  setItem(StorageKeys.ALERTS, alertsSeed);
  setItem(StorageKeys.DELIVERY, deliverySeed);
  setItem(StorageKeys.INVOICES, invoicesSeed);
  setItem(StorageKeys.IVMS, ivmsSeed);
  setItem(StorageKeys.DFMS, dfmsSeed);
  setItem(StorageKeys.VEHICLE_TYPES, vehicleTypesSeed);
  setItem(StorageKeys.VEHICLES, vehiclesSeed);
  setItem(StorageKeys.MODULE_DOCUMENTS, moduleDocumentsSeed);
  setItem(StorageKeys.ROLES, rolesSeed);
  setItem(StorageKeys.USERS, usersSeed);
  setItem(StorageKeys.LOCATIONS, locationsSeed);
  setItem(StorageKeys.ROUTES, routesSeed);
  setItem(StorageKeys.SEEDED, true);
}
