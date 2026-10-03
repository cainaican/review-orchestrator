# review-orchestrator

Staged deep code review for [opencode](https://opencode.ai): one orchestrator subagent + 4 parallel read-only critics (correctness, security, performance, Angular library conventions). No harness — five markdown agent files, nothing else.

Inspired by the pipeline patterns of [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch): critics must cite code, the orchestrator adversarially verifies blocker/important findings before they reach the report.

## Install

**Route A — bootstrap skill (loads from this repo on demand):**

```
npx skills add <your-user>/review-orchestrator
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
| `code-reviewer` | orchestrator: intake → context → 4 parallel critics → adversarial verification → report | read-only, `git diff/log/show/branch`, Task only on critics |
| `critic-correctness` | logic bugs, edge cases, races, regressions | read-only, hidden |
| `critic-security` | secrets, auth, injection, XSS, SSRF | read-only, hidden |
| `critic-performance` | N+1, bundle, tree-shaking, change detection | read-only, hidden |
| `critic-angular` | signals/OnPush/RxJS, public API surface, semver, templates | read-only, hidden |

Anti-hallucination contract: critics may only report findings with a verbatim code excerpt; the orchestrator re-opens every blocker/important file itself and moves unverifiable findings to a "Dropped findings" appendix.

## Repo layout

```
agents/                          # the five agent definitions (source of truth)
skills/review-orchestrator/
  SKILL.md                       # bootstrap router: installs agents, gathers inputs, hands off
```
