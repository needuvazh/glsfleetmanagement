# Next.js / Vite Architect Guide

## Routing Architecture

This project uses **Wouter** for client-side routing (not Next.js App Router, since it runs on Vite). All routes are defined in `App.tsx`.

### Route Convention
```tsx
<Route path="/feature-name" component={FeaturePage} />
```

### Adding a New Route
1. Create `pages/NewPage.tsx`
2. Import in `App.tsx`
3. Add `<Route path="/new-page" component={NewPage} />`
4. Add navigation entry in `AppSidebar.tsx`

## Server vs Client Components

Since this is a Vite SPA (not Next.js SSR), all components are client-side. However, the architecture is designed so that if migrated to Next.js App Router:

- **Layout shells** (`DashboardLayout`, `AppSidebar`, `AppHeader`) would become server components
- **Interactive pages** with Zustand usage would remain client components with `'use client'`
- **Static content** (empty states, icons) could be server components

### Current Rule
All page components use `'use client'` directive as a forward-compatible marker.

## Layout Structure

```
DashboardLayout
├── AppSidebar (fixed left, collapsible)
├── Main Content Area
│   ├── AppHeader (sticky top)
│   └── Page Content (scrollable)
```

## Performance Guidelines

1. **Lazy loading**: For large pages, use `React.lazy()` with `Suspense`
2. **Memoization**: Use `useMemo` for expensive computations in stores
3. **Stable references**: Always memoize objects/arrays passed as query inputs
4. **Code splitting**: Each page is already a separate module

## Folder Conventions

| Path | Purpose |
|------|---------|
| `pages/` | Route-level page components |
| `components/` | Reusable UI components |
| `components/ui/` | shadcn/ui primitives |
| `components/shared/` | App-specific shared components |
| `store/` | Zustand state stores |
| `lib/` | Utility functions and services |
| `types/` | TypeScript interfaces |
| `repositories/` | Data access layer |
