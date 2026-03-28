'use client';

import { useEffect, useState } from 'react';
import { useRoleStore } from '@/store';
import { SectionCard, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Shield, Plus } from 'lucide-react';
import { toast } from 'sonner';

export default function Roles() {
  const { items, load, addRole } = useRoleStore();
  const [roleName, setRoleName] = useState('');

  useEffect(() => { load(); }, [load]);

  const handleCreate = () => {
    const msg = addRole(roleName);
    if (msg.startsWith('Role created')) {
      toast.success(msg);
      setRoleName('');
    } else {
      toast.error(msg);
    }
  };

  return (
    <div className="space-y-6">
      <SectionCard title="Create Role" subtitle="Manage role definitions for user assignment" icon={Shield} accent="#2563eb">
        <div className="flex gap-3">
          <Input
            placeholder="Role name (e.g. Dispatcher)"
            value={roleName}
            onChange={(e) => setRoleName(e.target.value)}
            className="max-w-sm"
            onKeyDown={(e) => e.key === 'Enter' && handleCreate()}
          />
          <Button onClick={handleCreate} className="gap-1.5">
            <Plus className="w-3.5 h-3.5" /> Create Role
          </Button>
        </div>
      </SectionCard>

      <SectionCard title="Available Roles" subtitle="Default and custom roles visible in User module" icon={Shield} accent="#16a34a">
        {items.length === 0 ? (
          <EmptyState title="No roles defined" icon={Shield} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">Role Name</TableHead>
                  <TableHead className="text-xs">Type</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((r) => (
                  <TableRow key={r.name}>
                    <TableCell className="text-xs font-medium">{r.name}</TableCell>
                    <TableCell>
                      <Badge variant="outline" className={`text-[10px] ${r.systemRole ? 'border-blue-300 text-blue-700 bg-blue-50' : 'border-gray-300 text-gray-600'}`}>
                        {r.systemRole ? 'System' : 'Custom'}
                      </Badge>
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
