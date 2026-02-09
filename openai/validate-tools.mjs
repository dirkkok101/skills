#!/usr/bin/env node

import fs from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const toolsPath = path.join(repoRoot, "openai", "tools.json");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

async function main() {
  const raw = await fs.readFile(toolsPath, "utf8");
  const parsed = JSON.parse(raw);

  assert(isObject(parsed), "tools.json root must be an object");
  assert(Array.isArray(parsed.tools), "tools.json must contain a tools array");

  const requiredTools = [
    "workflow_diagnose",
    "workflow_brainstorm",
    "workflow_plan",
    "workflow_beads",
    "workflow_execute",
    "workflow_review",
    "workflow_compound",
    "workflow_docs"
  ];

  const names = new Set();
  for (const tool of parsed.tools) {
    assert(isObject(tool), "Each tool entry must be an object");
    assert(tool.type === "function", "Each tool entry must use type='function'");
    assert(isObject(tool.function), "Each tool entry must contain a function object");

    const fn = tool.function;
    assert(typeof fn.name === "string" && fn.name.length > 0, "Tool function.name is required");
    assert(typeof fn.description === "string" && fn.description.length > 0, `Tool ${fn.name} description is required`);
    assert(isObject(fn.parameters), `Tool ${fn.name} must include parameters schema`);

    names.add(fn.name);
  }

  for (const requiredName of requiredTools) {
    assert(names.has(requiredName), `Missing required tool: ${requiredName}`);
  }

  console.log(`Validated ${parsed.tools.length} OpenAI function tools in openai/tools.json`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
