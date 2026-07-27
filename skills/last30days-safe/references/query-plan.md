# Query plan reference

Read this before any normal (non-discovery) run. You write the plan; the engine
skips its internal planner when you pass `--plan`.

Adapted from upstream Step 0.75 for this profile's constrained source set.

## Why it matters

Without `--plan` the engine falls back to a deterministic planner meant for
headless/cron use. You are the reasoning model - you have context the fallback
does not. Upstream documents the delta: a bare run on "Kevin Rose" returned 55
items with roughly zero about the actual Digg founder, until every subquery was
anchored to "Digg founder". Same topic, same model, same cache - the only
difference was the plan.

## Shape

```json
{
  "intent": "concept",
  "freshness_mode": "evergreen_ok",
  "cluster_mode": "none",
  "subqueries": [
    {
      "label": "primary",
      "search_query": "claude code subagents",
      "ranking_query": "What are people actually doing with Claude Code subagents?",
      "sources": ["reddit", "hackernews", "youtube"],
      "weight": 1.0
    },
    {
      "label": "friction",
      "search_query": "claude code subagents problems limits",
      "ranking_query": "What breaks or frustrates people about Claude Code subagents?",
      "sources": ["reddit", "hackernews"],
      "weight": 0.8
    },
    {
      "label": "reactions",
      "search_query": "claude code subagents review workflow",
      "ranking_query": "How are creators demoing and reviewing Claude Code subagents?",
      "sources": ["youtube", "reddit"],
      "weight": 0.6
    }
  ]
}
```

Write it to a tmpfile and pass the path - never inline the JSON on the command
line (an apostrophe in any query string breaks shell parsing):

```bash
PLAN_FILE=$(mktemp "${TMPDIR:-/tmp}/last30days-plan.XXXXXX")
trap 'rm -f "$PLAN_FILE"' EXIT
cat >| "$PLAN_FILE" <<'PLAN_EOF'
{PLAN_JSON}
PLAN_EOF
scripts/find-ideas.sh "$TOPIC" --plan "$PLAN_FILE"
```

## Rules

- 1 to 4 subqueries. Simple topic - fewer. Multi-faceted - more.
- **The primary subquery carries every source this profile allows:
  `["reddit", "hackernews", "youtube"]`.** (Upstream requires x/tiktok/instagram
  here too; this profile does not run them. Add a source only when the user
  explicitly turned it on for this run.)
- `search_query`: short, keyword-heavy, phrased the way content is *titled*.
- `ranking_query`: a natural-language question.
- **Anchor collision-prone names in EVERY subquery, not just the primary** -
  and mirror the anchor in `ranking_query`. `"tella screen recording"` not
  `"tella"`; `"kevin rose digg founder"` not `"kevin rose"`. Skip the anchor
  only when the name is globally unambiguous (Nvidia, Kanye West).
- Never put time words in `search_query`: no "last 30 days", "recent", month
  names, year numbers.
- Never put meta-research words in it either: no "news", "updates".
- Keep proper nouns exactly as the user wrote them.
- Weights: primary 1.0, secondary 0.6-0.8, peripheral 0.3-0.5.

## For idea scouting specifically

The default three subqueries that earn their keep:

| label | what it finds | why you want it |
|---|---|---|
| `primary` | the topic itself | is anyone talking about this at all |
| `friction` | complaints, limits, "doesn't work" | the tension a video is built on |
| `reactions` | reviews, demos, workflows | what angle is already saturated |

Route by intent: product topics lean YouTube (reviews) and Reddit
(discussion); how-to topics lean YouTube (tutorials) and Reddit (guides);
concept topics lean Reddit and Hacker News.

## intent → modes

| intent | freshness_mode | cluster_mode |
|---|---|---|
| breaking_news | strict_recent | story |
| prediction | strict_recent | market |
| comparison, opinion | balanced_recent | debate |
| how_to | evergreen_ok | workflow |
| concept | evergreen_ok | none |
| everything else | balanced_recent | none |
