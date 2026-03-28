'use client';

import { useEffect, useState } from 'react';
import { useWorkOrderFlowStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Package, Plus, Search } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function WorkOrders() {
  const { items, load, addWorkOrder, updateStatus } = useWorkOrderFlowStore();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [query, setQuery] = useState('');

  useEffect(() => { load(); }, [load]);

  const filtered = items.filter((w) =>
    !query || `${w.woId} ${w.customer} ${w.route} ${w.cargo} ${w.status}`.toLowerCase().includes(query.toLowerCase())
  );

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextNum = items.length > 0 ? Math.max(...items.map((w) => parseInt(w.woId.split('-')[2] || '0'))) + 1 : 893;
    addWorkOrder({
      woId: `WO-2025-${String(nextNum).padStart(4, '0')}`,
      customer: fd.get('customer') as string,
      route: fd.get('route') as string,
      cargo: fd.get('cargo') as string,
      status: 'Pending Assignment',
    });
    toast.success('Work order created');
    setDialogOpen(false);
  };

  return (
    <div className="space-y-6">
      <SectionCard
        title="Work Orders"
        subtitle="Order creation, fleet assignment, and tracking"
        icon={Package}
        accent="#2563eb"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> New Work Order</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Create Work Order</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Customer</Label><Input name="customer" required /></div>
                <div><Label>Route</Label><Input name="route" required placeholder="e.g. Muscat -> Sohar" /></div>
                <div><Label>Cargo</Label><Input name="cargo" required /></div>
                <Button type="submit" className="w-full">Create Work Order</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Search work orders..." value={query} onChange={(e) => setQuery(e.target.value)} className="pl-9" />
        </div>

        {filtered.length === 0 ? (
          <EmptyState title="No work orders found" icon={Package} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">WO ID</TableHead>
                  <TableHead className="text-xs">Customer</TableHead>
                  <TableHead className="text-xs">Route</TableHead>
                  <TableHead className="text-xs">Cargo</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((w) => (
                  <TableRow key={w.woId}>
                    <TableCell className="font-mono text-xs font-medium">{w.woId}</TableCell>
                    <TableCell className="text-xs">{w.customer}</TableCell>
                    <TableCell className="text-xs">{w.route}</TableCell>
                    <TableCell className="text-xs">{w.cargo}</TableCell>
                    <TableCell><StatusPill label={w.status} variant={getStatusVariant(w.status)} /></TableCell>
                    <TableCell>
                      {w.status === 'Pending Assignment' && (
                        <Button size="sm" variant="outline" className="text-xs h-7" onClick={() => { updateStatus(w.woId, 'In Transit'); toast.success('Status updated'); }}>
                          Start Transit
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
