# UI System and Design Guide

## Design Philosophy: Logistics Blueprint

The application follows a **Swiss Design / Technical Schematic** aesthetic:
- Clean, precise, data-dense layouts
- Cool white background with deep navy primary
- Mathematical 8px spacing grid
- Blueprint-inspired accent borders and dotted patterns
- DM Sans (headings) + Source Sans 3 (body) typography

## Color System

| Token | Usage | Value |
|-------|-------|-------|
| `--primary` | Buttons, active states | Navy blue |
| `--accent` | Hover, secondary actions | Light gray |
| `--destructive` | Delete, error states | Red |
| `--muted` | Backgrounds, disabled | Light gray |
| Chart colors | `--chart-1` through `--chart-5` | Blue spectrum |

## Component Conventions

### SectionCard
The primary container for page sections:
```tsx
<SectionCard
  title="Section Title"
  subtitle="Description text"
  icon={LucideIcon}
  accent="#hexcolor"     // Left border accent
  trailing={<Button />}  // Optional action button
>
  {children}
</SectionCard>
```

### KpiCard
For dashboard metric display:
```tsx
<KpiCard
  title="Metric Name"
  value={128}
  subtitle="Description"
  icon={LucideIcon}
  color="#hexcolor"
/>
```

### StatusPill
For status badges:
```tsx
<StatusPill label="Active" variant="success" />
// Variants: success, warning, danger, info, neutral
```

### EmptyState
For empty data views:
```tsx
<EmptyState title="No items found" icon={LucideIcon} />
```

### PageLoading
For loading states:
```tsx
if (loading) return <PageLoading />;
```

## Table Conventions

- Use shadcn `Table` components
- Header text: `text-xs font-semibold text-muted-foreground`
- Cell text: `text-xs`
- Monospace for IDs and numbers: `font-mono`
- Bold for primary identifiers: `font-medium`
- Truncate long text: `max-w-[200px] truncate`

## Responsive Design Rules

1. **Grid breakpoints**: `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5`
2. **Table overflow**: Always wrap in `overflow-x-auto`
3. **Sidebar**: Collapsible on mobile
4. **Forms**: Stack on mobile, grid on desktop
5. **Min touch targets**: 44px for interactive elements

## Animation Guidance

- Use `framer-motion` for page transitions and list animations
- Keep animations subtle (200-300ms duration)
- Use `transition-colors` for hover states
- Use `animate-spin` for loading spinners
- Avoid animations that block user interaction

## Consistency Rules

1. All pages follow the same structure: KPI cards (if applicable) → Main content section
2. All tables use the same header/cell styling
3. All forms use Dialog with consistent layout
4. All actions show toast notifications
5. All pages handle loading and empty states
6. All search inputs use the same pattern (Search icon + Input)
