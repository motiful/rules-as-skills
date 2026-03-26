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
| Constitutional | Immutable file marking + namespace | Systemic | "-rules suffix reserved for system deployer" |

**Best practice**: Layer enforcement. Behavioral (skill body) catches most violations. Tooling (only exposing the right tool) prevents misuse. Automatic (code enforcement) handles critical limits. Constitutional (immutability marking) prevents self-modification.

## Checklist for New Rule-Skills

- [ ] Name ends with `-rules`
- [ ] Description contains MUST/NEVER summary
- [ ] Description ends with "MUST read SKILL.md BEFORE [action]"
- [ ] Description under 1024 characters
- [ ] Body has domain sections with specific MUST/NEVER statements
- [ ] Each MUST/NEVER statement includes rationale
- [ ] References capability counterpart skill
- [ ] Body header marked "(Immutable)" if system-deployed
- [ ] Body header includes "Deployed by [author/system]"
- [ ] Positive counterpart exists for every prohibition (MUST/NEVER duality)
