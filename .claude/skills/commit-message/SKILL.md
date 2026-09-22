---
name: commit-message
description: Produce the Conventional Commits message for the changes made in this session. Use at the end of every task that touched files, or when the owner asks "commit message?". Works from your own record of what you edited — never runs git.
---

# Commit message

You cannot inspect the working tree with git. Work from the files you created or edited in this
conversation. If you are unsure whether something changed, say so rather than guess.

## Format

```
<type>(<scope>): <subject>

<body — optional, 1–3 lines, what and why, not how>
```

- **type**: `feat` new section/capability · `fix` bug · `style` visual only, no behaviour change ·
  `refactor` structure without visible change · `content` CV text/data edits · `chore` tooling,
  deps, config · `docs` README/AGENTS.md · `perf` · `a11y` accessibility · `seo`
- **scope** (optional): the area — `experience`, `layout`, `print`, `head`, `theme`, `content`, `claude`.
- **subject**: imperative mood, lower-case, no trailing period, ≤ 72 characters including type and scope.
- One logical change per message. If this session made two unrelated changes, offer two messages
  and say which files belong to each.

## Output

End the reply with exactly this shape so the Stop hook recognises it:

Suggested commit:

```
content(experience): add 2024 platform-team role at ACME

Three bullets on the migration to Astro islands and the p95 latency work.
```

No attribution trailers unless the owner asks for them.
