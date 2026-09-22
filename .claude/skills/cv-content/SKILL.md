---
name: cv-content
description: Add or edit CV data for the Astro site — experience entries, education, skills, projects, contacts, summary. Use when the owner wants to change what the CV says (not how it looks). Keeps data in typed content collections, never in components.
---

# CV content

You edit **data**, not markup. All CV facts live in `src/content/` (Astro content collections)
or `src/data/*.ts`. Components read from there.

## Workflow

1. Locate the collection: `src/content.config.ts` (or `src/content/config.ts`) defines the schemas.
   If none exists yet, propose one before writing entries (see "Default schema").
2. Read the existing entry that is closest to what you are adding and copy its shape exactly.
3. Write or edit the entry. Dates are ISO (`2024-03` or `2024-03-01`); an ongoing role has no `end`.
4. Run `/typecheck` — schema errors from `astro check` are the only verification allowed.
5. End the reply with a suggested commit message, prefix `content:`.

## Writing rules for CV text

- Bullet points start with a strong verb in past tense (present for the current role).
- One idea per bullet, with an outcome or number where honest: "Cut p95 latency from 800 ms to 120 ms".
- No first-person pronouns, no buzzword lists, no "responsible for".
- Keep each role to 3–5 bullets. The most recent role may have more.
- Do not invent facts. If a number or date is missing, leave a `TODO` marker and say so in the reply.

## Default schema (propose only if the project has none)

```ts
// src/content.config.ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const experience = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/experience' }),
  schema: z.object({
    company: z.string(),
    role: z.string(),
    location: z.string().optional(),
    start: z.string(),          // YYYY-MM
    end: z.string().optional(), // absent = present
    url: z.string().url().optional(),
    stack: z.array(z.string()).default([]),
    order: z.number().default(0),
  }),
});

const education = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/education' }),
  schema: z.object({
    institution: z.string(),
    degree: z.string(),
    start: z.string(),
    end: z.string().optional(),
  }),
});

export const collections = { experience, education };
```

Profile-level data (name, headline, summary, contacts, skills grouped by area) goes in
`src/data/profile.ts` as a single typed `export const profile = { ... } satisfies Profile`.
