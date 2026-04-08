---
name: rules-as-skills
description: 'Methodology for encoding hard constraints (Rules) as dynamically-loaded Skills. Solves: rules always-loaded wasting context, rules not portable across platforms, constraints not publishable or shareable. Use when creating constraint-type skills, encoding MUST/NEVER boundaries for AI agents, or adapting rules across platforms (Claude Code, Codex, Cursor, Windsurf). Core pattern: MUST/NEVER summary in skill description (always visible) + detailed rules in body (loaded on demand) + optional platform-native rule file as hard fallback.'
license: MIT
metadata:
  author: motiful
  version: "1.1"
---

# Rules as Skills — Constraint Delivery via the Skills Mechanism

Encode MUST/NEVER constraints as dynamically-loaded skills using the three-layer model: description (always visible), body (on-demand), optional platform rule file (hard fallback).

## Execution Procedure

```python
def create_rule_skill(constraints, domain) -> rule_skill:
    # STEP 1: Assess — should this be a rule-skill?
    mechanism = assess(constraints)              # references/decision-tree.md
    if mechanism == "traditional_rule": return   # short + universal → keep as rule file
    if mechanism == "code_enforced": return      # already mechanical → neither needed

    # STEP 2: Name and pair
    name = f"{domain}-rules"                     # -rules suffix reserved for constraints
    counterpart = find_capability_skill(domain)  # e.g., browser-hygiene for browser-rules

    # STEP 3: Write description (Layer 1)
    description = write_description(constraints) # references/anatomy.md §Description Format
    assert "MUST" in description or "NEVER" in description
    assert description.ends_with("MUST read SKILL.md BEFORE [action]")
    assert len(description) <= 1024

    # STEP 4: Write body (Layer 2)
    body = write_body(constraints, counterpart)  # references/anatomy.md §Body Structure
    # Domain sections with MUST/NEVER statements + rationale
    # "(Immutable)" in title if system-deployed
    # Counterpart cross-reference in subtitle

    # STEP 5: Deploy platform fallback (Layer 3)
    if critical(constraints):                    # references/decision-tree.md §When to Use Both
        deploy_thin_rule(name, description)      # see Platform Adaptation section
    # Skip ONLY when: not critical (violation won't cause data loss or security breach)

    # STEP 6: Cross-reference
    if counterpart:
        add_cross_ref(counterpart, name)         # "Use with <name>-rules"
        add_cross_ref(name, counterpart)         # "Capability teaching: see <counterpart>"

    return rule_skill
```

## The Three-Layer Model

### Layer 1 — Description (always in context)

Put MUST/NEVER constraint summary in the skill's `description` field. On most platforms, skill descriptions are always visible to the model (~2% of context window). This is your guardrail that's always on.

Cost: minimal. Benefit: the model always knows the constraint exists.

### Layer 2 — Body (loaded on demand)

Full constraint rules with context, examples, violation scenarios. Only loaded when the model determines relevance or user invokes the skill.

This is where detailed MUST/NEVER statements live, organized by domain section. The body is the authoritative source; the description is a summary.

### Layer 3 — Platform Rule File (hard fallback for critical constraints)

For constraints where violation causes data loss, security breach, or irreversible damage — deploy a thin rule file to the platform's native rule mechanism:

| Platform | Rule File Location |
|----------|-------------------|
| Claude Code | `~/.claude/rules/<name>.md` |
| OpenClaw | `AGENTS-RULES.md` |
| Codex | `AGENTS.md` |
| Cursor | `.cursorrules` |

Keep the rule file thin — a pointer to the skill, not a duplicate of its content.

Deploy Layer 3 when: constraint is critical AND must not be missed even if skill isn't triggered. Skip when: constraint is domain-specific and non-critical.

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

These patterns emerged from 6+ rule-skills running in production across multi-agent orchestration projects:

1. **Pre-Action Reading Requirement** — "MUST read SKILL.md BEFORE..." forces the agent to load full constraints before acting, not after.

2. **MUST/NEVER Duality** — Every prohibition has a positive counterpart. "NEVER leave dead tabs" pairs with "MUST clean up tabs after navigation." This reduces ambiguity.

3. **Clear Tooling References** — Reference specific tools/commands the agent should use. "MUST use `tg-send-album.sh`" not "must send properly."

4. **Resource Management Focus** — Explicit limits and cleanup requirements. "MAX_TABS=4", "MUST close browser after task."

5. **Metadata Tagging** — Visual markers distinguish rule-skills from capability skills. "Immutable", "Deployed by [system]" in the body header.

6. **Immutability Marking** — Rule-skills are not modifiable by the agent. The body header states this explicitly, preventing self-modification loops.

See `references/anatomy.md` for structural details of each pattern.

## In-Repo Rule-Skills

Not all rule-skills are published as standalone repos. Some ship with the project repo itself.

**What they are**: Rule-skills that live in `.claude/skills/` within a project repository. They are version-controlled and distributed with the repo (clone/fork gets them), but are not independently installable via `npx skills add`.

**When to use**: Constraints that only apply to THIS repo's context — maintenance procedures, project-specific coding standards, deployment checklists, security rules.

**Directory setup**:
```
project-repo/
├── SKILL.md                              ← main skill (published)
├── .claude/skills/<name>-rules/
│   └── SKILL.md                          ← in-repo rule-skill (source of truth)
├── .agents/skills/<name>-rules            → relative symlink to .claude/skills/<name>-rules
└── .gitignore                            ← needs !.claude/skills/ exception
```

**Platform coverage** (`.claude/skills/` as source of truth):
- Claude Code: native
- VS Code/Copilot: compat scan
- Windsurf: compat scan
- Codex: via `.agents/skills/` symlink

**Symlink**: MUST use relative paths in git repos (absolute paths break on clone).

**.gitignore config**:
```
.claude/*
!.claude/skills/
.agents/*
!.agents/skills/
```

**Format**: Same as published rule-skills — MUST/NEVER summary in description, full rules in body. No README or LICENSE needed (not independently published).

**Example**: `maintenance-rules` — repo maintenance constraints (update triggers, verification steps, contribution criteria).

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
