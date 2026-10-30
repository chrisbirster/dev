local M = {}

local terminals = {
	float = { buf = nil, win = nil },
	bottom = { buf = nil, win = nil },
}

local function window_is_open(state)
	return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function terminal_is_running(buf)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	local job = vim.b[buf].terminal_job_id
	return job and vim.fn.jobwait({ job }, 0)[1] == -1
end

local function hide_current_window()
	vim.api.nvim_win_hide(0)
end

local function start_terminal(state)
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	vim.api.nvim_win_set_buf(state.win, state.buf)

	vim.fn.jobstart({ vim.o.shell }, {
		term = true,
		cwd = vim.fn.getcwd(),
	})

	local opts = { buffer = state.buf, silent = true }
	vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("n", "q", hide_current_window, opts)
	vim.keymap.set("n", "<Esc>", hide_current_window, opts)
end

local function show_terminal(state)
	if terminal_is_running(state.buf) then
		vim.api.nvim_win_set_buf(state.win, state.buf)
	else
		start_terminal(state)
	end
	vim.api.nvim_set_current_win(state.win)
	vim.cmd.startinsert()
end

function M.toggle_float()
	local state = terminals.float
	if window_is_open(state) then
		vim.api.nvim_win_hide(state.win)
		state.win = nil
		return
	end

	local width = math.max(60, math.floor(vim.o.columns * 0.8))
	local height = math.max(12, math.floor(vim.o.lines * 0.7))
	width = math.min(width, vim.o.columns - 4)
	height = math.min(height, vim.o.lines - 4)

	state.win = vim.api.nvim_open_win(0, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " Terminal ",
		title_pos = "center",
	})
	show_terminal(state)
end

function M.toggle_bottom()
	local state = terminals.bottom
	if window_is_open(state) then
		vim.api.nvim_win_hide(state.win)
		state.win = nil
		return
	end

	vim.cmd("botright 12split")
	state.win = vim.api.nvim_get_current_win()
	show_terminal(state)
end

vim.keymap.set({ "n", "t" }, "<leader>tf", M.toggle_float, { desc = "Toggle floating terminal" })
vim.keymap.set({ "n", "t" }, "<leader>tb", M.toggle_bottom, { desc = "Toggle bottom terminal" })

vim.api.nvim_create_user_command("TermFloat", M.toggle_float, { desc = "Toggle floating terminal" })
vim.api.nvim_create_user_command("TermBottom", M.toggle_bottom, { desc = "Toggle bottom terminal" })

return M
