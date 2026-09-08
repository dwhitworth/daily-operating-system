---
name: unslop-writing
description: Use whenever you compose human-facing prose destined for an external surface — Notion pages, Slack messages, 1:1 docs (Items Discussed / Action Items), emails, Showcase/Brag entries, showcase blurbs, or anything a person will read and paste. It is a "what to avoid" profile that strips AI-default phrasing so the output reads like a specific human wrote it. Do NOT apply to code, commit messages, or internal battle-card/journal shorthand.
---

# unslop-writing

Adapted from mshumer/unslop (`profiles/writing.md`). Philosophy: **remove the
repetitive defaults a model collapses toward — don't prescribe one new template.**
When you catch yourself reaching for any pattern below, stop and say it a different way.

Apply this quietly, at draft time. Don't announce that you applied it and don't
show the reader a checklist — just produce cleaner text.

## Phrases to never use (or close variants)

- "In today's [adjective] landscape/world/era" / "In an increasingly [adjective] world"
- "It's not just about X — it's about Y" / "This isn't just X — it's Z"
- "Here's the thing" / "Here's why that matters" / "The thing is"
- "Let's dive in" / "Let's unpack this" / "Let's dig into"
- "At its core" / "At the end of the day" / "The bottom line"
- "It's worth noting that" / "It goes without saying" / "Make no mistake"
- "This is where it gets interesting" / "This raises an important question"
- "The short answer is" / "To put it simply" / "In other words"
- "The good news is" / "The bad news is" / "But here's the catch"
- "Perhaps most importantly" / "The question isn't whether X, but Y"
- "That said," as a reflexive pivot on every paragraph

## Structure to avoid

- Don't open with a sweeping statement about the industry/world before getting to
  the point. Start with the actual thing.
- Don't use the "[Broad claim]. But [complication]. Here's [resolution]." arc.
- Don't end by restating the point in grander terms than it warrants.
- Don't default every piece to: hook → context → 3–5 sections → takeaway → CTA. Vary it.
- Don't add "Final thoughts," "Key takeaways," or "The future of X" sections.
- Don't use rhetorical questions as section transitions.
- Don't number points unless order actually matters.

## Tone to avoid

- Don't hedge on every claim ("might," "could potentially," "it remains to be seen").
  Commit, or drop the claim.
- Don't affect enthusiasm — not everything is "exciting," "fascinating,"
  "game-changing," or "transformative."
- Don't address the reader as "you" in every sentence.
- Don't write in false-authority voice where opinion sounds like settled consensus.
- Don't end paragraphs with a one-line dramatic kicker meant to sound profound.

## Punctuation

- **Avoid em-dashes (—).** They are a signature AI tell. Use a period, a comma, or
  a colon instead, or split into two sentences. If a pause genuinely needs marking,
  a comma or parentheses almost always works. This applies everywhere, not just prose.

## Words to stop leaning on

landscape, paradigm, leverage (verb), robust, seamless, ecosystem, holistic,
nuanced, compelling, innovative, crucial, essential, fundamental, delve/delve into,
navigate (as metaphor), unlock (as metaphor), "double-edged sword",
"at the intersection of X and Y", "a testament to", "in the realm of".

## House voice (positive direction) — rewrite this section for yours

The anti-slop list says what to remove; this says what the remainder should sound like.

- **Direct and specific.** Concrete nouns, real numbers, named people/tickets.
  "Alex shipped the Node-EOL spike (PROJ-1188)" beats "significant progress was made."
- **Pragmatic Chief-of-Staff register** — a peer in the foxhole, not a press release.
- **1:1 Notion docs** stay in the house format: **Items Discussed** (factual record of
  what was covered) and **Action Items** (owner + concrete next step). Tight bullets,
  no narrative padding, no private strategic reads. (Sentinel: see DOS/CLAUDE.md.)
- **Slack** — short, plain, no throat-clearing preamble. Lead with the ask or the fact.
- Prefer the shorter sentence. Cut the transition word if the two sentences already connect.

## Quick self-check before you hand text over

1. Does the first sentence say something real, or is it warming up?
2. Any phrase from the lists above? Rewrite it.
3. Could a specific human have written this, or is it the median of the internet?
4. Every hedge either committed or cut?

If you want a fresh, empirically-generated profile for a new surface (e.g. a specific
kind of report), run the upstream tool: `mshumer/unslop` → `python3 unslop.py --domain "<domain>"`,
then fold its `skill.md` findings into this file.
