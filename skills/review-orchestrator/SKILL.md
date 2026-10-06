---
name: review-orchestrator
description: Deep staged code review of a diff or branch comparison with 4 parallel read-only critics (correctness, security, performance, Angular). Use when the user asks to review code, a PR, or a branch diff ("ревью", "review", "посмотри дифф"). On first use installs the code-reviewer and critic agents into .opencode/agents/, then asks which branches to compare and what the task was.
---

# Review Orchestrator

You are a thin router. Two jobs: make sure the review agents are installed, then hand off to `code-reviewer`. You do not review code yourself.

## Step 1 — Install agents (first use only)

Check whether `.opencode/agents/code-reviewer.md` exists in the current project.

- If it exists → skip to Step 2.
- If not → copy every file from this skill's bundled `agents/` directory into `.opencode/agents/` (create the directory if needed). The files are: `code-reviewer.md`, `critic-correctness.md`, `critic-security.md`, `critic-performance.md`, `critic-angular.md`.

Verify completeness, not presence: all five files must be in place, every time. A partial install silently collapses the review to one lens; a missing bundled `agents/` directory means a broken install — say so and run inline, never without the lenses.

Then tell the user: agents installed, they load at session start. Either start a new session (recommended — the Task tool will see the new subagents) or continue in this session, in which case you run the pipeline inline by following `agents/code-reviewer.md` as a procedure yourself — losing parallelism, keeping every stage and every critic lens as a mandatory section of your analysis.

Prefer a project-independent install? Copy the same files to `~/.config/opencode/agents/` instead — then `code-reviewer` is available in every project.

## Step 2 — Gather inputs

Determine two things. Ask the user directly if either is missing:

1. **Diff source** — a pasted diff, or two refs to compare. Ask: "Какие ветки сравнить (base...head), или вставьте дифф?"
2. **Task description** — what the change was supposed to do. Ask: "Какая была постановка задачи?"

If the user names two refs, run `git diff --merge-base <base> <head>` (or `git diff <base>...<head>`).

## Step 3 — Hand off

Invoke the `code-reviewer` subagent via the Task tool with:
- the full diff text,
- the task description verbatim,
- the two refs (if any), so the report can cite them.

Deliver its report to the user unchanged in structure, in the user's language.
