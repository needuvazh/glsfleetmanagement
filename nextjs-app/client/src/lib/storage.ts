// ============================================================
// LocalStorage Utility — Safe read/write with JSON serialization
// Design: All persistence goes through this layer.
// Future: Replace with API calls without changing store code.
// ============================================================

const PREFIX = 'gls_';

export const StorageKeys = {
  DASHBOARD: `${PREFIX}dashboard`,
  FLEET: `${PREFIX}fleet`,
  DRIVERS: `${PREFIX}drivers`,
  CUSTOMERS: `${PREFIX}customers`,
  CUSTOMER_REQUESTS: `${PREFIX}customer_requests`,
  QUOTATIONS: `${PREFIX}quotations`,
  WORK_ORDERS_FLOW: `${PREFIX}work_orders_flow`,
  WORK_ORDERS: `${PREFIX}work_orders`,
  REQUESTS: `${PREFIX}requests`,
  JOURNEY_PLANS: `${PREFIX}journey_plans`,
  JOURNEY_MASTER: `${PREFIX}journey_master`,
  JOURNEYS: `${PREFIX}journeys`,
  COMPLIANCE: `${PREFIX}compliance`,
  ALERTS: `${PREFIX}alerts`,
  DELIVERY: `${PREFIX}delivery`,
  INVOICES: `${PREFIX}invoices`,
  IVMS: `${PREFIX}ivms`,
  DFMS: `${PREFIX}dfms`,
  VEHICLE_TYPES: `${PREFIX}vehicle_types`,
  VEHICLES: `${PREFIX}vehicles`,
  MODULE_DOCUMENTS: `${PREFIX}module_documents`,
  ROLES: `${PREFIX}roles`,
  USERS: `${PREFIX}users`,
  LOCATIONS: `${PREFIX}locations`,
  ROUTES: `${PREFIX}routes`,
  SEEDED: `${PREFIX}seeded`,
} as const;

export type StorageKey = (typeof StorageKeys)[keyof typeof StorageKeys];

export function getItem<T>(key: StorageKey): T | null {
  try {
    const raw = localStorage.getItem(key);
    if (raw === null) return null;
    return JSON.parse(raw) as T;
  } catch {
    console.warn(`[Storage] Failed to read key "${key}"`);
    return null;
  }
}

export function setItem<T>(key: StorageKey, value: T): void {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (e) {
    console.error(`[Storage] Failed to write key "${key}"`, e);
  }
}

export function removeItem(key: StorageKey): void {
  try {
    localStorage.removeItem(key);
  } catch {
    console.warn(`[Storage] Failed to remove key "${key}"`);
  }
}

export function clearAll(): void {
  try {
    Object.values(StorageKeys).forEach((key) => localStorage.removeItem(key));
  } catch {
    console.warn('[Storage] Failed to clear storage');
  }
}
