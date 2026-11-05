local side_width = 32
local minimum_editor_width = 90

local function editor_width()
	-- Keep the side panels visually consistent on large displays and give all
	-- additional horizontal space to the editor. On smaller displays, retain
	-- the original 90-column editor and allow the side panels to shrink.
	return math.max(minimum_editor_width, vim.o.columns - (side_width * 2))
end

require("no-neck-pain").setup({
	width = editor_width(),
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

local responsive_layout_group = vim.api.nvim_create_augroup("ViminatrixResponsiveCenteredLayout", {
	clear = true,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = responsive_layout_group,
	desc = "Expand the centered editor while keeping fixed-width side panels",
	callback = function()
		vim.schedule(function()
			local state = _G.NoNeckPain and _G.NoNeckPain.state
			if state and state.enabled then
				require("no-neck-pain").resize(editor_width())
			end
		end)
	end,
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
