'use client';

import { useEffect, useState } from 'react';
import { useFleetStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, PageLoading, EmptyState, FlowStepper } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Truck, Search, Plus, Fuel } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function FleetManagement() {
  const { items, loading, load, query, setQuery, filter, setFilter, addVehicle } = useFleetStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const filters = ['All', 'Active', 'Maintenance', 'Idle'];

  const filtered = items.filter((v) => {
    const matchFilter = filter === 'All' || v.status === filter;
    const matchQuery = !query || `${v.vehicleNumber} ${v.type} ${v.driver} ${v.status}`.toLowerCase().includes(query.toLowerCase());
    return matchFilter && matchQuery;
  });

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addVehicle({
      id: fd.get('vehicleNumber') as string,
      vehicleNumber: fd.get('vehicleNumber') as string,
      type: fd.get('type') as string,
      status: 'Active',
      driver: fd.get('driver') as string,
      fuelLevel: 100,
      odometerKm: 0,
      lastServiceDate: new Date().toISOString().split('T')[0],
      location: { lat: 23.58, lng: 58.38 },
    });
    toast.success('Vehicle added successfully');
    setDialogOpen(false);
  };

  if (loading) return <PageLoading />;

  const TRUCK_IMAGE = 'https://d2xsxph8kpxj0f.cloudfront.net/310519663460866270/k4KT9S5J2HBerZ38Wnyj66/truck-fleet-NL6XV3dcaySmh8YVMVPcWE.webp';

  return (
    <div className="space-y-6">
      {/* Hero Banner */}
      <div className="relative rounded-xl overflow-hidden h-[140px]">
        <img src={TRUCK_IMAGE} alt="Fleet" className="absolute inset-0 w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-r from-[#0f172a]/85 via-[#0f172a]/60 to-transparent" />
        <div className="relative z-10 h-full flex flex-col justify-center px-8">
          <h2 className="text-xl font-bold text-white" style={{ fontFamily: 'var(--font-heading)' }}>Fleet Management</h2>
          <p className="text-xs text-blue-100/80 mt-1">{items.length} registered vehicles | {items.filter(v => v.status === 'Active').length} active</p>
        </div>
      </div>

      <FlowStepper currentStep={3} />

      <SectionCard
        title="Fleet Registry"
        subtitle="Vehicle, capacity, IVMS device and status"
        icon={Truck}
        accent="#2563eb"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Add Vehicle</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add New Vehicle</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Vehicle Number</Label><Input name="vehicleNumber" required placeholder="e.g. 1234 AB" /></div>
                <div><Label>Type</Label><Input name="type" required placeholder="e.g. Truck" /></div>
                <div><Label>Driver</Label><Input name="driver" required placeholder="Driver name" /></div>
                <Button type="submit" className="w-full">Add Vehicle</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-3 mb-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Search by vehicle, driver, type, status..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="pl-9"
            />
          </div>
          <div className="flex gap-1.5">
            {filters.map((f) => (
              <Button
                key={f}
                variant={filter === f ? 'default' : 'outline'}
                size="sm"
                onClick={() => setFilter(f)}
                className="text-xs"
              >
                {f}
              </Button>
            ))}
          </div>
        </div>

        {/* Table */}
        {filtered.length === 0 ? (
          <EmptyState title="No vehicles found" icon={Truck} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Vehicle No</TableHead>
                  <TableHead className="text-xs">Type</TableHead>
                  <TableHead className="text-xs">Driver</TableHead>
                  <TableHead className="text-xs">Fuel Level</TableHead>
                  <TableHead className="text-xs">Odometer</TableHead>
                  <TableHead className="text-xs">Last Service</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((v) => (
                  <TableRow key={v.id}>
                    <TableCell className="font-mono text-xs font-medium">{v.vehicleNumber}</TableCell>
                    <TableCell className="text-xs">{v.type}</TableCell>
                    <TableCell className="text-xs">{v.driver}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Fuel className="w-3.5 h-3.5 text-muted-foreground" />
                        <div className="w-16 h-1.5 bg-muted rounded-full overflow-hidden">
                          <div className="h-full rounded-full" style={{
                            width: `${v.fuelLevel}%`,
                            backgroundColor: v.fuelLevel > 50 ? '#16a34a' : v.fuelLevel > 25 ? '#f59e0b' : '#dc2626',
                          }} />
                        </div>
                        <span className="text-[10px] font-mono">{v.fuelLevel}%</span>
                      </div>
                    </TableCell>
                    <TableCell className="text-xs font-mono">{v.odometerKm.toLocaleString()} km</TableCell>
                    <TableCell className="text-xs">{v.lastServiceDate}</TableCell>
                    <TableCell><StatusPill label={v.status} variant={getStatusVariant(v.status)} /></TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
        <p className="text-xs text-muted-foreground mt-3">Showing {filtered.length} of {items.length} vehicles</p>
      </SectionCard>
    </div>
  );
}
