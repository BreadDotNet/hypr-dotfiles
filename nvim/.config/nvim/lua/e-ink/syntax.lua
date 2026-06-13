local M = {}

local function set_hl(group, styles)
   vim.api.nvim_set_hl(0, group, styles)
end

function M.generate_syntax()
   local set_var = vim.api.nvim_set_var
   local palette = require("e-ink.palette").get()
   local p      = palette.mono
   local accent = palette.accent
   local raw    = palette.raw

   local lsp_kind_colors = {
      Array         = raw.aqua,
      Boolean       = raw.aqua,
      Class         = raw.brown,
      Color         = raw.aqua,
      Constant      = raw.brown,
      Constructor   = p.border,
      Default       = raw.aqua,
      Enum          = raw.yellow,
      EnumMember    = raw.purple,
      Event         = raw.orange,
      Field         = raw.blue,
      File          = p.fg,
      Folder        = p.fg,
      Function      = p.fg,
      Interface     = raw.brown,
      Key           = raw.brick,
      Keyword       = p.border,
      Method        = p.fg,
      Module        = p.border,
      Namespace     = raw.purple,
      Null          = raw.aqua,
      Number        = raw.grass,
      Object        = raw.aqua,
      Operator      = p.border,
      Package       = raw.purple,
      Property      = raw.blue,
      Reference     = raw.aqua,
      Snippet       = raw.aqua,
      String        = raw.cactus,
      Struct        = raw.brown,
      Text          = p.fg,
      TypeParameter = raw.yellow,
      Unit          = raw.purple,
      Value         = raw.purple,
      Variable      = p.fg,
   }

   -- terminal colors use literal color names, so raw values are correct here
   set_var("terminal_color_0",  p.bg)
   set_var("terminal_color_1",  raw.red)
   set_var("terminal_color_2",  raw.green)
   set_var("terminal_color_3",  raw.yellow)
   set_var("terminal_color_4",  raw.blue)
   set_var("terminal_color_5",  raw.purple)
   set_var("terminal_color_6",  raw.aqua)
   set_var("terminal_color_7",  p.subtle)
   set_var("terminal_color_8",  p.border)
   set_var("terminal_color_9",  raw.red)
   set_var("terminal_color_10", raw.green)
   set_var("terminal_color_11", raw.yellow)
   set_var("terminal_color_12", raw.blue)
   set_var("terminal_color_13", raw.purple)
   set_var("terminal_color_14", raw.aqua)
   set_var("terminal_color_15", p.intense)

   set_hl("ColorColumn",   { link = "CursorLine" })
   set_hl("Comment",       { fg = p.muted })
   set_hl("Constant",      { link = "@variable" })
   set_hl("CurSearch",     { fg = raw.fruit, underline = true })
   set_hl("CursorColumn",  { link = "CursorLine" })
   set_hl("CursorLine",    { bg = p.surface })
   set_hl("CursorLineNr",  { bg = p.surface })
   set_hl("Delimiter",     { fg = p.fg })
   set_hl("Directory",     { fg = p.fg })
   set_hl("EndOfBuffer",   { fg = p.bg })
   set_hl("ErrorMsg",      { fg = accent.error })
   set_hl("FloatBorder",   { fg = p.secondary })
   set_hl("Folded",        { bg = p.surface })
   set_hl("Function",      { fg = p.fg })
   set_hl("Identifier",    { fg = p.fg })
   set_hl("MoreMsg",       { fg = p.bright })
   set_hl("Normal",        { fg = p.fg, bg = p.bg })
   set_hl("NormalFloat",   { link = "Normal" })
   set_hl("Number",        { fg = raw.grass })
   set_hl("Boolean",       { fg = raw.grass })
   set_hl("Character",     { fg = raw.grass })
   set_hl("Operator",      { fg = p.border })
   set_hl("PMenu",         { bg = p.surface })
   set_hl("Question",      { link = "MoreMsg" })
   set_hl("QuickFixLine",  { link = "MoreMsg" })
   set_hl("Search",        { fg = raw.fruit, underline = true })
   set_hl("Special",       { fg = raw.purple })
   set_hl("SpecialChar",   { fg = raw.purple })
   set_hl("SpecialKey",    { fg = raw.purple })
   set_hl("SpellBad",      { sp = accent.error,   undercurl = true })
   set_hl("SpellCap",      { sp = accent.hint,    undercurl = true })
   set_hl("SpellLocal",    { sp = accent.ok,      undercurl = true })
   set_hl("SpellRare",     { sp = raw.purple,     undercurl = true })
   set_hl("Statement",     { fg = p.fg })
   set_hl("StatusLine",    { fg = p.strong, bg = p.bg, bold = true })
   set_hl("StatusLineNC",  { fg = p.border, bg = p.bg })
   set_hl("String",        { fg = raw.cactus })
   set_hl("Tabline",       { fg = p.subtle, bg = p.overlay })
   set_hl("TablineFill",   { bg = p.bg })
   set_hl("Title",         { fg = raw.cyan, bold = true })
   set_hl("Todo",          { fg = raw.fruit })
   set_hl("Type",          { fg = p.fg })
   set_hl("Visual",        { bg = p.overlay })
   set_hl("WarningMsg",    { fg = accent.warning })
   set_hl("WinBar",        { bg = p.overlay })
   set_hl("WinBarNC",      { link = "WinBar" })
   set_hl("WinSeparator",  { fg = p.border })

   set_hl("Added",   { fg = accent.add })
   set_hl("Changed", { fg = accent.change })
   set_hl("Removed", { fg = accent.remove })

   set_hl("GitSignsAdd",          { fg = accent.add })
   set_hl("GitSignsChange",       { fg = accent.change })
   set_hl("GitSignsDelete",       { fg = accent.remove })
   set_hl("GitSignsTopdelete",    { fg = accent.remove })
   set_hl("GitSignsChangedelete", { fg = accent.change })

   set_hl("OilDir",          { fg = p.fg })
   set_hl("OilDirHidden",    { fg = p.muted })
   set_hl("OilDirIcon",      { fg = p.fg })
   set_hl("OilFile",         { fg = p.fg })
   set_hl("OilFileHidden",   { fg = p.muted })
   set_hl("OilCreate",       { fg = accent.add })
   set_hl("OilDelete",       { fg = accent.remove })
   set_hl("OilChange",       { fg = accent.change })
   set_hl("OilMove",         { fg = raw.blue })
   set_hl("OilCopy",         { fg = raw.purple })
   set_hl("OilRestore",      { fg = accent.add })
   set_hl("OilPurge",        { fg = accent.remove })
   set_hl("OilTrash",        { fg = accent.remove })
   set_hl("OilGitAdded",            { fg = accent.add })
   set_hl("OilGitModified",         { fg = accent.change })
   set_hl("OilGitModifiedStaged",   { fg = accent.change })
   set_hl("OilGitModifiedUnstaged", { fg = raw.orange })
   set_hl("OilGitBranch",           { fg = raw.blue })
   set_hl("OilGitRenamed",          { fg = raw.purple })
   set_hl("OilGitDeleted",          { fg = accent.remove })
   set_hl("OilGitCopied",           { fg = raw.purple })
   set_hl("OilGitConflict",         { fg = raw.orange })
   set_hl("OilGitUntracked",        { fg = raw.blue })
   set_hl("OilGitIgnored",          { fg = p.muted })

   set_hl("Label",        { fg = raw.blue })
   set_hl("Tag",          { fg = raw.blue })
   set_hl("MatchParen",   { fg = raw.cyan })

   set_hl("DiagnosticOk",             { fg = accent.ok })
   set_hl("DiagnosticHint",           { fg = p.muted })
   set_hl("DiagnosticInfo",           { fg = p.muted })
   set_hl("DiagnosticWarn",           { fg = accent.warning })
   set_hl("DiagnosticError",          { fg = accent.error })
   set_hl("DiagnosticUnderlineOk",    { sp = accent.ok,      underline = true })
   set_hl("DiagnosticUnderlineHint",  { sp = accent.hint,    underline = true })
   set_hl("DiagnosticUnderlineInfo",  { sp = accent.info,    underline = true })
   set_hl("DiagnosticUnderlineWarn",  { sp = accent.warning, underline = true })
   set_hl("DiagnosticUnderlineError", { sp = accent.error,   underline = true })

   set_hl("markdownLinkText", { underline = false })
   set_hl("markdownUrl",      { underline = true })

   set_hl("DiffAdd",     { bg = accent.diff_add })
   set_hl("DiffChange",  { bg = accent.diff_change })
   set_hl("DiffDelete",  { bg = accent.diff_remove })
   set_hl("DiffText",    { fg = raw.brown })
   set_hl("diffAdded",   { link = "DiagnosticOk" })
   set_hl("diffChanged", { link = "DiagnosticHint" })
   set_hl("diffRemoved", { link = "DiagnosticError" })
   set_hl("@diff.plus",  { link = "DiagnosticOk" })
   set_hl("@diff.delta", { link = "DiagnosticHint" })
   set_hl("@diff.minus", { link = "DiagnosticError" })

   set_hl("NotifyInfoIcon",   { link = "DiagnosticOk" })
   set_hl("NotifyWarnIcon",   { link = "DiagnosticWarn" })
   set_hl("NotifyErrorIcon",  { link = "DiagnosticError" })
   set_hl("NotifyInfoTitle",  { link = "DiagnosticOk" })
   set_hl("NotifyWarnTitle",  { link = "DiagnosticWarn" })
   set_hl("NotifyErrorTitle", { link = "DiagnosticError" })
   set_hl("NotifyInfoBorder", { link = "DiagnosticOk" })
   set_hl("NotifyWarnBorder", { link = "DiagnosticWarn" })
   set_hl("NotifyErrorBorder",{ link = "DiagnosticError" })

   set_hl("@keyword",                { fg = p.border })
   set_hl("@constant.builtin",       { fg = raw.brown })
   set_hl("@constructor",            { fg = p.border })
   set_hl("@function",               { fg = p.fg })
   set_hl("@function.builtin",       { fg = p.fg })
   set_hl("@function.method",        { fg = p.fg })
   set_hl("@function.macro",         { fg = p.border })
   set_hl("@method",                 { fg = p.fg })
   set_hl("@field",                  { fg = raw.blue })
   set_hl("@property",               { fg = raw.blue })
   set_hl("@attribute",              { fg = raw.brown })
   set_hl("@keyword.storage",        { fg = raw.blue })
   set_hl("@keyword.conditional",    { fg = p.border })
   set_hl("@keyword.exception",      { fg = p.border })
   set_hl("@keyword.import",         { fg = p.border })
   set_hl("@keyword.operator",       { fg = p.border })
   set_hl("@keyword.repeat",         { fg = p.border })
   set_hl("@module",                 { fg = p.border })
   set_hl("@namespace",              { fg = p.border })
   set_hl("@number",                 { fg = raw.grass })
   set_hl("@number.float",           { fg = raw.grass })
   set_hl("@boolean",                { fg = raw.grass })
   set_hl("@character",              { fg = raw.grass })
   set_hl("@operator",               { fg = p.border })
   set_hl("@string",                 { fg = raw.cactus })
   set_hl("@string.special",         { fg = raw.purple })
   set_hl("@string.escape",          { fg = raw.purple })
   set_hl("@constant",               { fg = p.fg })
   set_hl("@constant.macro",         { fg = p.border })
   set_hl("@label",                  { fg = raw.blue })
   set_hl("@type",                   { fg = p.fg })
   set_hl("@type.builtin",           { fg = p.fg })
   set_hl("@type.qualifier",         { fg = p.border })
   set_hl("@variable",               { fg = p.fg })
   set_hl("@variable.builtin",       { fg = raw.cactus })
   set_hl("@markup.link",            { fg = raw.blue })
   set_hl("@markup.link.label",      { bold = true, underline = false })
   set_hl("@markup.link.url",        { fg = p.subtle, bold = false, underline = true })
   set_hl("@markup.list.checked",    { fg = p.muted,  bold = true })
   set_hl("@markup.list.unchecked",  { fg = p.intense, bold = true })
   set_hl("@markup.quote",           { fg = p.subtle })
   set_hl("@markup.raw",             { fg = p.subtle })
   set_hl("@markup.strong",          { fg = p.intense, bold = true })
   set_hl("@punctuation.bracket",    { bold = true })
   set_hl("@tag",                    { fg = raw.blue, bold = true })
   set_hl("@tag.attribute",          { fg = raw.brown, bold = true })
   set_hl("@tag.delimiter",          { fg = p.subtle, bold = false })

   set_hl("TreesitterContextBottom", { underline = true })

   set_hl("EyelinerPrimary",   { fg = p.fg,  bold = true, reverse = true })
   set_hl("EyelinerSecondary", { fg = p.dim, bold = true, reverse = true })

   set_hl("FzfLuaBufNr",       { fg = p.faint })
   set_hl("FzfLuaHeaderBind",  { fg = p.faint })
   set_hl("FzfLuaLivePrompt",  { fg = p.fg })
   set_hl("FzfLuaLiveSym",     { fg = p.fg })
   set_hl("FzfLuaPathLineNr",  { fg = p.faint })
   set_hl("FzfLuaTabMarker",   { fg = p.bright })

   set_hl("htmlArg",     { link = "@tag.attribute" })
   set_hl("htmlTag",     { link = "@tag.delimiter" })
   set_hl("htmlTagName", { link = "@tag" })

   set_hl("xmlAttrib",   { link = "@tag.attribute" })
   set_hl("xmlTag",      { link = "@tag.delimiter" })
   set_hl("xmlTagName",  { link = "@tag" })

   set_hl("BlinkCmpDoc",           { link = "Pmenu" })
   set_hl("BlinkCmpDocBorder",     { link = "Pmenu" })
   set_hl("BlinkCmpDocSeparator",  { link = "Pmenu" })
   set_hl("BlinkCmpMenuSelection", { link = "Visual" })
   for kind, color in pairs(lsp_kind_colors) do
      set_hl("BlinkCmpKind" .. kind, { fg = color })
   end

   set_hl("diffFile",    { fg = raw.orange, bold = true })
   set_hl("diffLine",    { fg = raw.blue,   bold = true })
   set_hl("diffNewFile", { fg = raw.green,  bold = true })
   set_hl("diffOldFile", { fg = raw.red,    bold = true })
   set_hl("gitHash",         { fg = p.intense, bold = true })
   set_hl("gitHashAbbrev",   { link = "gitHash" })
   set_hl("gitIdentity",     { fg = p.intense, bold = true })
   set_hl("fugitiveHash",              { link = "gitHash" })
   set_hl("fugitiveStagedHeading",     { fg = raw.green,  bold = true })
   set_hl("fugitiveStagedModifier",    { link = "fugitiveStagedHeading" })
   set_hl("fugitiveUntrackedHeading",  { fg = raw.red,    bold = true })
   set_hl("fugitiveUntrackedModifier", { link = "fugitiveUntrackedHeading" })
   set_hl("fugitiveUnstagedHeading",   { fg = raw.orange, bold = true })
   set_hl("fugitiveUnstagedModifier",  { link = "fugitiveUnstagedHeading" })

   set_hl("Bold",              { fg = p.intense, bold = true })
   set_hl("LazyCommitIssue",   { fg = raw.orange, bold = true })
   set_hl("LazyCommitType",    { fg = p.intense,  bold = true })
   set_hl("LazyReasonCmd",     { fg = raw.yellow })
   set_hl("LazyReasonEvent",   { fg = raw.orange })
   set_hl("LazyReasonFt",      { fg = raw.green })
   set_hl("LazyReasonImport",  { fg = raw.blue })
   set_hl("LazyReasonIssue",   { fg = raw.orange })
   set_hl("LazyReasonKeys",    { fg = raw.red })
   set_hl("LazyReasonPlugin",  { fg = raw.yellow })
   set_hl("LazyReasonRequire", { fg = raw.red })
   set_hl("LazyReasonSource",  { fg = raw.aqua })
   set_hl("LazyReasonStart",   { fg = raw.blue })
end

return M
