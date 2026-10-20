# review-orchestrator

Staged deep code review for [opencode](https://opencode.ai): one orchestrator subagent + 6 read-only critics run sequentially (correctness → security → Angular library conventions → shape → performance → tests) with a verified findings digest passed down the chain, plus an orchestrator-run mental-trace pass and a coverage sweep. No harness — seven markdown agent files, nothing else.

Inspired by the pipeline patterns of [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch): critics must cite code; the orchestrator mentally executes calculational functions on adversarial inputs, adversarially verifies critic findings for both existence AND coverage, and iteratively deep-dives on blockers before the report.

## Install or update

The same command does both — idempotent (`git pull` if already installed, fresh clone otherwise).

**Global** — every project sees `@code-reviewer`:

```sh
curl -fsSL https://raw.githubusercontent.com/cainaican/review-orchestrator/main/install.sh | sh
```

**Project-local** — only this project:

```sh
curl -fsSL https://raw.githubusercontent.com/cainaican/review-orchestrator/main/install.sh | sh -s -- --project
```

The script clones the repo into `.../skills/review-orchestrator/` and copies the seven agent files into `.../agents/`. Restart the opencode session so the Task tool sees the agents.

Prefer manual control (same two steps, idempotent):

```sh
# Install
git clone --depth 1 https://github.com/cainaican/review-orchestrator ~/.config/opencode/skills/review-orchestrator
cp ~/.config/opencode/skills/review-orchestrator/agents/*.md ~/.config/opencode/agents/

# Update later
git -C ~/.config/opencode/skills/review-orchestrator pull --ff-only
cp ~/.config/opencode/skills/review-orchestrator/agents/*.md ~/.config/opencode/agents/
```

For project-local, substitute `~/.config/opencode` → `./.opencode`.

## Usage

Direct call:

```
@code-reviewer сравни main...feature/auth, задача: добавили OAuth-логин
```

Or via the skill (`ревью ветки X относительно Y`) — the orchestrator asks four questions:

1. **Diff source** (required) — two refs, or paste the diff.
2. **Task summary** (required, one line).
3. **Acceptance criteria / полная постановка** (optional, multi-line) — when present, critics treat it as the authoritative intent spec.
4. **External references** (optional, URLs) — tickets, specs, design docs. The orchestrator tries an MCP tool by hostname (`atlassian.net`→jira, `linear.app`→linear, `github.com`→github, `notion.so`→notion); on failure, falls back to asking you to paste the content.

The report ends with a `## Review log` YAML block for analytics. Saved to `~/.config/opencode/review-logs/<id>.yaml` on `y`; drop into the repo's `calibration/` directory to tune critic prompts over time.

## Roster

| Agent | Lens | Access |
|---|---|---|
| `code-reviewer` | orchestrator: intake → context+domain brief → critic plan (conservative skip gates) → sequential critics with verified findings digest → mental trace → verification + coverage sweep → deep-dive on blockers → report | read-only, `git diff/log/show/branch`, Task only on critics, `mcp__*` tools for external refs |
| `critic-correctness` | 1st: logic bugs, edge cases, races, regressions; mental execution over adversarial inputs | read-only, hidden |
| `critic-security` | 2nd: secrets, auth, injection, XSS, SSRF | read-only, hidden |
| `critic-angular` | 3rd: signals/OnPush, RxJS interaction-stream traps (drag/scroll/pointer), public API surface, semver, templates; diff-relative | read-only, hidden |
| `critic-shape` | 4th: overbuild, dead scaffolding, stock-primitive mismatches, library-API shape debt | read-only, hidden |
| `critic-performance` | 5th: N+1, bundle, tree-shaking, change detection; diff-relative, rejects bounded micro-noise without semantic risk | read-only, hidden |
| `critic-tests` | 6th: spec vs behavior correspondence, missing edge-case coverage, concrete test cases to add (harvests the digest into regression templates) | read-only, hidden |

Anti-hallucination contract: critics may only report findings with a verbatim code excerpt; the orchestrator verifies every blocker/important itself inline — before the finding may travel further down the chain (proof-of-existence) — and sweeps every changed file with no findings (proof-of-coverage) before the report.

Sequential critic chain: critics run in a fixed order (correctness → security → Angular → shape → performance → tests), not in parallel. After each critic returns, the orchestrator verifies its blocker/important findings against the code and passes a compact **findings digest** (titles only, ~4 KB cap) to the next critic — verified context, not an agenda: later critics must not re-report digest items, confirm them without their own excerpt, or let the digest narrow their sweep. Conservative skip gates may skip a critic whose lens has no surface in the diff (e.g. no input/network hunks → security skipped); every skip is logged with its reason in the review log. The tests critic runs last and converts every surviving finding into regression-test templates.

Interaction-impact gate: the orchestrator classifies every changed mechanism by intervention class; delivery-level changes — anything altering event delivery or timing — get a mandatory **victims list** of the existing interactions they intersect, consumer side included. Critics answer "what does this diff BREAK?" explicitly, and the report's "Interaction impact" section forbids unverified negatives. Public-API diffing alone does not cover delivery-level coupling: "no callers changed" is not evidence that behavior survived.

## Repo layout

```
agents/                          # the seven agent definitions (source of truth)
skills/review-orchestrator/
  SKILL.md                       # bootstrap router: installs agents, gathers inputs, hands off
calibration/                     # review-log YAMLs with human_feedback — used to tune critic prompts
install.sh                       # idempotent install/update script
```
