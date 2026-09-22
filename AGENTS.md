# isalikov — personal CV website

Instructions for any AI coding agent working in this repository (Claude Code, Codex, Cursor,
Gemini CLI, Copilot, …). Claude Code reads this file through `CLAUDE.md`; other tools read
`AGENTS.md` directly.

Personal website built with [Astro](https://astro.build). The site is a CV: who I am,
experience, skills, education, contacts. Static output, content-first, fast, printable.

## Hard rules

1. **Never run git commands.** No status, add, commit, diff, log, push, nothing.
   The owner handles all version control by hand.
2. **After every code change, end the reply with a suggested commit message.**
   The message must cover **all uncommitted changes in the working tree**, not just the last step:
   everything edited or created during the session plus files already untracked or modified
   when the session started (agents cannot run git, so keep track as you go).
   Format: Conventional Commits (`feat:`, `fix:`, `style:`, `refactor:`, `content:`, `chore:`, `docs:`).
   One-line subject (≤ 72 chars), optional short body. Put it in a fenced code block under
   a line that says `Suggested commit:`.
3. **Never run build or test commands.** No `astro build`, `npm run build`, `vitest`, `playwright`, etc.
   The only verification allowed is **typecheck**: `mise run check` (= `pnpm astro check`)
   and/or `pnpm tsc --noEmit`.
4. **Never start the dev server.** No `astro dev`, `astro preview`, `pnpm dev`, `mise run dev`, `mise run preview`.
   The owner runs it locally and reports what they see. Instead, tell the owner exactly what
   route, viewport or print preview to look at and what "correct" looks like.

If a command is blocked or not allowed, do not look for a workaround. Explain what you wanted
to check and ask the owner to run it.

## Stack & conventions

- Astro (latest stable), TypeScript strict, static output (`output: 'static'`).
- Toolchain: Node.js (latest LTS) and pnpm (latest) are managed by [mise](https://mise.jdx.dev)
  via `mise.toml`; resolved versions are pinned in `mise.lock`. Run `mise install` once.
  Use `pnpm` for everything; never `npm`, `yarn`, `bun` or `npx`. Do not install packages unless the owner asks.
- CV data lives in content collections (`src/content/`) or typed data files (`src/data/`),
  never hard-coded inside components. Components render data; they do not own it.
- Zero client-side JavaScript by default. Add a framework island only when interaction truly
  needs it, and say so in the reply.
- Styling: scoped `<style>` in `.astro` files plus CSS custom properties defined once in a
  global stylesheet. Support light/dark via `prefers-color-scheme` and a print stylesheet
  (a CV must print cleanly to one or two A4 pages).
- Accessibility: semantic landmarks, one `<h1>`, real links for contacts, visible focus states.
- SEO: `<title>`, meta description, canonical URL, Open Graph tags, `JSON-LD` `Person` schema.

## CV writing rules

- Bullets start with a strong verb, past tense (present for the current role). One idea per bullet,
  with an outcome or number where honest.
- No first-person pronouns, no buzzword lists, no "responsible for". 3–5 bullets per role.
- Never invent facts. Leave a `TODO` marker and say so if a date or number is missing.

## Workflow for a typical change

1. Read the closest existing file (component, layout, or content entry) and match its shape.
2. Make the change.
3. Run typecheck (rule 3). Report errors as `file:line` with a plain-words meaning.
4. Tell the owner what to look at in the dev server.
5. End with the suggested commit message (rule 2).

## Detailed guides

Step-by-step guides live in `.claude/skills/*/SKILL.md`. They are plain Markdown and apply to
any agent; read the relevant one before starting:

- `.claude/skills/cv-content/SKILL.md` — add or edit CV data (schema, writing rules).
- `.claude/skills/astro-component/SKILL.md` — components, layouts, pages, print and dark mode.
- `.claude/skills/typecheck/SKILL.md` — the only allowed verification and how to read its output.
- `.claude/skills/commit-message/SKILL.md` — commit message format and types.

## Tool-specific notes

- **Claude Code**: `CLAUDE.md` imports this file. Rules 1, 3 and 4 are enforced by a
  PreToolUse hook and permission rules in `.claude/settings.json`; rule 2 by a Stop hook.
  The guides above are also available as slash commands (`/cv-content`, `/astro-component`,
  `/typecheck`, `/commit-message`).
- **Other agents**: nothing is enforced mechanically. Follow the rules as written.
