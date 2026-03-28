'use client';

// ============================================================
// AppSidebar — Persistent sidebar navigation
// Design: Logistics Blueprint — deep navy sidebar with icon+text nav
// ============================================================

import { useLocation, Link } from 'wouter';
import { useSidebarStore } from '@/store';
import {
  LayoutDashboard, Truck, Users, FileText, MapPin, Route, Shield,
  Bell, Package, ClipboardList, UserCog, FolderOpen, Settings,
  ChevronLeft, ChevronRight, Navigation, Receipt, Milestone,
  type LucideIcon,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';

interface NavItem {
  label: string;
  href: string;
  icon: LucideIcon;
  group: string;
}

const navItems: NavItem[] = [
  // Operations
  { label: 'Dashboard', href: '/', icon: LayoutDashboard, group: 'Operations' },
  { label: 'Customer Requests', href: '/customer-requests', icon: ClipboardList, group: 'Operations' },
  { label: 'Quotations', href: '/quotations', icon: Receipt, group: 'Operations' },
  { label: 'Work Orders', href: '/work-orders', icon: Package, group: 'Operations' },

  // Fleet
  { label: 'Fleet Management', href: '/fleet', icon: Truck, group: 'Fleet' },
  { label: 'Driver Management', href: '/drivers', icon: Users, group: 'Fleet' },
  { label: 'Compliance', href: '/compliance', icon: Shield, group: 'Fleet' },

  // Journey
  { label: 'Journey Management', href: '/journey', icon: Navigation, group: 'Journey' },
  { label: 'Trip Execution', href: '/trip-execution', icon: Milestone, group: 'Journey' },
  { label: 'Delivery (POD)', href: '/delivery', icon: MapPin, group: 'Journey' },

  // Documents & Finance
  { label: 'Documents', href: '/documents', icon: FolderOpen, group: 'Documents' },
  { label: 'Invoice', href: '/invoice', icon: Receipt, group: 'Documents' },
  { label: 'Alerts', href: '/alerts', icon: Bell, group: 'Documents' },

  // Master Data
  { label: 'Vehicle Types', href: '/vehicle-types', icon: Settings, group: 'Master Data' },
  { label: 'Locations', href: '/locations', icon: MapPin, group: 'Master Data' },
  { label: 'Routes', href: '/routes', icon: Route, group: 'Master Data' },
  { label: 'Document Mgmt', href: '/document-management', icon: FileText, group: 'Master Data' },

  // Admin
  { label: 'Roles', href: '/roles', icon: Shield, group: 'Admin' },
  { label: 'Users', href: '/users', icon: UserCog, group: 'Admin' },
];

export default function AppSidebar() {
  const [location] = useLocation();
  const { collapsed, toggle } = useSidebarStore();

  const groups = navItems.reduce<Record<string, NavItem[]>>((acc, item) => {
    if (!acc[item.group]) acc[item.group] = [];
    acc[item.group].push(item);
    return acc;
  }, {});

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 h-screen bg-sidebar text-sidebar-foreground border-r border-sidebar-border transition-all duration-300 flex flex-col',
        collapsed ? 'w-[68px]' : 'w-[260px]'
      )}
    >
      {/* Logo */}
      <div className="flex items-center gap-3 px-4 h-16 border-b border-sidebar-border shrink-0">
        <div className="w-8 h-8 rounded-lg bg-sidebar-primary flex items-center justify-center shrink-0">
          <Truck className="w-4.5 h-4.5 text-sidebar-primary-foreground" />
        </div>
        {!collapsed && (
          <div className="overflow-hidden">
            <h1 className="text-sm font-bold tracking-tight text-sidebar-foreground truncate" style={{ fontFamily: 'var(--font-heading)' }}>
              GLS Fleet
            </h1>
            <p className="text-[10px] text-sidebar-foreground/50 truncate">Management System</p>
          </div>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-3 px-2 space-y-4">
        {Object.entries(groups).map(([group, items]) => (
          <div key={group}>
            {!collapsed && (
              <p className="px-3 mb-1.5 text-[10px] font-semibold uppercase tracking-widest text-sidebar-foreground/40">
                {group}
              </p>
            )}
            <div className="space-y-0.5">
              {items.map((item) => {
                const isActive = location === item.href || (item.href !== '/' && location.startsWith(item.href));
                const Icon = item.icon;

                const linkContent = (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      'flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors',
                      isActive
                        ? 'bg-sidebar-accent text-sidebar-accent-foreground font-semibold'
                        : 'text-sidebar-foreground/70 hover:bg-sidebar-accent/50 hover:text-sidebar-foreground'
                    )}
                  >
                    <Icon className="w-4 h-4 shrink-0" />
                    {!collapsed && <span className="truncate">{item.label}</span>}
                  </Link>
                );

                if (collapsed) {
                  return (
                    <Tooltip key={item.href} delayDuration={0}>
                      <TooltipTrigger asChild>{linkContent}</TooltipTrigger>
                      <TooltipContent side="right" className="text-xs">
                        {item.label}
                      </TooltipContent>
                    </Tooltip>
                  );
                }

                return linkContent;
              })}
            </div>
          </div>
        ))}
      </nav>

      {/* Collapse Toggle */}
      <button
        onClick={toggle}
        className="flex items-center justify-center h-10 border-t border-sidebar-border text-sidebar-foreground/50 hover:text-sidebar-foreground hover:bg-sidebar-accent/30 transition-colors"
      >
        {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
      </button>
    </aside>
  );
}
