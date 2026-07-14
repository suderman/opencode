---
name: platform2nf
description: Use ONLY when migrating Nonfiction platform WordPress sites to nf theme projects, Kinsta deploys, nonfiction/theme, Timber 2, Vite, or the local canalta/themestarter examples.
---

# Platform2nf

## Purpose

Use this skill to migrate a legacy Nonfiction platform-style WordPress project to
an `nf` WordPress theme project.

The target shape is a deployable theme repository managed by `nf`, using:

- `theme/` as the deployable unit
- `nf.json` as the project/environment/deployment manifest
- `nonfiction/theme` as the shared PHP theme foundation
- Timber 2 and Twig 3 for rendering
- Vite for assets
- Kinsta-compatible standard WordPress paths

This skill is not a generic WordPress modernization checklist. It is specifically
for moving old Nonfiction platform projects away from Bedrock/platform/Docker
deployment and into the newer `nf` theme workflow.

## Local References

These local directories are the primary references in this repository:

| Path                                             | Role                                                                                                                                                                                 |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `~/src/nonfiction/platform2nf/canalta-platform/` | Legacy platform source example. Full WordPress app with root Composer/npm, Docker, `web/`, root `app/`, root `config/`, root `src/`, and webpack.                                    |
| `~/src/nonfiction/platform2nf/canalta-nf/`       | Complete converted site example. Use it to understand real migration decisions and legacy edge cases.                                                                                |
| `~/src/nonfiction/platform2nf/themestarter/`     | Greenfield `nf` theme baseline. Use it for clean target layout, starter conventions, and local `theme/src` guidance.                                                                 |
| `~/src/nonfiction/platform2nf/theme/`            | Local clone of the `nonfiction/theme` Composer package. Use it as read-only reference for shared package APIs and boundaries unless the user explicitly asks to work on the package. |

Use `canalta-nf` when you need a full conversion example. Use `themestarter`
when you need the clean target shape. Use `theme` when you need to confirm what
the shared package already provides.

## Reference Safety

The directories above are examples in this repository. Do not assume they are the
active migration target.

Before editing, identify the actual source project and target project from the
user's request and current working directory. Treat `canalta-platform/`,
`canalta-nf/`, `themestarter/`, and the local package clone `theme/` as read-only
references unless the user explicitly asks to modify one of them.

The word `theme` is overloaded:

- in this reference repository, root `theme/` is the cloned `nonfiction/theme`
  Composer package
- in a migrated client repository, `theme/` is usually the consuming WordPress
  theme that gets deployed

Do not run consuming-theme npm or Composer commands inside the package clone by
mistake. Confirm the target path first.

## Name Glossary

Keep these names distinct:

