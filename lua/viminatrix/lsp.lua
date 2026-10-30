-- lsp
vim.lsp.enable({ "lua_ls", "tsgo", "ts_ls", "gopls", "zls" })
vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local opts = { buffer = ev.buf }
    if client ~= nil and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      -- Ensure $ triggers completions for MongoDB pipeline/query operators
      if client.name == "mongodb_ls" then
        local cp = client.server_capabilities.completionProvider
        if cp then
          cp.triggerCharacters = cp.triggerCharacters or {}
          if not vim.tbl_contains(cp.triggerCharacters, "$") then
            table.insert(cp.triggerCharacters, "$")
          end
        end
      end
    end
    if client ~= nil and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    vim.keymap.set("n", "<leader>vh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
    end, { buffer = ev.buf, desc = "Toggle inlay hints" })

    vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
    end, opts)

    vim.keymap.set("n", "gD", function()
      vim.lsp.buf.declaration()
    end, opts)

    vim.keymap.set("n", "<leader>ws", function()
      vim.lsp.buf.workspace_symbol()
    end, opts)

    vim.keymap.set("n", "<leader>ds", function()
      vim.lsp.buf.document_symbol()
    end, opts)

    vim.keymap.set("n", "<leader>ca", function()
      vim.lsp.buf.code_action()
    end, opts)

    vim.keymap.set("n", "<leader>gr", function()
      vim.lsp.buf.references()
    end, opts)

    vim.keymap.set("n", "<leader>rn", function()
      vim.lsp.buf.rename()
    end, opts)

    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, opts)

    vim.keymap.set("n", "<leader>k", function()
      vim.lsp.buf.signature_help()
    end, opts)

    vim.keymap.set("i", "<C-k>", function()
      vim.lsp.buf.signature_help()
    end, opts)
  end,
})

vim.cmd("set completeopt+=noselect")
