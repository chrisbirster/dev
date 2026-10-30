local M = {}

function M.show(items, on_select)
    local width = 4
    for _, item in ipairs(items) do 
        width = math.max(width, #item + 4)
    end

    local buf = wim.api.nvim_create_buf(false, true)
    wim.bo[buf].bufhidden = "wipe"

    local lines = {}
    for _, item in ipairs(items) do
        lines[#lines + 1] = "  " .. item
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        heigh = #items,
        style = "minimal",
        border = "rounded",
    })
    vim.wo[win].cursorline = true

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "<CR>", function() 
        local idx = vim.api.nvim_win_get_cursor(win)[1]
        close()
        on_select(items[idx], idx)
    end, { buffer = buf, nowait = true })

    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
end

return M