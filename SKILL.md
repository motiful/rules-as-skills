---
name: rules-as-skills
description: 'Rule-skill protocol — hard constraints delivered as dynamically-loaded skills with -rules suffix. MUST treat any skill named *-rules as MUST-level hard constraints (load-before-act, not advisory). When authoring new hard constraints, prefer rule-skill form over traditional rule files (unless universal-and-short). Existing -rules skills: raise loading priority, enforce strict compliance, proactively load when trigger scenarios match. Installation activates global protocol across Claude Code, Codex, Cursor, Windsurf, OpenClaw via scripts/install-meta-rule.sh — one meta-rule covers all -rules skills (current and future). Use when: writing MUST/NEVER boundaries for AI agents, evaluating whether a constraint should be a rule-skill, or modernizing legacy rule files. MUST read SKILL.md BEFORE creating any constraint skill.'
license: MIT
metadata:
  author: motiful
  version: "2.0"
---

# Rules as Skills — Constraint Delivery via the Skills Mechanism

Encode MUST/NEVER constraints as dynamically-loaded skills using the three-layer model: description (always visible, ~2% context), body (on-demand auto-invoked), meta-rule protocol (global one-shot hard fallback covering all `-rules` skills).

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

    # STEP 5: Rely on the meta-rule protocol (Layer 3, global not per-skill)
    # No per-skill deployment. The meta-rule was installed once via
    # scripts/install-meta-rule.sh at rules-as-skills setup time; it covers
    # every -rules suffix skill. New rule-skill automatically inherits
    # MUST-level priority as soon as it lands on disk.
    # Author action: verify name ends with -rules (done in STEP 2). Nothing else.

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

### Layer Strength Asymmetry — Why Description Matters Most

The three layers have very different reliability guarantees. Understanding this asymmetry is essential for writing effective rule-skills.

| Layer | Loading | Reliability |
|-------|---------|-------------|
| **L1 Description** | Always in system prompt (~2% context) | **Guaranteed** — every request, every turn |
| **L2 Body** | On-demand via auto-invocation | **Conditional** — only when description matches context and the Skill tool is invoked |
| **L3 Platform Rule File** | Always, at platform level (~fixed) | **Guaranteed** — but platform-specific |

