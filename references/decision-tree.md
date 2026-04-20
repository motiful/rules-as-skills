---
name: decision-tree
description: Decision framework for choosing the right constraint delivery mechanism. Step 0 classifies the constraint's own scope (universal / single-file / domain-specific); primary framework picks between traditional rule files and rule-skills when scope warrants extraction; meta-rule protocol provides global hard fallback without per-skill deployment.
---

# Decision Tree — Rules vs Rule-Skills

Decision framework for choosing the right constraint delivery mechanism. Called by parent EP at Step 1.

## Execution Procedure

```python
def assess(constraints) -> "universal_spec" | "inline_comment" | "traditional_rule" | "rule_skill" | "neither":
    # Called by SKILL.md Step 1

    # STEP 0: Classify by constraint's own nature (not by who enforces)
    scope = classify_scope(constraints)                # see Step 0 below
    if scope == "universal_engineering":
        return "universal_spec"                        # → project README or general spec
    if scope == "single_file":
        return "inline_comment"                        # → 5-10 line comment at top of file
    # scope == "cross_file_domain_specific" → continue to Step 1

    if code_enforced(constraints):                     # see When to Use Neither
        return "neither"

    result = walk_decision_tree(constraints)           # see Primary Decision Framework
    # Questions 1-4 in order: universal? → domain-specific? → portable? → paired?

    return result
```

## Step 0 — Classify Constraint by Its Own Nature

Before walking the rule-skill decision framework, check whether the constraint belongs in the rule-skill domain at all. A constraint's **scope and locality** determine its right home — not the tool that enforces it.

```
What is the constraint's scope?

A. Universal engineering rule — applies to any skill, any project, any codebase
   Examples: "commit messages in English", "variable names camelCase"
   → NOT a rule-skill. Belongs in a general engineering spec (project README,
     CONTRIBUTING, style guide, or team handbook).

B. Single-file or single-module scope — only governs one specific file/module
   Examples: "this reference's EP field must resolve",
             "this file only callable by X", "this module must not import Y"
   → NOT a rule-skill. Write 5-10 lines of comment at the top of the
     constrained file. Proximity to enforcement target beats extraction.

C. Cross-file / cross-session / domain-specific hard constraint
   Examples: "browser operations must clean up tabs",
             "memory writes must go through the hygiene layer"
   → Candidate for rule-skill. Continue to Primary Decision Framework below.
```

**Why Step 0 matters**: Extraction has a cost. A rule-skill adds a file, a dependency link, a maintenance surface, and an installation step. For constraints whose scope never leaves one file, a top-of-file comment is simpler, closer to the code, and harder to miss. For constraints that are universal engineering hygiene, no extraction brings value — they belong in the project's overall spec.

Only constraints whose **locus is genuinely the domain itself** (not a single file, not universal hygiene) earn the rule-skill form.

## Primary Decision Framework

```
Is the constraint...

1. Universal (applies in ALL contexts, not domain-specific)?
   YES -> Short enough for a rule file (<10 lines)?
          YES -> Traditional rule (always-loaded, cheap)
          NO  -> Rule-skill (dynamic loading saves context);
                 meta-rule protocol covers hard-fallback automatically.
   NO  -> Continue

2. Domain-specific (only relevant in certain contexts)?
   YES -> Complex enough to justify a full SKILL.md (>3 statements)?
          YES -> Rule-skill (dynamic loading, portable, publishable)
          NO  -> Traditional rule (simpler infrastructure)
   NO  -> Continue

3. Does it need cross-platform portability?
   YES -> Rule-skill (Skills are the most portable mechanism)
   NO  -> Traditional rule is fine

4. Does it have a capability counterpart?
   YES -> Rule-skill, paired with capability skill
   NO  -> Consider if standalone rule-skill or traditional rule is simpler
```

## Hard Fallback — Meta-Rule Protocol (covered automatically)

Earlier versions of this skill used a **per-skill belt-and-suspenders** design: each critical rule-skill deployed its own thin rule file (e.g., `~/.claude/rules/<name>.md`). That design scales with N (every skill = one manual step).

**Current design**: a single meta-rule installed once via `scripts/install-meta-rule.sh` covers every `-rules` suffix skill automatically. Any rule-skill that lands on disk inherits hard-constraint semantics without per-skill deployment work.

Consequences for this decision framework:
- Authors **do not** need to choose between "rule-skill only" vs "rule-skill + fallback" — the meta-rule applies uniformly
- The only author decisions are: (a) should this be a rule-skill at all (Step 0 + Primary Framework), (b) what domain + counterpart pairing
- Platform fallback is a **deployer-level one-time setup**, not a per-skill choice

## When to Use Neither

- The constraint is already enforced by **code/tooling** (mechanical enforcement)
- Adding a rule-skill would be redundant documentation of what the code already prevents
- Example: if `MAX_TABS` is enforced by a daemon that kills excess tabs, a rule-skill saying "NEVER exceed MAX_TABS" is redundant

## Quick Reference

| Scenario | Mechanism | Example |
|----------|-----------|---------|
| Universal engineering rule (any project) | General spec (README, CONTRIBUTING) | "commit messages in English" |
| Single-file / single-module scope | 5-10 line comment at top of file | "this file only callable by X" |
| Short, universal runtime constraint | Traditional rule | "Never commit .env files" |
| Domain-specific, complex constraint | Rule-skill | browser-rules (10+ MUST/NEVER) |
| Critical + must not miss | Rule-skill (meta-rule protocol handles fallback) | memory-rules |
| Already code-enforced | Neither | Tab limit daemon |
| Needs cross-platform sharing | Rule-skill | Publish to npm/GitHub |
| Has capability counterpart | Rule-skill, paired | browser-hygiene + browser-rules |
| In-repo constraints (maintenance, coding standards) | In-repo rule-skill | maintenance-rules in .claude/skills/ |

## Cost-Benefit Summary

| Mechanism | Context Cost | Portability | Publishable | Dynamic Loading |
|-----------|-------------|-------------|-------------|-----------------|
| General spec / top-of-file comment | None (read by devs, not agent) | Project-bound | No | N/A |
| Traditional rule file | Always-on (~fixed) | Platform-specific | No | No |
| Rule-skill (description only) | ~2% context | Cross-platform | Yes | Partial |
| Rule-skill (full body) | On-demand | Cross-platform | Yes | Yes |
| Rule-skill + meta-rule protocol | ~2% + global meta-rule (one-time) | Cross-platform | Yes | Yes |
