'use client';

// ============================================================
// Shared UI Components — Reusable across all pages
// Design: Logistics Blueprint — clean cards, blue accents
// ============================================================

import { cn } from '@/lib/utils';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { FLOW_STEPS } from '@/types';
import type { LucideIcon } from 'lucide-react';

// --- KPI Card ---
interface KpiCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: LucideIcon;
  color: string;
  className?: string;
}

export function KpiCard({ title, value, subtitle, icon: Icon, color, className }: KpiCardProps) {
  return (
    <Card className={cn('relative overflow-hidden', className)}>
      <div className="absolute left-0 top-0 bottom-0 w-1" style={{ backgroundColor: color }} />
      <CardContent className="p-5 pl-6">
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{title}</p>
            <p className="text-2xl font-bold mt-1" style={{ fontFamily: 'var(--font-mono)', color }}>
              {value}
            </p>
            {subtitle && <p className="text-xs text-muted-foreground mt-1">{subtitle}</p>}
          </div>
          <div
            className="w-10 h-10 rounded-lg flex items-center justify-center"
            style={{ backgroundColor: `${color}15` }}
          >
            <Icon className="w-5 h-5" style={{ color }} />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

// --- Section Card (OpsShell equivalent) ---
interface SectionCardProps {
  title: string;
  subtitle?: string;
  icon?: LucideIcon;
  accent?: string;
  trailing?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}

export function SectionCard({ title, subtitle, icon: Icon, accent = '#3b82f6', trailing, children, className }: SectionCardProps) {
  return (
    <Card className={cn('relative overflow-hidden', className)}>
      <div className="absolute left-0 top-0 bottom-0 w-1" style={{ backgroundColor: accent }} />
      <CardHeader className="pb-3 pl-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {Icon && (
              <div
                className="w-9 h-9 rounded-lg flex items-center justify-center"
                style={{ backgroundColor: `${accent}15` }}
              >
                <Icon className="w-4.5 h-4.5" style={{ color: accent }} />
              </div>
            )}
            <div>
              <CardTitle className="text-sm font-bold">{title}</CardTitle>
              {subtitle && <p className="text-xs text-muted-foreground mt-0.5">{subtitle}</p>}
            </div>
          </div>
          {trailing}
        </div>
      </CardHeader>
      <CardContent className="pl-6">{children}</CardContent>
    </Card>
  );
}

// --- Status Pill ---
interface StatusPillProps {
  label: string;
  variant?: 'success' | 'warning' | 'danger' | 'info' | 'default';
  className?: string;
}

const pillColors = {
  success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  warning: 'bg-amber-50 text-amber-700 border-amber-200',
  danger: 'bg-red-50 text-red-700 border-red-200',
  info: 'bg-blue-50 text-blue-700 border-blue-200',
  default: 'bg-gray-50 text-gray-700 border-gray-200',
};

export function StatusPill({ label, variant = 'default', className }: StatusPillProps) {
  return (
    <Badge
      variant="outline"
      className={cn('text-[11px] font-semibold px-2.5 py-0.5 rounded-full', pillColors[variant], className)}
    >
      {label}
    </Badge>
  );
}

export function getStatusVariant(status: string): StatusPillProps['variant'] {
  const s = status.toLowerCase();
  if (['active', 'compliant', 'available', 'delivered', 'approved', 'assigned', 'completed'].includes(s)) return 'success';
  if (['maintenance', 'expiring soon', 'on duty', 'pending', 'in transit', 'pending assignment'].includes(s)) return 'warning';
  if (['idle', 'overdue', 'rest', 'delayed', 'inactive', 'high'].includes(s)) return 'danger';
  if (['on trip', 'moving', 'planned', 'medium'].includes(s)) return 'info';
  return 'default';
}

// --- Flow Stepper ---
interface FlowStepperProps {
  currentStep: number;
  className?: string;
}

export function FlowStepper({ currentStep, className }: FlowStepperProps) {
  const progress = ((currentStep + 1) / FLOW_STEPS.length) * 100;

  return (
    <Card className={cn('', className)}>
      <CardContent className="p-5">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-bold" style={{ fontFamily: 'var(--font-heading)' }}>
            End-to-End Flow
          </h3>
          <span className="text-xs text-muted-foreground font-mono">
            Step {currentStep + 1} of {FLOW_STEPS.length}
          </span>
        </div>
        <Progress value={progress} className="h-2 mb-4" />
        <div className="flex flex-wrap gap-2">
          {FLOW_STEPS.map((step, i) => (
            <div key={step} className="flex items-center gap-1.5">
              <div
                className={cn(
                  'w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold transition-colors',
                  i <= currentStep
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-muted text-muted-foreground'
                )}
              >
                {i + 1}
              </div>
              <span
                className={cn(
                  'text-[11px]',
                  i === currentStep ? 'font-bold text-foreground' : 'text-muted-foreground'
                )}
              >
                {step}
              </span>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

// --- Empty State ---
interface EmptyStateProps {
  title?: string;
  description?: string;
  icon?: LucideIcon;
}

export function EmptyState({ title = 'No data found', description, icon: Icon }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      {Icon && <Icon className="w-12 h-12 text-muted-foreground/30 mb-4" />}
      <p className="text-sm font-medium text-muted-foreground">{title}</p>
      {description && <p className="text-xs text-muted-foreground/70 mt-1">{description}</p>}
    </div>
  );
}

// --- Page Loading ---
export function PageLoading() {
  return (
    <div className="flex items-center justify-center py-24">
      <div className="flex flex-col items-center gap-3">
        <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        <p className="text-sm text-muted-foreground">Loading...</p>
      </div>
    </div>
  );
}
