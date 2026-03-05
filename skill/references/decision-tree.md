# Decision Tree — Rules vs Rule-Skills

## Primary Decision Framework

```
Is the constraint...

1. Universal (applies in ALL contexts, not domain-specific)?
   YES -> Short enough for a rule file (<10 lines)?
          YES -> Traditional rule (always-loaded, cheap)
          NO  -> Rule-skill (dynamic loading saves context)
                 + thin rule file as hard fallback
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

## When to Use Both (Belt + Suspenders)

Use a rule-skill AND a platform rule file when:
- Constraint is **critical** — violation causes data loss, security breach, or irreversible damage
- Constraint **must never be missed** — even if the skill isn't triggered by the agent

Deploy:
1. Full rule-skill for dynamic loading, portability, detailed context
2. Thin rule file (platform-native) that says: "See [skill-name] for full constraints. Summary: [1-2 line MUST/NEVER]."

Example: `memory-hygiene` skill (full rules in SKILL.md) + `~/.claude/rules/memory-hygiene.md` (thin pointer with critical summary).

## When to Use Neither

- The constraint is already enforced by **code/tooling** (mechanical enforcement)
- Adding a rule-skill would be redundant documentation of what the code already prevents
- Example: if `MAX_TABS` is enforced by a daemon that kills excess tabs, a rule-skill saying "NEVER exceed MAX_TABS" is redundant

## Quick Reference

| Scenario | Mechanism | Example |
|----------|-----------|---------|
| Short, universal constraint | Traditional rule | "Never commit .env files" |
| Domain-specific, complex constraint | Rule-skill | browser-rules (10+ MUST/NEVER) |
| Critical + must not miss | Rule-skill + rule file | memory-rules + thin fallback |
| Already code-enforced | Neither | Tab limit daemon |
| Needs cross-platform sharing | Rule-skill | Publish to npm/GitHub |
| Has capability counterpart | Rule-skill, paired | browser-hygiene + browser-rules |

## Cost-Benefit Summary

| Mechanism | Context Cost | Portability | Publishable | Dynamic Loading |
|-----------|-------------|-------------|-------------|-----------------|
| Traditional rule file | Always-on (~fixed) | Platform-specific | No | No |
| Rule-skill (description only) | ~2% context | Cross-platform | Yes | Partial |
| Rule-skill (full body) | On-demand | Cross-platform | Yes | Yes |
| Rule-skill + rule fallback | ~2% + thin rule | Cross-platform | Yes | Yes |