| Name               | Meaning                                                                                                                  |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `nonfiction/theme` | Composer package name on Packagist. Lowercase package identifier.                                                        |
| `Nonfiction\Theme` | PHP namespace provided by the package. Preserve this exact capitalization.                                               |
| `theme/`           | Consuming WordPress theme directory in an `nf` project. In this reference repo only, root `theme/` is the package clone. |
| `theme/src/`       | Project-local PHP extensions for the consuming theme. Not the shared package.                                            |
| `nf/*` block slugs | WordPress block names saved in post content, such as `nf/banner`. Do not rename just because PHP namespaces changed.     |
| project namespace  | Site PHP namespace such as `Canalta\`, `nf\`, or another client-specific namespace. This is separate from block slugs.   |
| theme slug         | WordPress theme slug in `nf.json` and `style.css`, such as `canalta`.                                                    |
| text domain        | Translation text domain. It may remain `nf` or be project-specific depending on the existing site.                       |

## Compare These First

When you need concrete examples, compare these files before inventing a pattern:

| Question                       | Compare                                                                                                                                                   |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bootstrap migration            | `canalta-platform/app/app.php` and `canalta-platform/theme/functions.php` against `canalta-nf/theme/functions.php` and `themestarter/theme/functions.php` |
| Old local framework extraction | `canalta-platform/src/PostType.php` against `theme/src/Timber/Post.php`                                                                                   |
| Asset build migration          | `canalta-platform/webpack.config.js` against `canalta-nf/theme/vite.config.js` and `themestarter/theme/vite.config.js`                                    |
| Local PHP extensions           | `themestarter/theme/src/README.md`                                                                                                                        |
| nf project metadata            | `themestarter/nf.json` and `canalta-nf/nf.json`                                                                                                           |
| Full converted site decisions  | `canalta-nf/AGENTS.md`, `canalta-nf/README.md`, and `canalta-nf/theme/`                                                                                   |

## Quick Migration Sequence

Use this as the high-level order of operations for a new migration:

1. Identify the active source and target repositories. Do not edit reference
   directories by accident.
2. Start from `themestarter` conventions or an existing partial `nf` target.
3. Create or update root `nf.json`, root docs, and root tooling for an `nf`
   theme project.
4. Move old `app/` application code into `theme/app/`, preserving useful module
   placement.
5. Move old `config/wp/` files into `theme/config/`, removing old namespaces and
   replacing Intervention helpers with direct WordPress hooks.
6. Convert `theme/functions.php` into the real bootstrap using
   `Nonfiction\Theme\App`.
7. Classify every old `src/` class before moving it: shared package, local
   `theme/src/`, `theme/app/`, repo-local plugin, or obsolete platform code.
8. Classify every required plugin: wordpress.org slug, paid/private cache
   plugin, repo-local plugin, or manually managed environment prerequisite.
9. Replace root Composer/npm with `theme/composer.json`, `theme/package.json`,
   and `theme/vite.config.js`.
10. Port blocks, CPTs, Twig views, Timber context, asset paths, and JS entrypoints.
11. Audit hard-coded platform paths and environment assumptions.
12. Run the narrowest useful checks, then build and dry-run package.

## Core Mental Model

Old platform projects are whole WordPress applications.

New `nf` projects are theme packages that deploy into an existing standard
WordPress install.

That means the migration is not a one-to-one file move. It is a split:

- theme presentation and theme application code move into `theme/`
- shared PHP framework behavior moves to the `nonfiction/theme` package
- site-specific PHP extensions remain in the consuming theme, usually `theme/src/`
- site functionality that should not live in a theme moves to `plugins/`
- WordPress/plugin/environment state moves to `nf.json` and the target host
- old platform infrastructure is deleted or ignored

Do not recreate the platform inside the new theme. The goal is to remove the old
platform shape, not hide it under `theme/`.

## Non-Negotiable Target Rules

- The deployable unit is `theme/`.
- `nf.json` is the source of truth for project slug, theme slug, plugin list,
  artifact path, tasks, uploads path, and remotes.
- Composer and npm commands are theme-scoped.
- WordPress core and public plugins are not installed by root Composer.
- Old Bedrock paths such as `/web`, `/content`, and `/wp` are not part of the
  target runtime.
- Old Docker/Swarm/Traefik deployment files are not consumed by Kinsta.
- `web/assets/dist` is replaced by `theme/dist`.
- `webpack` is replaced by Vite.
- `ROOT_DIR` and platform bootstrap constants should not be needed in migrated
  theme code.
- WordPress block slugs such as `nf/banner` may stay unchanged for content
  compatibility. These slugs are content identifiers, not PHP namespaces.

## First Actions

When invoked on a new migration, do this before editing:

1. Inspect the source repository shape.
2. Identify whether there is already an `nf` target, a `themestarter` clone, or
   a partially converted repo.
3. Read `composer.json`, `package.json`, asset config, bootstrap files, and
   `AGENTS.md`/`README.md` before deciding what to move.
4. Inventory custom post types, custom blocks, Twig/PHP templates, config files,
   site-specific classes, integrations, plugins, and hard-coded paths.
5. Classify old `src/` code before moving it.
6. Make the smallest safe migration step and verify it in the relevant path.

Prefer repository evidence over assumptions. Platform projects are similar but
not identical.

## Discovery Checklist

Look for these files and directories in the source project:

| Source item                                                            | What it usually means                                                                                         |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `app/app.php`                                                          | Old platform bootstrap. Usually replaced by `theme/functions.php` using `Nonfiction\Theme\App`.               |
| `theme/functions.php`                                                  | Old theme entry point. Often only required `ROOT_DIR . '/app/app.php'`. Must become the real theme bootstrap. |
| `app/`                                                                 | Site application modules, views, blocks, CPTs, and asset entrypoints. Usually migrates to `theme/app/`.       |
| `config/wp/`                                                           | WordPress tweaks. Usually migrates to `theme/config/` with namespaces removed and direct WP hooks.            |
| `config/application.php`                                               | Bedrock/platform environment config. Usually dropped. Do not migrate wholesale.                               |
| `src/`                                                                 | Old local PHP framework plus possible site-specific extensions. Must be classified carefully.                 |
| `web/`                                                                 | Old WordPress webroot and content path. Do not recreate in target.                                            |
| `webpack.config.js`                                                    | Old asset build. Replace with `theme/vite.config.js`.                                                         |
| root `composer.json`                                                   | Old full-site dependency manager. Replace with `theme/composer.json` plus `nf.json` plugins.                  |
| root `package.json`                                                    | Old root asset tooling. Replace with `theme/package.json`.                                                    |
| `Dockerfile`, `stack-*.yml`, `docker-compose.yaml`, `Makefile`, `bin/` | Old platform local/deploy tooling. Usually dropped in favor of `nf env` and `nf theme`.                       |

Search for these old assumptions:

```text
ROOT_DIR
WP_ENV
/wp
/content
/assets
/app/views
web/assets/dist
require.context
add_intervention
Twig_Environment
Timber\Twig_Function
register_extended_post_type
register_extended_taxonomy
show_in_graphql
graphql_single_name
graphql_plural_name
```

Also search for hard-coded production URLs, upload URLs, CDN URLs, AJAX paths,
image paths, and platform-only service names.

## Source Stack Discovery

Do not assume every source site starts on Timber 1. Some may already be partly
modernized, custom, or inconsistent.

Determine:

- Timber version and usage style
- Twig version and extension classes
- whether templates are Twig, PHP, or mixed
- whether post types extend old `nf\PostType`, use direct WP functions, use
  `extended-cpts`, or use another helper
- whether blocks are dynamic PHP/Twig blocks, static JS blocks, ACF blocks, or
  mixed
- whether old `src/` contains framework code, site-specific classes, or both
- whether business logic belongs in the theme or a repo-local plugin
- whether plugins are Composer-managed, vendored, private, premium, or admin
  installed
- whether deployment assumes Docker, Bedrock, Redis, cron, custom uploads paths,
  symlinks, or drop-ins

Target Timber 2 and `nonfiction/theme`, but choose migration steps based on the
actual source stack.

## Target Layout

The target project should resemble `themestarter/` and `canalta-nf/`:

```text
nf.json
README.md
AGENTS.md
flake.nix
treefmt.nix
plugins/
  optional-repo-plugin/
    optional-repo-plugin.php
theme/
  composer.json
  package.json
  vite.config.js
  functions.php
  style.css
  index.php
  app/
    head.js
    body.js
    blocks.js
    editor.js
    views/
    blocks/
    <post-type>/
  config/
    admin.js
    admin.css
    *.php
  lib/
    index.js
    ajax.js
    blocks.js
  src/
    optional site-specific PHP extensions
  dist/
    generated build output
  vendor/
    generated Composer dependencies
