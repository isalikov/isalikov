# Contributing

This is a personal CV website built with [Astro](https://astro.build). The toolchain is
managed by [mise](https://mise.jdx.dev), so you never install Node.js or pnpm by hand.

## Prerequisites

Install mise once (see the [getting-started guide](https://mise.jdx.dev/getting-started.html)):

```sh
curl https://mise.run | sh
```

Then activate it in your shell so it can switch tool versions per directory. For zsh:

```sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
```

Restart the shell. `mise doctor` should report no problems.

## Setup

```sh
git clone <this repo>
cd isalikov
mise trust        # allow mise to read this repo's mise.toml
mise install      # installs Node.js and pnpm at the versions pinned in mise.lock
mise run install  # pnpm install --frozen-lockfile
```

Inside the repository directory, `node` and `pnpm` now resolve to the mise-managed versions.
Outside it, your global tools are untouched.

## How mise is used here

- `mise.toml` declares the tools and the project tasks.
  - `node = "lts"` — the current Node.js LTS line.
  - `pnpm = "latest"` — the current stable pnpm.
- `mise.lock` pins the exact versions those specs resolved to, so every machine and CI run
  uses the same toolchain. It is committed.
- `mise.local.toml` is git-ignored. Use it for personal overrides such as a different Node
  version or extra environment variables.

Check what is active:

```sh
mise ls --current
```

Upgrade the toolchain (updates `mise.lock`; commit the result):

```sh
mise upgrade
```

## Tasks

Run tasks with `mise run <name>` (or `mise r <name>`). List them with `mise tasks`.

| task      | runs                            | notes                                   |
|-----------|---------------------------------|-----------------------------------------|
| `install` | `pnpm install --frozen-lockfile` | after cloning or when the lockfile changes |
| `check`   | `pnpm astro check`              | typecheck; the only verification AI agents may run |
| `dev`     | `pnpm astro dev`                | local dev server with hot reload        |
| `preview` | `pnpm astro preview`            | serve the production build locally      |
| `build`   | `pnpm astro build`              | production build into `dist/`           |

`pnpm-workspace.yaml` holds pnpm settings, notably which packages may run install scripts
(`allowBuilds`); pnpm 10+ blocks all others. Use `pnpm` for everything package-related. Do not use `npm`, `yarn`, `bun` or `npx`;
mixing package managers corrupts the lockfile.

## Making changes

1. Content (experience, education, skills, contacts) lives in `src/content/` and `src/data/`.
   Components in `src/components/` only render that data.
2. Follow the conventions in [AGENTS.md](AGENTS.md): zero client-side JavaScript by default,
   scoped styles with shared CSS custom properties, light/dark and print support,
   semantic HTML, SEO metadata.
3. Run `mise run check` before committing. Zero errors is the bar.
4. Start `mise run dev` and look at the page in a normal viewport, a narrow one, and in the
   browser's print preview. The CV must fit one or two A4 pages when printed.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

Types used here: `feat`, `fix`, `style`, `refactor`, `content`, `chore`, `docs`, `perf`, `a11y`, `seo`.
Subject in imperative mood, lower-case, no trailing period, at most 72 characters in total.

## Working with AI coding agents

Agent instructions are in [AGENTS.md](AGENTS.md) (Claude Code loads it through `CLAUDE.md`).
Agents do not run git, do not build or test, do not start the dev server, and end every
change with a suggested commit message. Those rules are enforced for Claude Code by hooks in
`.claude/settings.json`; for other tools they are conventions. Step-by-step guides for common
tasks are in `.claude/skills/*/SKILL.md` and are plain Markdown any tool can read.
