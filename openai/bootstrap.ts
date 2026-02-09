import { execFile } from "node:child_process";
import { promises as fs } from "node:fs";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const DEFAULT_MAX_RESULTS = 50;
const DEFAULT_MAX_FILE_BYTES = 262_144;
const DEFAULT_MAX_SUMMARY_CHARS = 1_200;

export type ToolName =
  | "workflow_diagnose"
  | "workflow_brainstorm"
  | "workflow_plan"
  | "workflow_beads"
  | "workflow_execute"
  | "workflow_review"
  | "workflow_compound"
  | "workflow_docs";

export interface DocsInput {
  action: "find" | "summarize" | "update";
  query?: string;
  path?: string;
  content?: string;
  max_results?: number;
  max_file_bytes?: number;
  max_summary_chars?: number;
  include_content?: boolean;
}

export interface DispatchContext {
  projectRoot?: string;
}

export async function loadSystemPrompt(projectRoot = process.cwd()): Promise<string> {
  const promptPath = path.join(projectRoot, "templates", "OPENAI_AGENT.md");
  return fs.readFile(promptPath, "utf8");
}

export async function loadTools(projectRoot = process.cwd()): Promise<unknown> {
  const toolsPath = path.join(projectRoot, "openai", "tools.json");
  const raw = await fs.readFile(toolsPath, "utf8");
  const parsed = JSON.parse(raw);

  if (Array.isArray(parsed)) {
    return parsed;
  }

  if (parsed && Array.isArray((parsed as { tools?: unknown[] }).tools)) {
    return (parsed as { tools: unknown[] }).tools;
  }

  throw new Error("openai/tools.json must be an array of tools or an object with a tools array");
}

export async function dispatchTool(
  tool: ToolName,
  input: Record<string, unknown>,
  context: DispatchContext = {}
): Promise<unknown> {
  const projectRoot = context.projectRoot ?? process.cwd();

  switch (tool) {
    case "workflow_docs":
      return handleWorkflowDocs(input as DocsInput, projectRoot);
    case "workflow_diagnose":
    case "workflow_brainstorm":
    case "workflow_plan":
    case "workflow_beads":
    case "workflow_execute":
    case "workflow_review":
    case "workflow_compound":
      return handleWorkflowPhase(tool, input, projectRoot);
    default:
      throw new Error(`Unsupported tool: ${tool}`);
  }
}

interface ApprovalState {
  phase: Exclude<ToolName, "workflow_docs">;
  allowed: boolean;
  required_signal: string | null;
  reason: string;
}

async function handleWorkflowPhase(
  tool: Exclude<ToolName, "workflow_docs">,
  input: Record<string, unknown>,
  projectRoot: string
): Promise<unknown> {
  const approval = approvalGate(tool, input);
  const brSummary = approval.allowed
    ? await readBrState(tool, input, projectRoot)
    : { invoked: false, skipped_reason: "approval_gate_blocked" };

  return {
    tool,
    approval,
    br: brSummary,
    guidance: "Use docs/designs, docs/plans, and docs/learnings for durable workflow artifacts."
  };
}

function approvalGate(tool: Exclude<ToolName, "workflow_docs">, input: Record<string, unknown>): ApprovalState {
  const defaultState: ApprovalState = {
    phase: tool,
    allowed: true,
    required_signal: null,
    reason: "Approval gate satisfied for current phase."
  };

  if (tool === "workflow_plan" && input.design_approved !== true) {
    return {
      phase: tool,
      allowed: false,
      required_signal: "design approved",
      reason: "Plan phase is blocked until the user says 'design approved'."
    };
  }

  if (tool === "workflow_beads" && input.plan_approved !== true) {
    return {
      phase: tool,
      allowed: false,
      required_signal: "plan approved",
      reason: "Beads phase is blocked until the user says 'plan approved'."
    };
  }

  if (tool === "workflow_execute" && input.beads_approved !== true) {
    return {
      phase: tool,
      allowed: false,
      required_signal: "beads approved",
      reason: "Execute phase is blocked until the user says 'beads approved'."
    };
  }

  return defaultState;
}

async function readBrState(
  tool: Exclude<ToolName, "workflow_docs">,
  input: Record<string, unknown>,
  projectRoot: string
): Promise<Record<string, unknown>> {
  const commands: string[][] = [];

  if (tool === "workflow_diagnose") {
    commands.push(["ready"]);
    if (typeof input.symptom === "string" && input.symptom.trim().length > 0) {
      commands.push(["search", input.symptom]);
    }
  }

  if (tool === "workflow_beads" || tool === "workflow_execute") {
    commands.push(["ready"]);
  }

  if (tool === "workflow_compound") {
    commands.push(["list", "--status", "in_progress"]);
  }

  if (commands.length === 0) {
    return { invoked: false };
  }

  const results = await Promise.all(commands.map((args) => runBr(args, projectRoot)));
  return { invoked: true, commands, results };
}

async function runBr(args: string[], cwd: string): Promise<Record<string, unknown>> {
  try {
    const { stdout, stderr } = await execFileAsync("br", args, { cwd });
    return {
      ok: true,
      command: ["br", ...args].join(" "),
      stdout: stdout.trim(),
      stderr: stderr.trim()
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      ok: false,
      command: ["br", ...args].join(" "),
      error: message
    };
  }
}

