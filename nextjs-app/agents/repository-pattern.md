# Repository Pattern Guide

## Architecture

```
repositories/
├── mock/
│   └── index.ts       ← Current: localStorage-backed CRUD
└── api/               ← Future: HTTP API-backed CRUD (placeholder)
    └── index.ts
```

## Mock Repository Rules

1. All localStorage access goes through `lib/storage.ts` utility
2. Repository functions are pure CRUD — no UI logic, no state management
3. Each function operates on a specific localStorage key
4. Functions return typed data — never `any`

## Storage Utility API

```typescript
const storageService = {
  get<T>(key: string): T | null,
  set<T>(key: string, value: T): void,
  remove(key: string): void,
  clear(): void,
  has(key: string): boolean,
}
```

## CRUD Pattern Convention

```typescript
// READ
function getAll(key: string): T[] {
  return storageService.get<T[]>(key) ?? [];
}

// CREATE
function add(key: string, item: T): void {
  const items = getAll(key);
  items.push(item);
  storageService.set(key, items);
}

// UPDATE
function update(key: string, id: string, updates: Partial<T>): void {
  const items = getAll(key);
  const idx = items.findIndex(i => i.id === id);
  if (idx !== -1) {
    items[idx] = { ...items[idx], ...updates };
    storageService.set(key, items);
  }
}

// DELETE
function remove(key: string, id: string): void {
  const items = getAll(key).filter(i => i.id !== id);
  storageService.set(key, items);
}
```

## Future API Replacement

When replacing mock with API:

1. Create `repositories/api/index.ts`
2. Implement identical function signatures using `fetch` or `axios`:

```typescript
// Before (mock)
export function getVehicles(): Vehicle[] {
  return storageService.get<Vehicle[]>('gls_vehicles') ?? [];
}

// After (API)
export async function getVehicles(): Promise<Vehicle[]> {
  const res = await fetch('/api/vehicles');
  return res.json();
}
```

3. Update store to call API repository
4. Make store actions `async` if not already
5. No UI changes needed

## Interface Design

Define repository interfaces so mock and API implementations are interchangeable:

```typescript
interface VehicleRepository {
  getAll(): Vehicle[] | Promise<Vehicle[]>;
  getById(id: string): Vehicle | null | Promise<Vehicle | null>;
  create(vehicle: Vehicle): void | Promise<void>;
  update(id: string, data: Partial<Vehicle>): void | Promise<void>;
  delete(id: string): void | Promise<void>;
}
```

## Storage Key Convention

All localStorage keys use the prefix `gls_`:
- `gls_vehicles`
- `gls_drivers`
- `gls_alerts`
- `gls_quotations`
- `gls_work_orders`
- etc.

This prevents conflicts with other applications sharing the same origin.