```

Do not add old root `app/`, root `config/`, root `src/`, root Composer/npm,
`web/`, Docker, Makefile, or webpack to a finished `nf` target.

## File Mapping

Use this as a starting point, not a blind copy rule:

| Old platform path             | New `nf` path                       | Notes                                                                                                                                                                            |
| ----------------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app/**`                      | `theme/app/**`                      | Preserve module layout where useful. Adjust imports and asset paths.                                                                                                             |
| `app/views/**`                | `theme/app/views/**`                | Global Twig layouts, partials, native post/page helper classes, global CSS/JS/images.                                                                                            |
| `app/blocks/<block>/**`       | `theme/app/blocks/<block>/**`       | Reusable blocks. Preserve block slugs if existing content uses them.                                                                                                             |
| `app/<cpt>/index.php`         | `theme/app/<cpt>/index.php`         | CPT module registration and class-backed post helpers.                                                                                                                           |
| `app/<cpt>/blocks/<block>/**` | `theme/app/<cpt>/blocks/<block>/**` | CPT-specific blocks.                                                                                                                                                             |
| `app/admin.js`                | `theme/config/admin.js`             | Admin entrypoint moves under config.                                                                                                                                             |
| `config/wp/*.php`             | `theme/config/*.php`                | Remove old namespace and Intervention helpers. Use direct WP hooks.                                                                                                              |
| `theme/functions.php`         | `theme/functions.php`               | Convert from a thin `app/app.php` require to the main bootstrap.                                                                                                                 |
| `src/**`                      | classify first                      | Shared baseline belongs in `nonfiction/theme`; site extensions may go in `theme/src/`; module code may belong in `theme/app/`; non-theme functionality may belong in `plugins/`. |
| `web/**`                      | none                                | Drop. Standard WordPress host provides webroot.                                                                                                                                  |
| `web/assets/dist`             | `theme/dist`                        | Generated Vite output.                                                                                                                                                           |
| root `composer.json`          | `theme/composer.json`               | Only theme PHP dependencies remain here. Plugins move to `nf.json`.                                                                                                              |
| root `package.json`           | `theme/package.json`                | Only theme asset tooling remains here.                                                                                                                                           |
| `webpack.config.js`           | `theme/vite.config.js`              | Preserve asset groups through custom Vite manifest.                                                                                                                              |

## Shared Package Versus Local `src`

Old platform projects used root `src/` for PHP extensions. In practice, that
directory often mixed reusable framework code with website-specific code.

In `nf` projects, the split is intentional:

- shared baseline code lives in the Composer package `nonfiction/theme`
- site-specific extensions live in the consuming theme's `theme/src/`
- site modules that are not reusable classes live under `theme/app/`
- business functionality that should survive theme changes lives under
  `plugins/`

The local `theme/` directory in this repository is the cloned
`nonfiction/theme` package. It autoloads `Nonfiction\Theme\` from its own
`src/` and contains shared helpers, bootstrapping, asset handling, Timber
adapters, and WordPress registrars.

Use the package as a dependency in consuming themes:

```sh
composer --working-dir=theme require nonfiction/theme
```

Only use a Composer path repository to the local `theme/` package when doing
package development. Do not make local path repositories the default migration
shape for client sites.

### Classify Each Old `src/` Item

| Old `src/` item                                                                              | New destination                                                                                                      |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `nf\App` bootstrap/import/views/enqueue behavior                                             | `Nonfiction\Theme\App` from `nonfiction/theme`. Do not recreate locally.                                             |
| shared helper functions like `pluralize`, `import`, `css`, `get_param`, `make_link_relative` | `Nonfiction\Theme\...` functions where available. Add local helpers only if site-specific.                           |
| `nf\PostType` framework behavior                                                             | `Nonfiction\Theme\Timber\Post` plus `Nonfiction\Theme\WordPress\PostTypeRegistrar`. Do not copy old class wholesale. |
| `nf\BlockType` framework behavior                                                            | `Nonfiction\Theme\Timber\Block` plus `Nonfiction\Theme\WordPress\BlockTypeRegistrar`.                                |
| `nf\Menu` and `nf\MenuItem`                                                                  | `Nonfiction\Theme\Timber\Menu` and `Nonfiction\Theme\Timber\MenuItem`.                                               |
| site API client, CRM integration, payment wrapper, import service                            | Usually `theme/src/<SiteNamespace>/...` or a repo-local plugin, depending on whether it is presentation-bound.       |
| CPT-specific methods and computed properties                                                 | Usually the class in `theme/app/<cpt>/index.php`, extending `Nonfiction\Theme\Timber\Post`.                          |
| block-specific render helpers                                                                | Usually the block module in `theme/app/blocks/<block>/` or `theme/app/<cpt>/blocks/<block>/`.                        |
| admin columns, filters, workflow behavior from `extended-cpts`                               | Recreate explicitly with WordPress hooks if still required. Verify in admin.                                         |
| GraphQL support                                                                              | Dropped from `nonfiction/theme`; add explicit support only if the migrated site still needs it.                      |
| Docker, Bedrock, Dotenv, Redis, webroot constants                                            | Drop or replace with `nf`/host behavior. Do not move to `theme/src/`.                                                |

### Local `theme/src/` Guidance

Local `theme/src/` is valid in the consuming theme, but it is not a dumping
ground for the old platform framework.

Use it for reusable PHP extensions that belong to this website, such as:

- custom Timber subclasses that need Composer autoloading
- API clients used by multiple modules
- value objects or service classes used across theme modules
- site-specific extensions to `Nonfiction\Theme` behavior

Do not use it for:

- old copies of `nf\App`, `nf\PostType`, `nf\BlockType`, or `nf\Menu`
- framework patches that should be contributed to `nonfiction/theme`
- block modules that belong under `theme/app/blocks/`
- CPT modules that belong under `theme/app/<cpt>/`
- functionality that should be a plugin

If adding local `theme/src/` classes, add or preserve PSR-4 autoloading in
`theme/composer.json`, then run:

```sh
composer --working-dir=theme dump-autoload
```

Composer autoloading only makes local classes available. It does not make
WordPress, Timber, or `nonfiction/theme` use those classes automatically. Wire
local classes explicitly through direct references, WordPress hooks, Timber
filters, factories, or service construction.

Example: a local `nf\Timber\MenuItem` subclass is inert until a filter such as
`timber/menuitem/class` returns that class.

Choose a clear site namespace. For existing converted sites, use the established
project namespace. Do not confuse PHP namespaces with legacy block slugs.

## `nonfiction/theme` Package Boundary

The `nonfiction/theme` package provides shared infrastructure only:

- `Nonfiction\Theme\App`
- `Nonfiction\Theme\Assets`
- `Nonfiction\Theme\Enqueue`
- `Nonfiction\Theme\ViteManifest`
- helpers from `Nonfiction\Theme\helpers.php`
- `Nonfiction\Theme\Timber\Post`
- `Nonfiction\Theme\Timber\Block`
- `Nonfiction\Theme\Timber\Menu`
- `Nonfiction\Theme\Timber\MenuItem`
- `Nonfiction\Theme\WordPress\PostTypeRegistrar`
- `Nonfiction\Theme\WordPress\TaxonomyRegistrar`
- `Nonfiction\Theme\WordPress\BlockTypeRegistrar`
- `Nonfiction\Theme\WordPress\Meta`

It intentionally does not contain client-specific content, routes, templates,
blocks, CPTs, design, or integrations.

If a migration reveals a missing generic capability, decide carefully:

- If it is reusable across nonfiction themes, it may belong in the package, but
  only change the package when the user asks for package work.
- If it is specific to the current site, keep it in the consuming theme or a
  repo-local plugin.
- If it is old platform compatibility glue, avoid adding it unless there is a
  concrete persisted-data or public-API need.

## Bootstrap Migration

Old platform pattern:

```php
require_once ROOT_DIR . '/app/app.php';
```

Old `app/app.php` usually called:

```php
App::init(ROOT_DIR);
App::import([
  'config/wp/*.php',
  'app/*/index.php',
  'app/blocks/*/index.php',
  'app/*/blocks/*/index.php',
]);
App::views(['app/views', 'app']);
App::enqueue('web/assets/dist/' . WP_ENV . '.json');
```

New `theme/functions.php` should become the real bootstrap:

```php
<?php

