# Form Validation and UX Guide

## Zod Usage Patterns

### Schema Definition
Define schemas in a centralized location or co-located with the feature:

```typescript
import { z } from 'zod';

export const vehicleSchema = z.object({
  vehicleNumber: z.string().min(1, 'Vehicle number is required'),
  type: z.string().min(1, 'Vehicle type is required'),
  driver: z.string().min(1, 'Driver name is required'),
  fuelLevel: z.number().min(0).max(100),
});

export type VehicleFormData = z.infer<typeof vehicleSchema>;
```

### Integration with React Hook Form
```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const form = useForm<VehicleFormData>({
  resolver: zodResolver(vehicleSchema),
  defaultValues: { vehicleNumber: '', type: '', driver: '', fuelLevel: 100 },
});
```

## Current Form Pattern

The current implementation uses native HTML forms with `FormData` for simplicity:

```typescript
const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  const fd = new FormData(e.currentTarget);
  store.addItem({
    name: fd.get('name') as string,
    // ...
  });
  toast.success('Item created');
  setDialogOpen(false);
};
```

### Upgrading to Zod Validation
To add Zod validation to existing forms:
1. Define the schema
2. Parse form data through the schema before submitting
3. Display validation errors inline

```typescript
const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  const fd = new FormData(e.currentTarget);
  const raw = Object.fromEntries(fd.entries());
  const result = vehicleSchema.safeParse(raw);
  
  if (!result.success) {
    const errors = result.error.flatten().fieldErrors;
    // Display errors to user
    Object.values(errors).flat().forEach(msg => toast.error(msg));
    return;
  }
  
  store.addItem(result.data);
  toast.success('Created successfully');
};
```

## Error Message Conventions

| Scenario | Message Pattern |
|----------|----------------|
| Required field | `"{Field name}" is required` |
| Invalid format | `"Please enter a valid {field}"` |
| Min/Max | `"{Field}" must be at least {n}` |
| Success | `"{Entity} created successfully"` |
| Delete | `"{Entity} removed"` |
| Update | `"Status updated"` or `"{Entity} updated"` |

## Loading and Submission States

```typescript
// In the form component
const [submitting, setSubmitting] = useState(false);

const handleSubmit = async () => {
  setSubmitting(true);
  try {
    await store.addItem(data);
    toast.success('Created');
    setDialogOpen(false);
  } catch {
    toast.error('Failed to create');
  } finally {
    setSubmitting(false);
  }
};

// In the button
<Button type="submit" disabled={submitting}>
  {submitting ? <Loader2 className="animate-spin" /> : 'Submit'}
</Button>
```

## Form Structure Guidelines

1. Use `Dialog` for create/edit forms (keeps context)
2. Use `Label` + `Input` pairs with proper `name` attributes
3. Group related fields with `grid grid-cols-2 gap-3`
4. Always include a full-width submit button at the bottom
5. Close dialog on successful submission
6. Show toast notification for success/error
