---
name: last30days-safe
version: "3.18.3-pavel-safe"
description: "Use when you want recent community signal for YouTube idea scouting, but in a narrower, safer default mode than the upstream last30days skill. Optimized for Pavel's AI/creator/personal-brand workflow inside Hermes."
author: Pavel Belov + Agent Smith
license: MIT
homepage: https://github.com/kohtabeloff/last30days-safe-profile
repository: https://github.com/kohtabeloff/last30days-safe-profile
upstream: https://github.com/mvanhorn/last30days-skill
user-invocable: true
metadata:
  hermes:
    tags: [research, youtube, ideation, x, reddit, hackernews, trends, creator]
    related_skills: [community-skill-hardening, hermes-agent]
---

# last30days - Pavel safe ideation profile

## Overview

This is a hardened adaptation of the upstream `last30days` community skill.

It keeps the core idea - recent, real-world signal from social/web sources - but changes the default operating mode for a specific workflow:

- YouTube idea scouting
- AI / creator / personal-brand topics
- short time horizon
- compact output
- safer defaults
- no broad "turn on everything" behavior by default

The point of this version is simple: **make `last30days` useful for ideation without making it sprawl into a giant general-purpose research monster every time it runs.**

## What is different from upstream

This version intentionally changes the default posture.

Upstream `last30days` is broad. It can fan out across many sources, many modes, and many setup paths.

This version is narrower:

1. **Primary use case is YouTube idea discovery, not generic deep research.**
2. **Default source set is constrained.**
3. **Browser cookie access is off by default.**
4. **Short-window creator-style output is preferred.**
5. **The safe wrapper is the default path.**
6. **X is best used as a first-pass signal outside this skill, then `last30days` is used to deepen or validate the topic.**

## When to use

Use this skill when you want to:

- find promising recent topics for YouTube videos
- check whether a theme has real community traction
- collect audience language people actually use
- pressure-test a content angle before scripting
- enrich a topic that first appeared in X search
- get a compact "is this worth making content about?" read

## When NOT to use

Do **not** use this as the default tool when:

- you only need a fresh X pulse - use `x_search` first
- you need a classic evergreen web research answer
- you need deep competitor teardown across many optional sources
- you need browser-cookie-based collection
- you want a fully open-ended broad research sweep

## Default workflow

For this profile, the preferred sequence is:

1. **Use `x_search` first** to catch fresh signal.
2. **Use this skill second** to deepen, validate, and collect community language.
3. **Use web only last** for spot-checking specific claims, launches, dates, or product pages.

Short version:

`x_search -> last30days -> web spot-check`

## Safe defaults

Unless explicitly overridden, this version assumes:

- sources: `reddit,hackernews,youtube`
- lookback window: `7 days`
- register: `creator`
- browser cookies: `off`
- output style: compact, idea-friendly

Optional higher-friction or higher-risk sources stay off by default unless explicitly requested.

That includes things like:

- X via browser-cookie paths
- TikTok
- Instagram
- LinkedIn
- Pinterest
- extra credentialed providers
- broad social expansion just because it is available

## Default command path

The safe entrypoint should be a wrapper script, not a raw direct call.

Expected wrapper:

```bash
scripts/find-ideas.sh "<topic>"
```

Expected wrapper behavior:

- inject safe defaults if they were not manually passed
- keep browser cookies disabled
- preserve the ability to override flags when explicitly needed
- avoid changing discovery mode behavior unless explicitly requested

The wrapper ships with this skill at `scripts/find-ideas.sh`. It picks a Python 3.12+
interpreter automatically (override with `LAST30DAYS_PYTHON`), then calls the bundled
engine at `scripts/last30days.py` with the safe defaults above.

## Reference files

This file stays short on purpose. The heavy detail lives next to it and is
read on demand:

| File | Read it when |
|---|---|
| `references/communities.md` | before planning any run - topic screening, subreddit resolution, category peers |
| `references/query-plan.md` | before every normal run - the `--plan` schema and rules |
| `references/discovery-protocol.md` | before any `--discover` run - the three-leg protocol |
| `references/save-html-brief.md` | only when the user asks for a saved HTML brief |

Read the first three when the run needs them, not preemptively - but do not
skip them to save a step. They are where the quality difference lives.

## Operational rules for the agent

If the agent loaded this skill, follow these rules:

1. **Do not run onboarding/setup by default.**
   Assume the environment is already configured unless the user explicitly asks to troubleshoot setup.

2. **Do not ask for browser cookie access by default.**
   Keep browser-cookie-based collection off unless the user explicitly requests it.

3. **Use the wrapper, not the raw engine, for normal idea scouting.**
   Prefer:

   ```bash
   scripts/find-ideas.sh "topic"
   ```

   Not:

   ```bash
   python3 scripts/last30days.py "topic"
   ```

4. **YOU are the planner. Pass `--plan` on every normal run.**
   You are the reasoning model - the engine's internal planner is the
   headless/cron path. A run without `--plan` is a downgraded run, and the
   engine says so in its log. Schema, rules and the tmpfile pattern:
   `references/query-plan.md`.

5. **Resolve communities before you plan.**
   Screen the topic for keyword traps, find the 3-5 subreddits where it
   actually lives, and add category peers - brand-only subs miss where
   technique gets discussed. Non-English topics get researched in English and
   answered in the user's language. Method and category table:
   `references/communities.md`.