require_once __DIR__ . '/vendor/autoload.php';

use Nonfiction\Theme\App;

App::init(get_template_directory());
App::import([
  'app/views/*.php',
  'app/*/index.php',
  'app/blocks/*/index.php',
  'app/*/blocks/*/index.php',
  'config/*.php',
]);
App::views(['app/views', 'app']);
App::enqueue('dist/manifest.json');
```

Add project-specific imports, theme supports, Timber context filters, Twig
extensions, menus, image globals, and block categories around this baseline.

Do not keep `app/app.php` as the main bootstrap unless there is a specific
project reason. The target convention is `theme/functions.php`.

### Import Ordering

`App::import()` loads files by glob order. If one imported module references a
class or function from another imported file at load time, ensure the dependency
is imported first.

Callbacks can defer references safely, but top-level class usage cannot. If in
doubt, make the import order explicit for special cases.

## Composer Migration

Old platform root Composer often installed:

- WordPress core
- public plugins via WPackagist
- premium/private plugins
- Bedrock/Roots packages
- old local framework autoloading such as `nf\` -> `src/`
- Timber 1
- Sober Intervention
- `extended-cpts`
- Dotenv and platform runtime dependencies

The target `theme/composer.json` should be theme-local and much smaller.

Typical target requirements:

```json
{
  "type": "wordpress-theme",
  "require": {
    "php": ">=8.3",
    "nonfiction/theme": "dev-main",
    "timber/timber": "^2.5.1"
  },
  "autoload": {
    "psr-4": {
      "SiteNamespace\\": "src/"
    }
  }
}
```

Rules:

- Do not restore root Composer for WordPress core installation.
- Do not restore `composer/installers` unless there is a concrete, current theme
  requirement.
- Do not restore `roots/wordpress`, Bedrock packages, or WPackagist plugin
  installation in the theme Composer file.
- Move plugin expectations to `nf.json`.
- Keep theme-specific PHP libraries in `theme/composer.json` only when the theme
  actually uses them.
- Prefer `nonfiction/theme` from Packagist. Use a path repository to the local
  package clone only for package development.
- Run Composer commands with `--working-dir=theme`.

Useful commands:

```sh
composer --working-dir=theme validate --strict
composer --working-dir=theme install
composer --working-dir=theme dump-autoload
composer --working-dir=theme test
```

## `nf.json` Migration

Every target project needs an `nf.json` at the repo root.

Use `themestarter/nf.json` as the clean baseline and `canalta-nf/nf.json` as a
converted real-site example.

Important sections:

```json
{
  "version": 1,
  "project": {
    "slug": "client-slug",
    "type": "wordpress-theme"
  },
  "wordpress": {
    "deploy_unit": "theme",
    "plugins": [],
    "themes": [{ "path": "theme", "slug": "client-slug", "source": "repo" }]
  },
  "artifact": {
    "path": "dist/client-slug-v{version}.zip"
  },
  "tasks": {
    "build": "npm --prefix theme run build",
    "check": "composer --working-dir=theme test && npm --prefix theme run lint",
    "watch": "npm --prefix theme start"
  }
}
```

Rules:

- `project.slug` and the first `wordpress.themes[].slug` should match the theme
  slug unless the project has an explicit reason not to.
- `wordpress.deploy_unit` should be `theme`.
- The repo theme entry should be `{ "path": "theme", "slug": "...", "source": "repo" }`.
- Public, cached, premium, and repo-local plugins belong in
  `wordpress.plugins`.
- Paid/private plugins should be referenced by their official plugin slug and a
  cache source, not by an invented download URL.
- Repo-local plugins can live under `plugins/<plugin>/` and use
  `source: "repo"`.
- `artifact.path` should point to a root `dist/*.zip` artifact.
- Tasks should run theme-scoped commands.
- Remotes should use the current `nf` provider target format.

## Plugin Handling And Paid Plugin Cache

Classify every plugin from the old platform before deciding where it goes.

| Plugin type                                       | Target handling                                                                                                                                  |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Public wordpress.org plugin                       | List the official wordpress.org slug directly in `wordpress.plugins`, such as `"query-monitor"`.                                                 |
| Paid/private plugin not on wordpress.org          | List the official vendor/plugin slug with `source: "cache"`, then ensure the local `nf` plugin cache contains that plugin.                       |
| Hand-written site plugin                          | Commit it under `plugins/<slug>/` and list it with `source: "repo"`.                                                                             |
| Agency-tweaked public plugin required by the site | Treat it as a repo plugin under `plugins/<slug>/` when those modifications are required and cannot be represented as theme/plugin configuration. |
| Host-installed or manually managed plugin         | Document it as an environment prerequisite if `nf` should not install it. Verify it on the target host.                                          |

Use the official plugin slug for paid plugins. Do not rename paid plugins to a
local shorthand. For example, `canalta-nf/nf.json` uses:

```json
{
  "slug": "gravityforms",
  "source": "cache"
},
{
  "slug": "seo-by-rank-math-pro",
  "source": "cache"
}
```

This tells `nf` to use the local plugin cache. It does not mean the agent can
download those plugins from wordpress.org.

If the local cache is empty or missing the required paid plugin, stop and report
the blocker clearly. A human with the correct license, paid account access,
internal package source, or approved plugin ZIP must populate the local `nf`
plugin cache before packaging/deployment can proceed.

Do not:

- download paid plugins from random websites
- invent plugin download URLs
- replace a paid plugin with a public alternative without explicit approval
- commit paid plugin ZIPs or vendor code unless the license and project policy
  explicitly allow it
- store license keys, vendor credentials, or paid account access in the repo

When migrating old private Composer or WPackagist-style plugin requirements,
reclassify each plugin as one of:

- public slug in `wordpress.plugins`
- paid/private cache plugin with official slug and `source: "cache"`
- repo-local plugin with `source: "repo"`
- manually managed host prerequisite documented in README/AGENTS/deployment notes

For paid/private plugins, verification must include install source, version,
activation status, license status, update path, settings, and any migrated data.

For Kinsta remotes, expect a workflow like:

```sh
nf provider check kinsta
nf remote add production client.kinsta:live
nf theme deploy production
```

Confirm current provider names and site refs with `nf`; do not invent remotes.

## Kinsta Deployment Model

Kinsta receives the built theme in a standard WordPress install:

```text
wp-content/themes/<theme-slug>
```

It does not consume the old platform's:

- Dockerfile
- Swarm stack files
- Traefik labels
- Bedrock `web/` directory
- root `config/application.php`
- Redis drop-ins
- platform Makefile targets
- old `bin/run`, `bin/wp`, or image build scripts

Do not add a theme-level Flush settings page, admin-bar Flush link, or default
`App::flush()` workflow for Kinsta-hosted sites. Kinsta's must-use plugin handles
object cache clearing. Some older examples include `theme/config/flush.php`, but
that pattern is not a default migration target and should only be added when the
project explicitly needs theme-managed flushing.

Before deployment:

- verify `nf.json` plugin list against the target Kinsta site
- confirm premium/private plugin availability
- confirm required `source: "cache"` plugins are present in the local `nf`
  plugin cache, or ask a human to populate the cache
- confirm required `source: "repo"` plugins are committed under `plugins/`
- confirm environment variables and secrets outside the repo
- confirm uploads/media path expectations
- confirm cache/object-cache clearing is handled by the host or an approved
  plugin, not duplicated by a theme admin page
- build Vite assets before packaging or deploy
- run the narrowest meaningful theme checks

Theme deploys do not migrate database content or host-managed state. Treat these
as separate migration or verification work:

- pages, posts, menus, options, widgets, redirects, and plugin settings
- uploads and media library files
- Gravity Forms or form plugin entries/settings
- SEO plugin settings, redirects, and sitemaps
- cron events and cache/object-cache settings
- production secrets and environment variables

Do not assume `nf theme package` runs front-end builds. Run the build explicitly:

```sh
npm --prefix theme run build
nf theme package --dry-run
```

Before packaging or deploying, ensure generated directories needed by the theme
exist locally, especially `theme/dist/` and Composer dependencies under
`theme/vendor/` when the project relies on them.

Composer behavior inside `nf theme package` may depend on the installed `nf`
version and project configuration. Do not rely on it as a substitute for local
validation.

## Vite Migration

Old platform webpack pattern:

- source root `app`
- output `web/assets/dist`
- public path `/assets/dist/`
- entrypoints `head`, `body`, `blocks`, `editor`, `admin`
- manifest files named by environment, such as `development.json` or
  `production.json`
- `require.context` for automatic module loading
- webpack-only CSS `~package` imports

Target Vite pattern:

- config at `theme/vite.config.js`
- output at `theme/dist`
- custom manifest at `theme/dist/manifest.json`
- entrypoints:
  - `app/head.js`
  - `app/body.js`
  - `app/blocks.js`
  - `app/editor.js`
  - `config/admin.js`
- alias `@lib` to `theme/lib/index.js`
- `publicDir: false`
- custom manifest shape consumed by `Nonfiction\Theme\Enqueue`

The example Vite configs also include a custom WordPress JSX transform for app
JavaScript. Preserve that pattern when migrating block/editor code that uses
JSX:

- use the classic JSX runtime
- compile JSX to `wp.element.createElement`
- compile fragments to `wp.element.Fragment`
- scope the transform to the theme app files as the examples do
- do not add React or a generic Vite React plugin unless the project already
  intentionally depends on React outside WordPress globals

Preserve this manifest shape:

```json
{
  "head": { "css": "/dist/head-HASH.css", "js": "/dist/head-HASH.js" },
  "body": { "css": "/dist/body-HASH.css", "js": "/dist/body-HASH.js" },
  "blocks": { "css": "/dist/blocks-HASH.css", "js": "/dist/blocks-HASH.js" },
  "editor": { "css": "/dist/editor-HASH.css", "js": "/dist/editor-HASH.js" },
  "admin": { "css": "/dist/admin-HASH.css", "js": "/dist/admin-HASH.js" }
}
```

Do not switch to Vite's native `.vite/manifest.json` unless you also update the
PHP loader intentionally.

Use theme-scoped npm commands:

```sh
npm --prefix theme install
npm --prefix theme run build
npm --prefix theme run lint
npm --prefix theme start
```

## JavaScript Entrypoints

Replace webpack dynamic imports with Vite patterns.

Old:

```js
require.context(__dirname, true, /^\.\/blocks\/[\w-]+\/script\.js$/);
```

New:

```js
Object.values(import.meta.glob("./blocks/*/script.js", { eager: true }));
Object.values(import.meta.glob("./*/blocks/*/script.js", { eager: true }));
```

Useful target entrypoint patterns:

```js
// app/head.js
import "./views/css/style.css";
Object.values(import.meta.glob("./*/script.js", { eager: true }));
```

```js
// app/blocks.js
Object.values(import.meta.glob("./blocks/*/script.js", { eager: true }));
Object.values(import.meta.glob("./*/blocks/*/script.js", { eager: true }));
```

```js
// app/editor.js
import "./views/css/editor-ui.css";
Object.values(import.meta.glob("./blocks/*/index.js", { eager: true }));
Object.values(import.meta.glob("./*/blocks/*/index.js", { eager: true }));
Object.values(import.meta.glob("./views/*/editor.js", { eager: true }));
Object.values(import.meta.glob("./*/editor.js", { eager: true }));
```

Old platform code may create a global `nf` helper. Do not recreate it by
default. Use module imports from `theme/lib/`:

```js
import { registerBlockType } from "@lib";
```

AJAX should target standard WordPress admin AJAX paths:

```js
globalThis.ajaxurl || "/wp-admin/admin-ajax.php";
```

Do not keep old `/wp/wp-admin/admin-ajax.php` assumptions unless the actual
target runtime still uses that path.

## CSS And Asset Paths

Old platform assets often assume root public paths:

```text
/assets/img/...
/app/views/img/...
/content/uploads/...
/wp/...
web/assets/dist
```

Replace those assumptions with theme-aware references.

PHP:

```php
use Nonfiction\Theme\Assets;

