local M = {}

-- User-configurable: filetype -> shell command (stdin/stdout)
M.formatters = {
	lua = "stylua -",
	javascript = "prettier --stdin-filepath %",
	typescript = "prettier --stdin-filepath %",
	typescriptreact = "prettier --stdin-filepath %",
	json = "prettier --stdin-filepath %",
}

local function lsp_format(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client:supports_method("textDocument/formatting") then
			vim.lsp.buf.format({
				bufnr = bufnr,
				async = false,
				id = client.id,
				timeout_ms = 10000,
			})
			return true
		end
	end
	return false
end

local function resolve_executable(command, bufname)
	local executable = command:match("^%S+")
	if not executable then
		return nil
	end

	-- Prefer a formatter installed in the nearest JavaScript package.
	local root = vim.fs.root(bufname, { "package.json" })
	if root then
		local local_executable = vim.fs.joinpath(root, "node_modules", ".bin", executable)
		if vim.fn.executable(local_executable) == 1 then
			return command:gsub("^%S+", vim.fn.shellescape(local_executable), 1)
		end
	end

	if vim.fn.executable(executable) == 1 then
		return command
	end

	return nil
end

function M.format_buf(bufnr, opts)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	opts = opts or {}
	local ft = vim.bo[bufnr].filetype
	local cmd = M.formatters[ft]

	if cmd then
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local executable = resolve_executable(cmd, bufname)
		if executable then
			local resolved = executable:gsub("%%", vim.fn.shellescape(bufname))
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local input = table.concat(lines, "\n")
			local output = vim.fn.system(resolved, input)

			if vim.v.shell_error == 0 then
				local formatted = vim.split(output, "\n", { plain = true })
				-- Remove trailing empty line that shell commands often append
				if formatted[#formatted] == "" then
					table.remove(formatted)
				end
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
				return true
			elseif not opts.silent then
				vim.notify("Formatter failed:\n" .. vim.trim(output), vim.log.levels.ERROR)
			end
		end
	end

	-- Use LSP when no external formatter is configured or available.
	if lsp_format(bufnr) then
		return true
	end

	if not opts.silent then
		local formatter = cmd and cmd:match("^%S+") or nil
		if formatter then
			vim.notify(formatter .. " is unavailable and no LSP formatter is attached", vim.log.levels.WARN)
		else
			vim.notify("No formatter available for " .. ft, vim.log.levels.WARN)
		end
	end
	return false
end


vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		M.format_buf(args.buf, { silent = true })
	end,
})

vim.keymap.set("n", "<leader>f", function() M.format_buf() end, { desc = "Format buffer" })

return M
