---
name: astro-component
description: Create or refactor an Astro component, layout or page for the CV site. Use for anything visual or structural — sections, layout, styles, print stylesheet, dark mode, SEO head tags. Enforces zero-JS-by-default, scoped styles, typed props, and print-friendliness.
---

# Astro component

## Before writing

1. Read `src/layouts/` and two existing components in `src/components/` to match naming,
   prop style and CSS token usage. Do not introduce a second convention.
2. Check the global stylesheet (`src/styles/global.css` or similar) for existing custom
   properties. Reuse tokens; add new ones there, not inline.
3. Decide: does this need client JS? Default answer is no. A CV site needs none for
   navigation, theming (use `prefers-color-scheme` + optional `<html data-theme>`), or print.

## Component template

```astro
---
import type { HTMLAttributes } from 'astro/types';

interface Props extends HTMLAttributes<'section'> {
  title: string;
  /** Visually hide the heading but keep it for screen readers. */
  hideTitle?: boolean;
}

const { title, hideTitle = false, class: className, ...rest } = Astro.props;
const id = title.toLowerCase().replace(/\s+/g, '-');
---

<section aria-labelledby={id} class:list={['cv-section', className]} {...rest}>
  <h2 id={id} class:list={{ 'visually-hidden': hideTitle }}>{title}</h2>
  <slot />
</section>

<style>
  .cv-section {
    padding-block: var(--space-6);
    border-top: 1px solid var(--color-border);
  }
  h2 {
    font-size: var(--text-lg);
    margin-block-end: var(--space-3);
  }
  @media print {
    .cv-section { break-inside: avoid; padding-block: var(--space-3); }
  }
</style>
```

## Checklist for every component

- Props typed via `interface Props`; destructure with defaults; spread `...rest` onto the root element.
- Styles scoped in `<style>`; only tokens from the global sheet; logical properties (`margin-block`, `padding-inline`).
- Responsive without breakpoint soup: `clamp()`, `min()`, intrinsic grids (`repeat(auto-fit, minmax(...))`).
- `@media print` block: hide nav and decorative elements, avoid page breaks inside entries, show link URLs
  via `a[href^="http"]::after { content: " (" attr(href) ")"; }` where useful.
- Dark mode via tokens that flip under `@media (prefers-color-scheme: dark)`; never hard-coded colours.
- Semantic HTML: one `<h1>` per page, `<header>`, `<main>`, `<section aria-labelledby>`, `<address>` for contacts,
  `<time datetime="...">` for dates, `<ul>` for lists of roles or skills.
- Images through `astro:assets` `<Image>` with explicit `width`/`height` and `alt`.
- Page-level `<head>`: title, description, canonical, Open Graph, `application/ld+json` `Person` schema.

## After writing

1. Run `/typecheck`.
2. Do not start the dev server. Tell the owner exactly what to look at when they run it
   (route, viewport, print preview) and what "correct" looks like.
3. End with a suggested commit message (`feat:`, `style:`, `refactor:`, `fix:`).
