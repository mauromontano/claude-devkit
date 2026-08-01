# Ecosystem: skills, plugins, MCPs, and hooks to add

Recommendations to round out the setup, ordered by impact for my stack (Node/Express,
Next.js/React/TS, Laravel) and my flow (plan-first, TDD, per-stage review).

> The Claude Code ecosystem moves fast. Before installing anything, check that it's
> maintained (last commit, open issues) and try it on a toy project.

## Ships with the devkit

Installed automatically by `install.sh` on any machine:

- **archify** (diagrams) — bundled skill, vendored in `dot-claude/skills/archify`.
- **context7** (latest docs via the `ctx7` CLI) — bundled rule in `dot-claude/rules`.
- **feature-workflow** + per-stack skills (laravel, node-next) — bundled.
- **superpowers, frontend-design, code-review, code-simplifier** — bootstrapped from the
  `claude-plugins-official` marketplace (reinstalled, not vendored, so they stay
  updated). See the note in the README about superpowers' overlap with the workflow.

## 1. TDD enforcement (most aligned with my process)

- **tdd-guard** — a hook that blocks writing implementation unless a failing test
  exists first. It's exactly Phase 3 of the workflow, automated at the hook level (it
  doesn't depend on anyone "remembering"). Supports several runners (Jest/Vitest,
  RSpec, etc.).
  → The strongest candidate to add. Check the repo's health before adopting.

Homemade alternative if you don't want a dependency: a custom `PreToolUse` hook that,
when a non-test code file is edited, checks that its associated test exists and fails.
More fragile, but zero dependencies.

## 2. MCP servers to connect

MCPs give the agent access to real tools. The highest-leverage ones for my stack:

| MCP | What for | Why it helps me |
|-----|----------|-----------------|
| **context7** | Up-to-date library docs | Stops the agent hallucinating Next/React/Laravel APIs; brings the real docs for the version. |
| **Playwright MCP** | Driving a real browser | Covers the e2e gap I have today. Critical flows: login, checkout. |
| **GitHub MCP** | Issues, PRs, code review | Closes the process loop: open PRs, read reviews, iterate without leaving the terminal. |
| **Postgres/MySQL MCP** | Schema introspection and queries | The agent understands the real data model instead of guessing it. |
| **Sentry / APM MCP** | Production errors | Bring a real stack trace into context for debugging. |

Start with **context7** and **Playwright**: they move the needle most for my
front-heavy combo + e2e gap.

## 3. Subagents already included in this devkit

`architecture-planner`, `code-reviewer`, `test-writer` (characterization tests),
`security-reviewer`, `docs-writer`, `spec-verifier`. They cover planning, refactor
safety nets, and per-stage review without polluting the main context. If a recurring
need appears (e.g. a `migration-reviewer` for schema changes, or a `perf-auditor`),
add one more `.md` in `dot-claude/agents/`.

## 4. Plugins/marketplaces to watch

- **superpowers** (already have it) — keep it updated; it often ships new skills and
  commands.
- **"awesome-claude-code"**-style lists — a good radar for community
  skills/plugins/hooks. Useful for discovery, not for blind installs.
- **My own marketplace** — once this devkit matures, package it as a plugin and
  publish a `marketplace.json` in a private repo. Install with `/plugin` instead of
  symlinks, with versioning. The natural step after dotfiles.

## 5. Additional hooks to consider

- **PostToolUse (included)** — lint/format after every edit.
- **PreToolUse protect-paths (included)** — blocks editing `.env`, schema, keys.
- **Stop / SubagentStop** — run the full suite when the agent "finishes", so it never
  closes a stage in red.
- **SessionStart** — load project context (current branch, recent changes) on open.

## Suggested adoption order

1. Use this devkit as-is (agents + commands + hooks) on a real project for a week.
2. Add the **context7** MCP.
3. Add **tdd-guard** (or the homemade TDD hook).
4. Add **Playwright MCP** for e2e on critical flows.
5. Package everything as a plugin + private marketplace once it's stable.

Don't install everything at once: each piece changes how you work, and it's worth
feeling the effect of one before adding the next.
