local M = {}

-- MongoDB playgrounds are JavaScript programs evaluated by mongosh. Treat
-- both the current *.mongodb.js convention and the older *.mongodb extension
-- as JavaScript so Tree-sitter, tsgo/ts_ls, and Prettier all work normally.
vim.filetype.add({
	filename = {
		[".mongoshrc.js"] = "javascript",
	},
	pattern = {
		[".*%.mongodb%.js"] = "javascript",
		[".*%.mongodb"] = "javascript",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ViminatrixMongoDB", { clear = true }),
	pattern = "javascript",
	callback = function(args)
		local name = vim.api.nvim_buf_get_name(args.buf)
		if name:match("%.mongodb%.js$") or name:match("%.mongodb$") then
			vim.b[args.buf].mongodb_playground = true
			vim.treesitter.start(args.buf, "javascript")
		end
	end,
})

local function show_output(lines, title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "mongodb"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	local width = math.min(math.max(60, math.floor(vim.o.columns * 0.75)), vim.o.columns - 4)
	local height = math.min(math.max(10, math.floor(vim.o.lines * 0.6)), vim.o.lines - 4)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
	vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
end

function M.run_current_file()
	if vim.fn.executable("mongosh") ~= 1 then
		vim.notify("mongosh is not installed or is not on PATH", vim.log.levels.ERROR)
		return
	end

	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Save the MongoDB playground before running it", vim.log.levels.WARN)
		return
	end

	vim.cmd.update()
	local command = { "mongosh" }
	if vim.env.MONGODB_URI and vim.env.MONGODB_URI ~= "" then
		table.insert(command, vim.env.MONGODB_URI)
	end
	vim.list_extend(command, { "--quiet", "--norc", "--file", file })

	vim.system(command, { text = true }, function(result)
		vim.schedule(function()
			local output = result.stdout or ""
			if result.stderr and result.stderr ~= "" then
				output = output .. (output ~= "" and "\n" or "") .. result.stderr
			end
			local lines = vim.split(vim.trim(output), "\n", { plain = true })
			if #lines == 1 and lines[1] == "" then
				lines = { result.code == 0 and "MongoDB playground completed successfully." or "No output." }
			end
			show_output(lines, result.code == 0 and "MongoDB Output" or "MongoDB Error")
		end)
	end)
end

vim.api.nvim_create_user_command("MongoRun", M.run_current_file, {
	desc = "Run the current MongoDB playground with mongosh",
})

vim.keymap.set("n", "<leader>mr", M.run_current_file, {
	silent = true,
	desc = "Run MongoDB playground",
})

return M
