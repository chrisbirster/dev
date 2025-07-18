return {
	"rose-pine/neovim",
	name = "rose-pine",
	priority = 1000, -- Make sure to load this before all the other start plugins.
	config = function()
		require("rose-pine").setup({
			disable_background = false,
		})
		vim.cmd.colorscheme("rose-pine")
	end,
}
