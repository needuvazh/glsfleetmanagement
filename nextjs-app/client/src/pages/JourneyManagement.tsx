'use client';

import { useEffect } from 'react';
import { useJourneyPlanStore } from '@/store';
import { SectionCard, EmptyState } from '@/components/shared';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Navigation, MapPin } from 'lucide-react';

export default function JourneyManagement() {
  const { items, masters, journeys, load } = useJourneyPlanStore();

  useEffect(() => { load(); }, [load]);

  return (
    <div className="space-y-6">
      {/* Journey Plans */}
      <SectionCard title="Journey Plans" subtitle="Pre-defined route plans with distance and fuel estimates" icon={Navigation} accent="#2563eb">
        {items.length === 0 ? (
          <EmptyState title="No journey plans" icon={Navigation} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">ID</TableHead>
                  <TableHead className="text-xs">Plan Name</TableHead>
                  <TableHead className="text-xs">Origin</TableHead>
                  <TableHead className="text-xs">Destination</TableHead>
                  <TableHead className="text-xs">Distance</TableHead>
                  <TableHead className="text-xs">Est. Time</TableHead>
                  <TableHead className="text-xs">Stops</TableHead>
                  <TableHead className="text-xs">Fuel Est.</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((j) => (
                  <TableRow key={j.id}>
                    <TableCell className="font-mono text-xs font-medium">{j.id}</TableCell>
                    <TableCell className="text-xs font-medium">{j.planName}</TableCell>
                    <TableCell className="text-xs">{j.origin}</TableCell>
                    <TableCell className="text-xs">{j.destination}</TableCell>
                    <TableCell className="text-xs font-mono">{j.distance} km</TableCell>
                    <TableCell className="text-xs font-mono">{j.estimatedTime} hrs</TableCell>
                    <TableCell>
                      <div className="flex gap-1 flex-wrap">
                        {j.stops.map((s) => (
                          <Badge key={s} variant="outline" className="text-[10px] px-1.5 py-0">{s}</Badge>
                        ))}
                      </div>
                    </TableCell>
                    <TableCell className="text-xs font-mono">{j.fuelEstimate} L</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </SectionCard>

      {/* Journey Masters */}
      <SectionCard title="Journey Master" subtitle="Master journey definitions with rest points" icon={MapPin} accent="#7c3aed">
        {masters.length === 0 ? (
          <EmptyState title="No journey masters" icon={MapPin} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Journey ID</TableHead>
                  <TableHead className="text-xs">Plan Name</TableHead>
                  <TableHead className="text-xs">Origin</TableHead>
                  <TableHead className="text-xs">Destination</TableHead>
                  <TableHead className="text-xs">Stops</TableHead>
                  <TableHead className="text-xs">Rest Points</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {masters.map((m) => (
                  <TableRow key={m.journeyId}>
                    <TableCell className="font-mono text-xs font-medium">{m.journeyId}</TableCell>
                    <TableCell className="text-xs font-medium">{m.planName}</TableCell>
                    <TableCell className="text-xs">{m.origin}</TableCell>
                    <TableCell className="text-xs">{m.destination}</TableCell>
                    <TableCell>
                      <div className="flex gap-1 flex-wrap">
                        {m.stops.map((s) => (
                          <Badge key={s} variant="outline" className="text-[10px] px-1.5 py-0">{s}</Badge>
                        ))}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-1 flex-wrap">
                        {m.restPoints.map((r) => (
                          <Badge key={r} variant="outline" className="text-[10px] px-1.5 py-0 border-amber-300 text-amber-700 bg-amber-50">{r}</Badge>
                        ))}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </SectionCard>

      {/* Active Journeys */}
      <SectionCard title="Active Journeys" subtitle="Currently active or planned journeys" icon={Navigation} accent="#059669">
        {journeys.length === 0 ? (
          <EmptyState title="No active journeys" icon={Navigation} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Journey ID</TableHead>
                  <TableHead className="text-xs">Work Order</TableHead>
                  <TableHead className="text-xs">Vehicle</TableHead>
                  <TableHead className="text-xs">Driver</TableHead>
                  <TableHead className="text-xs">Route</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {journeys.map((j) => (
                  <TableRow key={j.journeyId}>
                    <TableCell className="font-mono text-xs font-medium">{j.journeyId}</TableCell>
                    <TableCell className="text-xs font-mono">{j.woId}</TableCell>
                    <TableCell className="text-xs font-mono">{j.vehicle}</TableCell>
                    <TableCell className="text-xs">{j.driver}</TableCell>
                    <TableCell className="text-xs">{j.route.join(' → ')}</TableCell>
                    <TableCell>
                      <Badge variant="outline" className={`text-[10px] ${
                        j.status === 'In Transit' ? 'border-blue-300 text-blue-700 bg-blue-50' : 'border-gray-300 text-gray-700 bg-gray-50'
                      }`}>{j.status}</Badge>
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
