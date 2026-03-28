# GLS Fleet Management — Architecture Skill Guide

## Overview

This is a fully migrated fleet management application, converted from Flutter to a React + Vite + TypeScript stack with Tailwind CSS, Zustand state management, and browser localStorage persistence. The architecture is designed for **easy future API integration** — swapping localStorage repositories for real API calls requires changing only the repository layer.

## When to Use This Architecture

- Building **internal tools, dashboards, or admin panels** that are data-heavy and CRUD-oriented
- Prototyping applications where the **backend is not yet ready** but the frontend must be fully functional
- Projects requiring **offline-first** or **localStorage-backed** persistence with a clear upgrade path to APIs
- Applications needing **feature-based state management** with Zustand

## Architecture Layers

```
Component (Page/UI)
    ↓ reads state, dispatches actions
Zustand Store (store/*.ts)
    ↓ calls repository methods
Repository (repositories/mock/*.ts → repositories/api/*.ts later)
    ↓ reads/writes data
Storage Layer (lib/storage.ts → fetch/axios later)
    ↓ persists to
Browser localStorage (→ Backend API later)
```

## Key Patterns

### 1. Repository Pattern
All data access goes through typed repository interfaces. Currently backed by localStorage, but designed to be swapped:

```typescript
// Current: localStorage
const vehicles = storageService.get<Vehicle[]>('gls_vehicles') ?? [];

// Future: API
const vehicles = await fetch('/api/vehicles').then(r => r.json());
```

### 2. Zustand Store Pattern
Each feature has its own store with:
- `items` — the data array
- `loading` — loading state boolean
- `load()` — initial data fetch from repository
- `add*()` / `update*()` / `remove*()` — CRUD actions
- Optional: `query`, `filter` for search/filter state

### 3. Seed Data Pattern
On first load, `lib/seed-data.ts` checks if localStorage keys exist. If not, it populates them with realistic test data derived from the original Flutter mock JSON files.

### 4. Component Pattern
- All pages are client components (`'use client'`) because they use Zustand and browser APIs
- Pages call `store.load()` in `useEffect` on mount
- Shared UI primitives live in `components/shared/index.tsx`
- shadcn/ui components are in `components/ui/`

## How to Add a New Feature

1. **Define types** in `types/index.ts`
2. **Add seed data** in `lib/seed-data.ts`
3. **Create repository functions** in `repositories/mock/index.ts`
4. **Create a Zustand store** in `store/index.ts`
5. **Build the page** in `pages/NewFeature.tsx`
6. **Add the route** in `App.tsx`
7. **Add sidebar navigation** in `components/AppSidebar.tsx`

## How to Replace Mock with API

1. Create `repositories/api/index.ts`
2. Implement the same function signatures using `fetch` or `axios`
3. Update the Zustand store to call API repository instead of mock repository
4. Remove localStorage seed data for that feature
5. No UI changes needed

## Do's and Don'ts

### Do
- Keep all localStorage access inside `lib/storage.ts`
- Keep all data operations inside repository files
- Use Zustand stores as the single source of truth for UI
- Use `toast` from sonner for user feedback
- Use `StatusPill` and `SectionCard` shared components for consistency
- Add loading and empty states to every page

### Don't
- Access `localStorage` directly in page or UI components
- Put business logic inside components — use stores
- Skip TypeScript types — every entity must be typed
- Use `any` type — use proper interfaces
- Mix mock persistence logic with presentation logic
- Skip error handling in repository operations

## Tech Stack Reference

| Layer | Technology |
|-------|-----------|
| Framework | React 19 + Vite |
| Routing | Wouter |
| Styling | Tailwind CSS 4 + shadcn/ui |
| State | Zustand |
| Validation | Zod |
| Charts | Recharts |
| Icons | Lucide React |
| Toasts | Sonner |
| Persistence | Browser localStorage |

## File Structure

```
client/src/
├── App.tsx              # Routes and layout
├── index.css            # Tailwind theme and design tokens
├── types/index.ts       # All TypeScript interfaces
├── lib/
│   ├── storage.ts       # localStorage utility service
│   └── seed-data.ts     # Test data seeder
├── repositories/
│   └── mock/index.ts    # localStorage-backed CRUD
├── store/index.ts       # All Zustand stores
├── components/
│   ├── AppSidebar.tsx   # Navigation sidebar
│   ├── AppHeader.tsx    # Top header bar
│   ├── DashboardLayout.tsx # Layout wrapper
│   └── shared/index.tsx # Reusable UI primitives
├── pages/               # All feature pages
│   ├── Dashboard.tsx
│   ├── FleetManagement.tsx
│   ├── DriverManagement.tsx
│   └── ... (19 pages total)
```
