'use client';

// ============================================================
// AppHeader — Top bar with breadcrumb and actions
// Design: Logistics Blueprint — clean, minimal top bar
// ============================================================

import { useLocation } from 'wouter';
import { Bell, Search } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { useAlertStore } from '@/store';
import { useEffect } from 'react';

const routeLabels: Record<string, string> = {
  '/': 'Operations Dashboard',
  '/customer-requests': 'Customer Requests',
  '/quotations': 'Feasibility & Quotations',
  '/work-orders': 'Work Orders',
  '/fleet': 'Fleet Management',
  '/drivers': 'Driver Management',
  '/compliance': 'Compliance & Inspection',
  '/journey': 'Journey Management',
  '/trip-execution': 'Trip Execution',
  '/delivery': 'Delivery (POD)',
  '/documents': 'Document Submission',
  '/invoice': 'Invoice & Reports',
  '/alerts': 'Alerts',
  '/vehicle-types': 'Vehicle Types',
  '/locations': 'Location Master',
  '/routes': 'Route Master',
  '/document-management': 'Document Management',
  '/roles': 'Role Management',
  '/users': 'User Management',
};

export default function AppHeader() {
  const [location] = useLocation();
  const { items: alerts, load: loadAlerts } = useAlertStore();

  useEffect(() => {
    loadAlerts();
  }, [loadAlerts]);

  const unreadCount = alerts.filter((a) => !a.isRead).length;
  const title = routeLabels[location] || 'GLS Fleet Management';

  return (
    <header className="h-16 border-b border-border bg-card flex items-center justify-between px-6 shrink-0">
      <div>
        <h2 className="text-lg font-bold text-foreground" style={{ fontFamily: 'var(--font-heading)' }}>
          {title}
        </h2>
      </div>

      <div className="flex items-center gap-3">
        <div className="relative hidden md:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Search..."
            className="pl-9 w-64 h-9 bg-muted/50 border-0 text-sm"
          />
        </div>

        <Button variant="ghost" size="icon" className="relative">
          <Bell className="w-4.5 h-4.5" />
          {unreadCount > 0 && (
            <Badge className="absolute -top-1 -right-1 h-4.5 min-w-4.5 px-1 text-[10px] bg-destructive text-destructive-foreground border-0">
              {unreadCount}
            </Badge>
          )}
        </Button>

        <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-primary-foreground text-xs font-bold">
          MA
        </div>
      </div>
    </header>
  );
}
