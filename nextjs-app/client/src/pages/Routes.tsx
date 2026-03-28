'use client';

import { useEffect, useState } from 'react';
import { useRouteStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, PageLoading, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Route as RouteIcon, Plus, Trash2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function Routes() {
  const { items, loading, load, addRoute, removeRoute } = useRouteStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); }, [load]);

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextNum = items.length + 1;
    addRoute({
      id: `RT-${String(nextNum).padStart(3, '0')}`,
      name: fd.get('name') as string,
      origin: fd.get('origin') as string,
      destination: fd.get('destination') as string,
      distance: parseFloat(fd.get('distance') as string) || 0,
      estimatedTime: parseFloat(fd.get('estimatedTime') as string) || 0,
      stops: (fd.get('stops') as string).split(',').map((s) => s.trim()).filter(Boolean),
      status: 'Active',
    });
    toast.success('Route added');
    setDialogOpen(false);
  };

  if (loading) return <PageLoading />;

  return (
    <div className="space-y-6">
      <SectionCard
        title="Route Master"
        subtitle="Pre-defined transport routes with stops and estimates"
        icon={RouteIcon}
        accent="#2563eb"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Add Route</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add Route</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Route Name</Label><Input name="name" required /></div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Origin</Label><Input name="origin" required /></div>
                  <div><Label>Destination</Label><Input name="destination" required /></div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Distance (km)</Label><Input name="distance" type="number" min="0" step="0.1" required /></div>
                  <div><Label>Est. Time (hrs)</Label><Input name="estimatedTime" type="number" min="0" step="0.1" required /></div>
                </div>
                <div><Label>Stops (comma-separated)</Label><Input name="stops" placeholder="Barka, Saham" /></div>
                <Button type="submit" className="w-full">Add Route</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        {items.length === 0 ? (
          <EmptyState title="No routes configured" icon={RouteIcon} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">ID</TableHead>
                  <TableHead className="text-xs">Name</TableHead>
                  <TableHead className="text-xs">Origin</TableHead>
                  <TableHead className="text-xs">Destination</TableHead>
                  <TableHead className="text-xs">Distance</TableHead>
                  <TableHead className="text-xs">Est. Time</TableHead>
                  <TableHead className="text-xs">Stops</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Delete</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((r) => (
                  <TableRow key={r.id}>
                    <TableCell className="font-mono text-xs font-medium">{r.id}</TableCell>
                    <TableCell className="text-xs font-medium">{r.name}</TableCell>
                    <TableCell className="text-xs">{r.origin}</TableCell>
                    <TableCell className="text-xs">{r.destination}</TableCell>
                    <TableCell className="text-xs font-mono">{r.distance} km</TableCell>
                    <TableCell className="text-xs font-mono">{r.estimatedTime} hrs</TableCell>
                    <TableCell>
                      <div className="flex gap-1 flex-wrap">
                        {r.stops.map((s) => (
                          <Badge key={s} variant="outline" className="text-[10px] px-1.5 py-0">{s}</Badge>
                        ))}
                      </div>
                    </TableCell>
                    <TableCell><StatusPill label={r.status} variant={getStatusVariant(r.status)} /></TableCell>
                    <TableCell>
                      <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { removeRoute(r.id); toast.success('Route removed'); }}>
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
