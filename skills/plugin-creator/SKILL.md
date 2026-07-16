---
name: plugin-creator
description: Scaffold codewhale local plugin directories and activation notes. Use when the user asks to create, package, or sketch a plugin for codewhale.
---

# Plugin Creator

Use this skill when a user wants a DeepSeek plugin scaffold or a plan for a
plugin-style extension.

DeepSeek plugins are currently a documented packaging convention, not an
auto-loaded runtime. Be explicit about that. A plugin becomes active only when
it is referenced from a skill, hook, MCP server, or future plugin loader.

## Workflow

1. Pick the location:
   - Global user plugin: `~/.deepseek/plugins/<plugin-name>/`
   - Workspace plugin: `<workspace>/plugins/<plugin-name>/`
2. Before creating, verify the target directory does not already exist. If it
   does, warn the user and list the existing files. Ask for explicit
   confirmation before overwriting or merging into an existing directory.
3. Normalize names to lower-case hyphen-case.
4. Create `PLUGIN.md` with frontmatter:

```markdown
---
name: my-plugin
description: What this plugin packages or enables.
status: draft
---

# My Plugin

What it does, how to enable it, and any scripts or MCP servers it expects.
```

5. Add companion folders only when useful:
   - `skills/` for model instructions
   - `scripts/` for helpers invoked by a skill or hook
   - `mcp/` for an MCP server package or config notes
   - `assets/` for templates, examples, or fixtures
6. Include an activation section in `PLUGIN.md` that says exactly how the user
   should turn it on today.
7. Validate by listing the created files and checking that `PLUGIN.md` has
   `name` and `description` frontmatter.

Do not claim that dropping a folder into `plugins/` changes runtime behavior by
itself. If the user asks for a live plugin system, propose a loader design
separately and keep the scaffold honest.
