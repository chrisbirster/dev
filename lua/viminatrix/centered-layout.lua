require("no-neck-pain").setup({
	width = 90,
	minSideBufferWidth = 10,
	disableOnLastBuffer = false,
	killAllBuffersOnDisable = false,
	fallbackOnBufferDelete = true,
	autocmds = {
		enableOnVimEnter = "safe",
		enableOnTabEnter = true,
		reloadOnColorSchemeChange = true,
		skipEnteringNoNeckPainBuffer = true,
	},
	mappings = {
		enabled = false,
	},
	buffers = {
		setNames = true,
		colors = {
			background = "rose-pine",
			blend = -0.15,
		},
	},
	integrations = {
		["neo-tree"] = {
			position = "left",
		},
		dap = {
			position = "right",
		},
	},
})

-- Keep the old Zen Mode key, now backed by a layout that can coexist with
-- normal sidebars and persists while switching buffers.
vim.keymap.set("n", "<leader>zz", "<cmd>NoNeckPain<cr>", {
	silent = true,
	desc = "Toggle centered editor layout",
})

vim.keymap.set("n", "<leader>z+", "<cmd>NoNeckPainWidthUp<cr>", {
	silent = true,
	desc = "Increase centered editor width",
})

vim.keymap.set("n", "<leader>z-", "<cmd>NoNeckPainWidthDown<cr>", {
	silent = true,
	desc = "Decrease centered editor width",
})
