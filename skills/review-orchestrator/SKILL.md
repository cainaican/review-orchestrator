---
name: review-orchestrator
description: Deep staged code review of a diff or branch comparison with 5 parallel read-only critics (correctness, security, performance, Angular, tests), orchestrator-run mental trace, and coverage sweep. Use when the user asks to review code, a PR, or a branch diff ("ревью", "review", "посмотри дифф"). On first use installs the code-reviewer and critic agents into .opencode/agents/, then asks which branches to compare and what the task was.
---

# Review Orchestrator

Thin router. Two jobs: ensure review agents are installed, then hand off to `code-reviewer`. Do not review code yourself.

## Step 1 — Install agents

Required seven: `code-reviewer.md`, `critic-correctness.md`, `critic-security.md`, `critic-performance.md`, `critic-angular.md`, `critic-tests.md`, `critic-shape.md`.

Look project-first, then global:
- project: `.opencode/agents/`
- global: `~/.config/opencode/agents/`

- All seven in either location → skip to Step 2.
- All seven global, none in project → use global install, don't copy.
- Missing anywhere → copy every file from this skill's bundled `agents/` into `.opencode/agents/` (create dir if needed).

Verify completeness every time, not presence — a partial install silently collapses the review to one lens. Missing bundled `agents/` means a broken install; say so and run inline rather than skip lenses.

After install, tell the user: agents installed, loaded at session start. Recommend a new session so the Task tool sees them. If they continue in-session, run the pipeline inline by following `agents/code-reviewer.md` as a procedure — losing parallelism, keeping every stage and every critic lens.

## Step 2 — Gather inputs

Ask sequentially; first two are mandatory, last two optional (Enter to skip):

1. **Diff source** (required) — "Какие ветки сравнить (base...head), или вставьте дифф?"
2. **Task summary** (required, one line) — "Какая была постановка задачи (одна строка)?"
3. **Acceptance criteria / полная постановка** (optional, multi-line) — "Полная постановка / acceptance criteria? Вставьте текст или Enter чтобы пропустить."
4. **External references** (optional, URLs) — "Ссылки на задачу/спеку/дизайн-док (по одной на строку)? Enter чтобы пропустить."

Two refs for #1 → `git diff --merge-base <base> <head>` (fallback `git diff <base>...<head>`).

For each URL in #4, attempt fetch by hostname convention:
- `*.atlassian.net` → `mcp__jira__*`
- `linear.app` → `mcp__linear__*`
- `github.com/*/issues/*` or `*/pull/*` → `mcp__github__*`
- `*.notion.so` / `notion.site` → `mcp__notion__*`
- Unknown host / tool undefined / error / empty → ask: "Не могу достать <URL> через MCP. Вставьте содержимое или Enter чтобы пропустить."

Record per-ref provenance `mcp | paste | skipped`. Pass all four fields + provenance list to `code-reviewer`.

## Step 3 — Hand off

Invoke `code-reviewer` via Task with: the full diff, the task summary verbatim, the two refs (if any), the acceptance criteria block (verbatim or `— not provided`), and the external refs list with per-ref provenance (`[{url, source: mcp|paste|skipped, content}]`). Deliver its report to the user unchanged in structure, in the user's language.

## Step 4 — Persist the review log

The report ends with a `## Review log (abstract — for analytics)` YAML block and a save-confirmation question. After the user answers:

- `n` → do nothing.
- `y` → write the YAML block (the fenced content under `## Review log`) to `~/.config/opencode/review-logs/<id>.yaml`, using the `id:` field from the YAML as filename. Create `~/.config/opencode/review-logs/` if missing. Tell the user the full path.
- any other string → treat as a user-provided path. If it ends with `/` or is a directory, append `<id>.yaml`; otherwise use it verbatim. Create parent dirs if missing. Tell the user the full path.

Write only the YAML content (strip the markdown fence); the file is a pure YAML document the user will later open and edit the `human_feedback:` block in.
