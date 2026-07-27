# Community targeting reference

Read this before writing the query plan. Resolving communities first is what
separates "searched all of Reddit and got noise" from "read the three places
where this topic actually lives".

Adapted from upstream Steps 0.45 and 0.55, trimmed to what this profile runs.

## 1. Screen the topic first (cheap, one turn)

Some topics are doomed before the engine starts. Catch them upfront - a bad run
costs minutes and returns junk.

**Tutorial phrasing.** "how to use X", "what is Y", "tutorial for Z". Social
posts don't talk that way. Nobody writes "how to use Docker"; they write "my
Docker setup", "tip for folks on Compose". Reframe to discussion vocabulary:
`Docker tips workflows production setups`.

**Bare common noun.** `coffee`, `sneakers`, `agents`. No anchor, infinite
corpus, pure noise. Ask which facet the user means before running.

**Stray numbers.** A number in the topic dominates retrieval and drags in
unrelated content ("42" pulls jersey and Hitchhiker's posts). Strip it unless
it's part of the name - "GPT-4" keeps it, "40 year old" drops it.

**Non-English topic.** Reddit, Hacker News and GitHub are English-dominant. A
topic written in Russian, Hebrew, Chinese etc. scores near-zero entity matches
and returns English noise as padding. **Search in English even when the user
asked in another language** - resolve the topic to its English name, run the
research in English, then write the answer back in the user's language. Say so
in one line when you do it.

If the topic trips one of these, say so in one line and either reframe it or
ask one narrowing question - before calling the engine, not after.

## 2. Resolve subreddits before planning

Run 1-2 WebSearches, not one per platform:

```
WebSearch("{TOPIC} subreddit reddit community")
WebSearch("{TOPIC} {CURRENT_MONTH} {CURRENT_YEAR}")
```

Take 3-5 subreddit names from the results. Split them:

- **Dedicated** - the sub exists *for* this topic (`r/ClaudeAI` for Claude,
  `r/SunoAI` for Suno). Pass via `--dedicated-subreddits`. The engine pulls
  these in full and skips the relevance floor, so an on-topic post that doesn't
  repeat the product name in its title still survives.
- **Broad** - mixed communities where the topic sometimes comes up
  (`r/artificial`, `r/SaaS`). Pass via `--subreddits`. These stay filtered.

Label conservatively. Most topics have 0-3 dedicated subs; when unsure, call it
broad.

## 3. Add category peers (this is the step that gets skipped)

Brand-specific subreddits are not enough. The cross-product communities are
where technique discussion actually happens - and that's where the content
angles are.

Upstream's documented failure: a run on "Prompting GPT Image 2" resolved
`r/OpenAI, r/ChatGPT, r/singularity, r/ChatGPTpromptengineering` - all
OpenAI-brand - and completely missed `r/StableDiffusion, r/midjourney,
r/dalle2, r/aiArt`, where people actually trade prompting technique. The user
had to manually ask "check image generation reddits too".

| Category | Triggers | Peer subs (priority order) |
|---|---|---|
| `ai_coding_agent` | Claude Code, Cursor, Copilot, Windsurf, Aider, Cline, Devin | `ChatGPTCoding, LocalLLaMA, singularity, PromptEngineering` |
| `ai_agent_framework` | agent framework, LangChain, LangGraph, CrewAI, AutoGen, LlamaIndex | `LangChain, LocalLLaMA, AI_Agents, MachineLearning` |
| `ai_chat_model` | GPT-5, Claude Opus/Sonnet, Gemini, Llama, DeepSeek, Qwen, Mistral, Grok | `LocalLLaMA, ChatGPT, ClaudeAI, singularity, artificial` |
| `ai_image_generation` | image generation, text to image, Midjourney, Stable Diffusion, DALL-E, Flux, Ideogram | `StableDiffusion, midjourney, dalle2, aiArt, PromptEngineering, MediaSynthesis` |
| `ai_video_generation` | video generation, text to video, Sora, Veo, Runway, Kling, Pika, Luma | `aivideo, StableDiffusion, runwayml, singularity, MediaSynthesis` |
| `ai_music_generation` | music generation, ai music, Suno, Udio, Riffusion | `SunoAI, udiomusic, aimusic, artificial` |
| `saas_productivity` | Notion, Obsidian, Linear, ClickUp, productivity app | `productivity, SaaS, ObsidianMD, Notion` |

**Merging:** start with what WebSearch returned, append 2-3 peers in priority
order, dedupe case-insensitively, cap at 10 total. If the cap bites, keep the
WebSearch results (freshest signal) and drop peers from the end.

**Not in the table?** Same spirit: pick the 2-3 most active cross-product
communities where technique gets discussed. A brand-new image tool still gets
`r/StableDiffusion, r/midjourney, r/aiArt`.

## 4. YouTube queries

Infer 2-3 content-type queries; don't search for them.

- products/tools: `{TOPIC} review`, `{TOPIC} tutorial`
- comparisons: `{A} vs {B}`
- workflows: `{TOPIC} workflow`, `{TOPIC} setup`

## Report what you resolved

One line before the findings, so the targeting is visible and correctable:

```
Resolved: r/ClaudeAI, r/ChatGPTCoding, r/LocalLLaMA (+ ai_coding_agent peers)
```
