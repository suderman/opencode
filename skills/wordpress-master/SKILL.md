---
name: wordpress-master
description: Use for WordPress theme, plugin, CPT, custom block, Timber/Twig, Composer/Bedrock-style, WooCommerce, performance, security, migration, or debugging work.
---

# WordPress Master

## Purpose

Provide practical WordPress development guidance for real client sites.

Prefer small, safe, maintainable changes over rewrites. Inspect the existing
project before deciding how WordPress should be structured.

This skill is for modern WordPress development, not WordPress core formatting
cosplay.

## Operating Principles

- Follow the existing project architecture and style first.
- Prefer WordPress APIs, security practices, and ecosystem conventions, but
  follow the project's PHP style rather than WordPress core formatting.
- Prefer modern PHP syntax where supported by the project.
- Prefer short array syntax `[]`, not `array()`.
- Avoid unnecessary modernization of legacy client code.
- Avoid unnecessary churn or broad reformatting.
- Do not introduce new plugins, frameworks, build tools, Composer packages, or
  infrastructure unless the user explicitly asks or the existing project already
  points in that direction.
- Do not claim performance, security, accessibility, SEO, or uptime improvements
  unless they were actually inspected or measured.
- Do not invent admin settings, custom fields, plugin behavior, template paths,
  deployment details, test results, or production impact.
- Keep diffs minimal and scoped to the request.
- Be especially careful around production-like WordPress code, migrations,
  database changes, payment plugins, forms, email delivery, multilingual
  content, redirects, and rewrite rules.

## Preferred WordPress Architecture

When the project allows it, prefer modern Composer-managed WordPress patterns:

- Bedrock-inspired project layout
- Composer for PHP dependencies
- WPackagist for public WordPress plugins/themes
- private Composer repositories for premium plugins when already used
- environment-based configuration
- explicit configuration over admin-panel mystery state when practical
- mu-plugins for site-specific functionality that should not be disabled
  casually
- custom plugins for reusable business logic
- themes for presentation/template concerns
- Timber v2 and Twig templates for theme rendering
- colocated modules for custom blocks, post types, templates, styles, scripts,
  and related assets

Use WordPress APIs and compatibility discipline, but write PHP like a sane
modern project when the repository supports it.

## Timber and Twig Preferences

Unless the existing repository clearly uses a different architecture, prefer a
modern Timber v2 / Twig-based theme structure.

Theme preferences:

- use Timber v2 patterns for PHP-to-template rendering
- keep presentation in Twig templates rather than large PHP templates
- pass explicit context from PHP into Twig
- keep business logic out of Twig where practical
- use Twig for custom block views when building custom blocks
- avoid embedding large amounts of HTML markup into PHP render callbacks
- preserve existing PHP templates when the repo is not Timber-based

When working with Twig:

- inspect the PHP render path before assuming a Twig variable exists
- preserve existing context conventions
- use global views for shared layouts and partials
- use module-local Twig views when the view belongs only to that block, post
  type, or feature area
- escape appropriately according to the project’s Timber/Twig conventions

Useful reference when current details matter: https://timber.github.io/docs/v2/

## Preferred WordPress App Structure

Some projects use a custom `app/` architecture. When present, preserve it.

Typical structure:

```text
app/
  app.php
  admin.js
  editor.js
  blocks.js
  body.js
  head.js
  style.css
  base.css

  views/
    *.twig
    partials/
    ...

  blocks/
    accordion/
      block.json
      index.php
      index.js
      script.js
      style.css
      *.twig
      *.svg

  fact-sheet/
    index.php
    single.twig
    related.twig
    style.css
    script.js
    blocks/
      fact-sheet-featured/
        block.json
        index.php
        index.js
        script.js
        style.css

src/
  App.php
  BlockType.php
  Enqueue.php
  Menu.php
  MenuItem.php
  PostType.php
```

In this architecture:

- `src/` contains reusable PHP classes and framework-like helpers.
- `app/` contains site/theme application code.
- `app/app.php` initializes the app, imports modules, registers Twig view paths,
  and enqueues assets from the build manifest.
- top-level JS files in `app/` are asset-pipeline entry points.
- `admin.js` and `editor.js` are not public-facing frontend entries.
- `app/views` contains global Twig views, layouts, and partials.
- `app/blocks/<block>/` contains generic reusable blocks.
- `app/<post-type>/` contains post-type-specific code and templates.
- `app/<post-type>/blocks/<block>/` contains blocks specific to that post type.

This pattern commonly imports:

- `config/wp/*.php` for WordPress tweaks
- `app/*/index.php` for post types or modules
- `app/blocks/*/index.php` for generic blocks
- `app/*/blocks/*/index.php` for post-type-specific blocks

Twig view paths commonly include:

- `app/views`
- `app`

This means a view may be global, post-type-specific, or block-specific depending
on where it belongs.

## Module Placement Rules

Prefer colocating related files when it makes sense:

- PHP registration/rendering code
- Twig views
- block metadata
- editor JS
- frontend JS
- CSS
- SVG/image assets

When adding a generic block:

- prefer `app/blocks/<block-name>/`
- include `block.json` when the project uses block metadata
- use `index.php` for registration/render setup
- use `index.js` for editor/block registration code
- use `script.js` for frontend behavior when needed
- use `style.css` for block styles
- use Twig views in the block directory when rendering markup through
  Timber/Twig

When adding a post-type-specific block:

- prefer `app/<post-type>/blocks/<block-name>/`
- do not put highly specific blocks in global `app/blocks/` unless they are
  meant to be reused broadly

When adding or changing a custom post type:

- prefer `app/<post-type>/index.php` when the project uses the `app/` convention
- keep related Twig views beside the post type when they are specific to it
- keep related CSS, JS, and SVG assets beside the post type when practical
- use `app/views` for global layouts, shared partials, and broadly reused views

When adding reusable PHP infrastructure:

- prefer `src/`
- keep project-specific module wiring in `app/`
- do not bury reusable classes inside random theme template folders

Do not move files into generic `inc/`, `templates/`, `assets/`, `post-types/`,
`taxonomies/`, or `features/` directories when the project already follows the
`app/` convention.

## Before Adding Files

Before creating a new block, post type, template, or asset entry:

1. inspect `app/app.php` when present
2. inspect existing `app/blocks/*`
3. inspect existing `app/<post-type>/index.php` modules
4. inspect `src/` framework classes
5. inspect the asset pipeline / webpack manifest conventions
6. match the existing import, view-resolution, and asset-entry patterns

## Common Project Patterns

Recognize and work comfortably with:

- Bedrock-inspired project layouts
- Composer-managed WordPress projects
- WPackagist-managed plugins/themes
- private Composer repositories for premium plugins when already used
- classic WordPress themes
- Timber v2 and Twig templates
- custom Twig-rendered blocks
- modular block directories with colocated PHP, Twig, CSS, JS, metadata, and
  assets
- custom post types and taxonomies
- custom fields, including ACF-style fields when present
- Docker/local development environments
- webpack or similar asset manifests
- WPML or multilingual plugin constraints
- WooCommerce customization
- Gravity Forms / Gravity Flow style workflow plugins
- Torro Forms or similar form plugins when present
- client-maintained legacy themes

## Dependency and Plugin Preferences

Prefer dependencies that are easy to install, update, and audit from public
sources.

Default preferences:

- open-source packages where practical
- Composer-managed PHP dependencies
- WPackagist-compatible WordPress plugins/themes when appropriate
- public packages with clear maintenance history
- minimal license-server dependence
- minimal admin-panel mystery state

Avoid adding paid or license-gated plugins for convenience alone.

Paid plugins are acceptable when they provide core site functionality that the
project clearly needs, such as:

- multilingual content
- advanced forms/workflows
- e-commerce/payment functionality
- complex search/filtering
- client-required integrations
- functionality already deeply embedded in the existing site

When choosing between a paid plugin and custom code, consider:

- update path
- long-term maintainability
- client ownership
- license management burden
- security exposure
- whether the feature is truly core to the site

## Development Rules

Before editing:

- inspect relevant templates, functions, hooks, classes, and styles
- identify whether behavior belongs in a theme, plugin, mu-plugin, template,
  block, module, or admin setting
- check for existing helper functions, naming conventions, enqueue patterns,
  import patterns, and escaping/sanitization style

When editing PHP:

- use modern PHP syntax where the project supports it
- prefer short array syntax `[]`
- escape output with the appropriate WordPress escaping function: `esc_html`,
  `esc_attr`, `esc_url`, `wp_kses_post`, etc.
- sanitize input before storing or querying
- validate permissions and nonces for admin, AJAX, and REST actions
- use prepared SQL via `$wpdb->prepare()` when direct SQL is necessary
- prefer `WP_Query`, core APIs, hooks, filters, and template hierarchy before
  custom machinery
- avoid `query_posts()`
- avoid broad global state changes
- avoid changing public URLs, slugs, or rewrite rules unless requested
- preserve surrounding style in older client code unless changing it is part of
  the requested work

When editing CSS/JS:

- preserve existing asset pipeline and enqueue process
- avoid introducing build steps unless already present
- keep selectors scoped
- avoid layout changes outside the requested component
- check responsive impact when touching layout
- respect the distinction between frontend, editor, and admin entry points

## Performance Guidance

Do not perform fake optimization. First identify the bottleneck.

Useful checks include:

- number and shape of queries
- repeated metadata lookups
- uncached remote requests
- expensive `WP_Query` usage
- missing pagination
- image sizes and lazy loading
- cache headers and page/object cache interaction
- plugin/theme conflicts
- asset size and unnecessary frontend scripts

Recommend Redis, page cache, CDN, database indexes, or infrastructure changes
only when the repository or runtime evidence supports it.

Do not report performance metrics unless they were actually measured.

## Security Guidance

Default to practical WordPress hardening:

- escape output
- sanitize input
- validate data before use
- verify nonces
- check capabilities
- avoid exposing private data through REST/AJAX
- avoid unsafe file writes/uploads
- avoid trusting `$_GET`, `$_POST`, headers, or cookies
- use `$wpdb->prepare()` for direct SQL
- do not disable security checks just to make something work

Do not make broad security-score claims.

## Debugging Workflow

For bugs:

1. reproduce or inspect the failing path where possible
2. locate the responsible template, hook, block, plugin, theme, or module code
3. explain the actual cause
4. make the smallest safe fix
5. verify with the narrowest useful check available

For unfamiliar WordPress sites:

- inspect the active theme structure
- inspect relevant plugin and mu-plugin code
- inspect CPT registrations, shortcodes, blocks, hooks, templates, and routes
- use `rg` heavily before assuming where behavior lives
- do not assume a normal WordPress layout when the repo uses a custom structure

## Git and Delivery Expectations

- Review `git status` before changes when working in a repo.
- Review `git diff` after edits.
- Run the narrowest relevant validation available.
- If no automated validation exists, state what was inspected manually.
- Do not commit unless the user explicitly asks.
- Do not push, deploy, tag, reset, clean, switch branches, or rewrite history
  unless the user explicitly asks.

## Final Response

Use the normal agent final format.

Include:

- what changed
- how it was verified
- risks or follow-up items

Never report imaginary metrics, imaginary tests, imaginary security scores, or
imaginary production impact.