async function handleWorkflowDocs(input: DocsInput, projectRoot: string): Promise<unknown> {
  const docsRoot = path.join(projectRoot, "docs");
  await fs.mkdir(docsRoot, { recursive: true });

  switch (input.action) {
    case "find":
      return findDocs(
        docsRoot,
        input.query ?? "",
        clamp(input.max_results, 1, 500, DEFAULT_MAX_RESULTS),
        clamp(input.max_file_bytes, 1_024, 4_194_304, DEFAULT_MAX_FILE_BYTES)
      );
    case "summarize":
      return summarizeDoc(
        docsRoot,
        input.path,
        clamp(input.max_summary_chars, 200, 8_000, DEFAULT_MAX_SUMMARY_CHARS),
        input.include_content === true
      );
    case "update":
      return updateDoc(docsRoot, input.path, input.content);
    default:
      throw new Error(`Unsupported workflow_docs action: ${String(input.action)}`);
  }
}

async function findDocs(docsRoot: string, query: string, maxResults: number, maxFileBytes: number) {
  if (!query.trim()) {
    throw new Error("workflow_docs.find requires a non-empty query");
  }

  const files = (await walkFiles(docsRoot)).sort();
  const needle = query.toLowerCase();
  const matches: Array<{ path: string; match_type: "path" | "content" }> = [];
  let scannedFiles = 0;
  let skippedFiles = 0;

  for (const filePath of files) {
    const relPath = normalizeRelPath(docsRoot, filePath);

    if (relPath.toLowerCase().includes(needle)) {
      matches.push({ path: relPath, match_type: "path" });
      if (matches.length >= maxResults) {
        break;
      }
      continue;
    }

    try {
      const buffer = await fs.readFile(filePath);
      scannedFiles += 1;

      if (buffer.length > maxFileBytes || looksBinary(buffer)) {
        skippedFiles += 1;
        continue;
      }

      const content = buffer.toString("utf8").toLowerCase();
      if (content.includes(needle)) {
        matches.push({ path: relPath, match_type: "content" });
        if (matches.length >= maxResults) {
          break;
        }
      }
    } catch {
      skippedFiles += 1;
    }
  }

  return {
    action: "find",
    query,
    total_matches: matches.length,
    scanned_files: scannedFiles,
    skipped_files: skippedFiles,
    matches
  };
}

async function summarizeDoc(
  docsRoot: string,
  relPath: string | undefined,
  maxSummaryChars: number,
  includeContent: boolean
) {
  if (!relPath) {
    throw new Error("workflow_docs.summarize requires path");
  }

  const fullPath = resolveDocsPath(docsRoot, relPath);
  const content = await fs.readFile(fullPath, "utf8");
  const normalizedPath = normalizeRelPath(docsRoot, fullPath);

  const response: Record<string, unknown> = {
    action: "summarize",
    path: normalizedPath,
    bytes: Buffer.byteLength(content, "utf8"),
    summary: summarizeText(content, maxSummaryChars)
  };

  if (includeContent) {
    response.content = content;
  }

  return response;
}

async function updateDoc(docsRoot: string, relPath: string | undefined, content: string | undefined) {
  if (!relPath) {
    throw new Error("workflow_docs.update requires path");
  }
  if (typeof content !== "string") {
    throw new Error("workflow_docs.update requires content");
  }

  const fullPath = resolveDocsPath(docsRoot, relPath);
  await fs.mkdir(path.dirname(fullPath), { recursive: true });
  await fs.writeFile(fullPath, content, "utf8");

  return {
    action: "update",
    path: normalizeRelPath(docsRoot, fullPath),
    bytes_written: Buffer.byteLength(content, "utf8")
  };
}

async function walkFiles(root: string): Promise<string[]> {
  const files: string[] = [];

  async function walk(dir: string) {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const entryPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        await walk(entryPath);
      } else if (entry.isFile()) {
        files.push(entryPath);
      }
    }
  }

  await walk(root);
  return files;
}

function resolveDocsPath(docsRoot: string, relPath: string): string {
  const normalized = relPath.replace(/\\/g, "/").replace(/^\/+/, "");
  const fullPath = path.resolve(docsRoot, normalized);

  if (fullPath !== docsRoot && !fullPath.startsWith(`${docsRoot}${path.sep}`)) {
    throw new Error(`Path escapes docs directory: ${relPath}`);
  }

  return fullPath;
}

function normalizeRelPath(docsRoot: string, filePath: string): string {
  return path.relative(docsRoot, filePath).replace(/\\/g, "/");
}

function looksBinary(buffer: Buffer): boolean {
  const sampleLength = Math.min(buffer.length, 1024);
  for (let i = 0; i < sampleLength; i += 1) {
    if (buffer[i] === 0) {
      return true;
    }
  }
  return false;
}

function summarizeText(content: string, maxChars: number): string {
  const singleLine = content.replace(/\s+/g, " ").trim();
  if (singleLine.length <= maxChars) {
    return singleLine;
  }
  return `${singleLine.slice(0, Math.max(0, maxChars - 1))}...`;
}

function clamp(value: number | undefined, min: number, max: number, fallback: number): number {
  if (typeof value !== "number" || Number.isNaN(value)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, Math.floor(value)));
}

function isDirectCliInvocation(): boolean {
  const scriptName = process.argv[1] ? path.basename(process.argv[1]) : "";
  return /^bootstrap\.(ts|js|mjs|cjs)$/.test(scriptName);
}

if (isDirectCliInvocation()) {
  (async () => {
    const [tool, payload] = process.argv.slice(2);
    if (!tool || !payload) {
      throw new Error("Usage: ts-node openai/bootstrap.ts <toolName> '<jsonPayload>'");
    }

    const result = await dispatchTool(tool as ToolName, JSON.parse(payload));
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  })().catch((error: unknown) => {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`${message}\n`);
    process.exitCode = 1;
  });
}
