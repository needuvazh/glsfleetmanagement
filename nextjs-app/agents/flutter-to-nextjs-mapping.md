# Flutter to Next.js/React Migration Mapping

## Concept Mapping

| Flutter Concept | React/Next.js Equivalent | Notes |
|----------------|-------------------------|-------|
| `StatefulWidget` | `useState` + functional component | All state in hooks |
| `StatelessWidget` | Functional component (no hooks) | Pure render |
| `Navigator.push` | `useLocation` from Wouter | Client-side routing |
| `Provider/Riverpod` | Zustand store | Feature-based stores |
| `FutureBuilder` | `useEffect` + loading state | Async data pattern |
| `StreamBuilder` | `useEffect` + subscription | Real-time updates |
| `setState()` | `useState` setter | Local component state |
| `BuildContext` | React Context / Props | Dependency injection |
| `Scaffold` | `DashboardLayout` | Page wrapper |
| `AppBar` | `AppHeader` component | Top navigation |
| `Drawer` | `AppSidebar` component | Side navigation |
| `ListView.builder` | `.map()` in JSX | List rendering |
| `DataTable` | shadcn `Table` component | Data display |
| `AlertDialog` | shadcn `Dialog` component | Modal dialogs |
| `SnackBar` | `toast()` from Sonner | Notifications |
| `TextFormField` | `Input` + `Label` | Form inputs |
| `DropdownButton` | shadcn `Select` | Dropdowns |
| `TabBar` | shadcn `Tabs` | Tab navigation |
| `CircularProgressIndicator` | `Loader2` with `animate-spin` | Loading spinner |
| `Container` with decoration | Tailwind utility classes | Styling |
| `EdgeInsets` | Tailwind `p-*`, `m-*` | Spacing |
| `Column` | `flex flex-col` | Vertical layout |
| `Row` | `flex flex-row` | Horizontal layout |
| `Expanded` | `flex-1` | Flex grow |
| `SizedBox` | `w-*`, `h-*`, `gap-*` | Spacing/sizing |
| `Card` | shadcn `Card` | Card container |
| `Theme.of(context)` | CSS variables / Tailwind tokens | Theming |

## Migration Rules

### State Management
```dart
// Flutter (Riverpod)
final vehicleProvider = StateNotifierProvider<VehicleNotifier, List<Vehicle>>((ref) {
  return VehicleNotifier();
});
```
```typescript
// React (Zustand)
export const useFleetStore = create<FleetStore>((set) => ({
  items: [],
  load: () => { /* ... */ },
}));
```

### Navigation
```dart
// Flutter
Navigator.pushNamed(context, '/fleet');
```
```typescript
// React (Wouter)
import { useLocation } from 'wouter';
const [, setLocation] = useLocation();
setLocation('/fleet');
```

### Data Models
```dart
// Flutter
class Vehicle {
  final String id;
  final String vehicleNumber;
  final String type;
  // ...
}
```
```typescript
// TypeScript
export interface Vehicle {
  id: string;
  vehicleNumber: string;
  type: string;
  // ...
}
```

### Form Handling
```dart
// Flutter
TextFormField(
  controller: _nameController,
  validator: (value) => value!.isEmpty ? 'Required' : null,
)
```
```typescript
// React
<Input name="name" required />
// Or with Zod:
const schema = z.object({ name: z.string().min(1, 'Required') });
```

### Lists
```dart
// Flutter
ListView.builder(
  itemCount: vehicles.length,
  itemBuilder: (context, index) => VehicleCard(vehicles[index]),
)
```
```tsx
// React
{vehicles.map((v) => <VehicleCard key={v.id} vehicle={v} />)}
```

## Common Conversion Examples

### Screen → Page
A Flutter screen with `Scaffold` + `AppBar` + `body` becomes a React page component wrapped in `DashboardLayout` (via App.tsx routing).

### ViewModel → Zustand Store
Flutter ViewModels/Notifiers become Zustand stores. The `load()` method replaces `init()` or constructor logic.

### Repository → Repository
The repository pattern maps 1:1. Flutter's `MockDataSource` becomes `repositories/mock/index.ts`.

### Mock JSON → Seed Data
Flutter's `assets/mock/*.json` files become `lib/seed-data.ts` with the same data structure.
