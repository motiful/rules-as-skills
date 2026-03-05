# Rules as Skills

> Methodology for encoding hard constraints (Rules) as dynamically-loaded Skills.

## What This Is

An [Agent Skills](https://agentskills.io) compatible skill that teaches how to use the Skills mechanism to deliver Rules — giving constraint enforcement the dynamic loading, portability, and publishability that traditional rule files lack.

## The Problem

AI agent platforms have robust capability delivery (skills/plugins), but weak constraint delivery. Traditional rules are always-loaded (wasting context), platform-specific (not portable), and not publishable. This skill bridges the gap.

## The Pattern

```
Layer 1 — Description    MUST/NEVER summary (always visible, ~2% context)
Layer 2 — Body           Detailed rules (loaded on demand)
Layer 3 — Rule File      Optional hard fallback (platform-native)
```

## Install

### Claude Code

```bash
git clone https://github.com/motiful/rules-as-skills ~/motifpool/rules-as-skills
ln -s ~/motifpool/rules-as-skills/skill ~/.claude/skills/rules-as-skills
```

### Other Platforms

Clone the repo and symlink/copy `skill/` to your agent's skills directory.

## See Also

- [memory-hygiene](https://github.com/motiful/memory-hygiene) — Reference implementation of this pattern

## License

MIT
