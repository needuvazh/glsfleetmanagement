# Zustand State Management Patterns

## Store Design Rules

1. **One store per feature domain** — `useFleetStore`, `useDriverStore`, `useAlertStore`, etc.
2. **Stores own state + actions** — no business logic in components
3. **Stores call repositories** — never access localStorage directly
4. **Stores are the single source of truth** — components read from stores only

## Store Structure Template

```typescript
interface FeatureStore {
  // State
  items: FeatureItem[];
  loading: boolean;
  
  // Optional UI state (not persisted)
  query: string;
  filter: string;
  
  // Actions
  load: () => void;
  addItem: (item: FeatureItem) => void;
  updateItem: (id: string, updates: Partial<FeatureItem>) => void;
  removeItem: (id: string) => void;
  
  // Optional UI actions
  setQuery: (q: string) => void;
  setFilter: (f: string) => void;
}
```

## Persist Middleware Guidance

### When to Persist
- User preferences (theme, sidebar state)
- Authentication tokens (future)
- Small, frequently accessed lookup data

### When NOT to Persist
- Large datasets already in localStorage via repositories
- Temporary UI state (search queries, dialog open state)
- Derived/computed data

### Current Approach
This project does **not** use Zustand persist middleware because all data is already persisted via the repository layer (localStorage). Stores load data on mount via `load()` and write back via repository functions.

## Store-Repository Separation

```
Component calls → store.addVehicle(data)
Store calls    → mockRepo.addVehicle(data)  // updates localStorage
Store updates  → set({ items: [...items, newVehicle] })  // updates UI
```

The store never knows about localStorage. It only knows about the repository interface.

## Async Flow Pattern

```typescript
load: () => {
  set({ loading: true });
  try {
    const items = mockRepo.getAll('storage_key');
    set({ items, loading: false });
  } catch {
    set({ loading: false });
    // handle error
  }
}
```

## Common Pitfalls

1. **Don't create stores inside components** — define at module level
2. **Don't use `set` with stale closures** — use the callback form: `set((state) => ({ ... }))`
3. **Don't store derived data** — compute in components or with selectors
4. **Don't mix UI state with domain state** — keep search/filter separate from entity data
