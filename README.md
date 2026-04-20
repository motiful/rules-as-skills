<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/logo-light.svg">
    <img alt="rules-as-skills" src=".github/logo-light.svg" width="440">
  </picture>
</div>

<div align="center">

[![License: MIT][license-shield]][license-url]
[![Agent Skills][skills-shield]][skills-url]

</div>

<div align="center">
  <a href="#quick-start">Quick Start</a> &middot;
  <a href="#when-to-use">When to Use</a> &middot;
  <a href="#works-best-with">Ecosystem</a>
</div>

> Teach your AI agent what it must never do — as installable, cross-platform skills.

---

## The Problem

AI agents have strong capability delivery (skills, plugins, tools) but weak constraint delivery. You can teach an agent a hundred new tricks — but telling it what it *must not do* is stuck in platform-specific, always-loaded rule files.

If you manage many rules, your system prompt gets bloated. If you have few, important constraints get lost in noise.

## Features

- **Dynamic loading** — constraints load only when the domain is relevant, not on every conversation
- **Cross-platform portability** — one skill works across Claude Code, Cursor, Codex, OpenClaw, and any Agent Skills platform
- **Never miss a critical constraint** — three layers of defense ensure constraints are always visible, loaded when relevant, and backed by platform-native fallback
- **Publishable constraints** — share and install MUST/NEVER rules as packages via `npx skills add`
- **Capability + constraint pairing** — `browser-hygiene` (teaches) + `browser-rules` (enforces) work as a complete pair
- **Production-proven patterns** — 6+ rule-skills running in production across multi-agent orchestration projects

## Quick Start

### Install

```bash
npx skills add motiful/rules-as-skills
```

Or manually:

```bash
git clone https://github.com/motiful/rules-as-skills ~/.skills/rules-as-skills
ln -sfn ~/.skills/rules-as-skills ~/.claude/skills/rules-as-skills
```

### Activate the Protocol

rules-as-skills is a **Protocol Skill** — installing the repo gives you the methodology, but the global hard-constraint protocol is activated by a one-time setup script:

```bash
./scripts/install-meta-rule.sh install
```

This detects your installed agents (Claude Code, Codex, and experimentally Cursor / Windsurf / OpenClaw) and injects a meta-rule into each platform's global rule file. From that point on, **any skill whose name ends with `-rules`** is treated as a MUST-level hard constraint — load-before-act, not advisory.

One installation covers every current and future `*-rules` skill. No per-skill deployment. Revoke any time with `./scripts/install-meta-rule.sh uninstall`.

### Usage

> "Create a rule-skill for database access. Constraints: MUST use parameterized queries, NEVER write raw SQL, MUST close connections in finally blocks."

The agent applies the three-layer model, uses the `-rules` naming convention, structures MUST/NEVER statements with rationale, and pairs with any existing capability skill.

## When to Use

| Scenario | Mechanism |
|----------|-----------|
| Universal engineering rule (any project) | General spec (README, CONTRIBUTING) |
| Single-file / single-module scope | 5-10 line comment at top of file |
| Short, universal runtime constraint (<10 lines) | Traditional rule file |
| Domain-specific, complex constraints | Rule-skill |
| Needs cross-platform portability | Rule-skill |
| Critical + must not be missed | Rule-skill (meta-rule protocol covers fallback) |
| Already enforced by code | Neither |

## How It Works

### The Three-Layer Model

```
Layer 1 — Description      MUST/NEVER summary (always visible, ~2% context cost)
Layer 2 — Body             Detailed rules (loaded on demand when relevant)
Layer 3 — Meta-Rule        Global protocol: any *-rules skill is hard MUST-level
                           (one-time install, covers all -rules skills)
```

- The agent always sees the constraint **exists** (Layer 1 — cheap)
- Full rules load only when **relevant** (Layer 2 — efficient)
- The `-rules` suffix carries **MUST-level authority** globally (Layer 3 — meta-rule protocol, installed once via `scripts/install-meta-rule.sh`, covers every `*-rules` skill on the machine)

### Passive vs Active Skills

- **Skills** are **active abilities** — triggered explicitly ("forge this skill", "review my code")
- **Rule-skills** are **passive abilities** — always present in the background, automatically constraining behavior when their domain becomes relevant

A capability skill teaches *how*. A rule-skill ensures *correctly*.

### Proven in Production

6+ rule-skills running in production across multi-agent orchestration projects. Key patterns that emerged:

1. **Pre-Action Reading** — "MUST read rules BEFORE acting" forces full constraint loading before action
2. **MUST/NEVER Duality** — every prohibition has a positive counterpart, reducing ambiguity
3. **Immutability Marking** — rule-skills mark themselves as non-modifiable, preventing self-modification loops
4. **Capability + Constraint Pairing** — `browser-hygiene` (teaches) + `browser-rules` (enforces) work together

## Works Best With

| Skill | Why |
|-------|-----|
| [Skill-Forge](https://github.com/motiful/skill-forge) | Publish your rule-skills as installable repos with one command |
| [Self-Review](https://github.com/motiful/self-review) | Auto-discovers patterns worth turning into rule-skills |
| [Memory-Hygiene](https://github.com/motiful/memory-hygiene) | Reference implementation — a constraint skill built with this pattern |

## What's Inside

```
├── SKILL.md                         — Three-layer methodology + platform adaptation
├── scripts/
│   └── install-meta-rule.sh         — One-time global protocol activator
└── references/
    ├── anatomy.md                   — Structural guide for building rule-skills
    ├── decision-tree.md             — Decision framework: rules vs rule-skills
    └── meta-rule-content.md         — Canonical meta-rule text (injection source)
```

## Contributing

Open an issue or pull request on [GitHub](https://github.com/motiful/rules-as-skills). Bug reports, new production patterns, and platform adaptation improvements are welcome.

## License

MIT

---

Forged with [Skill Forge](https://github.com/motiful/skill-forge) · Crafted with [Readme Craft](https://github.com/motiful/readme-craft)

[license-shield]: https://img.shields.io/github/license/motiful/rules-as-skills.svg
[license-url]: https://github.com/motiful/rules-as-skills/blob/main/LICENSE
[skills-shield]: https://img.shields.io/badge/Agent%20Skills-compatible-blue
[skills-url]: https://agentskills.io
