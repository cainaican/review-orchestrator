# review-orchestrator

Staged deep code review for [opencode](https://opencode.ai): one orchestrator subagent + 5 parallel read-only critics (correctness, security, performance, Angular library conventions, tests), plus an orchestrator-run mental-trace pass and a coverage sweep. No harness — six markdown agent files, nothing else.

Inspired by the pipeline patterns of [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch): critics must cite code; the orchestrator mentally executes calculational functions on adversarial inputs, adversarially verifies critic findings for both existence AND coverage, and iteratively deep-dives on blockers before the report.

## Install

**Route A — bootstrap skill (loads from this repo on demand):**

```
npx skills add cainaican/review-orchestrator
```

Then just ask in any opencode session: "ревью ветки X относительно Y". The skill installs the agents into `.opencode/agents/` on first use (restart the session so the Task tool sees them).

**Route B — global, no project changes:**

```
git clone https://github.com/<your-user>/review-orchestrator
cp review-orchestrator/agents/*.md ~/.config/opencode/agents/
```

`@code-reviewer` becomes available in every project, the repo never touches your projects.

## Usage

```
@code-reviewer сравни main...feature/auth, задача: добавили OAuth-логин
```

If you give neither a diff nor refs, the orchestrator asks which branches to compare and what the task was, then runs `git diff --merge-base <base> <head>` itself.

## Roster

| Agent | Lens | Access |
|---|---|---|
| `code-reviewer` | orchestrator: intake → context+domain brief → 5 parallel critics → mental trace → verification + coverage sweep → deep-dive on blockers → report | read-only, `git diff/log/show/branch`, Task only on critics |
| `critic-correctness` | logic bugs, edge cases, races, regressions; mental execution over adversarial inputs | read-only, hidden |
| `critic-security` | secrets, auth, injection, XSS, SSRF | read-only, hidden |
| `critic-performance` | N+1, bundle, tree-shaking, change detection | read-only, hidden |
| `critic-angular` | signals/OnPush, RxJS interaction-stream traps (drag/scroll/pointer), public API surface, semver, templates | read-only, hidden |
| `critic-tests` | spec vs behavior correspondence, missing edge-case coverage, concrete test cases to add | read-only, hidden |

Anti-hallucination contract: critics may only report findings with a verbatim code excerpt; the orchestrator re-opens every blocker/important file itself (proof-of-existence) AND sweeps every changed file with no findings (proof-of-coverage) before the report.

Interaction-impact gate: the orchestrator classifies every changed mechanism by intervention class; delivery-level changes — anything altering event delivery or timing — get a mandatory **victims list** of the existing interactions they intersect, consumer side included. Critics answer "what does this diff BREAK?" explicitly, and the report's "Interaction impact" section forbids unverified negatives. Public-API diffing alone does not cover delivery-level coupling: "no callers changed" is not evidence that behavior survived.

## Repo layout

```
agents/                          # the six agent definitions (source of truth)
skills/review-orchestrator/
  SKILL.md                       # bootstrap router: installs agents, gathers inputs, hands off
```
