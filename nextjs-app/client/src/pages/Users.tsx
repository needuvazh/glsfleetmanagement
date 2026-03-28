'use client';

import { useEffect, useState } from 'react';
import { useUserStore, useRoleStore } from '@/store';
import { SectionCard, StatusPill, getStatusVariant, PageLoading, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { UserCog, Plus, Trash2, Search } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export default function Users() {
  const { items, loading, load, addUser, removeUser } = useUserStore();
  const { items: roles, load: loadRoles } = useRoleStore();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [query, setQuery] = useState('');

  useEffect(() => { load(); loadRoles(); }, [load, loadRoles]);

  const filtered = items.filter((u) =>
    !query || `${u.id} ${u.name} ${u.email} ${u.role} ${u.status}`.toLowerCase().includes(query.toLowerCase())
  );

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const nextNum = items.length + 1;
    addUser({
      id: `USR${String(nextNum).padStart(3, '0')}`,
      name: fd.get('name') as string,
      email: fd.get('email') as string,
      role: fd.get('role') as string,
      status: 'Active',
      joinDate: new Date().toISOString().split('T')[0],
    });
    toast.success('User created');
    setDialogOpen(false);
  };

  if (loading) return <PageLoading />;

  return (
    <div className="space-y-6">
      <SectionCard
        title="User Management"
        subtitle="Create and manage system users"
        icon={UserCog}
        accent="#7c3aed"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Add User</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Create User</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Full Name</Label><Input name="name" required /></div>
                <div><Label>Email</Label><Input name="email" type="email" required /></div>
                <div>
                  <Label>Role</Label>
                  <select name="role" required className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm">
                    <option value="">Select role...</option>
                    {roles.map((r) => <option key={r.name} value={r.name}>{r.name}</option>)}
                  </select>
                </div>
                <Button type="submit" className="w-full">Create User</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Search users..." value={query} onChange={(e) => setQuery(e.target.value)} className="pl-9" />
        </div>

        {filtered.length === 0 ? (
          <EmptyState title="No users found" icon={UserCog} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">ID</TableHead>
                  <TableHead className="text-xs">Name</TableHead>
                  <TableHead className="text-xs">Email</TableHead>
                  <TableHead className="text-xs">Role</TableHead>
                  <TableHead className="text-xs">Join Date</TableHead>
                  <TableHead className="text-xs">Status</TableHead>
                  <TableHead className="text-xs">Delete</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((u) => (
                  <TableRow key={u.id}>
                    <TableCell className="font-mono text-xs font-medium">{u.id}</TableCell>
                    <TableCell className="text-xs font-medium">{u.name}</TableCell>
                    <TableCell className="text-xs">{u.email}</TableCell>
                    <TableCell className="text-xs">{u.role}</TableCell>
                    <TableCell className="text-xs">{u.joinDate}</TableCell>
                    <TableCell><StatusPill label={u.status} variant={getStatusVariant(u.status)} /></TableCell>
                    <TableCell>
                      <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { removeUser(u.id); toast.success('User removed'); }}>
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
