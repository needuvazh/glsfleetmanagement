'use client';

import { useEffect, useState } from 'react';
import { useModuleDocumentStore, useRoleStore } from '@/store';
import { SectionCard, EmptyState } from '@/components/shared';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { FileText, Plus, Trash2, Search } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

const DOCUMENT_TYPES = ['PDF', 'XLSX', 'DOCX', 'JPG', 'PNG', 'Other'];

export default function DocumentManagement() {
  const { items, query, roleFilter, load, setQuery, setRoleFilter, addDocument, removeDocument } = useModuleDocumentStore();
  const { items: roles, load: loadRoles } = useRoleStore();
  const [dialogOpen, setDialogOpen] = useState(false);

  useEffect(() => { load(); loadRoles(); }, [load, loadRoles]);

  const filtered = items.filter((d) => {
    const matchRole = roleFilter === 'All' || d.targetType === roleFilter;
    const matchQuery = !query || `${d.id} ${d.documentName} ${d.documentType} ${d.targetType}`.toLowerCase().includes(query.toLowerCase());
    return matchRole && matchQuery;
  });

  const handleAdd = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const maxNum = items.reduce((max, d) => {
      const n = parseInt(d.id.replace('DOC-', ''));
      return n > max ? n : max;
    }, 0);
    const msg = addDocument({
      id: `DOC-${String(maxNum + 1).padStart(3, '0')}`,
      documentName: fd.get('documentName') as string,
      targetType: fd.get('targetType') as string,
      documentType: fd.get('documentType') as string,
    });
    if (msg.includes('success')) {
      toast.success(msg);
      setDialogOpen(false);
    } else {
      toast.error(msg);
    }
  };

  return (
    <div className="space-y-6">
      <SectionCard
        title="Document Management"
        subtitle="Define role-based document requirements"
        icon={FileText}
        accent="#2563eb"
        trailing={
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-1.5"><Plus className="w-3.5 h-3.5" /> Create Document</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Create Document Definition</DialogTitle></DialogHeader>
              <form onSubmit={handleAdd} className="space-y-4">
                <div><Label>Document Name</Label><Input name="documentName" required /></div>
                <div>
                  <Label>User Role</Label>
                  <select name="targetType" required className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm">
                    <option value="">Select role...</option>
                    {roles.map((r) => <option key={r.name} value={r.name}>{r.name}</option>)}
                  </select>
                </div>
                <div>
                  <Label>Document Type</Label>
                  <select name="documentType" required className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm">
                    <option value="">Select type...</option>
                    {DOCUMENT_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
                  </select>
                </div>
                <Button type="submit" className="w-full">Create Document</Button>
              </form>
            </DialogContent>
          </Dialog>
        }
      >
        <div className="flex flex-col sm:flex-row gap-3 mb-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input placeholder="Search documents..." value={query} onChange={(e) => setQuery(e.target.value)} className="pl-9" />
          </div>
          <Select value={roleFilter} onValueChange={setRoleFilter}>
            <SelectTrigger className="w-48"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="All">All Roles</SelectItem>
              {roles.map((r) => <SelectItem key={r.name} value={r.name}>{r.name}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>

        {filtered.length === 0 ? (
          <EmptyState title="No documents found" icon={FileText} />
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs">ID</TableHead>
                  <TableHead className="text-xs">Document Name</TableHead>
                  <TableHead className="text-xs">Document Type</TableHead>
                  <TableHead className="text-xs">User Role</TableHead>
                  <TableHead className="text-xs">Delete</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((d) => (
                  <TableRow key={d.id}>
                    <TableCell className="font-mono text-xs font-medium">{d.id}</TableCell>
                    <TableCell className="text-xs font-medium">{d.documentName}</TableCell>
                    <TableCell className="text-xs">{d.documentType}</TableCell>
                    <TableCell className="text-xs">{d.targetType}</TableCell>
                    <TableCell>
                      <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { removeDocument(d.id); toast.success('Document deleted'); }}>
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
