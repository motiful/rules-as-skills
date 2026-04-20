---
name: meta-rule-content
description: The canonical meta-rule text injected into each agent's global rule file by install-meta-rule.sh. Declares MUST-level hard-constraint treatment for any skill whose name ends with -rules. Single source of truth for the Layer 3 protocol content.
---

# Meta-Rule Content — Canonical Text for Injection

This file is the single source of truth for the meta-rule text that `scripts/install-meta-rule.sh` writes into each agent's global rule file.

## Injection Block

The installer writes the block between `<!-- rules-as-skills-meta:start -->` and `<!-- rules-as-skills-meta:end -->` markers (exact byte copy):

```markdown
<!-- rules-as-skills-meta:start -->
## Rule-Skill Hard-Constraint Protocol

Any skill whose name ends with `-rules` is a **MUST-level hard constraint**, not advisory:

- **Load priority**: highest among skills when the skill description matches the current context
- **Compliance**: MUST / NEVER statements in the body are binding — treat them with the same authority as platform-native rule files, not as suggestions
- **Proactive loading**: when trigger conditions in a `*-rules` skill description match the current task but the body has not been loaded yet, load it before acting
- **Authoring preference**: when creating a new hard constraint, prefer the rule-skill form (with `-rules` suffix) over adding new entries to traditional rule files — unless the constraint is universal and short (<10 lines)

This protocol is installed by [rules-as-skills](https://github.com/motiful/rules-as-skills) and applies to every `*-rules` skill on this machine, current and future.
<!-- rules-as-skills-meta:end -->
```

## Why This Format

- **Markers are HTML comments**: safe across markdown rendering, invisible in rendered docs, visible to scripts for idempotent append and clean uninstall
- **Single H2 heading**: predictable anchor if the host file has a TOC; low enough priority to not disrupt the host file's own structure
- **List-form rules**: each rule stands alone, easier for the agent to cite individually
- **Authoring preference included**: drives new hard constraints toward rule-skill form, reinforcing the protocol's reach

## Uninstall Contract

`install-meta-rule.sh uninstall` removes everything between the two markers inclusively. If markers are edited by the user, the uninstall is skipped with a warning — the user can remove manually.

## Do Not Edit Injected Copies

Once injected, agents and users should treat the block as read-only. To update the protocol text across all machines, edit this file and re-run `install-meta-rule.sh install --force` (which replaces the block between markers).

## Format Variants

Most platforms accept the markdown form above. Where a platform uses a different syntax, the installer wraps or transforms the content:

| Platform | Rule file format | Wrapping |
|----------|-----------------|----------|
| Claude Code | Markdown | Raw markdown (as above) |
| Codex | `.rules` plaintext | Markdown converted to plaintext bullets (headings flattened) |
| OpenClaw | `AGENTS-RULES.md` | Wrapped in `<rules>` XML tag after the start marker |
| Cursor | `.mdc` | Raw markdown |
| Windsurf | Markdown | Raw markdown |

Exact transformations are implemented in `scripts/install-meta-rule.sh`.