$context['img'] = Assets::asset_uri('app/views/img');
$url = get_theme_file_uri('app/views/img/example.jpg');
```

Twig:

```twig
<img src="{{ img }}/logo.svg" alt="">
```

JavaScript:

```js
import icon from "../../views/img/icon.svg";

const arrow = new URL("../img/arrow.svg", import.meta.url).href;
```

CSS package imports should be Vite-compatible:

```css
@import "normalize.css";
@import "hamburgers/dist/hamburgers.css";
@import "slick-carousel/slick/slick.css";
```

Do not use webpack-only tilde imports:

```css
@import "~normalize.css";
```

If a file such as `site.webmanifest` or `browserconfig.xml` moves from the old
webroot into `theme/app/views/img/favicons`, audit its internal URLs too.

## PHP API Migration Map

Common replacements:

| Old platform                                       | New target                                                                  |
| -------------------------------------------------- | --------------------------------------------------------------------------- |
| `nf\App`                                           | `Nonfiction\Theme\App`                                                      |
| `nf\PostType`                                      | `Nonfiction\Theme\Timber\Post` or `Timber\Timber` static helpers            |
| `nf\BlockType`                                     | `Nonfiction\Theme\Timber\Block`                                             |
| `nf\Menu`                                          | `Nonfiction\Theme\Timber\Menu`                                              |
| `nf\MenuItem`                                      | `Nonfiction\Theme\Timber\MenuItem`                                          |
| `nf\API` when site-specific                        | site namespace such as `Client\API`, loaded from `theme/app` or `theme/src` |
| `nf\import`                                        | `Nonfiction\Theme\import`                                                   |
| `nf\css`                                           | `Nonfiction\Theme\css`                                                      |
| `nf\merge`                                         | `Nonfiction\Theme\merge`                                                    |
| `nf\get_param`                                     | `Nonfiction\Theme\get_param` if available and appropriate                   |
| `nf\add_ajax_action`                               | `Nonfiction\Theme\add_ajax_action` if available, or explicit WP AJAX hooks  |
| `nf\hyphenate`, `titleize`, `humanize`, `is_empty` | `Nonfiction\Theme\...` helper functions                                     |
| `nf\make_link_relative`                            | `Nonfiction\Theme\make_link_relative`                                       |

Always confirm the current package API in the local `theme/` clone before using
an unfamiliar helper.

## Timber 2 And Twig 3 Target

The final target is Timber 2 and Twig 3. The source may or may not be Timber 1.

Common Timber 1 to Timber 2 changes:

| Old                        | New                                                                             |
| -------------------------- | ------------------------------------------------------------------------------- |
| `new Timber\Timber()`      | `Timber\Timber::init()` via `App::init()`                                       |
| `new \Timber\Image($id)`   | `Timber\Timber::get_image($id)`                                                 |
| `new \Timber\User($id)`    | `Timber\Timber::get_user($id)`                                                  |
| `new \Timber\Term($id)`    | `Timber\Timber::get_term($id)`                                                  |
| `nf\PostType::get_post()`  | `Timber\Timber::get_post()` or a `Nonfiction\Theme\Timber\Post` subclass helper |
| `nf\PostType::get_posts()` | `Timber\Timber::get_posts()` or a subclass helper                               |
| `\Twig_Environment`        | `\Twig\Environment`                                                             |
| `Timber\Twig_Function`     | `\Twig\TwigFunction`                                                            |

Timber 2 returns can be nullable. Guard image, user, term, and post lookups
before calling methods or passing values to Twig.

Twig 3 is stricter about undefined values. Use explicit defaults and truthy
checks where migrated templates depended on old lax behavior.

## Blocks

Dynamic PHP/Twig blocks usually keep their directory shape, but switch to the
shared package APIs.

Target PHP pattern:

```php
<?php

