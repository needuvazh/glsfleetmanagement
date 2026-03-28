// ============================================================
// Mock Repositories — localStorage-backed CRUD
// Pattern: Component → Store → Repository → localStorage
// Future: Swap with API repositories without changing stores
// ============================================================

import type {
  DashboardData, FleetVehicle, Driver, Customer, CustomerRequest,
  Quotation, WorkOrderFlow, WorkOrder, TransportRequest, JourneyPlan,
  JourneyMaster, Journey, ComplianceRecord, Alert, Delivery, Invoice,
  IvmsData, DfmsData, VehicleType, ModuleDocument, Role, User,
  Location, RouteMaster, Vehicle,
} from '@/types';
import { StorageKeys, getItem, setItem } from '@/lib/storage';
import {
  dashboardSeed, fleetSeed, driversSeed, customersSeed, customerRequestsSeed,
  quotationsSeed, workOrdersFlowSeed, workOrdersSeed, requestsSeed,
  journeyPlansSeed, journeyMasterSeed, journeysSeed, complianceSeed,
  alertsSeed, deliverySeed, invoicesSeed, ivmsSeed, dfmsSeed,
  vehicleTypesSeed, vehiclesSeed, moduleDocumentsSeed, rolesSeed,
  usersSeed, locationsSeed, routesSeed,
} from '@/lib/seed-data';

function getOrDefault<T>(key: string, fallback: T): T {
  return getItem<T>(key as any) ?? fallback;
}

// --- Dashboard ---
export const dashboardRepo = {
  get: (): DashboardData => getOrDefault(StorageKeys.DASHBOARD, dashboardSeed),
};

// --- Fleet ---
export const fleetRepo = {
  getAll: (): FleetVehicle[] => getOrDefault(StorageKeys.FLEET, fleetSeed),
  getById: (id: string): FleetVehicle | undefined =>
    fleetRepo.getAll().find((v) => v.id === id),
  update: (id: string, data: Partial<FleetVehicle>): FleetVehicle[] => {
    const items = fleetRepo.getAll().map((v) => (v.id === id ? { ...v, ...data } : v));
    setItem(StorageKeys.FLEET, items);
    return items;
  },
  add: (vehicle: FleetVehicle): FleetVehicle[] => {
    const items = [...fleetRepo.getAll(), vehicle];
    setItem(StorageKeys.FLEET, items);
    return items;
  },
  remove: (id: string): FleetVehicle[] => {
    const items = fleetRepo.getAll().filter((v) => v.id !== id);
    setItem(StorageKeys.FLEET, items);
    return items;
  },
};

// --- Drivers ---
export const driverRepo = {
  getAll: (): Driver[] => getOrDefault(StorageKeys.DRIVERS, driversSeed),
  getById: (id: string): Driver | undefined =>
    driverRepo.getAll().find((d) => d.driverId === id),
  add: (driver: Driver): Driver[] => {
    const items = [...driverRepo.getAll(), driver];
    setItem(StorageKeys.DRIVERS, items);
    return items;
  },
  update: (id: string, data: Partial<Driver>): Driver[] => {
    const items = driverRepo.getAll().map((d) => (d.driverId === id ? { ...d, ...data } : d));
    setItem(StorageKeys.DRIVERS, items);
    return items;
  },
  remove: (id: string): Driver[] => {
    const items = driverRepo.getAll().filter((d) => d.driverId !== id);
    setItem(StorageKeys.DRIVERS, items);
    return items;
  },
};

// --- Customers ---
export const customerRepo = {
  getAll: (): Customer[] => getOrDefault(StorageKeys.CUSTOMERS, customersSeed),
  add: (customer: Customer): Customer[] => {
    const items = [...customerRepo.getAll(), customer];
    setItem(StorageKeys.CUSTOMERS, items);
    return items;
  },
};

// --- Customer Requests ---
export const customerRequestRepo = {
  getAll: (): CustomerRequest[] => getOrDefault(StorageKeys.CUSTOMER_REQUESTS, customerRequestsSeed),
  add: (req: CustomerRequest): CustomerRequest[] => {
    const items = [...customerRequestRepo.getAll(), req];
    setItem(StorageKeys.CUSTOMER_REQUESTS, items);
    return items;
  },
};

// --- Quotations ---
export const quotationRepo = {
  getAll: (): Quotation[] => getOrDefault(StorageKeys.QUOTATIONS, quotationsSeed),
  add: (q: Quotation): Quotation[] => {
    const items = [...quotationRepo.getAll(), q];
    setItem(StorageKeys.QUOTATIONS, items);
    return items;
  },
  update: (slNo: number, data: Partial<Quotation>): Quotation[] => {
    const items = quotationRepo.getAll().map((q) => (q.slNo === slNo ? { ...q, ...data } : q));
    setItem(StorageKeys.QUOTATIONS, items);
    return items;
  },
};

