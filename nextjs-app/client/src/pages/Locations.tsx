'use client';

import { useEffect, useState } from 'react';
import { useLocationStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, PageLoading, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { MapPin, Plus, Trash2 } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function Locations() {
  const { items, loading, load, addLocation, removeLocation } = useLocationStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addLocation({
      code: fd.get('code') as string,
      name: fd.get('name') as string,
      type: fd.get('type') as string,
      region: fd.get('region') as string,
      lat: parseFloat(fd.get('lat') as string) || 0,
      lng: parseFloat(fd.get('lng') as string) || 0,
      status: 'Active',
    });
    toast.success('Location added');
    setDialogOpen(false);
  };

  if (loading) return <PageLoading />;

  return (
    <div className="space-y-6">
      <SectionCard
        title="Location Master"
        subtitle="Hubs, depots, yards, and ports"
        icon={MapPin}
        accent="#059669"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Add Location</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add Location</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Code</Label><Input name="code" required placeholder="LOC-XXX" /></div>
                  <div><Label>Name</Label><Input name="name" required /></div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Type</Label><Input name="type" required placeholder="Hub, Depot, Yard, Port" /></div>
                  <div><Label>Region</Label><Input name="region" required /></div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Latitude</Label><Input name="lat" type="number" step="any" required /></div>
                  <div><Label>Longitude</Label><Input name="lng" type="number" step="any" required /></div>
                </div>
                <Button type="submit" className="w-full">Add Location</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {items.length === 0 ? (
          <EmptyState title="No locations configured" icon={MapPin} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Code</TableHead>
                  <TableHead className="text-xs">Name</TableHead>
                  <TableHead className="text-xs">Type</TableHead>
                  <TableHead className="text-xs">Region</TableHead>
                  <TableHead className="text-xs">Lat</TableHead>
                  <TableHead className="text-xs">Lng</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Delete</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((l) => (
                  <TableRow key={l.code}>
                    <TableCell className="font-mono text-xs font-medium">{l.code}</TableCell>
                    <TableCell className="text-xs font-medium">{l.name}</TableCell>
                    <TableCell className="text-xs">{l.type}</TableCell>
                    <TableCell className="text-xs">{l.region}</TableCell>
                    <TableCell className="text-xs font-mono">{l.lat.toFixed(4)}</TableCell>
                    <TableCell className="text-xs font-mono">{l.lng.toFixed(4)}</TableCell>
                    <TableCell><StatusPill label={l.status} variant={getStatusVariant(l.status)} /></TableCell>
                    <TableCell>
                      <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { removeLocation(l.code); toast.success('Location removed'); }}>
                        <Trash2 className="w-3.5 h-3.5 text-destructive" />
                      </Button>
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
