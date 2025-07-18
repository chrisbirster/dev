return {
	"stevearc/conform.nvim",
	event = "BufWritePre", -- or "LspAttach"
	cmd = { "ConformInfo" },

	opts = { -- <-- just the plain table, no requires here
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "biome", "prettierd", "prettier" },
			typescriptreact = { "biome", "prettierd", "prettier" },
			javascript = { "biome", "prettierd", "prettier" },
			javascriptreact = { "biome", "prettierd", "prettier" },
			css = { "biome", "prettierd", "prettier" },
			html = { "biome", "prettierd", "prettier" },
			json = { "biome", "prettierd", "prettier" },
			yaml = { "biome", "prettierd", "prettier" },
			sh = { "beautysh" },
			zsh = { "beautysh" },
			templ = { "templ" },
		},

		format_on_save = function(bufnr)
			return { lsp_fallback = true }
		end,
	},

	---------------------------------------------------------------------------
	-- Everything plugin-specific happens **inside** this callback
	---------------------------------------------------------------------------
	config = function(_, opts)
		local conform = require("conform") -- plugin is now on runtimepath
		conform.setup(opts)

		-- now it's safe to touch conform.util
		local util = require("conform.util")

		-- define / override formatters
		conform.formatters.prettierd = {
			command = util.from_node_modules(
				vim.loop.os_uname().sysname == "Windows_NT" and "prettierd.cmd" or "prettierd"
			),
			args = { "$FILENAME" },
			stdin = true,
		}

		conform.formatters.prettier = {
			command = util.from_node_modules(
				vim.loop.os_uname().sysname == "Windows_NT" and "prettier.cmd" or "prettier"
			),
			args = { "--stdin-filepath", "$FILENAME" },
			stdin = true,
		}

		-- optional: tweak beautysh indent size
		conform.formatters.beautysh = {
			prepend_args = { "--indent-size", "2" },
		}
	end,
}
