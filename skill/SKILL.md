---
name: rules-as-skills
description: >-
  Methodology for encoding hard constraints (Rules) as dynamically-loaded Skills.
  Solves: rules always-loaded wasting context, rules not portable across platforms,
  constraints not publishable or shareable.
  Use when creating constraint-type skills, encoding MUST/NEVER boundaries for AI agents,
  or adapting rules across platforms (Claude Code, OpenClaw, Codex, Cursor).
  Core pattern: MUST/NEVER summary in skill description (always visible) + detailed rules
  in body (loaded on demand) + optional platform-native rule file as hard fallback.
license: MIT
metadata:
  author: motiful
  version: "1.0"
---

# Rules as Skills — Constraint Delivery via the Skills Mechanism

## The Problem

Skills teach "what you CAN do" (capability). Nothing teaches "what you MUST/NEVER do" (constraint).

LLMs are goal-seeking — "complete the task" has incentive, "clean up after" doesn't. Without explicit constraint delivery, agents cut corners, skip cleanup, violate boundaries.

Traditional rules mechanisms (CC's `~/.claude/rules/`, Codex's `AGENTS.md`, OpenClaw's `AGENTS-RULES.md`) are:
- **Always-loaded** — every rule consumes context regardless of relevance
- **Not dynamic** — cannot be triggered conditionally based on task domain
- **Not portable** — each platform has its own format, no sharing across ecosystems
- **Not publishable** — cannot be distributed as reusable packages

## The Solution: Three-Layer Model

### Layer 1 — Description (always in context)

Put MUST/NEVER constraint summary in the skill's `description` field. On most platforms, skill descriptions are always visible to the model (~2% of context window). This is your guardrail that's always on.

Cost: minimal. Benefit: the model always knows the constraint exists.

### Layer 2 — Body (loaded on demand)

Full constraint rules with context, examples, violation scenarios. Only loaded when the model determines relevance or user invokes the skill.

This is where detailed MUST/NEVER statements live, organized by domain section. The body is the authoritative source; the description is a summary.

### Layer 3 — Platform Rule File (optional hard fallback)

For truly critical constraints that cannot be missed even if the skill isn't triggered. Deploy a thin rule file to the platform's native rule mechanism:

| Platform | Rule File Location |
|----------|-------------------|
| Claude Code | `~/.claude/rules/<name>.md` |
| OpenClaw | `AGENTS-RULES.md` |
| Codex | `AGENTS.md` |
| Cursor | `.cursorrules` |

Keep the rule file thin — a pointer to the skill, not a duplicate of its content.

## Anatomy of a Rule-Skill

**Naming**: Use `-rules` suffix (e.g., `browser-rules`, `memory-rules`). This suffix is reserved for constraint skills.

**Description format**: Include MUST/NEVER keywords, reference the capability counterpart, end with "MUST read SKILL.md BEFORE [action]".

**Body format**: Domain sections with specific MUST/NEVER statements tied to concrete actions.

**Pairing**: Each rule-skill pairs with a capability skill (e.g., `browser-hygiene` + `browser-rules`).

See `references/anatomy.md` for the detailed structural guide.

## When to Use (vs Traditional Rules)

See `references/decision-tree.md` for the full decision framework.

**Short version**: Use rule-skills when constraints are domain-specific, need cross-platform portability, or have a capability counterpart. Use traditional rules when constraints are universal and short.

## Platform Adaptation

### Claude Code
Skill descriptions always in context. Full SKILL.md loaded on auto-invocation. Optional: deploy thin rule to `~/.claude/rules/` for hard fallback.

### OpenClaw
Use `<rules>` XML wrapper in description for semantic parsing. `-rules` suffix namespace reserved for system deployer. Constitutional backing via `AGENTS-RULES.md`.

### Codex
Reference constraints in `AGENTS.md`. Skill body provides detailed rules when loaded.

### Cursor
Same as CC — skill descriptions in context, body on demand. Deploy to `.cursorrules` for hard fallback.

## Six Patterns from Production

These patterns emerged from 6 rule-skills running in production (OpenClaw/Clawfather project):

1. **Pre-Action Reading Requirement** — "MUST read SKILL.md BEFORE..." forces the agent to load full constraints before acting, not after.

2. **MUST/NEVER Duality** — Every prohibition has a positive counterpart. "NEVER leave dead tabs" pairs with "MUST clean up tabs after navigation." This reduces ambiguity.

3. **Clear Tooling References** — Reference specific tools/commands the agent should use. "MUST use `tg-send-album.sh`" not "must send properly."

4. **Resource Management Focus** — Explicit limits and cleanup requirements. "MAX_TABS=4", "MUST close browser after task."

5. **Metadata Tagging** — Visual markers distinguish rule-skills from capability skills. "Immutable", "Deployed by [system]" in the body header.

6. **Immutability Marking** — Rule-skills are not modifiable by the agent. The body header states this explicitly, preventing self-modification loops.

See `references/anatomy.md` for structural details of each pattern.

## Example

A capability + constraint pair for the browser domain:

```
browser-hygiene (capability):
  Teaches tab management, cleanup habits, resource budgets.
  Description: "Browser lifecycle management. Use with browser-rules."

browser-rules (constraint):
  MUST check open tabs before any browser operation.
  NEVER leave dead/stale tabs after navigation.
  MUST snapshot page state after every navigate action.
  Description: "...MUST read SKILL.md BEFORE any browser operation."
```

For the memory domain: `memory-hygiene` (capability) teaches memory management patterns + a deployable rule template (constraint) enforces write-back and cleanup obligations.
