local M = {}

-- Attempt to parse palette.sh and return a table of var->value strings.
-- Resolves simple $VAR references one level deep (enough for the alias chains).
local function parse_palette_sh()
   local paths = {
      vim.fn.expand("~/dotfiles/theme/palette.sh"),
      vim.fn.expand("~/.dotfiles/theme/palette.sh"),
      vim.fn.expand("~/.config/dotfiles/theme/palette.sh"),
   }

   local text
   for _, path in ipairs(paths) do
      local f = io.open(path, "r")
      if f then
         text = f:read("*a")
         f:close()
         break
      end
   end

   if not text then
      return nil
   end

   local vars = {}
   for line in text:gmatch("[^\n]+") do
      local key, val = line:match("^([%w_]+)=(%S+)")
      if key and val then
         -- Resolve $REF variable references
         val = val:gsub("%$([%w_]+)", function(ref)
            return vars[ref] or ref
         end)
         vars[key] = val
      end
   end
   return vars
end

-- Hardcoded fallback values (kept in sync with palette.sh)
local function hardcoded_fallback()
   -- dark variant
   local dark = {
      BG        = "333333",
      SURFACE   = "474747",
      OVERLAY   = "545454",
      FAINT     = "5E5E5E",
      DIM       = "686868",
      MUTED     = "727272",
      SUBTLE    = "7C7C7C",
      BORDER    = "868686",
      SECONDARY = "909090",
      TERTIARY  = "9A9A9A",
      FG        = "A4A4A4",
      EMPHASIS  = "AEAEAE",
      STRONG    = "B8B8B8",
      BRIGHT    = "C2C2C2",
      INTENSE   = "CCCCCC",
      RED       = "E67E80",
      YELLOW    = "DBBC7F",
      GREEN     = "A7C080",
      BLUE      = "7FBBB3",
      AQUA      = "83C092",
      PURPLE    = "D699B6",
      ORANGE    = "E69875",
      BG_RED    = "4C3743",
      BG_GREEN  = "3C4841",
      BG_BLUE   = "384B55",
   }
   -- light variant
   local light = {
      BG        = "CCCCCC",
      SURFACE   = "C2C2C2",
      OVERLAY   = "AEAEAE",
      FAINT     = "A4A4A4",
      DIM       = "9A9A9A",
      MUTED     = "909090",
      SUBTLE    = "868686",
      BORDER    = "7C7C7C",
      SECONDARY = "727272",
      TERTIARY  = "686868",
      FG        = "5E5E5E",
      EMPHASIS  = "545454",
      STRONG    = "4A4A4A",
      BRIGHT    = "474747",
      INTENSE   = "333333",
      RED       = "F85552",
      YELLOW    = "DFA000",
      GREEN     = "8DA101",
      BLUE      = "3A94C5",
      AQUA      = "35A77C",
      PURPLE    = "DF69BA",
      ORANGE    = "F57D26",
      BG_RED    = "FFE7DE",
      BG_GREEN  = "f3f5d9",
      BG_BLUE   = "ECF5ED",
   }
   -- Build a flat vars table keyed as DARK_X / LIGHT_X
   local vars = {}
   for k, v in pairs(dark) do
      vars["DARK_" .. k] = v
   end
   for k, v in pairs(light) do
      vars["LIGHT_" .. k] = v
   end
   -- Derived semantic aliases for accents
   local function alias(prefix, dst, src)
      vars[prefix .. dst] = vars[prefix .. src]
   end
   for _, p in ipairs({ "DARK_", "LIGHT_" }) do
      alias(p, "ERROR",      "RED")
      alias(p, "WARNING",    "YELLOW")
      alias(p, "OK",         "GREEN")
      alias(p, "INFO",       "AQUA")
      alias(p, "HINT",       "BLUE")
      alias(p, "SEARCH",     "ORANGE")
      alias(p, "VCS_ADD",    "GREEN")
      alias(p, "VCS_CHANGE", "BLUE")
      alias(p, "VCS_REMOVE", "RED")
      alias(p, "DIFF_ADD",    "BG_GREEN")
      alias(p, "DIFF_CHANGE", "BG_BLUE")
      alias(p, "DIFF_REMOVE", "BG_RED")
   end
   return vars
end

function M.get()
   local vars = parse_palette_sh() or hardcoded_fallback()
   local prefix = vim.o.background == "light" and "LIGHT_" or "DARK_"

   local function v(name)
      local val = vars[prefix .. name]
      if not val then
         return "#000000"
      end
      return "#" .. val
   end

   return {
      mono = {
         bg        = v("BG"),
         surface   = v("SURFACE"),
         overlay   = v("OVERLAY"),
         faint     = v("FAINT"),
         dim       = v("DIM"),
         muted     = v("MUTED"),
         subtle    = v("SUBTLE"),
         border    = v("BORDER"),
         secondary = v("SECONDARY"),
         tertiary  = v("TERTIARY"),
         fg        = v("FG"),
         emphasis  = v("EMPHASIS"),
         strong    = v("STRONG"),
         bright    = v("BRIGHT"),
         intense   = v("INTENSE"),
      },
      accent = {
         error       = v("ERROR"),
         warning     = v("WARNING"),
         ok          = v("OK"),
         info        = v("INFO"),
         hint        = v("HINT"),
         search      = v("SEARCH"),
         add         = v("VCS_ADD"),
         change      = v("VCS_CHANGE"),
         remove      = v("VCS_REMOVE"),
         diff_add    = v("DIFF_ADD"),
         diff_change = v("DIFF_CHANGE"),
         diff_remove = v("DIFF_REMOVE"),
      },
      raw = {
         red      = v("RED"),
         yellow   = v("YELLOW"),
         green    = v("GREEN"),
         blue     = v("BLUE"),
         aqua     = v("AQUA"),
         purple   = v("PURPLE"),
         orange   = v("ORANGE"),
         bg_red   = v("BG_RED"),
         bg_green = v("BG_GREEN"),
         bg_blue  = v("BG_BLUE"),
      },
   }
end

return M
