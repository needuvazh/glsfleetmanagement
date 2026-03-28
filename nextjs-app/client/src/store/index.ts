// ============================================================
// Zustand Stores — Feature-based state management
// Pattern: Component → Store → Repository → localStorage
// ============================================================

import { create } from 'zustand';
import type {
  DashboardData, FleetVehicle, Driver, Customer, CustomerRequest,
  Quotation, WorkOrderFlow, ComplianceRecord, Alert, Delivery, Invoice,
  IvmsData, DfmsData, VehicleType, ModuleDocument, Role, User,
  Location, RouteMaster, JourneyPlan, JourneyMaster, Journey,
  TransportRequest, WorkOrder,
} from '@/types';
import {
  dashboardRepo, fleetRepo, driverRepo, customerRepo, customerRequestRepo,
  quotationRepo, workOrderFlowRepo, complianceRepo, alertRepo, deliveryRepo,
  invoiceRepo, ivmsRepo, dfmsRepo, vehicleTypeRepo, moduleDocumentRepo,
  roleRepo, userRepo, locationRepo, routeRepo, journeyPlanRepo,
  journeyMasterRepo, journeyRepo, requestRepo, workOrderRepo,
} from '@/repositories/mock';

// --- Dashboard Store ---
interface DashboardStore {
  data: DashboardData | null;
  loading: boolean;
  load: () => void;
}

export const useDashboardStore = create<DashboardStore>((set) => ({
  data: null,
  loading: true,
  load: () => {
    const data = dashboardRepo.get();
    set({ data, loading: false });
  },
}));

// --- Fleet Store ---
interface FleetStore {
  items: FleetVehicle[];
  filter: string;
  query: string;
  loading: boolean;
  load: () => void;
  setFilter: (f: string) => void;
  setQuery: (q: string) => void;
  addVehicle: (v: FleetVehicle) => void;
  updateVehicle: (id: string, data: Partial<FleetVehicle>) => void;
  removeVehicle: (id: string) => void;
}

export const useFleetStore = create<FleetStore>((set) => ({
  items: [],
  filter: 'All',
  query: '',
  loading: true,
  load: () => {
    set({ items: fleetRepo.getAll(), loading: false });
  },
  setFilter: (filter) => set({ filter }),
  setQuery: (query) => set({ query }),
  addVehicle: (v) => {
    const items = fleetRepo.add(v);
    set({ items });
  },
  updateVehicle: (id, data) => {
    const items = fleetRepo.update(id, data);
    set({ items });
  },
  removeVehicle: (id) => {
    const items = fleetRepo.remove(id);
    set({ items });
  },
}));

// --- Driver Store ---
interface DriverStore {
  items: Driver[];
  loading: boolean;
  load: () => void;
  addDriver: (d: Driver) => void;
  updateDriver: (id: string, data: Partial<Driver>) => void;
  removeDriver: (id: string) => void;
}

export const useDriverStore = create<DriverStore>((set) => ({
  items: [],
  loading: true,
  load: () => set({ items: driverRepo.getAll(), loading: false }),
  addDriver: (d) => set({ items: driverRepo.add(d) }),
  updateDriver: (id, data) => set({ items: driverRepo.update(id, data) }),
  removeDriver: (id) => set({ items: driverRepo.remove(id) }),
}));

// --- Customer Store ---
interface CustomerStore {
  items: Customer[];
  load: () => void;
}

export const useCustomerStore = create<CustomerStore>((set) => ({
  items: [],
  load: () => set({ items: customerRepo.getAll() }),
}));

// --- Customer Request Store ---
interface CustomerRequestStore {
  items: CustomerRequest[];
  load: () => void;
  addRequest: (r: CustomerRequest) => void;
}

export const useCustomerRequestStore = create<CustomerRequestStore>((set) => ({
  items: [],
  load: () => set({ items: customerRequestRepo.getAll() }),
  addRequest: (r) => set({ items: customerRequestRepo.add(r) }),
}));

// --- Quotation Store ---
interface QuotationStore {
  items: Quotation[];
  load: () => void;
  addQuotation: (q: Quotation) => void;
  approveQuotation: (slNo: number) => void;
}

export const useQuotationStore = create<QuotationStore>((set) => ({
  items: [],
  load: () => set({ items: quotationRepo.getAll() }),
  addQuotation: (q) => set({ items: quotationRepo.add(q) }),
  approveQuotation: (slNo) => set({ items: quotationRepo.update(slNo, { approved: true }) }),
}));