6. **Discovery is three commands, never one.**
   On any `--discover` run you are the judge: nominate, judge, finalize with
   your angles. A one-shot run generates no content angles at all - which is
   the whole deliverable. Protocol: `references/discovery-protocol.md`.

7. **Treat this as a second-pass enrichment tool, not the first sensor.**
   If the user wants fresh momentum, start with X search.

8. **Keep the output compact and useful for content decisions.**
   Focus on:
   - what people are reacting to
   - what language they use
   - what tension/problem/opportunity appears repeatedly
   - whether the topic feels alive enough for content

9. **Quote the community verbatim; never narrate the tooling.**
   The evidence carries a `## Top Community Comments` block - real
   vote-ranked comments with author and URL. Weave at least two of them in
   as actual quotes, attributed (`u/name`), inside the narrative rather than
   in a separate section. A top comment with thousands of votes outranks its
   parent post. Copy comment URLs verbatim, never reconstruct one. And keep
   engine mechanics out of the deliverable - no "the engine struck out", no
   "the source came back empty"; report what is true about the topic and drop
   the junk quietly.

10. **Do not broaden sources just because results are thin.**
    First report thin evidence honestly. Expand only if the user asks.
    Widening the *window* is different and allowed: on a thin run, or on an
    evergreen topic where steady demand matters more than this week's spike,
    re-run with `--days 30` and say why. Seven days answers "what is hot now";
    thirty answers "what stays worth making".

11. **Web is for validation, not replacement.**
    Use web only to confirm specific details after community signal has surfaced.

## Output shape

For this profile, the best output is not a giant report.

Preferred shape:

- **1 line:** verdict on whether the topic looks alive
- **3 to 5 bullets:** strongest recurring angles or audience pains
- **1 short block:** actual phrasing / language people use
- **1 short block:** content angle suggestions
- **1 short block:** what to check next if needed

Good example:

```md
Verdict: worth exploring - signal is real, but still early.

- People are not just asking about the tool. They are asking how to get actual output from it.
- Repeated tension: the promise sounds powerful, but setup/consistency still feels messy.
- Best hook: show a concrete before/after workflow instead of generic hype.
- The audience reacts more to use cases and proof than to feature lists.

Audience language:
- "looks cool but what do I actually use it for?"
- "does this save time or just add another layer?"
- "show me the workflow, not the pitch"

Content angles:
- 3 real workflows people actually care about
- where the hype is true vs fake
- what breaks when you try to use it for real

Next check:
- verify whether the biggest claim is driven by X chatter only or also repeated on Reddit/YouTube
```

## Suggested commands

### Safe default

```bash
scripts/find-ideas.sh "AI agent workflows"
```

### Override source set on purpose

```bash
scripts/find-ideas.sh "AI video avatars" --search reddit,youtube
```

### Widen the window on purpose

```bash
scripts/find-ideas.sh "personal AI brand" --days 14
```

### Discovery mode

If using discovery mode, do not force the normal scouting defaults onto it unless you intentionally want that.

Discovery runs as three commands, not one - see `references/discovery-protocol.md`.
The first leg is:

```bash
scripts/find-ideas.sh --discover --nominate-only --save-dir="$MEMORY_DIR"
```

## Common pitfalls

1. **Using this skill before X search when the user asked for freshest ideas.**
   That loses speed. X should usually be first.

2. **Calling the raw engine directly for normal ideation.**
   That bypasses the safe profile defaults.

3. **Expanding into extra sources because the first run was weak.**
   Thin evidence is a valid result. Do not hide it with scope creep.

4. **Treating this like a final research report generator.**
   For this profile, it is primarily a topic filter and angle extractor.

5. **Using web as the primary source.**
   That defeats the point of recent community signal.

6. **Turning on browser-cookie paths by default.**
   Keep them off unless explicitly requested.

7. **Running without `--plan` and reading the engine's warning as a missing key.**
   The engine says "no LLM provider configured" and means "the model skipped
   its own planning step". You are the provider. Write the plan.

8. **Running `--discover` as a single command.**
   It returns topic names with no content angles. Run the three-leg protocol.

9. **Searching a non-English topic in its own language.**
   The sources are English-dominant; the run returns padding. Research in
   English, answer in the user's language.

## Verification checklist

- [ ] Wrapper script exists at `scripts/find-ideas.sh`
- [ ] Wrapper injects safe defaults only when they were not manually overridden
- [ ] Browser cookies stay off by default
- [ ] Default source set is constrained
- [ ] Normal runs carry `--plan` with resolved subreddits
- [ ] Discovery runs use the three-leg protocol, with one shared `--save-dir`
- [ ] At least two verbatim community comments appear in the output
- [ ] A live query returns compact output
- [ ] The output is useful for content decisions, not bloated research theater
- [ ] The workflow remains `x_search -> last30days -> web spot-check`

## Maintainer note

This file is not meant to replace the upstream project.

It is meant to provide a **GitHub-committable, user-specific operating profile** for the upstream project.

If you publish it, make that explicit:

- this is an adapted profile
- upstream engine belongs to `mvanhorn/last30days-skill`
- this version changes defaults for a narrower workflow
- the wrapper script is part of the intended behavior
