'use client';

import { useEffect, useState } from 'react';
import { useQuotationStore } from '@/store';
import { SectionCard, StatusPill, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Receipt, Plus, CheckCircle } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function Quotations() {
  const { items, load, addQuotation, approveQuotation } = useQuotationStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextSlNo = items.length > 0 ? Math.max(...items.map((q) => q.slNo)) + 1 : 1;
    addQuotation({
      slNo: nextSlNo,
      date: fd.get('date') as string,
      quoteRef: `QTN-${new Date().getFullYear()}-${String(nextSlNo).padStart(3, '0')}`,
      salesPerson: fd.get('salesPerson') as string,
      customer: fd.get('customer') as string,
      customerContact: fd.get('customerContact') as string,
      workDescription: fd.get('workDescription') as string,
      noOfTrips: parseInt(fd.get('noOfTrips') as string) || 1,
      kilometer: parseFloat(fd.get('kilometer') as string) || 0,
      rate: parseFloat(fd.get('rate') as string) || 0,
      amount: (parseInt(fd.get('noOfTrips') as string) || 1) * (parseFloat(fd.get('kilometer') as string) || 0) * (parseFloat(fd.get('rate') as string) || 0),
      approved: false,
    });
    toast.success('Quotation created');
    setDialogOpen(false);
  };

  return (
    <div className="space-y-6">
      <SectionCard
        title="Quotation Register"
        subtitle="Feasibility check and quotation management"
        icon={Receipt}
        accent="#059669"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> New Quotation</Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader><DialogTitle>Create Quotation</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Date</Label><Input name="date" type="date" required /></div>
                  <div><Label>Sales Person</Label><Input name="salesPerson" required /></div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Customer</Label><Input name="customer" required /></div>
                  <div><Label>Customer Contact</Label><Input name="customerContact" required /></div>
                </div>
                <div><Label>Work Description</Label><Input name="workDescription" required /></div>
                <div className="grid grid-cols-3 gap-3">
                  <div><Label>No. of Trips</Label><Input name="noOfTrips" type="number" min="1" required /></div>
                  <div><Label>Kilometer</Label><Input name="kilometer" type="number" min="0" step="0.1" required /></div>
                  <div><Label>Rate (OMR/km)</Label><Input name="rate" type="number" min="0" step="0.01" required /></div>
                </div>
                <Button type="submit" className="w-full">Create Quotation</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {items.length === 0 ? (
          <EmptyState title="No quotations yet" icon={Receipt} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Sl</TableHead>
                  <TableHead className="text-xs">Date</TableHead>
                  <TableHead className="text-xs">Quote Ref</TableHead>
                  <TableHead className="text-xs">Sales Person</TableHead>
                  <TableHead className="text-xs">Customer</TableHead>
                  <TableHead className="text-xs">Work</TableHead>
                  <TableHead className="text-xs">Trips</TableHead>
                  <TableHead className="text-xs">Km</TableHead>
                  <TableHead className="text-xs">Rate</TableHead>
                  <TableHead className="text-xs">Amount</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((q) => (
                  <TableRow key={q.slNo}>
                    <TableCell className="text-xs font-mono">{q.slNo}</TableCell>
                    <TableCell className="text-xs">{q.date}</TableCell>
                    <TableCell className="text-xs font-mono font-medium">{q.quoteRef}</TableCell>
                    <TableCell className="text-xs">{q.salesPerson}</TableCell>
                    <TableCell className="text-xs">{q.customer}</TableCell>
                    <TableCell className="text-xs max-w-[150px] truncate">{q.workDescription}</TableCell>
                    <TableCell className="text-xs font-mono">{q.noOfTrips}</TableCell>
                    <TableCell className="text-xs font-mono">{q.kilometer}</TableCell>
                    <TableCell className="text-xs font-mono">{q.rate}</TableCell>
                    <TableCell className="text-xs font-mono font-medium">{q.amount.toLocaleString()}</TableCell>
                    <TableCell>
                      <StatusPill label={q.approved ? 'Approved' : 'Pending'} variant={q.approved ? 'success' : 'warning'} />
                    </TableCell>
                    <TableCell>
                      {!q.approved && (
                        <Button size="sm" variant="outline" className="gap-1 text-xs h-7" onClick={() => { approveQuotation(q.slNo); toast.success('Quotation approved'); }}>
                          <CheckCircle className="w-3 h-3" /> Approve
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
