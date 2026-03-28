'use client';

import { useEffect } from 'react';
import { useAlertStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, EmptyState } from '@/components/shared';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Bell, Eye } from 'lucide-react';

export default function Alerts() {
  const { items, load, markRead } = useAlertStore();

  useEffect(() => { load(); }, [load]);

  const unread = items.filter((a) => !a.isRead);
  const read = items.filter((a) => a.isRead);

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: 'Total Alerts', count: items.length, color: '#3b82f6' },
          { label: 'Unread', count: unread.length, color: '#dc2626' },
          { label: 'Read', count: read.length, color: '#16a34a' },
        ].map((s) => (
          <div key={s.label} className="bg-card border border-border rounded-lg p-4 relative overflow-hidden">
            <div className="absolute left-0 top-0 bottom-0 w-1" style={{ backgroundColor: s.color }} />
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider pl-3">{s.label}</p>
            <p className="text-3xl font-bold mt-1 pl-3" style={{ fontFamily: 'var(--font-mono)', color: s.color }}>{s.count}</p>
          </div>
        ))}
      </div>

      <SectionCard title="Alert Log" subtitle="Vehicle alerts with severity and status" icon={Bell} accent="#dc2626">
        {items.length === 0 ? (
          <EmptyState title="No alerts" icon={Bell} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">ID</TableHead>
                  <TableHead className="text-xs">Vehicle</TableHead>
                  <TableHead className="text-xs">Type</TableHead>
                  <TableHead className="text-xs">Severity</TableHead>
                  <TableHead className="text-xs">Message</TableHead>
                  <TableHead className="text-xs">Time</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((a) => (
                  <TableRow key={a.id} className={!a.isRead ? 'bg-red-50/50' : ''}>
                    <TableCell className="font-mono text-xs font-medium">{a.id}</TableCell>
                    <TableCell className="text-xs font-mono">{a.vehicleId}</TableCell>
                    <TableCell className="text-xs">{a.type}</TableCell>
                    <TableCell><StatusPill label={a.severity} variant={getStatusVariant(a.severity)} /></TableCell>
                    <TableCell className="text-xs max-w-[200px] truncate">{a.message}</TableCell>
                    <TableCell className="text-xs font-mono">{new Date(a.timestamp).toLocaleString()}</TableCell>
                    <TableCell>
                      <StatusPill label={a.isRead ? 'Read' : 'Unread'} variant={a.isRead ? 'success' : 'danger'} />
                    </TableCell>
                    <TableCell>
                      {!a.isRead && (
                        <Button size="sm" variant="ghost" className="gap-1 text-xs h-7" onClick={() => markRead(a.id)}>
                          <Eye className="w-3 h-3" /> Mark Read
                        </Button>
                      )}
                    </TableCell>
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
