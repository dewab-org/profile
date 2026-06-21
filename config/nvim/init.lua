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
  local palette_ok, palette = pcall(
    require("catppuccin.palettes").get_palette,
    "mocha"
  )
  local colors = palette_ok and palette or {
    blue = "#89b4fa",
    crust = "#11111b",
    green = "#a6e3a1",
    lavender = "#b4befe",
    mauve = "#cba6f7",
    peach = "#fab387",
    red = "#f38ba8",
    sapphire = "#74c7ec",
    surface0 = "#313244",
    surface1 = "#45475a",
    teal = "#94e2d5",
    text = "#cdd6f4",
    yellow = "#f9e2af",
  }

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
        {
          "branch",
          color = {
            bg = colors.surface0,
            fg = colors.green,
            gui = "bold",
          },
        },
        {
          "diff",
          color = {
            bg = colors.surface0,
            fg = colors.yellow,
          },
          symbols = {
            added = "+",
            modified = "~",
            removed = "-",
          },
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.yellow },
            removed = { fg = colors.red },
          },
        },
      },
      lualine_c = {
        {
          "filename",
          color = {
            bg = colors.surface1,
            fg = colors.blue,
            gui = "bold",
          },
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
          color = {
            bg = colors.surface0,
            fg = colors.text,
          },
          sources = { "nvim_diagnostic" },
          symbols = {
            error = "E:",
            warn = "W:",
            info = "I:",
            hint = "H:",
          },
          diagnostics_color = {
            error = { fg = colors.red },
            warn = { fg = colors.yellow },
            info = { fg = colors.sapphire },
            hint = { fg = colors.teal },
          },
        },
        {
          "encoding",
          color = {
            bg = colors.surface0,
            fg = colors.lavender,
          },
        },
        {
          "fileformat",
          color = {
            bg = colors.surface0,
            fg = colors.peach,
          },
        },
        {
          "filetype",
          color = {
            bg = colors.surface1,
            fg = colors.mauve,
            gui = "bold",
          },
        },
      },
      lualine_y = {
        {
          "progress",
          color = {
            bg = colors.surface0,
            fg = colors.teal,
            gui = "bold",
          },
        },
      },
      lualine_z = {
        {
          "location",
          color = {
            bg = colors.blue,
            fg = colors.crust,
            gui = "bold",
          },
        },
      },
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
