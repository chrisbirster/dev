local M = {}

local main_win = nil

function M.set_main_win(win)
    main_win = win
end

function M.get_win()
    if main_win and wim.api.nvim_win_is_valid(main_win) then
        return main_win
    end

    -- Find any window that isn't the tree
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf) ~= "bongo://tree" then
            main_win = win
            return win
        end
    end

    -- No suitable window - create a vertical split from tree
    local tree_win = M.find_tree_win()
    if tree_win then
        vim.api.nvim_set_current_win(tree_win)
        vim.cmd("vsplit")
        main_win = vim.api.nvim_get_current_win()
        return main_win
    end
    return vim.api.nvim_get_current_win()
end

function M.find_tree_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf) == "bongo://tree" then
            return win
        end
    end
    return nil
end

function M.show(view_type, conn, db, coll)
    local win = M.get_win()
    if view_type == "documents" then
        require("bongo.documents").show(win, conn, db, coll)
    elseif view_type == "indexes" then
        require("bongo.indexes").show(win, conn, db, coll)
    elseif view_type == "schema" then
        require("bongo.schema").show(win, conn, db, coll)
    end

    -- Return focus to tree
    local tree_win = M.find_tree_win()
    if tree_win then
        vim.api.nvim_set_current_win(tree_win)
    end
end
    
function M.show_playgroun(playground)
    local win = M.get_win()
    require("bongo.playground").show(win, playground)
end

return M