// --- Work Order Flow Store ---
interface WorkOrderFlowStore {
  items: WorkOrderFlow[];
  load: () => void;
  addWorkOrder: (wo: WorkOrderFlow) => void;
  updateStatus: (woId: string, status: string) => void;
}

export const useWorkOrderFlowStore = create<WorkOrderFlowStore>((set) => ({
  items: [],
  load: () => set({ items: workOrderFlowRepo.getAll() }),
  addWorkOrder: (wo) => set({ items: workOrderFlowRepo.add(wo) }),
  updateStatus: (woId, status) => set({ items: workOrderFlowRepo.updateStatus(woId, status) }),
}));

// --- Compliance Store ---
interface ComplianceStore {
  items: ComplianceRecord[];
  load: () => void;
}

export const useComplianceStore = create<ComplianceStore>((set) => ({
  items: [],
  load: () => set({ items: complianceRepo.getAll() }),
}));

// --- Alert Store ---
interface AlertStore {
  items: Alert[];
  load: () => void;
  markRead: (id: string) => void;
}

export const useAlertStore = create<AlertStore>((set) => ({
  items: [],
  load: () => set({ items: alertRepo.getAll() }),
  markRead: (id) => set({ items: alertRepo.markRead(id) }),
}));

// --- Delivery Store ---
interface DeliveryStore {
  items: Delivery[];
  load: () => void;
  updateDelivery: (id: string, data: Partial<Delivery>) => void;
}

export const useDeliveryStore = create<DeliveryStore>((set) => ({
  items: [],
  load: () => set({ items: deliveryRepo.getAll() }),
  updateDelivery: (id, data) => set({ items: deliveryRepo.update(id, data) }),
}));

// --- Invoice Store ---
interface InvoiceStore {
  items: Invoice[];
  load: () => void;
  addInvoice: (inv: Invoice) => void;
}

export const useInvoiceStore = create<InvoiceStore>((set) => ({
  items: [],
  load: () => set({ items: invoiceRepo.getAll() }),
  addInvoice: (inv) => set({ items: invoiceRepo.add(inv) }),
}));

// --- IVMS Store ---
interface IvmsStore {
  items: IvmsData[];
  load: () => void;
}

export const useIvmsStore = create<IvmsStore>((set) => ({
  items: [],
  load: () => set({ items: ivmsRepo.getAll() }),
}));

// --- DFMS Store ---
interface DfmsStore {
  items: DfmsData[];
  load: () => void;
}

export const useDfmsStore = create<DfmsStore>((set) => ({
  items: [],
  load: () => set({ items: dfmsRepo.getAll() }),
}));

// --- Vehicle Type Store ---
interface VehicleTypeStore {
  items: VehicleType[];
  loading: boolean;
  load: () => void;
  addType: (vt: VehicleType) => void;
  updateType: (code: string, data: Partial<VehicleType>) => void;
  removeType: (code: string) => void;
}

export const useVehicleTypeStore = create<VehicleTypeStore>((set) => ({
  items: [],
  loading: true,
  load: () => set({ items: vehicleTypeRepo.getAll(), loading: false }),
  addType: (vt) => set({ items: vehicleTypeRepo.add(vt) }),
  updateType: (code, data) => set({ items: vehicleTypeRepo.update(code, data) }),
  removeType: (code) => set({ items: vehicleTypeRepo.remove(code) }),
}));

// --- Module Document Store ---
interface ModuleDocumentStore {
  items: ModuleDocument[];
  query: string;
  roleFilter: string;
  load: () => void;
  setQuery: (q: string) => void;
  setRoleFilter: (f: string) => void;
  addDocument: (doc: ModuleDocument) => string;
  removeDocument: (id: string) => void;
}

export const useModuleDocumentStore = create<ModuleDocumentStore>((set, get) => ({
  items: [],
  query: '',
  roleFilter: 'All',
  load: () => set({ items: moduleDocumentRepo.getAll() }),
  setQuery: (query) => set({ query }),
  setRoleFilter: (roleFilter) => set({ roleFilter }),
  addDocument: (doc) => {
    const existing = get().items;
    const dup = existing.some(
      (d) => d.targetType.toLowerCase() === doc.targetType.toLowerCase() &&
        d.documentName.toLowerCase() === doc.documentName.toLowerCase()
    );
    if (dup) return 'Document name already exists for this role.';
    set({ items: moduleDocumentRepo.add(doc) });
    return 'Document created successfully.';
  },
  removeDocument: (id) => set({ items: moduleDocumentRepo.remove(id) }),
}));

