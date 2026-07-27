# last30days-safe

A narrower, safer operating profile for [`last30days`](https://github.com/mvanhorn/last30days-skill) — tuned for **content idea scouting** instead of open-ended research.

Same engine. Different defaults.

## Why

`last30days` is a powerful research skill: it can fan out across Reddit, X, YouTube, TikTok, Instagram, Hacker News, Polymarket, GitHub and more. That breadth is great for deep research and heavy for a simple question:

> Is this topic actually alive right now, and is it worth making content about?

This profile answers that question and stops there. It keeps the engine, narrows the defaults, and asks for a compact answer you can act on — rather than a sprawling report you still have to read.

## What changes

| | upstream `last30days` | `last30days-safe` |
|---|---|---|
| Sources | broad fan-out, many optional | `reddit,hackernews,youtube` |
| Window | 30 days | 7 days |
| Register | default | `creator` |
| Browser cookies | available | **off** unless you ask |
| Output | full research report | verdict + angles + audience language |
| Entry point | engine directly | `find-ideas.sh` wrapper |

Higher-friction or credentialed sources (X via browser cookies, TikTok, Instagram, LinkedIn, Pinterest) stay off unless you explicitly turn them on. Every default is an override, never a lock — pass any upstream flag and it wins.

## Install

**Claude Code:**

```bash
/plugin marketplace add kohtabeloff/last30days-safe-profile
```

then

```bash
/plugin install last30days-safe
```

The engine is bundled — nothing else to install. It is pure Python with no third-party dependencies; you just need **Python 3.12 or newer**. The wrapper finds a suitable interpreter on its own, or you can point it at one with `LAST30DAYS_PYTHON`.

This installs as `last30days-safe`, so it sits alongside the upstream `last30days` plugin without conflicting. You can run both.

## Usage

```bash
scripts/find-ideas.sh "AI agent workflows"
```

Override anything when you mean to:

```bash
scripts/find-ideas.sh "AI video avatars" --search reddit,youtube
scripts/find-ideas.sh "personal AI brand" --days 14
scripts/find-ideas.sh --discover "AI creators"
```

The intended sequence is:

```
x_search  ->  last30days-safe  ->  web spot-check
```

Fresh pulse first, community depth second, web only to verify specific claims.

## Output shape

```md
Verdict: worth exploring - signal is real, but still early.

- People are not just asking about the tool. They are asking how to get actual output from it.
- Repeated tension: the promise sounds powerful, but setup/consistency still feels messy.
- Best hook: show a concrete before/after workflow instead of generic hype.

Audience language:
- "looks cool but what do I actually use it for?"
- "show me the workflow, not the pitch"

Content angles:
- 3 real workflows people actually care about
- where the hype is true vs fake
```

Not YouTube-only, despite the examples — the same read works for shorts, newsletters, posts, or anything else you're deciding whether to make.

## Updating the engine

The upstream engine is vendored under `skills/last30days-safe/scripts/`. To pull a newer version:

```bash
scripts/sync-upstream.sh          # track upstream main
scripts/sync-upstream.sh v3.19.0  # track a specific tag
```

It replaces only upstream-owned files and leaves `SKILL.md` and `find-ideas.sh` alone.

## Credits

The research engine is [`last30days`](https://github.com/mvanhorn/last30days-skill) by **Matt Van Horn**, MIT licensed, vendored here unmodified (minus demo media). All the hard parts are his.

This repository adds the operating profile (`SKILL.md`) and the wrapper (`find-ideas.sh`). If you want the full-power version, install upstream — this one is deliberately smaller.

MIT. See [LICENSE](LICENSE).
