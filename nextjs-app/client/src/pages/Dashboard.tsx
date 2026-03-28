'use client';

// ============================================================
// Dashboard Page — Operations Dashboard with KPIs and Charts
// Migrated from: ops_dashboard_screen.dart, dashboard_screen.dart
// Design: Logistics Blueprint — Swiss Design / Technical Schematic
// ============================================================

import { useEffect } from 'react';
import { useDashboardStore, useFleetStore, useAlertStore } from '@/store';
import { KpiCard, SectionCard, PageLoading } from '@/components/shared';
import { Card, CardContent } from '@/components/ui/card';
import {
  Truck, CheckCircle, Wrench, AlertTriangle, Fuel, Activity, MapPin, TrendingUp,
} from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip as ReTooltip,
  ResponsiveContainer, PieChart, Pie, Cell, Legend, AreaChart, Area,
} from 'recharts';

const PIE_COLORS = ['#3b82f6', '#f59e0b', '#94a3b8'];

const HERO_IMAGE = 'https://d2xsxph8kpxj0f.cloudfront.net/310519663460866270/k4KT9S5J2HBerZ38Wnyj66/fleet-hero-EB7UTUZo7vmxq5f6zmvLzW.webp';
const MAP_IMAGE = 'https://d2xsxph8kpxj0f.cloudfront.net/310519663460866270/k4KT9S5J2HBerZ38Wnyj66/logistics-map-cMFyYzjM9WdqW5b6fYHK7e.webp';

