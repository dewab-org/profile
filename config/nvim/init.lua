vim.opt.termguicolors = true
vim.opt.background = "dark"

local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "mocha",
    background = {
      light = "latte",
      dark = "mocha",
    },
    transparent_background = false,
    term_colors = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      native_lsp = {
        enabled = true,
      },
      treesitter = true,
    },
  })

  vim.cmd.colorscheme("catppuccin-mocha")
end
