'use client';

import { SectionCard } from '@/components/shared';
import { FolderOpen, Upload, FileText } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

export default function Documents() {
  return (
    <div className="space-y-6">
      <SectionCard title="Document Submission" subtitle="Upload and manage transport-related documents" icon={FolderOpen} accent="#2563eb">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Upload area */}
          <div className="border-2 border-dashed border-border rounded-lg p-8 flex flex-col items-center justify-center text-center">
            <Upload className="w-10 h-10 text-muted-foreground/40 mb-3" />
            <p className="text-sm font-medium text-muted-foreground">Drag & drop documents here</p>
            <p className="text-xs text-muted-foreground/70 mt-1">PDF, XLSX, DOCX, JPG, PNG</p>
            <Button variant="outline" size="sm" className="mt-4" onClick={() => toast.info('Feature coming soon')}>
              Browse Files
            </Button>
          </div>

          {/* Document categories */}
          <div className="space-y-3">
            {[
              { name: 'Trip Reports', count: 12, color: '#3b82f6' },
              { name: 'Compliance Certificates', count: 8, color: '#16a34a' },
              { name: 'Insurance Documents', count: 5, color: '#f59e0b' },
              { name: 'Inspection Reports', count: 15, color: '#7c3aed' },
            ].map((cat) => (
              <div key={cat.name} className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                <div className="flex items-center gap-3">
                  <FileText className="w-4 h-4" style={{ color: cat.color }} />
                  <span className="text-sm">{cat.name}</span>
                </div>
                <span className="text-xs font-mono text-muted-foreground">{cat.count} files</span>
              </div>
            ))}
          </div>
        </div>
      </SectionCard>
    </div>
  );
}
