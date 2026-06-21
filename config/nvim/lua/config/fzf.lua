local ok, fzf = pcall(require, "fzf-lua")
if not ok then
  return
end

fzf.setup({
  "fzf-native",
  fzf_opts = {
    ["--layout"] = "reverse",
    ["--info"] = "inline",
  },
  files = {
    fd_opts = "--color=never --type f --hidden --follow --exclude .git",
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git",
  },
  winopts = {
    height = 0.85,
    width = 0.90,
    preview = {
      layout = "flex",
    },
  },
})

fzf.register_ui_select()

local map = vim.keymap.set
map("n", "<C-p>", fzf.files, { desc = "Find files" })
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fc", fzf.commands, { desc = "Commands" })
map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
