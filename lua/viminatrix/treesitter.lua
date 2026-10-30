require("nvim-treesitter").setup()
require("nvim-treesitter").install({
	"lua",
	"python",
	"typescript",
	"javascript",
	"go",
	"markdown",
	"markdown_inline",
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ViminatrixMarkdownTreesitter", { clear = true }),
	pattern = "markdown",
	callback = function(args)
		vim.treesitter.start(args.buf)
	end,
})