use Nonfiction\Theme\Timber\Block as BlockType;

BlockType::register_block_type(__DIR__ . '/block.json', [
  'render' => function (array $context) {
    return 'blocks/banner/banner.twig';
  },
]);
```

Target JS pattern:

```js
import json from "./block.json";
import { registerBlockType } from "@lib";

registerBlockType(json, {
  edit() {
    return <div />;
  },
});
```

Rules:

- Preserve existing block names such as `nf/banner` if content already uses
  them.
- Do not rename block slugs just because PHP namespaces changed.
- Keep reusable blocks in `theme/app/blocks/<block>/`.
- Keep CPT-specific blocks in `theme/app/<cpt>/blocks/<block>/`.
- Keep `block.json`, `index.php`, `index.js`, `script.js`, `style.css`, Twig,
  and block assets colocated when they change together.
- Modernize `block.json` only when safe; do not break saved block content.
- Replace global `nf.registerBlockType` with `@lib` imports.

## Post Types, Taxonomies, Meta, And Admin Behavior

Old platform post types may extend `nf\PostType` and depend on
`johnbillion/extended-cpts` behavior.

Target class-backed post types usually extend `Nonfiction\Theme\Timber\Post`:

```php
<?php

namespace Client;

use Nonfiction\Theme\Timber\Post as PostType;

