'use client';

import { useEffect, useState } from 'react';
import { useInvoiceStore } from '@/store';
import { SectionCard, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Receipt, Plus } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function Invoice() {
  const { items, load, addInvoice } = useInvoiceStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const totalAmount = items.reduce((sum, inv) => sum + inv.amount, 0);

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextNum = items.length + 1;
    addInvoice({
      invoiceId: `INV${String(nextNum).padStart(3, '0')}`,
      woId: fd.get('woId') as string,
      client: fd.get('client') as string,
      amount: parseFloat(fd.get('amount') as string) || 0,
      paymentTerms: fd.get('paymentTerms') as string,
    });
    toast.success('Invoice created');
    setDialogOpen(false);
  };

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="bg-card border border-border rounded-lg p-4 relative overflow-hidden">
          <div className="absolute left-0 top-0 bottom-0 w-1 bg-blue-500" />
          <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider pl-3">Total Invoices</p>
          <p className="text-3xl font-bold mt-1 pl-3 text-blue-600" style={{ fontFamily: 'var(--font-mono)' }}>{items.length}</p>
        </div>
        <div className="bg-card border border-border rounded-lg p-4 relative overflow-hidden">
          <div className="absolute left-0 top-0 bottom-0 w-1 bg-emerald-500" />
          <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider pl-3">Total Amount</p>
          <p className="text-3xl font-bold mt-1 pl-3 text-emerald-600" style={{ fontFamily: 'var(--font-mono)' }}>OMR {totalAmount.toLocaleString()}</p>
        </div>
      </div>

      <SectionCard
        title="Invoice Register"
        subtitle="Generated invoices for completed work orders"
        icon={Receipt}
        accent="#059669"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> New Invoice</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Create Invoice</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Work Order ID</Label><Input name="woId" required /></div>
                <div><Label>Client</Label><Input name="client" required /></div>
                <div><Label>Amount (OMR)</Label><Input name="amount" type="number" min="0" step="0.01" required /></div>
                <div><Label>Payment Terms</Label><Input name="paymentTerms" required placeholder="e.g. 30 days" /></div>
                <Button type="submit" className="w-full">Create Invoice</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {items.length === 0 ? (
          <EmptyState title="No invoices yet" icon={Receipt} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Invoice ID</TableHead>
                  <TableHead className="text-xs">Work Order</TableHead>
                  <TableHead className="text-xs">Client</TableHead>
                  <TableHead className="text-xs">Amount (OMR)</TableHead>
                  <TableHead className="text-xs">Payment Terms</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((inv) => (
                  <TableRow key={inv.invoiceId}>
                    <TableCell className="font-mono text-xs font-medium">{inv.invoiceId}</TableCell>
                    <TableCell className="text-xs font-mono">{inv.woId}</TableCell>
                    <TableCell className="text-xs">{inv.client}</TableCell>
                    <TableCell className="text-xs font-mono font-medium">{inv.amount.toLocaleString()}</TableCell>
                    <TableCell className="text-xs">{inv.paymentTerms}</TableCell>
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