export default function Dashboard() {
  const { data, loading, load } = useDashboardStore();
  const { items: fleet, load: loadFleet } = useFleetStore();
  const { items: alerts, load: loadAlerts } = useAlertStore();

  useEffect(() => {
    load();
    loadFleet();
    loadAlerts();
  }, [load, loadFleet, loadAlerts]);

  if (loading || !data) return <PageLoading />;

  const { kpis, weeklyMileageKm, vehicleStatusShare } = data;
  const recentAlerts = alerts.filter((a) => !a.isRead).slice(0, 4);

  // Derive some extra metrics
  const fleetUtilization = kpis.totalVehicles > 0 ? Math.round((kpis.activeVehicles / kpis.totalVehicles) * 100) : 0;
  const avgFuel = fleet.length > 0 ? Math.round(fleet.reduce((s, v) => s + v.fuelLevel, 0) / fleet.length) : 0;

  return (
    <div className="space-y-6">
      {/* Hero Banner */}
      <div className="relative rounded-xl overflow-hidden h-[200px]">
        <img
          src={HERO_IMAGE}
          alt="Fleet Operations Hub"
          className="absolute inset-0 w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-[#0f172a]/90 via-[#0f172a]/70 to-transparent" />
        <div className="relative z-10 h-full flex flex-col justify-center px-8">
          <div className="flex items-center gap-2 mb-2">
            <Activity className="w-4 h-4 text-blue-400" />
            <span className="text-xs font-semibold text-blue-300 uppercase tracking-widest">Live Operations</span>
          </div>
          <h1 className="text-2xl font-bold text-white" style={{ fontFamily: 'var(--font-heading)' }}>
            Fleet Command Center
          </h1>
          <p className="text-sm text-blue-100/80 mt-1 max-w-lg">
            Real-time monitoring of {kpis.totalVehicles} vehicles across all operational zones. {kpis.activeVehicles} units currently active.
          </p>
          <div className="flex gap-6 mt-4">
            <div className="text-center">
              <span className="text-lg font-bold text-white">{fleetUtilization}%</span>
              <p className="text-[10px] text-blue-200 uppercase tracking-wide">Utilization</p>
            </div>
            <div className="w-px bg-white/20" />
            <div className="text-center">
              <span className="text-lg font-bold text-white">{avgFuel}%</span>
              <p className="text-[10px] text-blue-200 uppercase tracking-wide">Avg Fuel</p>
            </div>
            <div className="w-px bg-white/20" />
            <div className="text-center">
              <span className="text-lg font-bold text-white">{recentAlerts.length}</span>
              <p className="text-[10px] text-blue-200 uppercase tracking-wide">Active Alerts</p>
            </div>
          </div>
        </div>
      </div>

      {/* KPI Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        <KpiCard title="Total Vehicles" value={kpis.totalVehicles} subtitle="Entire registered fleet" icon={Truck} color="#0284c7" />
        <KpiCard title="Active Vehicles" value={kpis.activeVehicles} subtitle="Currently on operation" icon={CheckCircle} color="#16a34a" />
        <KpiCard title="In Maintenance" value={kpis.inMaintenance} subtitle="Service or repair queue" icon={Wrench} color="#f59e0b" />
        <KpiCard title="Critical Alerts" value={kpis.criticalAlerts} subtitle="Requires immediate action" icon={AlertTriangle} color="#dc2626" />
        <KpiCard title="Avg Fuel Use" value={`${kpis.avgFuelConsumptionLPer100km} L/100km`} subtitle="Rolling operational average" icon={Fuel} color="#7c3aed" />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <Card className="border-l-4 border-l-blue-500">
          <CardContent className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold" style={{ fontFamily: 'var(--font-heading)' }}>
                Weekly Mileage Trend
              </h3>
              <TrendingUp className="w-4 h-4 text-muted-foreground" />
            </div>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={weeklyMileageKm}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis dataKey="day" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <ReTooltip
                  contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0', fontSize: '12px' }}
                />
                <Bar dataKey="value" fill="#3b82f6" radius={[4, 4, 0, 0]} name="Mileage (km)" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-amber-500">
          <CardContent className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold" style={{ fontFamily: 'var(--font-heading)' }}>
                Vehicle Status Distribution
              </h3>
              <Truck className="w-4 h-4 text-muted-foreground" />
            </div>
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={vehicleStatusShare}
                  dataKey="value"
                  nameKey="status"
                  cx="50%"
                  cy="50%"
                  outerRadius={100}
                  innerRadius={55}
                  strokeWidth={2}
                  label={({ status, value }) => `${status}: ${value}`}
                >
                  {vehicleStatusShare.map((_, i) => (
                    <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Legend iconType="circle" wrapperStyle={{ fontSize: '12px' }} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Recent Alerts + Fleet Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <SectionCard title="Recent Alerts" subtitle="Unread alerts requiring attention" accent="#dc2626" icon={AlertTriangle}>
          {recentAlerts.length === 0 ? (
            <p className="text-sm text-muted-foreground py-4">No unread alerts</p>
          ) : (
            <div className="space-y-3">
              {recentAlerts.map((alert) => (
                <div key={alert.id} className="flex items-start gap-3 p-3 rounded-lg bg-muted/50 transition-colors hover:bg-muted/80">
                  <AlertTriangle className={`w-4 h-4 mt-0.5 shrink-0 ${
                    alert.severity === 'High' ? 'text-red-500' :
                    alert.severity === 'Medium' ? 'text-amber-500' : 'text-gray-400'
                  }`} />
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-semibold">{alert.type}</span>
                      <span className="text-[10px] text-muted-foreground font-mono">{alert.vehicleId}</span>
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5 truncate">{alert.message}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </SectionCard>

        <SectionCard title="Fleet Overview" subtitle="Current vehicle status" accent="#0284c7" icon={Truck}>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  <th className="text-left py-2 text-xs font-semibold text-muted-foreground">Vehicle</th>
                  <th className="text-left py-2 text-xs font-semibold text-muted-foreground">Type</th>
                  <th className="text-left py-2 text-xs font-semibold text-muted-foreground">Driver</th>
                  <th className="text-left py-2 text-xs font-semibold text-muted-foreground">Fuel</th>
                  <th className="text-left py-2 text-xs font-semibold text-muted-foreground">Status</th>
                </tr>
              </thead>
              <tbody>
                {fleet.slice(0, 5).map((v) => (
                  <tr key={v.id} className="border-b border-border/50 last:border-0 transition-colors hover:bg-muted/30">
                    <td className="py-2.5 font-mono text-xs font-medium">{v.vehicleNumber}</td>
                    <td className="py-2.5 text-xs">{v.type}</td>
                    <td className="py-2.5 text-xs">{v.driver}</td>
                    <td className="py-2.5">
                      <div className="flex items-center gap-2">
                        <div className="w-16 h-1.5 bg-muted rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all"
                            style={{
                              width: `${v.fuelLevel}%`,
                              backgroundColor: v.fuelLevel > 50 ? '#16a34a' : v.fuelLevel > 25 ? '#f59e0b' : '#dc2626',
                            }}
                          />
                        </div>
                        <span className="text-[10px] font-mono text-muted-foreground">{v.fuelLevel}%</span>
                      </div>
                    </td>
                    <td className="py-2.5">
                      <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-full ${
                        v.status === 'Active' ? 'bg-emerald-50 text-emerald-700' :
                        v.status === 'Maintenance' ? 'bg-amber-50 text-amber-700' :
                        'bg-gray-100 text-gray-600'
                      }`}>
                        {v.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </SectionCard>
      </div>

      {/* Logistics Network Map */}
      <Card className="overflow-hidden">
        <div className="relative h-[200px]">
          <img
            src={MAP_IMAGE}
            alt="Global Logistics Network"
            className="absolute inset-0 w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0f172a]/80 to-transparent" />
          <div className="absolute bottom-0 left-0 right-0 p-5">
            <div className="flex items-center gap-2 mb-1">
              <MapPin className="w-4 h-4 text-blue-400" />
              <span className="text-xs font-semibold text-blue-300 uppercase tracking-wider">Network Coverage</span>
            </div>
            <p className="text-sm text-white/80">
              Tracking fleet operations across multiple logistics zones with real-time IVMS and DFMS integration.
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
}
