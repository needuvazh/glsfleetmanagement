'use client';

import { useEffect } from 'react';
import { useComplianceStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, EmptyState } from '@/components/shared';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Shield } from 'lucide-react';

export default function Compliance() {
  const { items, load } = useComplianceStore();

  useEffect(() => { load(); }, [load]);

  return (
    <div className="space-y-6">
      {/* Summary cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {['Compliant', 'Expiring Soon', 'Overdue'].map((status) => {
          const count = items.filter((c) => c.complianceStatus === status).length;
          const colors: Record<string, string> = { Compliant: '#16a34a', 'Expiring Soon': '#f59e0b', Overdue: '#dc2626' };
          return (
            <div key={status} className="bg-card border border-border rounded-lg p-4 relative overflow-hidden">
              <div className="absolute left-0 top-0 bottom-0 w-1" style={{ backgroundColor: colors[status] }} />
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider pl-3">{status}</p>
              <p className="text-3xl font-bold mt-1 pl-3" style={{ fontFamily: 'var(--font-mono)', color: colors[status] }}>{count}</p>
            </div>
          );
        })}
      </div>

      <SectionCard title="Compliance Records" subtitle="Registration, insurance, and inspection status" icon={Shield} accent="#16a34a">
        {items.length === 0 ? (
          <EmptyState title="No compliance records" icon={Shield} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Vehicle ID</TableHead>
                  <TableHead className="text-xs">Registration Expiry</TableHead>
                  <TableHead className="text-xs">Insurance Expiry</TableHead>
                  <TableHead className="text-xs">Inspection Due</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((c) => (
                  <TableRow key={c.vehicleId}>
                    <TableCell className="font-mono text-xs font-medium">{c.vehicleId}</TableCell>
                    <TableCell className="text-xs">{c.registrationExpiry}</TableCell>
                    <TableCell className="text-xs">{c.insuranceExpiry}</TableCell>
                    <TableCell className="text-xs">{c.inspectionDue}</TableCell>
                    <TableCell><StatusPill label={c.complianceStatus} variant={getStatusVariant(c.complianceStatus)} /></TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </SectionCard>
    </div>
  );
}
