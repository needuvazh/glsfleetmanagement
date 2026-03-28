'use client';

// ============================================================
// DashboardLayout — Main layout with sidebar + header + content
// Server-like shell: wraps all pages
// ============================================================

import { useEffect } from 'react';
import AppSidebar from './AppSidebar';
import AppHeader from './AppHeader';
import { useSidebarStore } from '@/store';
import { seedIfNeeded } from '@/lib/seed-data';
import { cn } from '@/lib/utils';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { collapsed } = useSidebarStore();

  useEffect(() => {
    seedIfNeeded();
  }, []);

  return (
    <div className="min-h-screen bg-background">
      <AppSidebar />
      <div
        className={cn(
          'transition-all duration-300 flex flex-col min-h-screen',
          collapsed ? 'ml-[68px]' : 'ml-[260px]'
        )}
      >
        <AppHeader />
        <main className="flex-1 p-6 overflow-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