// --- Work Orders Flow ---
export const workOrderFlowRepo = {
  getAll: (): WorkOrderFlow[] => getOrDefault(StorageKeys.WORK_ORDERS_FLOW, workOrdersFlowSeed),
  add: (wo: WorkOrderFlow): WorkOrderFlow[] => {
    const items = [...workOrderFlowRepo.getAll(), wo];
    setItem(StorageKeys.WORK_ORDERS_FLOW, items);
    return items;
  },
  updateStatus: (woId: string, status: string): WorkOrderFlow[] => {
    const items = workOrderFlowRepo.getAll().map((w) => (w.woId === woId ? { ...w, status } : w));
    setItem(StorageKeys.WORK_ORDERS_FLOW, items);
    return items;
  },
};

// --- Work Orders ---
export const workOrderRepo = {
  getAll: (): WorkOrder[] => getOrDefault(StorageKeys.WORK_ORDERS, workOrdersSeed),
  add: (wo: WorkOrder): WorkOrder[] => {
    const items = [...workOrderRepo.getAll(), wo];
    setItem(StorageKeys.WORK_ORDERS, items);
    return items;
  },
};

// --- Requests ---
export const requestRepo = {
  getAll: (): TransportRequest[] => getOrDefault(StorageKeys.REQUESTS, requestsSeed),
  add: (req: TransportRequest): TransportRequest[] => {
    const items = [...requestRepo.getAll(), req];
    setItem(StorageKeys.REQUESTS, items);
    return items;
  },
};

// --- Journey Plans ---
export const journeyPlanRepo = {
  getAll: (): JourneyPlan[] => getOrDefault(StorageKeys.JOURNEY_PLANS, journeyPlansSeed),
  getById: (id: string): JourneyPlan | undefined =>
    journeyPlanRepo.getAll().find((j) => j.id === id),
  add: (plan: JourneyPlan): JourneyPlan[] => {
    const items = [...journeyPlanRepo.getAll(), plan];
    setItem(StorageKeys.JOURNEY_PLANS, items);
    return items;
  },
};

// --- Journey Master ---
export const journeyMasterRepo = {
  getAll: (): JourneyMaster[] => getOrDefault(StorageKeys.JOURNEY_MASTER, journeyMasterSeed),
};

// --- Journeys ---
export const journeyRepo = {
  getAll: (): Journey[] => getOrDefault(StorageKeys.JOURNEYS, journeysSeed),
  add: (journey: Journey): Journey[] => {
    const items = [...journeyRepo.getAll(), journey];
    setItem(StorageKeys.JOURNEYS, items);
    return items;
  },
};

// --- Compliance ---
export const complianceRepo = {
  getAll: (): ComplianceRecord[] => getOrDefault(StorageKeys.COMPLIANCE, complianceSeed),
};

// --- Alerts ---
export const alertRepo = {
  getAll: (): Alert[] => getOrDefault(StorageKeys.ALERTS, alertsSeed),
  markRead: (id: string): Alert[] => {
    const items = alertRepo.getAll().map((a) => (a.id === id ? { ...a, isRead: true } : a));
    setItem(StorageKeys.ALERTS, items);
    return items;
  },
};

// --- Delivery ---
export const deliveryRepo = {
  getAll: (): Delivery[] => getOrDefault(StorageKeys.DELIVERY, deliverySeed),
  update: (deliveryId: string, data: Partial<Delivery>): Delivery[] => {
    const items = deliveryRepo.getAll().map((d) => (d.deliveryId === deliveryId ? { ...d, ...data } : d));
    setItem(StorageKeys.DELIVERY, items);
    return items;
  },
};

// --- Invoices ---
export const invoiceRepo = {
  getAll: (): Invoice[] => getOrDefault(StorageKeys.INVOICES, invoicesSeed),
  add: (inv: Invoice): Invoice[] => {
    const items = [...invoiceRepo.getAll(), inv];
    setItem(StorageKeys.INVOICES, items);
    return items;
  },
};

// --- IVMS ---
export const ivmsRepo = {
  getAll: (): IvmsData[] => getOrDefault(StorageKeys.IVMS, ivmsSeed),
  getByVehicle: (vehicleId: string): IvmsData | undefined =>
    ivmsRepo.getAll().find((i) => i.vehicleId === vehicleId),
};

// --- DFMS ---
export const dfmsRepo = {
  getAll: (): DfmsData[] => getOrDefault(StorageKeys.DFMS, dfmsSeed),
  getByDriver: (driverId: string): DfmsData | undefined =>
    dfmsRepo.getAll().find((d) => d.driverId === driverId),
};