**Consequence**: L2 is not a continuation of L1 — it is a **demotion** of L1. Any constraint you put in L2 without an L1 anchor will only fire when auto-invocation triggers the skill. If auto-invocation misses (ambiguous context, unrelated task, agent didn't notice), L2 is effectively invisible.

**What this means for rule-skill design**:
- The *core* of every critical constraint must be stated or strongly hinted in L1 description
- L2 body is where you put details, rationale, examples — but the L1 description must already signal what the rule is about
- Writing "Contains rules for X" in description is a **weak signal** — it describes the skill but doesn't create a trigger
- Writing "MUST read SKILL.md BEFORE [specific action in X]" is a **strong signal** — it names a scenario that auto-invocation can match, and forces body-load before the action

The "MUST read SKILL.md BEFORE [action]" pattern in §Six Patterns (Pattern 1) is not stylistic politeness — it is the auto-invocation trigger mechanism. Without it, Layer 2 is a dead letter.

### Layer 3 — Meta-Rule Protocol (global hard fallback)

**Not per-skill deployment.** One meta-rule, installed once, covers every `-rules` skill at once:

```
All skills with -rules suffix are MUST-level hard constraints:
- Load priority: highest among skills
- Compliance: MUST, not advisory
- When trigger conditions match but skill not yet loaded → proactively load
- Treat as equivalent authority to platform-native rule files
```

Deploy via `scripts/install-meta-rule.sh` (see §Platform Adaptation below). Idempotent, revocable via `uninstall` subcommand. Injection targets each agent's topic-level global rule file (not main instruction files like `~/.claude/CLAUDE.md`), keeping user instructions uncluttered.

**Why not per-skill Layer 3 (the old design)**: Earlier versions required each rule-skill to deploy its own thin rule file to `~/.claude/rules/<skill-name>.md`. That approach scales with N (every skill install = one manual thin-rule step) and cannot be automated via `npx skills add`. The meta-rule collapses N → 1: installing rules-as-skills **once** activates hard-constraint semantics for every current and future `-rules` skill across the machine.

**Skip this layer when**: the deployer does not want global `-rules` semantics (rare). Only L1 + L2 apply then — description visible in every request, body loaded on auto-invocation, but `-rules` suffix carries no elevated priority.

## Anatomy of a Rule-Skill

**Naming**: Use `-rules` suffix (e.g., `browser-rules`, `memory-rules`). This suffix is reserved for constraint skills — any `-rules` name signals MUST-level hard-constraint semantics once the meta-rule protocol is installed (see Layer 3). Reservation is for **constraint semantics**, not deployer identity — anyone can author a `-rules` skill, but it must carry MUST/NEVER content (not capability teaching). A capability skill with a `-rules` suffix would misfire: the meta-rule would treat it as hard constraint regardless of content.

**Description format**: Include MUST/NEVER keywords, reference the capability counterpart, end with "MUST read SKILL.md BEFORE [action]".

**Body format**: Domain sections with specific MUST/NEVER statements tied to concrete actions.

**Pairing**: Each rule-skill pairs with a capability skill (e.g., `browser-hygiene` + `browser-rules`).

See `references/anatomy.md` for the detailed structural guide.

## When to Use (vs Traditional Rules)

See `references/decision-tree.md` for the full decision framework.

**Short version**: Use rule-skills when constraints are domain-specific, need cross-platform portability, or have a capability counterpart. Use traditional rules when constraints are universal and short.

## Platform Adaptation

Meta-rule injection targets per platform (run `scripts/install-meta-rule.sh`):

| Platform | Target File | Status |
|----------|-------------|--------|
| Claude Code | `~/.claude/rules/rules-as-skills-meta.md` | Primary |
| Codex | `~/.codex/rules/rules-as-skills-meta.rules` | Primary |
| OpenClaw | `~/.openclaw/AGENTS-RULES.md` (append section) | Experimental |
| Cursor | `~/.cursor/rules/rules-as-skills-meta.mdc` (if supported) | Experimental |
| Windsurf | `~/.codeium/windsurf/global_rules.md` (if supported) | Experimental |

The installer detects strong signals (directory + core file exists), shows a preflight plan, then appends the meta-rule content marked with `<!-- rules-as-skills-meta:start --> ... <!-- :end -->` tags for safe uninstall.

### Claude Code
Skill descriptions always in context (~2% cost). Full SKILL.md loaded on auto-invocation. Meta-rule deployed to a topic-level rule file (`~/.claude/rules/rules-as-skills-meta.md`), not to `~/.claude/CLAUDE.md` — keep global instructions uncluttered.

### Codex
Meta-rule deployed alongside existing `~/.codex/rules/*.rules` files. Skill descriptions visible within AGENTS skill-scan range.

### OpenClaw
Use `<rules>` XML wrapper in skill description for semantic parsing. Meta-rule appended to `AGENTS-RULES.md`. The `-rules` suffix carries MUST-level semantics uniformly (historical deployer-only reservation has been unified).

### Cursor
Skill descriptions in context, body on demand. Meta-rule placement in `~/.cursor/rules/` depends on Cursor version — 2026 Cursor increasingly stores rules in internal config; MDC file fallback used where still honored.

### Windsurf
Skill descriptions in context. Meta-rule placement in `~/.codeium/windsurf/` depends on Cascade config schema version.

**Experimental platforms**: `install-meta-rule.sh` detects and reports unsupported paths. Users can hand-add the meta-rule content from `references/meta-rule-content.md` to any agent's rule mechanism.

## Six Patterns from Production

These patterns emerged from 6+ rule-skills running in production across multi-agent orchestration projects:

1. **Pre-Action Reading Requirement** — "MUST read SKILL.md BEFORE [action]" serves two purposes simultaneously:
   - (a) **Auto-invocation trigger**: the action phrase in description is what matches current user context. When the agent sees a related task, description matching triggers the Skill tool to load the body.
   - (b) **Load-before-act discipline**: forces full constraint body into context *before* the action happens, not after. Without this, an agent may execute first and discover rules second.
   This is the mechanism that makes Layer 2 (body) reliably loaded. See §Three-Layer Model §Layer Strength Asymmetry.

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