// --- Role Store ---
interface RoleStore {
  items: Role[];
  load: () => void;
  addRole: (name: string) => string;
}

export const useRoleStore = create<RoleStore>((set, get) => ({
  items: [],
  load: () => set({ items: roleRepo.getAll() }),
  addRole: (name) => {
    const trimmed = name.trim();
    if (!trimmed) return 'Role name is required.';
    const exists = get().items.some((r) => r.name.toLowerCase() === trimmed.toLowerCase());
    if (exists) return 'Role already exists.';
    set({ items: roleRepo.add({ name: trimmed, systemRole: false }) });
    return `Role created: ${trimmed}`;
  },
}));

// --- User Store ---
interface UserStore {
  items: User[];
  loading: boolean;
  load: () => void;
  addUser: (user: User) => void;
  updateUser: (id: string, data: Partial<User>) => void;
  removeUser: (id: string) => void;
}

export const useUserStore = create<UserStore>((set) => ({
  items: [],
  loading: true,
  load: () => set({ items: userRepo.getAll(), loading: false }),
  addUser: (user) => set({ items: userRepo.add(user) }),
  updateUser: (id, data) => set({ items: userRepo.update(id, data) }),
  removeUser: (id) => set({ items: userRepo.remove(id) }),
}));

// --- Location Store ---
interface LocationStore {
  items: Location[];
  loading: boolean;
  load: () => void;
  addLocation: (loc: Location) => void;
  updateLocation: (code: string, data: Partial<Location>) => void;
  removeLocation: (code: string) => void;
}

export const useLocationStore = create<LocationStore>((set) => ({
  items: [],
  loading: true,
  load: () => set({ items: locationRepo.getAll(), loading: false }),
  addLocation: (loc) => set({ items: locationRepo.add(loc) }),
  updateLocation: (code, data) => set({ items: locationRepo.update(code, data) }),
  removeLocation: (code) => set({ items: locationRepo.remove(code) }),
}));

// --- Route Store ---
interface RouteStore {
  items: RouteMaster[];
  loading: boolean;
  load: () => void;
  addRoute: (route: RouteMaster) => void;
  updateRoute: (id: string, data: Partial<RouteMaster>) => void;
  removeRoute: (id: string) => void;
}

export const useRouteStore = create<RouteStore>((set) => ({
  items: [],
  loading: true,
  load: () => set({ items: routeRepo.getAll(), loading: false }),
  addRoute: (route) => set({ items: routeRepo.add(route) }),
  updateRoute: (id, data) => set({ items: routeRepo.update(id, data) }),
  removeRoute: (id) => set({ items: routeRepo.remove(id) }),
}));

// --- Journey Plan Store ---
interface JourneyPlanStore {
  items: JourneyPlan[];
  masters: JourneyMaster[];
  journeys: Journey[];
  load: () => void;
}

export const useJourneyPlanStore = create<JourneyPlanStore>((set) => ({
  items: [],
  masters: [],
  journeys: [],
  load: () => set({
    items: journeyPlanRepo.getAll(),
    masters: journeyMasterRepo.getAll(),
    journeys: journeyRepo.getAll(),
  }),
}));

// --- Request Store ---
interface RequestStore {
  items: TransportRequest[];
  load: () => void;
}

export const useRequestStore = create<RequestStore>((set) => ({
  items: [],
  load: () => set({ items: requestRepo.getAll() }),
}));

// --- Logistics Flow Store (for the end-to-end flow) ---
interface LogisticsFlowStore {
  currentStep: number;
  assignedVehicleNo: string | null;
  assignedDriverId: string | null;
  setStep: (step: number) => void;
  assignFleetDriver: (vehicleNo: string, driverId: string) => void;
}

export const useLogisticsFlowStore = create<LogisticsFlowStore>((set) => ({
  currentStep: 0,
  assignedVehicleNo: null,
  assignedDriverId: null,
  setStep: (step) => set({ currentStep: step }),
  assignFleetDriver: (vehicleNo, driverId) =>
    set({ assignedVehicleNo: vehicleNo, assignedDriverId: driverId }),
}));

// --- Sidebar Store ---
interface SidebarStore {
  collapsed: boolean;
  toggle: () => void;
  setCollapsed: (v: boolean) => void;
}

export const useSidebarStore = create<SidebarStore>((set) => ({
  collapsed: false,
  toggle: () => set((s) => ({ collapsed: !s.collapsed })),
  setCollapsed: (collapsed) => set({ collapsed }),
}));
