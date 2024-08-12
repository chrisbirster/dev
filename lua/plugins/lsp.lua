return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      -- Plugin and UI to automatically install LSPs to stdpath
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      "hrsh7th/cmp-nvim-lsp",

      -- Install neodev for better nvim configuration and plugin authoring via lsp configurations
      "folke/neodev.nvim",

      -- Progress/Status update for LSP
      { "j-hui/fidget.nvim", tag = "legacy" },
    },
    config = function()
      local map_lsp_keybinds = require("viminatrix.keymaps").map_lsp_keybinds -- Has to load keymaps before pluginslsp
      local opam_prefix = os.getenv("OPAM_SWITCH_PREFIX")
      local opam_cmd = opam_prefix .. "_opam/bin/ocamllsp"

      -- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
      require("neodev").setup()

      -- Setup mason so it can manage 3rd party LSP servers
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })

      -- Configure mason to auto install servers
      require("mason-lspconfig").setup({
        automatic_installation = { exclude = { "ocamllsp", "gleam" } },
      })

      -- Override tsserver diagnostics to filter out specific messages
      local messages_to_filter = {
        "This may be converted to an async function.",
        "'_Assertion' is declared but never used.",
        "'__Assertion' is declared but never used.",
        "The signature '(data: string): string' of 'atob' is deprecated.",
        "The signature '(data: string): string' of 'btoa' is deprecated.",
      }

      local function tsserver_on_publish_diagnostics_override(_, result, ctx, config)
        local filtered_diagnostics = {}

        for _, diagnostic in ipairs(result.diagnostics) do
          local found = false
          for _, message in ipairs(messages_to_filter) do
            if diagnostic.message == message then
              found = true
              break
            end
          end
          if not found then
            table.insert(filtered_diagnostics, diagnostic)
          end
        end

        result.diagnostics = filtered_diagnostics

        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
      end

      -- LSP servers to install (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )

      local servers = {
        bashls = {},
        -- clangd = {},
        cssls = {},
        gleam = {},
        graphql = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enabled = false },
            },
          },
        },
        marksman = {},
        gopls = {},
        prismals = {},
        pyright = {},
        solidity = {},
        sqlls = {},
        templ = {},
        ocamllsp = {
          cmd = { opam_cmd },
        },
        tailwindcss = {
          filetypes = {
            "gleam",
          },
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  '\\bclass[\\s(<|]+"([^"]*)"',
                },
              },
            },
          },
        },
        tsserver = {
          settings = {
            experimental = {
              enableProjectDiagnostics = true,

            },
          },
          handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
              tsserver_on_publish_diagnostics_override,
              {}
            ),
          },
        },
        yamlls = {},
        zls = {
          cmd = { '/Users/gm/.local/share/nvim/mason/packages/zls/zig-out/bin/zls' },
        },
      }

      -- Default handlers for LSP
      local default_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local default_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      ---@diagnostic disable-next-line: unused-local
      local on_attach = function(_client, buffer_number)
        -- Pass the current buffer to map lsp keybinds
        map_lsp_keybinds(buffer_number)

        -- if client.server_capabilities.codeLensProvider then
        -- 	vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
        -- 		buffer = buffer_number,
        -- 		callback = vim.lsp.codelens.refresh,
        -- 		desc = "LSP: Refresh code lens",
        -- 		group = vim.api.nvim_create_augroup("codelens", { clear = true }),
        -- 	})
        -- end
      end

      -- Iterate over our servers and set them up
      for name, config in pairs(servers) do
        require("lspconfig")[name].setup({
          capabilities = default_capabilities,
          filetypes = config.filetypes,
          handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
          on_attach = on_attach,
          settings = config.settings,
        })
      end

      -- Configure borderd for LspInfo ui
      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- Configure diagostics border
      vim.diagnostic.config({
        float = {
          border = "rounded",
        },
      })
    end,
  },
}
