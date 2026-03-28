'use client';

import { useEffect, useState } from 'react';
import { useVehicleTypeStore } from '@/store';
import { SectionCard, EmptyState, PageLoading } from '@/components/shared';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Settings, ChevronDown, ChevronUp, FileText } from 'lucide-react';

export default function VehicleTypes() {
  const { items, loading, load } = useVehicleTypeStore();
  const [expanded, setExpanded] = useState<string | null>(null);

  useEffect(() => { load(); }, [load]);

  if (loading) return <PageLoading />;

  return (
    <div className="space-y-6">
      <SectionCard title="Vehicle Type Configuration" subtitle="Define vehicle categories, compliance rules, and document requirements" icon={Settings} accent="#7c3aed">
        {items.length === 0 ? (
          <EmptyState title="No vehicle types configured" icon={Settings} />
        ) : (
          <div className="space-y-3">
            {items.map((vt) => (
              <div key={vt.code} className="border border-border rounded-lg overflow-hidden">
                {/* Header */}
                <button
                  className="w-full flex items-center justify-between p-4 hover:bg-muted/30 transition-colors text-left"
                  onClick={() => setExpanded(expanded === vt.code ? null : vt.code)}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 rounded-full" style={{ backgroundColor: vt.status === 'Active' ? '#16a34a' : '#94a3b8' }} />
                    <div>
                      <p className="text-sm font-bold">{vt.name}</p>
                      <p className="text-xs text-muted-foreground font-mono">{vt.code} · {vt.category} · {vt.vehicleClass}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline" className="text-[10px]">{vt.loadType}</Badge>
                    {expanded === vt.code ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                  </div>
                </button>

                {/* Expanded Details */}
                {expanded === vt.code && (
                  <div className="border-t border-border p-4 bg-muted/20 space-y-4">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      {[
                        { label: 'Max Trips/Day', value: vt.maxTripsPerDay },
                        { label: 'Capacity', value: `${vt.defaultCapacity.toLocaleString()} ${vt.capacityUnit}` },
                        { label: 'Transport Type', value: vt.transportType },
                        { label: 'Compliance Mode', value: vt.complianceMode },
                        { label: 'Multi-Day Journey', value: vt.allowMultiDayJourney ? 'Yes' : 'No' },
                        { label: 'Multiple Stops', value: `${vt.allowMultipleStops ? 'Yes' : 'No'} (max ${vt.maxStopsAllowed})` },
                        { label: 'Hazardous', value: vt.isHazardous ? 'Yes' : 'No' },
                        { label: 'Escort Required', value: vt.requiresEscortVehicle ? 'Yes' : 'No' },
                      ].map((item) => (
                        <div key={item.label}>
                          <p className="text-[10px] font-medium text-muted-foreground uppercase tracking-wider">{item.label}</p>
                          <p className="text-sm font-medium mt-0.5">{item.value}</p>
                        </div>
                      ))}
                    </div>

                    {/* Features */}
                    <div>
                      <p className="text-[10px] font-medium text-muted-foreground uppercase tracking-wider mb-1.5">Features</p>
                      <div className="flex flex-wrap gap-1.5">
                        {vt.features.map((f) => (
                          <Badge key={f} variant="outline" className="text-[10px] px-2 py-0.5">{f}</Badge>
                        ))}
                      </div>
                    </div>

                    {/* Document Requirements */}
                    {vt.documentRequirements.length > 0 && (
                      <div>
                        <p className="text-[10px] font-medium text-muted-foreground uppercase tracking-wider mb-1.5">Document Requirements</p>
                        <div className="space-y-1.5">
                          {vt.documentRequirements.map((doc) => (
                            <div key={doc.documentName} className="flex items-center gap-2 text-xs">
                              <FileText className="w-3.5 h-3.5 text-muted-foreground" />
                              <span className="font-medium">{doc.documentName}</span>
                              <Badge variant="outline" className="text-[9px] px-1.5 py-0">{doc.mandatory ? 'Mandatory' : 'Optional'}</Badge>
                              <span className="text-muted-foreground">Valid: {doc.validityValue} {doc.validityUnit}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </SectionCard>
    </div>
  );
}
