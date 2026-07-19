# Neovim Config Architecture

## Structure

```
~/.config/nvim/
├── init.lua                 -- Entry point. Only requires core modules.
├── lua/
│   ├── core/                -- Neovim settings, no plugins
│   │   ├── options.lua      -- vim.opt, vim.g, vim.o
│   │   ├── keymaps.lua      -- Base keymaps (no plugin dependencies)
│   │   ├── autocmds.lua     -- Autocommands
│   │   └── lazy.lua         -- lazy.nvim bootstrap + plugin loader
│   └── plugins/             -- Plugin specs, auto-imported by lazy.nvim
│       ├── lsp.lua
│       ├── completion.lua
│       ├── telescope.lua
│       └── ...
```

## Rules

### init.lua

- Contains only `require` calls to `core/*` modules.
- No plugin specs, no keymaps, no options — nothing else.

### core/

- **options.lua** — all `vim.opt`, `vim.o`, `vim.g` settings. No `require` of any plugin.
- **keymaps.lua** — keymaps that work without plugins (navigation, diagnostics, terminal). Plugin-specific keymaps belong in the plugin's file.
- **autocmds.lua** — autocommands not tied to a specific plugin.
- **lazy.lua** — bootstraps lazy.nvim and calls `require('lazy').setup({ import = 'plugins' })`. This is the only place that references the `plugins/` directory.

### plugins/

- **One file per plugin** (or per tightly coupled group, e.g. `lsp.lua` contains `lspconfig` + `mason` + `lazydev`).
- Each file returns a lazy.nvim plugin spec — either a single table or a list of tables.
- Plugin-specific keymaps, autocommands, and config go inside that plugin's file, not in `core/`.
- File name matches the plugin's purpose, not its repo name: `completion.lua` not `blink-cmp.lua`, `colorscheme.lua` not `tokyonight.lua`.

## How To

### Add a new plugin

Create `lua/plugins/<name>.lua`:

```lua
return {
  'author/plugin-name',
  opts = {},
}
```

lazy.nvim picks it up automatically — no imports to update.

### Disable a plugin

Either delete the file or add `enabled = false`:

```lua
return {
  'author/plugin-name',
  enabled = false,
}
```

### Add a keymap

- Depends on a plugin → put it in that plugin's file (inside `config`, `keys`, or `opts.on_attach`).
- General purpose → put it in `core/keymaps.lua`.

### Add an autocommand

- Triggered by a plugin event → put it in that plugin's file.
- General purpose → put it in `core/autocmds.lua`.

### Add a new LSP server

Edit `lua/plugins/lsp.lua`, add to the `servers` table:

```lua
local servers = {
  pyright = {},
  -- ...
}
```

Mason installs it automatically.

### Add a new formatter

Edit `lua/plugins/conform.lua`, add to `formatters_by_ft`:

```lua
formatters_by_ft = {
  lua = { 'stylua' },
  python = { 'black' },
}
```

### Add a new linter

Edit `lua/plugins/lint.lua`, add to `linters_by_ft`:

```lua
lint.linters_by_ft = {
  markdown = { 'markdownlint' },
  python = { 'flake8' },
}
```

## Conventions

- No business logic in `init.lua`.
- No cross-file dependencies between plugin files. Each plugin file is self-contained.
- Group tightly coupled plugins in one file (lsp + mason, completion + snippets) — split loosely coupled ones.
- Name files by function, not by plugin repo name.
- Keep `core/` free of plugin requires. If it needs a plugin, it belongs in `plugins/`.
