local function open_diagnostic_float()
	vim.diagnostic.open_float({
		scope = "line",
		border = "rounded",
		source = "if_many",
		focusable = true,
		wrap = true,
		max_width = math.floor(vim.o.columns * 0.8),
		max_height = math.floor(vim.o.lines * 0.5),
	})
end

-- Show the complete diagnostic for the current line. Long messages wrap.
vim.keymap.set("n", "gl", open_diagnostic_float, { desc = "Show diagnostic details" })
vim.keymap.set("n", "<leader>vd", open_diagnostic_float, { desc = "Show diagnostic details" })

-- Put every diagnostic in quickfix for project-wide navigation.
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.setqflist({ open = true })
end, { silent = true, desc = "Open diagnostics in quickfix" })

-- Quickfix entries can contain long compiler messages; wrap instead of
-- clipping them at the window edge.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.wo.wrap = true
		vim.wo.linebreak = true
	end,
})

-- Goto previous diagnostic of any severity
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next diagnostic of any severity
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous error diagnostic
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next error diagnostic
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous warning diagnostic
vim.keymap.set("n", "[w", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next warning diagnostic
vim.keymap.set("n", "]w", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN})
	vim.api.nvim_feedkeys("zz", "n", false)
end)
