'use client';

import { useEffect, useState } from 'react';
import { useCustomerRequestStore } from '@/store';
import { SectionCard, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { ClipboardList, Plus } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function CustomerRequests() {
  const { items, load, addRequest } = useCustomerRequestStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addRequest({
      customerName: fd.get('customerName') as string,
      contact: fd.get('contact') as string,
      cargoType: fd.get('cargoType') as string,
      weightVolume: fd.get('weightVolume') as string,
      pickup: fd.get('pickup') as string,
      delivery: fd.get('delivery') as string,
      date: fd.get('date') as string,
    });
    toast.success('Customer request created');
    setDialogOpen(false);
  };

  return (
    <div className="space-y-6">
      <SectionCard
        title="Customer Requests"
        subtitle="Incoming transport requests from customers"
        icon={ClipboardList}
        accent="#0284c7"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> New Request</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>New Customer Request</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Customer Name</Label><Input name="customerName" required /></div>
                <div><Label>Contact</Label><Input name="contact" required /></div>
                <div><Label>Cargo Type</Label><Input name="cargoType" required /></div>
                <div><Label>Weight / Volume</Label><Input name="weightVolume" required /></div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Pickup</Label><Input name="pickup" required /></div>
                  <div><Label>Delivery</Label><Input name="delivery" required /></div>
                </div>
                <div><Label>Date</Label><Input name="date" type="date" required /></div>
                <Button type="submit" className="w-full">Submit Request</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {items.length === 0 ? (
          <EmptyState title="No customer requests yet" icon={ClipboardList} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Customer</TableHead>
                  <TableHead className="text-xs">Contact</TableHead>
                  <TableHead className="text-xs">Cargo</TableHead>
                  <TableHead className="text-xs">Weight/Vol</TableHead>
                  <TableHead className="text-xs">Pickup</TableHead>
                  <TableHead className="text-xs">Delivery</TableHead>
                  <TableHead className="text-xs">Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((r, i) => (
                  <TableRow key={i}>
                    <TableCell className="text-xs font-medium">{r.customerName}</TableCell>
                    <TableCell className="text-xs">{r.contact}</TableCell>
                    <TableCell className="text-xs">{r.cargoType}</TableCell>
                    <TableCell className="text-xs font-mono">{r.weightVolume}</TableCell>
                    <TableCell className="text-xs">{r.pickup}</TableCell>
                    <TableCell className="text-xs">{r.delivery}</TableCell>
                    <TableCell className="text-xs">{r.date}</TableCell>
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
