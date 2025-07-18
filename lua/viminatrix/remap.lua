local utils = require("viminatrix.utils")

local opts = { noremap = true, silent = true }

-- Harpoon
vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>2", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", opts)

-- Map NeoTree to leader e
vim.keymap.set("n", "<leader>e", ":Neotree position=left toggle=true reveal<CR>")

vim.keymap.set("i", "jk", "<Esc>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

-- Normal --
-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("n", "<space>", "<nop>")

-- Swap between last two buffers
vim.keymap.set("n", "<leader>;", "<C-^>", { desc = "Switch to last buffer" })

-- Save with leader key
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = false })

-- Quit with leader key
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = false })

-- Save and Quit with leader key
vim.keymap.set("n", "<leader>z", "<cmd>wq<cr>", { silent = false })

-- Map NeoTree to leader e
vim.keymap.set("n", "<leader>e", ":Neotree position=left toggle=true reveal<CR>", { desc = "[E]xplorer" })

-- Center buffer while navigating
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "gg", "ggzz")
vim.keymap.set("n", "<C-i>", "<C-i>zz")
vim.keymap.set("n", "<C-o>", "<C-o>zz")
vim.keymap.set("n", "%", "%zz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

-- Press 'S' for quick find/replace for the word under the cursor
vim.keymap.set("n", "S", function()
	local cmd = ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>"
	local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end)

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vim.keymap.set("n", "L", "$")
vim.keymap.set("n", "H", "^")

-- Move selected text up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Press 'U' for undo
vim.keymap.set("n", "U", "<C-r>")

-- Turn off highlighted results
vim.keymap.set("n", "<leader>no", "<cmd>noh<cr>")

-- Diagnostics

-- Goto next diagnostic of any severity
vim.keymap.set("n", "]d", function()
	vim.diagnostic.get_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous diagnostic of any severity
vim.keymap.set("n", "[d", function()
	vim.diagnostic.get_prev({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next error diagnostic
vim.keymap.set("n", "]e", function()
	vim.diagnostic.get_next({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous error diagnostic
vim.keymap.set("n", "[e", function()
	vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next warning diagnostic
vim.keymap.set("n", "]w", function()
	vim.diagnostic.get_next({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous warning diagnostic
vim.keymap.set("n", "[w", function()
	vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float({
		border = "rounded",
	})
end)

-- Place all dignostics into a qflist
vim.keymap.set("n", "<leader>ld", vim.diagnostic.setqflist, { desc = "Quickfix [L]ist [D]iagnostics" })

-- Navigate to next qflist item
vim.keymap.set("n", "<leader>cn", ":cnext<cr>zz")

-- Navigate to previos qflist item
vim.keymap.set("n", "<leader>cp", ":cprevious<cr>zz")

-- Open the qflist
vim.keymap.set("n", "<leader>co", ":copen<cr>zz")

-- Close the qflist
vim.keymap.set("n", "<leader>cc", ":cclose<cr>zz")

-- Map MaximizerToggle (szw/vim-maximizer) to leader-m
vim.keymap.set("n", "<leader>m", ":MaximizerToggle<cr>")

-- Press leader f to format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "[F]ormat" })

-- Press gx to open the link under the cursor
vim.keymap.set("n", "gx", ":sil !open <cWORD><cr>", { silent = true })

-- Git keymaps --
vim.keymap.set("n", "<leader>gf", function()
	local cmd = {
		"sort",
		"-u",
		"<(git diff --name-only --cached)",
		"<(git diff --name-only)",
		"<(git diff --name-only --diff-filter=U)",
	}

	if not utils.is_git_directory() then
		vim.notify(
			"Current project is not a git directory",
			vim.log.levels.WARN,
			{ title = "Telescope Git Files", git_command = cmd }
		)
	else
		require("telescope.builtin").git_files()
	end
end, { desc = "Search [G]it [F]iles" })

-- Symbol Outline keybind
vim.keymap.set("n", "<leader>so", ":SymbolsOutline<cr>")

-- Visual --
-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("v", "<space>", "<nop>")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vim.keymap.set("v", "L", "$<left>")
vim.keymap.set("v", "H", "^")

-- Paste without losing the contents of the register
vim.keymap.set("x", "<leader>p", '"_dP')

-- Move selected text up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Reselect the last visual selection
vim.keymap.set("x", "<<", function()
	vim.cmd("normal! <<")
	vim.cmd("normal! gv")
end)

vim.keymap.set("x", ">>", function()
	vim.cmd("normal! >>")
	vim.cmd("normal! gv")
end)
