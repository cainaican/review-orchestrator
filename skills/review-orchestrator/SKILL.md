---
name: review-orchestrator
description: Deep staged code review of a diff or branch comparison with 5 parallel read-only critics (correctness, security, performance, Angular, tests), orchestrator-run mental trace, and coverage sweep. Use when the user asks to review code, a PR, or a branch diff ("ревью", "review", "посмотри дифф"). On first use installs the code-reviewer and critic agents into .opencode/agents/, then asks which branches to compare and what the task was.
---

# Review Orchestrator

Thin router. Two jobs: ensure review agents are installed, then hand off to `code-reviewer`. Do not review code yourself.

## Step 1 — Install agents

Required six: `code-reviewer.md`, `critic-correctness.md`, `critic-security.md`, `critic-performance.md`, `critic-angular.md`, `critic-tests.md`.

Look project-first, then global:
- project: `.opencode/agents/`
- global: `~/.config/opencode/agents/`

- All six in either location → skip to Step 2.
- All six global, none in project → use global install, don't copy.
- Missing anywhere → copy every file from this skill's bundled `agents/` into `.opencode/agents/` (create dir if needed).

Verify completeness every time, not presence — a partial install silently collapses the review to one lens. Missing bundled `agents/` means a broken install; say so and run inline rather than skip lenses.

After install, tell the user: agents installed, loaded at session start. Recommend a new session so the Task tool sees them. If they continue in-session, run the pipeline inline by following `agents/code-reviewer.md` as a procedure — losing parallelism, keeping every stage and every critic lens.

## Step 2 — Gather inputs

Ask directly if either is missing:
1. **Diff source** — pasted diff, or two refs. Ask: "Какие ветки сравнить (base...head), или вставьте дифф?"
2. **Task description** — what the change was supposed to do. Ask: "Какая была постановка задачи?"

Two refs → `git diff --merge-base <base> <head>` (fallback `git diff <base>...<head>`).

## Step 3 — Hand off

Invoke `code-reviewer` via Task with: the full diff, the task description verbatim, the two refs (if any). Deliver its report to the user unchanged in structure, in the user's language.
