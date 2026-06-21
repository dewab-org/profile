local blink_ok, blink = pcall(require, "blink.cmp")
local capabilities = blink_ok
    and blink.get_lsp_capabilities()
  or vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

local servers = {
  bashls = "bash-language-server",
  clangd = "clangd",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  ruff = "ruff",
  terraformls = "terraform-ls",
  yamlls = "yaml-language-server",
}

for server, executable in pairs(servers) do
  if vim.fn.executable(executable) == 1 then
    vim.lsp.enable(server)
  end
end

vim.diagnostic.config({
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, {
        buffer = event.buf,
        desc = desc,
      })
    end

    local fzf_ok, fzf = pcall(require, "fzf-lua")
    if fzf_ok then
      map("gd", fzf.lsp_definitions, "Go to definition")
      map("gr", fzf.lsp_references, "Find references")
      map("gI", fzf.lsp_implementations, "Go to implementation")
      map("<leader>ds", fzf.lsp_document_symbols, "Document symbols")
      map("<leader>ws", fzf.lsp_workspace_symbols, "Workspace symbols")
    end

    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
  end,
})
