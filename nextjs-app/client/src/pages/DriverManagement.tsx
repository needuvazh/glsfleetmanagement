'use client';

import { useEffect, useState } from 'react';
import { useDriverStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, PageLoading, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Users, Plus, Search } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function DriverManagement() {
  const { items, loading, load, addDriver } = useDriverStore();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [query, setQuery] = useState('');

  useEffect(() => { load(); }, [load]);

  const filtered = items.filter((d) =>
    !query || `${d.driverId} ${d.name} ${d.licenseNo} ${d.status}`.toLowerCase().includes(query.toLowerCase())
  );

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextId = `DRV${String(items.length + 1).padStart(3, '0')}`;
    addDriver({
      driverId: nextId,
      name: fd.get('name') as string,
      licenseNo: fd.get('licenseNo') as string,
      expiryDate: fd.get('expiryDate') as string,
      phone: fd.get('phone') as string,
      experience: parseInt(fd.get('experience') as string) || 0,
      dfmsDeviceId: `DFMS-${nextId}`,
      status: 'Available',
    });
    toast.success('Driver added successfully');
    setDialogOpen(false);
  };

  if (loading) return <PageLoading />;

  return (
    <div className="space-y-6">
      <SectionCard
        title="Driver Registry"
        subtitle="License, DFMS device, experience and availability"
        icon={Users}
        accent="#7c3aed"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Add Driver</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add New Driver</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Full Name</Label><Input name="name" required /></div>
                <div><Label>License Number</Label><Input name="licenseNo" required /></div>
                <div><Label>License Expiry</Label><Input name="expiryDate" type="date" required /></div>
                <div><Label>Phone</Label><Input name="phone" required /></div>
                <div><Label>Experience (years)</Label><Input name="experience" type="number" min="0" required /></div>
                <Button type="submit" className="w-full">Add Driver</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Search drivers..." value={query} onChange={(e) => setQuery(e.target.value)} className="pl-9" />
        </div>

        {filtered.length === 0 ? (
          <EmptyState title="No drivers found" icon={Users} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Driver ID</TableHead>
                  <TableHead className="text-xs">Name</TableHead>
                  <TableHead className="text-xs">License No</TableHead>
                  <TableHead className="text-xs">Expiry</TableHead>
                  <TableHead className="text-xs">Phone</TableHead>
                  <TableHead className="text-xs">Experience</TableHead>
                  <TableHead className="text-xs">DFMS Device</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((d) => (
                  <TableRow key={d.driverId}>
                    <TableCell className="font-mono text-xs font-medium">{d.driverId}</TableCell>
                    <TableCell className="text-xs font-medium">{d.name}</TableCell>
                    <TableCell className="text-xs font-mono">{d.licenseNo}</TableCell>
                    <TableCell className="text-xs">{d.expiryDate}</TableCell>
                    <TableCell className="text-xs">{d.phone}</TableCell>
                    <TableCell className="text-xs font-mono">{d.experience} yrs</TableCell>
                    <TableCell className="text-xs font-mono">{d.dfmsDeviceId}</TableCell>
                    <TableCell><StatusPill label={d.status} variant={getStatusVariant(d.status)} /></TableCell>
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
