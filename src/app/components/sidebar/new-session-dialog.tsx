"use client";

import { useState, useEffect, useRef } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Plus, Loader2 } from "lucide-react";
import type { Playbook } from "@/app/lib/types";
import { fetchPlaybooks, createSession } from "@/app/lib/sessions";

interface NewSessionDialogProps {
  onSessionCreated: () => void;
  /** Called before the dialog opens — used to close a parent sheet on mobile. */
  onBeforeOpen?: () => void;
}

const FEATURE_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*$/;

function validateFeatureName(name: string): string | null {
  const trimmed = name.trim();
  if (!trimmed) return null; // empty is not an error, just disables submit
  if (trimmed !== name) return "Feature name must not have leading or trailing whitespace";
  if (!FEATURE_NAME_PATTERN.test(trimmed)) {
    return "Only lowercase letters, numbers, and hyphens allowed (must start with a letter or number)";
  }
  return null;
}

export function NewSessionDialog({ onSessionCreated, onBeforeOpen }: NewSessionDialogProps) {
  const [open, setOpen] = useState(false);
  const [playbooks, setPlaybooks] = useState<Playbook[]>([]);
  const [selectedPlaybook, setSelectedPlaybook] = useState("");
  const [featureName, setFeatureName] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [validationError, setValidationError] = useState<string | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);

  function handleOpenChange(isOpen: boolean) {
    if (isOpen) {
      onBeforeOpen?.();
    }
    setOpen(isOpen);
    if (!isOpen) {
      abortControllerRef.current?.abort();
      abortControllerRef.current = null;
      setSelectedPlaybook("");
      setFeatureName("");
      setError(null);
      setValidationError(null);
      setLoading(false);
    }
  }

  useEffect(() => {
    if (open) {
      fetchPlaybooks()
        .then(setPlaybooks)
        .catch(() => setPlaybooks([]));
    }
  }, [open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = featureName.trim();
    if (!selectedPlaybook || !trimmed || validateFeatureName(featureName)) return;

    setLoading(true);
    setError(null);

    const controller = new AbortController();
    abortControllerRef.current = controller;

    try {
      await createSession(selectedPlaybook, featureName, controller.signal);
      setOpen(false);
      setSelectedPlaybook("");
      setFeatureName("");
      onSessionCreated();
    } catch (err) {
      if (controller.signal.aborted) return;
      setError(err instanceof Error ? err.message : "Session creation failed");
    } finally {
      if (!controller.signal.aborted) {
        setLoading(false);
      }
      abortControllerRef.current = null;
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger asChild>
        <Button
          variant="outline"
          size="sm"
          className="w-full border-neon-cyan/30 text-neon-cyan hover:bg-neon-cyan-dim/20 hover:text-neon-cyan glow-cyan"
        >
          <Plus className="h-4 w-4 mr-2" />
          New Session
        </Button>
      </DialogTrigger>
      <DialogContent className="bg-card border-border">
        <DialogHeader>
          <DialogTitle className="font-mono text-neon-cyan text-glow-cyan">
            Create Session
          </DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="playbook" className="text-sm text-muted-foreground">
              Playbook
            </Label>
            <Select value={selectedPlaybook} onValueChange={setSelectedPlaybook}>
              <SelectTrigger className="bg-secondary border-border">
                <SelectValue placeholder="Select a playbook..." />
              </SelectTrigger>
              <SelectContent className="bg-card border-border">
                {playbooks.map((p) => (
                  <SelectItem key={p.name} value={p.name}>
                    {p.title}
                  </SelectItem>
                ))}
                {playbooks.length === 0 && (
                  <SelectItem value="_none" disabled>
                    No playbooks found
                  </SelectItem>
                )}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="feature" className="text-sm text-muted-foreground">
              Feature Name
            </Label>
            <Input
              id="feature"
              value={featureName}
              onChange={(e) => {
                const val = e.target.value;
                setFeatureName(val);
                setValidationError(validateFeatureName(val));
              }}
              maxLength={100}
              placeholder="e.g., 018-new-feature"
              className="bg-secondary border-border font-mono"
            />
            {validationError && (
              <p className="text-xs text-destructive font-mono">{validationError}</p>
            )}
          </div>
          {error && (
            <div className="text-sm text-destructive bg-destructive/10 border border-destructive/30 rounded p-3 font-mono">
              {error}
            </div>
          )}
          <Button
            type="submit"
            disabled={loading || !selectedPlaybook || !featureName.trim() || !!validationError}
            className="w-full bg-neon-cyan text-background hover:bg-neon-cyan/80 font-mono"
          >
            {loading ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Creating...
              </>
            ) : (
              "Create Session"
            )}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
