---
name: anatomy
description: Structural guide for building rule-skills. Covers description format (capability vs constraint vs OpenClaw variant), body structure (immutability marking, domain sections, MUST/NEVER statements), pairing convention (naming patterns, cross-references), enforcement levels, and new rule-skill checklist.
---

# Rule-Skill Anatomy — Structural Guide

Structural standards for rule-skill files. Called by parent EP at Step 3 (description) and Step 4 (body).

## Execution Procedure

```python
def build_rule_skill_structure(constraints, domain, counterpart) -> structured_skill:
    # Called by SKILL.md Step 3 + Step 4

    # Description
    description = write_description(constraints, counterpart)  # see Description Format
    assert "MUST" in description or "NEVER" in description
    assert description.ends_with("MUST read SKILL.md BEFORE [action]")
    assert len(description) <= 1024

    # Body
    body = write_body(constraints, counterpart)                # see Body Structure
    assert body.has_domain_sections
    assert all(stmt.has_rationale for stmt in body.must_never_statements)

    # Pairing
    if counterpart:
        setup_cross_references(skill, counterpart)             # see Pairing Convention

    # Verification
    run_checklist(skill)                                       # see Checklist for New Rule-Skills
    assert all_items_checked

    return structured_skill
```

## Description Format

### Capability Skill Description

Plain text. Describe what it teaches, when to trigger, and reference the paired constraint skill.

```
Browser lifecycle management — tab limits, cleanup routines, resource budgets.
Trigger: any task involving browser automation or web scraping.
Use with browser-rules for constraint enforcement.
```

### Constraint Skill Description

Include MUST/NEVER summary. End with reading requirement.

```
Browser operation constraints. MUST check tabs before operating.
NEVER leave dead tabs. MUST snapshot after navigate.
Capability teaching: see browser-hygiene.
MUST read SKILL.md BEFORE any browser operation.
```

**Why this format**: The `MUST read SKILL.md BEFORE [action]` phrase is the auto-invocation trigger — it names a specific scenario (browser operation) so agent can match on browser-related tasks, and it enforces body load before any such action. Without this phrase, the body rarely loads. See §Auto-Invocation Trigger Discipline below.

### OpenClaw Variant

Wrap in `<rules>` XML tags for semantic parsing:

```xml
<rules>
Browser operation constraints. MUST check tabs before operating.
NEVER leave dead tabs. MUST snapshot after navigate.
MUST read SKILL.md BEFORE any browser operation.
</rules>
```

### Limits

Keep descriptions under 1024 characters (Agent Skills standard limit).

### Activation Constraints via `paths` Frontmatter

Claude Code skill frontmatter supports an optional `paths` field that accepts glob patterns:

```yaml
---
name: react-component-rules
description: "React component rules — a11y, naming, hooks hygiene. MUST read SKILL.md BEFORE editing any *.tsx component file."
paths: "**/*.tsx"
---
```

**Important — `paths` is an activation _constraint_, not a trigger**: Claude must already decide (via description matching) to use the skill; `paths` then filters out activation in files that don't match the glob. Setting `paths` on a skill does **not** proactively trigger loading when a matching file appears.

**Use `paths` for rule-skills when**:
- The skill's domain is strongly tied to specific file types or paths (e.g., `*.sql` for migration-rules, `*.tsx` for component-rules)
- You want to prevent the skill from firing on unrelated files even if description keywords accidentally match
- Scope is narrower than the trigger phrase can convey

**Do NOT use `paths` to solve weak-trigger problems** — if description is vague, `paths` won't rescue it, because the skill is never selected for activation in the first place. Fix description strength (see §Auto-Invocation Trigger Discipline) first.

**Combining with meta-rule protocol**: meta-rule treatment applies to any `-rules` suffix skill regardless of `paths`. `paths` only scopes where the body loads once the skill is selected — it does not exempt the skill from the MUST-level treatment declared by the meta-rule.

### Auto-Invocation Trigger Discipline

A rule-skill's body is only loaded when the description matches current context. Three levels of trigger strength:

| Level | Description Format | Auto-invocation |
|-------|-------------------|-----------------|
| **Weak** | "Contains rules for X" | Rarely matches — describes the skill, not a scenario |
| **Medium** | "Rules for X. Use with X-capability." | May match X keyword but no action binding |
| **Strong** | "Rules for X. MUST read SKILL.md BEFORE [specific action in X]." | Matches action scenario + enforces body load |