class Hotel extends PostType {
  protected static $register_post_type = [
    'name' => 'hotel',
    'supports' => ['title', 'editor', 'thumbnail', 'revisions'],
    'has_archive' => true,
  ];
}

Hotel::__constructStatic();
```

Package behavior to remember:

- `Nonfiction\Theme\Timber\Post` delegates core registration to the
  `Nonfiction\Theme\WordPress` registrar layer.
- Taxonomy, meta, and CMB2-style metabox concepts are preserved where supported.
- `extended-cpts` has intentionally been removed.
- Unsupported custom keys such as `admin_cols`, `site_sortables`,
  `site_filters`, `dashboard_glance`, `quick_edit`, and GraphQL keys are stripped
  before core registration.
- `has_archive` is not assumed by default. Listing pages may be normal pages
  with custom blocks.

If old admin columns, filters, custom title placeholders, featured image labels,
feeds, or GraphQL fields are business requirements, recreate them explicitly
with WordPress hooks and verify them in the admin or API.

## Config Migration

Old files under `config/wp/*.php` usually move to `theme/config/*.php`.

Rules:

- Remove old `namespace nf;` declarations unless a specific file still needs a
  project namespace.
- Replace `add_intervention(...)` with explicit WordPress hooks. Do not keep
  `soberwp/intervention`, local `add_intervention` shims, or config files that
  still depend on Sober Intervention.
- Use `Nonfiction\Theme` helpers directly where appropriate.
- Keep admin entry assets in `theme/config/admin.js` and `theme/config/admin.css`.
- Use config files for WordPress tweaks, not for old environment bootstrapping.

When converting Intervention config, preserve the old behavior by mapping each
module to direct WordPress APIs. Useful examples:

- `remove-howdy`: update the `my-account` admin-bar node late on
  `admin_bar_menu`.
- `remove-help-tabs`: call `get_current_screen()->remove_help_tabs()` from
  `admin_head`.
- `remove-update-notices`: remove `update_nag` from admin notice hooks, scoped
  to the original capability/role intent.
- `remove-toolbar-items`: call `$admin_bar->remove_node()` for each item.
- `remove-user-fields`: hide selected profile field groups with profile-screen
  hooks and `user_contactmethods` when needed.
- `remove-page-components` and `remove-post-components`: use
  `remove_post_type_support()` or explicit meta-box removal, matching the old
  component names.
- `remove-widgets`: remove dashboard meta boxes from both normal and side
  contexts.
- `update-pagination`: add the per-page filters for posts, pages, and the
  current post type from `current_screen`.

Common target config files from `themestarter` and `canalta-nf`:

- `clean-admin.php`
- `relative-urls.php`
- `editor-styles.php`
- `pretty-permalinks.php`
- `vite-module-scripts.php`
- `support-svg.php`
- `disable-emoji.php`
- `disable-feeds.php`
- `disable-dev-crawlers.php`

Be careful with `WP_ENV`. Some examples still reference it. For new Kinsta/nf
targets, audit whether that constant exists. Prefer `wp_get_environment_type()`
or a project-approved environment check when possible.

Treat `flush.php` and `pretty-permalinks.php` as opt-in examples, not baseline
migration files. `flush.php` is usually undesired on Kinsta because host-managed
must-use plugins handle object cache clearing. `pretty-permalinks.php` mutates a
site option and should only be used when that behavior is explicitly wanted.

## Vite Module Scripts

Vite outputs ES modules. Preserve the config that marks generated handles as
module scripts.

Check the installed `nonfiction/theme` version before assuming this is handled
globally. If the package only marks some handles as modules, add a consuming-theme
config file such as `theme/config/vite-module-scripts.php` so every generated
Vite entry script is served with `type="module"`.

Expected handles:

```text
nf-admin-js
nf-blocks-js
nf-body-js
nf-editor-js
nf-head-js
```

If script handles change, update the module-script filter too.

## Plugins Versus Theme Code

Do not put all old application code in the theme by default.

Theme-appropriate code:

- templates and presentation logic
- block rendering tied to theme markup
- theme asset behavior
- Timber context and view helpers
- CPT display helpers

Plugin-appropriate code:

- payment integrations
- external API synchronization
- form processing workflows
- CRM or booking system integrations
- custom REST/AJAX endpoints not tied to presentation
- business rules that should survive theme replacement
- must-use site behavior
- hand-written plugins required by the site
- agency-tweaked public plugins that the site depends on and that cannot be
  represented as configuration

`nf` supports repo-local plugins under `plugins/`. Use `themestarter`'s
`plugins/agency-credit` as a simple local plugin example.

Repo-local plugins should be listed in `nf.json` with `source: "repo"`. Do not
try to reconstruct agency-tweaked public plugins from wordpress.org during
deployment; commit the required plugin code when licensing and project policy
allow it.

When unsure, preserve behavior first, then recommend extracting to a plugin as
a follow-up if the boundary is not required for the migration to work.

## Root Scaffold

Use the converted examples for root project scaffolding:

- `.editorconfig`
- `.gitignore`
- `flake.nix`
- `treefmt.nix`
- `statix.toml`
- `README.md`
- `AGENTS.md`
- `nf.json`

Target `.gitignore` should ignore generated and local state such as:

```text
.env
.direnv
node_modules/
theme/node_modules/
theme/vendor/*
!theme/vendor/.gitkeep
dist/
theme/dist/
uploads/
process-compose.yaml
result
```

Do not carry over ignores for old `web/wp`, `web/content/*`, or
`web/assets/dist` unless a temporary migration workspace still contains those
paths.

## README And AGENTS Updates

For migrated repos, update docs so future agents do not restore platform files.

Document:

- repo is an `nf` WordPress theme project
- deployable unit is `theme/`
- use `nf.json` for tasks/plugins/remotes/artifact path
- run Composer/npm in `theme/`
- use `nonfiction/theme` APIs
- keep project-specific PHP extensions in `theme/src/` only when needed
- keep repo-local plugins in `plugins/`
- document paid/private cache plugins and any human cache-population requirement
- do not restore `web/`, Docker, Makefile, root Composer/npm, or webpack
- build assets before packaging/deploying

## Commands

Use the narrowest relevant commands for the task. Common commands:

```sh
nix develop
nf theme update
nf env up
nf env show
nf theme watch
```

Theme-scoped direct commands:

```sh
composer --working-dir=theme install
composer --working-dir=theme validate --strict
composer --working-dir=theme dump-autoload
composer --working-dir=theme test
npm --prefix theme install
npm --prefix theme run build
npm --prefix theme run lint
npm --prefix theme start
```

Packaging and deployment checks:

```sh
nf theme check
nf theme build
nf theme package --dry-run
nf theme deploy <remote>
```

Do not commit, deploy, or push unless the user explicitly asks.

## Verification Checklist

At minimum, verify the migration path relevant to the change.

Static checks:

- `composer --working-dir=theme validate --strict`
- `composer --working-dir=theme test`
- `npm --prefix theme run lint`
- `npm --prefix theme run build`
- `nf theme check`
- `nf theme package --dry-run`

Runtime checks when feasible:

- theme activates
- frontend renders key pages
- Timber/Twig templates resolve
- block editor loads custom blocks
- dynamic blocks render in frontend and editor
- CPT archive/single/admin screens work
- menus render
- assets load from `theme/dist` and theme asset URLs
- admin config changes apply
- AJAX or REST endpoints work
- forms, payments, bookings, CRM, or other integrations still work
- uploads/media references resolve
- no PHP fatal errors in logs

Kinsta-specific checks:

- plugin list in `nf.json` matches target site requirements
- premium/cached plugins are available
- any empty paid plugin cache has been populated by a human with legitimate
  access to the plugin
- repo-local plugins are present under `plugins/` and listed with
  `source: "repo"`
- paid/private plugins use official slugs and `source: "cache"`
- environment variables and secrets are configured outside the repo
- standard `wp-content` paths are used
- no Bedrock `/web`, `/content`, or `/wp` assumptions remain
- no theme Flush page or admin-bar Flush link duplicates Kinsta cache clearing
- cron/cache behavior is understood for the target host

## Common Pitfalls

- Copying old root `src/` wholesale and recreating the platform framework.
- Treating `nf/*` block slugs as PHP namespaces and renaming them.
- Leaving `/wp/wp-admin/admin-ajax.php` in JavaScript.
- Leaving `/assets/img` or `/app/views/img` public paths in CSS/Twig.
- Using Vite's native manifest without updating the PHP enqueue loader.
- Forgetting `type="module"` handling for Vite scripts.
- Adding a Flush admin page or admin-bar link just because an example has one;
  Kinsta-hosted sites normally rely on Kinsta's must-use plugin for object cache
  clearing.
- Moving business integrations into the theme when they should be plugins.
- Replacing paid/private plugins with public alternatives without approval.
- Inventing download URLs or using unofficial sources for paid plugins.
- Forgetting to ask a human to populate an empty paid plugin cache.
- Losing agency modifications by treating a tweaked public plugin as a plain
  wordpress.org slug.
- Assuming `nf theme package` runs the Vite build.
- Assuming every source site uses Timber 1.
- Dropping `extended-cpts` without checking admin columns, filters, and taxonomy
  behavior.
- Keeping old GraphQL args even though the target registrar strips them.
- Keeping `WP_ENV` checks when the target environment does not define it.
- Restoring Docker/Makefile deployment docs in a Kinsta-targeted repo.

## Acceptance Criteria

A migration is not done just because files moved.

The result should satisfy:

- repo has an `nf` root shape and valid `nf.json`
- theme code lives under `theme/`
- shared PHP foundation comes from `nonfiction/theme`
- local `theme/src/` contains only site-specific extensions, if any
- old platform infrastructure is absent or explicitly quarantined as reference
- Composer/npm are theme-scoped
- Vite builds `theme/dist/manifest.json` in the expected custom shape
- PHP bootstrap uses `App::init(get_template_directory())`
- blocks, CPTs, menus, templates, and assets work in the current theme
- required plugins are classified as public, cached paid/private, repo-local, or
  environment-managed prerequisites
- paid/private cache plugins use official slugs and have a populated local cache
  or a clearly reported human action item
- hard-coded platform paths have been audited
- Kinsta deployment assumptions are standard WordPress assumptions
- validation commands have been run or clearly bounded

When reporting results, state what changed, what was verified, and what remains
risky or untested.
