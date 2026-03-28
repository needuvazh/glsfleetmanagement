'use client';

import { useEffect } from 'react';
import { useIvmsStore, useDfmsStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, EmptyState } from '@/components/shared';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Milestone, Gauge, Eye } from 'lucide-react';
import { Progress } from '@/components/ui/progress';

export default function TripExecution() {
  const { items: ivms, load: loadIvms } = useIvmsStore();
  const { items: dfms, load: loadDfms } = useDfmsStore();

  useEffect(() => { loadIvms(); loadDfms(); }, [loadIvms, loadDfms]);

  return (
    <div className="space-y-6">
      {/* IVMS - Vehicle Tracking */}
      <SectionCard title="IVMS — Vehicle Tracking" subtitle="Real-time vehicle location, speed, and fuel data" icon={Gauge} accent="#2563eb">
        {ivms.length === 0 ? (
          <EmptyState title="No IVMS data" icon={Gauge} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Vehicle ID</TableHead>
                  <TableHead className="text-xs">Lat</TableHead>
                  <TableHead className="text-xs">Lng</TableHead>
                  <TableHead className="text-xs">Speed</TableHead>
                  <TableHead className="text-xs">Fuel Level</TableHead>
                  <TableHead className="text-xs">Distance</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {ivms.map((v) => (
                  <TableRow key={v.vehicleId}>
                    <TableCell className="font-mono text-xs font-medium">{v.vehicleId}</TableCell>
                    <TableCell className="text-xs font-mono">{v.location.lat.toFixed(4)}</TableCell>
                    <TableCell className="text-xs font-mono">{v.location.lng.toFixed(4)}</TableCell>
                    <TableCell className="text-xs font-mono">{v.speed} km/h</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Progress value={v.fuelLevel} className="h-1.5 w-16" />
                        <span className="text-[10px] font-mono">{v.fuelLevel}%</span>
                      </div>
                    </TableCell>
                    <TableCell className="text-xs font-mono">{v.distanceCovered} km</TableCell>
                    <TableCell><StatusPill label={v.status} variant={getStatusVariant(v.status)} /></TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </SectionCard>

      {/* DFMS - Driver Fatigue */}
      <SectionCard title="DFMS — Driver Fatigue Monitoring" subtitle="Eye closure rate, driving hours, and fatigue alerts" icon={Eye} accent="#dc2626">
        {dfms.length === 0 ? (
          <EmptyState title="No DFMS data" icon={Eye} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Driver ID</TableHead>
                  <TableHead className="text-xs">Fatigue Level</TableHead>
                  <TableHead className="text-xs">Eye Closure Rate</TableHead>
                  <TableHead className="text-xs">Driving Hours</TableHead>
                  <TableHead className="text-xs">Alert</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {dfms.map((d) => (
                  <TableRow key={d.driverId}>
                    <TableCell className="font-mono text-xs font-medium">{d.driverId}</TableCell>
                    <TableCell><StatusPill label={d.fatigueLevel} variant={getStatusVariant(d.fatigueLevel)} /></TableCell>
                    <TableCell className="text-xs font-mono">{(d.eyeClosureRate * 100).toFixed(0)}%</TableCell>
                    <TableCell className="text-xs font-mono">{d.drivingHours} hrs</TableCell>
                    <TableCell className="text-xs">{d.alert}</TableCell>
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
