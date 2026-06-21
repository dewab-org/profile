vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
      blink_cmp = true,
      cmp = true,
      gitsigns = true,
      native_lsp = {
        enabled = true,
      },
      treesitter = true,
      lualine = true,
    },
  })

  vim.cmd.colorscheme("catppuccin-mocha")
end

local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
  gitsigns.setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    current_line_blame = false,
  })
end

local lualine_ok, lualine = pcall(require, "lualine")
if lualine_ok then
  lualine.setup({
    options = {
      icons_enabled = true,
      theme = "catppuccin",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "dashboard", "lazy", "mason", "NvimTree" },
        winbar = {},
      },
      always_divide_middle = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        {
          "diff",
          symbols = {
            added = "+",
            modified = "~",
            removed = "-",
          },
        },
      },
      lualine_c = {
        {
          "filename",
          file_status = true,
          newfile_status = true,
          path = 1,
          symbols = {
            modified = "[+]",
            readonly = "[-]",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = "E:",
            warn = "W:",
            info = "I:",
            hint = "H:",
          },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = { "fugitive", "man", "quickfix" },
  })
end

require("config.fzf")
require("config.completion")
require("config.lsp")
require("config.format")