// --- Vehicle Types ---
export const vehicleTypeRepo = {
  getAll: (): VehicleType[] => getOrDefault(StorageKeys.VEHICLE_TYPES, vehicleTypesSeed),
  getByCode: (code: string): VehicleType | undefined =>
    vehicleTypeRepo.getAll().find((v) => v.code === code),
  add: (vt: VehicleType): VehicleType[] => {
    const items = [...vehicleTypeRepo.getAll(), vt];
    setItem(StorageKeys.VEHICLE_TYPES, items);
    return items;
  },
  update: (code: string, data: Partial<VehicleType>): VehicleType[] => {
    const items = vehicleTypeRepo.getAll().map((v) => (v.code === code ? { ...v, ...data } : v));
    setItem(StorageKeys.VEHICLE_TYPES, items);
    return items;
  },
  remove: (code: string): VehicleType[] => {
    const items = vehicleTypeRepo.getAll().filter((v) => v.code !== code);
    setItem(StorageKeys.VEHICLE_TYPES, items);
    return items;
  },
};

// --- Vehicles ---
export const vehicleRepo = {
  getAll: (): Vehicle[] => getOrDefault(StorageKeys.VEHICLES, vehiclesSeed),
};

// --- Module Documents ---
export const moduleDocumentRepo = {
  getAll: (): ModuleDocument[] => getOrDefault(StorageKeys.MODULE_DOCUMENTS, moduleDocumentsSeed),
  add: (doc: ModuleDocument): ModuleDocument[] => {
    const items = [...moduleDocumentRepo.getAll(), doc];
    setItem(StorageKeys.MODULE_DOCUMENTS, items);
    return items;
  },
  remove: (id: string): ModuleDocument[] => {
    const items = moduleDocumentRepo.getAll().filter((d) => d.id !== id);
    setItem(StorageKeys.MODULE_DOCUMENTS, items);
    return items;
  },
};

// --- Roles ---
export const roleRepo = {
  getAll: (): Role[] => getOrDefault(StorageKeys.ROLES, rolesSeed),
  add: (role: Role): Role[] => {
    const items = [...roleRepo.getAll(), role];
    setItem(StorageKeys.ROLES, items);
    return items;
  },
};

// --- Users ---
export const userRepo = {
  getAll: (): User[] => getOrDefault(StorageKeys.USERS, usersSeed),
  add: (user: User): User[] => {
    const items = [...userRepo.getAll(), user];
    setItem(StorageKeys.USERS, items);
    return items;
  },
  update: (id: string, data: Partial<User>): User[] => {
    const items = userRepo.getAll().map((u) => (u.id === id ? { ...u, ...data } : u));
    setItem(StorageKeys.USERS, items);
    return items;
  },
  remove: (id: string): User[] => {
    const items = userRepo.getAll().filter((u) => u.id !== id);
    setItem(StorageKeys.USERS, items);
    return items;
  },
};

// --- Locations ---
export const locationRepo = {
  getAll: (): Location[] => getOrDefault(StorageKeys.LOCATIONS, locationsSeed),
  getByCode: (code: string): Location | undefined =>
    locationRepo.getAll().find((l) => l.code === code),
  add: (loc: Location): Location[] => {
    const items = [...locationRepo.getAll(), loc];
    setItem(StorageKeys.LOCATIONS, items);
    return items;
  },
  update: (code: string, data: Partial<Location>): Location[] => {
    const items = locationRepo.getAll().map((l) => (l.code === code ? { ...l, ...data } : l));
    setItem(StorageKeys.LOCATIONS, items);
    return items;
  },
  remove: (code: string): Location[] => {
    const items = locationRepo.getAll().filter((l) => l.code !== code);
    setItem(StorageKeys.LOCATIONS, items);
    return items;
  },
};

// --- Routes ---
export const routeRepo = {
  getAll: (): RouteMaster[] => getOrDefault(StorageKeys.ROUTES, routesSeed),
  getById: (id: string): RouteMaster | undefined =>
    routeRepo.getAll().find((r) => r.id === id),
  add: (route: RouteMaster): RouteMaster[] => {
    const items = [...routeRepo.getAll(), route];
    setItem(StorageKeys.ROUTES, items);
    return items;
  },
  update: (id: string, data: Partial<RouteMaster>): RouteMaster[] => {
    const items = routeRepo.getAll().map((r) => (r.id === id ? { ...r, ...data } : r));
    setItem(StorageKeys.ROUTES, items);
    return items;
  },
  remove: (id: string): RouteMaster[] => {
    const items = routeRepo.getAll().filter((r) => r.id !== id);
    setItem(StorageKeys.ROUTES, items);
    return items;
  },
};
