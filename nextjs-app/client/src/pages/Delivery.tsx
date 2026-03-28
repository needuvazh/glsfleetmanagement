'use client';

import { useEffect } from 'react';
import { useDeliveryStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, EmptyState } from '@/components/shared';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { MapPin, CheckCircle } from 'lucide-react';
import { toast } from 'sonner';

export default function Delivery() {
  const { items, load, updateDelivery } = useDeliveryStore();

  useEffect(() => { load(); }, [load]);

  return (
    <div className="space-y-6">
      <SectionCard title="Delivery — Proof of Delivery" subtitle="Confirm deliveries and capture receiver details" icon={MapPin} accent="#059669">
        {items.length === 0 ? (
          <EmptyState title="No deliveries" icon={MapPin} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Delivery ID</TableHead>
                  <TableHead className="text-xs">Work Order</TableHead>
                  <TableHead className="text-xs">Location</TableHead>
                  <TableHead className="text-xs">Receiver</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((d) => (
                  <TableRow key={d.deliveryId}>
                    <TableCell className="font-mono text-xs font-medium">{d.deliveryId}</TableCell>
                    <TableCell className="text-xs font-mono">{d.woId}</TableCell>
                    <TableCell className="text-xs">{d.location}</TableCell>
                    <TableCell className="text-xs">{d.receiver || '—'}</TableCell>
                    <TableCell><StatusPill label={d.status} variant={getStatusVariant(d.status)} /></TableCell>
                    <TableCell>
                      {d.status === 'Pending' && (
                        <Button size="sm" variant="outline" className="gap-1 text-xs h-7" onClick={() => {
                          updateDelivery(d.deliveryId, { status: 'Delivered', receiver: 'Confirmed' });
                          toast.success('Delivery confirmed');
                        }}>
                          <CheckCircle className="w-3 h-3" /> Confirm
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
