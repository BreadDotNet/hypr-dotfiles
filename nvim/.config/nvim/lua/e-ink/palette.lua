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
      BG        = "121212",
      SURFACE   = "1C1C1C",
      OVERLAY   = "303030",
      FAINT     = "3A3A3A",
      DIM       = "444444",
      MUTED     = "585858",
      SUBTLE    = "626262",
      BORDER    = "767676",
      SECONDARY = "808080",
      TERTIARY  = "8A8A8A",
      FG        = "949494",
      EMPHASIS  = "9E9E9E",
      STRONG    = "A8A8A8",
      BRIGHT    = "B2B2B2",
      INTENSE   = "BCBCBC",
      RED       = "D75F5F",
      YELLOW    = "AF875F",
      GREEN     = "87AF87",
      BLUE      = "5F87AF",
      AQUA      = "87AFD7",
      PURPLE    = "8787AF",
      ORANGE    = "D7875F",
      CACTUS    = "5F875F",
      GRASS     = "87AF87",
      FRUIT     = "D787AF",
      BRICK     = "875F5F",
      BROWN     = "AF875F",
      CYAN      = "87AFD7",
      BG_RED    = "2A1F1F",
      BG_GREEN  = "1F2A1F",
      BG_BLUE   = "1F252A",
   }
   -- light variant
   local light = {
      BG        = "EEEEEE",
      SURFACE   = "E4E4E4",
      OVERLAY   = "D0D0D0",
      FAINT     = "C6C6C6",
      DIM       = "BCBCBC",
      MUTED     = "A8A8A8",
      SUBTLE    = "9E9E9E",
      BORDER    = "949494",
      SECONDARY = "808080",
      TERTIARY  = "6C6C6C",
      FG        = "585858",
      EMPHASIS  = "4E4E4E",
      STRONG    = "444444",
      BRIGHT    = "303030",
      INTENSE   = "1C1C1C",
      RED       = "875F5F",
      YELLOW    = "875F00",
      GREEN     = "4E754E",
      BLUE      = "3F6F8F",
      AQUA      = "2F7373",
      PURPLE    = "5F5F87",
      ORANGE    = "875F00",
      CACTUS    = "4E754E",
      GRASS     = "4E754E",
      FRUIT     = "875F87",
      BRICK     = "875F5F",
      BROWN     = "875F00",
      CYAN      = "2F7373",
      BG_RED    = "E8DEDE",
      BG_GREEN  = "DEE8DE",
      BG_BLUE   = "DEE5EA",
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
      alias(p, "WARNING",    "ORANGE")
      alias(p, "OK",         "GREEN")
      alias(p, "INFO",       "AQUA")
      alias(p, "HINT",       "BLUE")
      alias(p, "SEARCH",     "FRUIT")
      alias(p, "VCS_ADD",    "CACTUS")
      alias(p, "VCS_CHANGE", "BROWN")
      alias(p, "VCS_REMOVE", "BRICK")
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
         cactus   = v("CACTUS"),
         grass    = v("GRASS"),
         fruit    = v("FRUIT"),
         brick    = v("BRICK"),
         brown    = v("BROWN"),
         cyan     = v("CYAN"),
         bg_red   = v("BG_RED"),
         bg_green = v("BG_GREEN"),
         bg_blue  = v("BG_BLUE"),
      },
   }
end

return M
