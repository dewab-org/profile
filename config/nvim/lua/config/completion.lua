local ok, blink = pcall(require, "blink.cmp")
if not ok then
  return
end

blink.setup({
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
    },
    ghost_text = {
      enabled = true,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  signature = {
    enabled = true,
  },
  fuzzy = {
    -- The Lua matcher keeps native-package installs portable and build-free.
    implementation = "lua",
  },
})
