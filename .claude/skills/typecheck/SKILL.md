---
name: typecheck
description: Run the only permitted verification for this project — Astro's type checker (astro check) and optionally tsc --noEmit — and interpret the output. Use after any code or content change, and whenever the owner asks to "check", "verify" or "validate". Never runs build, test or dev.
---

# Typecheck

Build, test and dev-server commands are blocked by hooks. This is the one verification you may run.

## Run

Node and pnpm are managed by mise (`mise.toml`), so the toolchain is already on PATH inside
the repo. Run the mise task:

```
mise run check
```

It executes `pnpm astro check`. If mise is not active in the shell, `pnpm astro check` directly
is equivalent. Never use `npm`, `npx`, `yarn` or `bun`.

If `@astrojs/check` is not installed, `astro check` will say so; report that and stop —
do not install packages unless the owner asks. If `node_modules` is missing, tell the owner to
run `mise install && mise run install`; do not run installs yourself.

For non-Astro TypeScript files only (`src/data/*.ts`, utilities), you may additionally run
`pnpm tsc --noEmit -p tsconfig.json`.

Use a timeout of at least 120 s; the first run downloads the language server.

## Interpret

- Report **errors** first, each as `file:line` plus a one-line meaning in plain words.
- Content-collection schema errors (`InvalidContentEntryDataError`) mean an entry violates
  the zod schema in `src/content.config.ts`. Fix the entry, not the schema, unless the schema is wrong.
- `hints` and `warnings` about unused variables or `any` are worth fixing when they are in files you touched.
- Zero errors is the pass condition. Say so plainly: "Typecheck passed, N files, 0 errors."

## After

Fix what you can, rerun once, then end the reply with the suggested commit message.
Do not attempt `astro build` "to be sure". If you believe a runtime check is needed, ask the owner to
run the dev server and describe exactly what to look at.