Only **Strong** guarantees Layer 2 (body) loads when a relevant task appears. Weak and Medium rely on the agent volunteering to read the skill, which does not happen reliably.

**Writing a Strong trigger**:
1. Name specific actions (edit, modify, add, deploy) — not abstract topics
2. Bind to file types or tools the agent will interact with ("any React component file", "any SQL migration", "any `scripts/deploy.sh` change")
3. Use imperative "MUST read SKILL.md BEFORE [action]" — not softeners like "should" or "consider reading"
4. Keep the scenario narrow enough that it only fires in the intended context (broad scenarios cause auto-invocation to fire constantly, wasting context)

**Example — same rule, three trigger strengths**:

| Strength | Description |
|----------|-------------|
| Weak | "Contains rules for React component authoring." |
| Medium | "React component rules — accessibility, naming, hooks. Use with react-dev." |
| Strong | "React component rules — a11y, naming, hooks hygiene. MUST read SKILL.md BEFORE editing any `*.tsx` component file or adding new React components." |

Only the Strong version reliably loads when the agent opens a `.tsx` file.

**Implication for multi-rule skills**: A single rule-skill can house multiple related rules in one body, as long as all rules share a common action context that the description can trigger on. If two rules trigger on different contexts (e.g., "editing components" vs "writing migrations"), they belong in **different rule-skills** — one description cannot strongly trigger on both scenarios.

## Body Structure

```markdown
# Skill Name — Domain Constraint (Immutable)

> Deployed by [system/author]. Capability teaching: see [counterpart skill].

## Domain Section 1

- MUST [positive action] — [why]
- NEVER [prohibition] — [consequence]

## Domain Section 2

- MUST [positive action] — [why]
- NEVER [prohibition] — [consequence]
```

Key elements:
- **Title**: includes "(Immutable)" marker
- **Subtitle**: attribution + counterpart reference
- **Sections**: grouped by domain (e.g., "Tab Management", "Resource Limits")
- **Statements**: always MUST or NEVER, followed by rationale

## Pairing Convention

| Type | Naming Pattern | Examples |
|------|---------------|----------|
| Capability | `xxx-hygiene`, `xxx-management`, `smart-xxx` | `browser-hygiene`, `memory-management`, `smart-search` |
| Constraint | `xxx-rules` | `browser-rules`, `memory-rules`, `search-rules` |

Cross-references:
- Capability description: "Use with xxx-rules" / "配合 xxx-rules 使用"
- Constraint description: "Capability teaching: see xxx-hygiene" / "能力教学见 xxx-hygiene"

## Enforcement Levels

| Level | Mechanism | Strength | Example |
|-------|-----------|----------|---------|
| Behavioral | Documented MUST/NEVER in body | Social contract | "MUST review before sending" |
| Tooling | Only correct tool available/documented | Structural | "MUST use tg-send-album.sh" |
| Automatic | Hard limit enforced by code/daemon | Mechanical | "tab-guard.js MAX_TABS=4" |
| Constitutional | Immutable file marking + `-rules` namespace covered by meta-rule protocol | Systemic | Any `*-rules` skill auto-elevated to MUST-level once meta-rule installed |

**Best practice**: Layer enforcement. Behavioral (skill body) catches most violations. Tooling (only exposing the right tool) prevents misuse. Automatic (code enforcement) handles critical limits. Constitutional (immutability marking) prevents self-modification.

## Checklist for New Rule-Skills

- [ ] Name ends with `-rules`
- [ ] Description contains MUST/NEVER summary
- [ ] Description ends with "MUST read SKILL.md BEFORE [action]"
- [ ] The "[action]" phrase names a specific scenario (file type, tool, operation) — not an abstract topic
- [ ] Description under 1024 characters
- [ ] Body has domain sections with specific MUST/NEVER statements
- [ ] Each MUST/NEVER statement includes rationale
- [ ] References capability counterpart skill
- [ ] Body header marked "(Immutable)" if system-deployed
- [ ] Body header includes "Deployed by [author/system]"
- [ ] Positive counterpart exists for every prohibition (MUST/NEVER duality)
