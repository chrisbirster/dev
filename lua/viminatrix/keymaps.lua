-- Show [current/total] match count when searching with /
vim.opt.shortmess:remove("S")

-- Write and quit
vim.keymap.set("n", "<leader>w", ":w<cr>", { silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { silent = true, desc = "Quit Neovim" })

-- Quick out of insert mode
vim.keymap.set("i", "jk", "<esc>")

-- Swap between last two buffers 
vim.keymap.set("n", "<leader>;", "<C-^>", { desc = "Switch between last two buffers" })

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

-- Redo
vim.keymap.set("n", "U", "<c-r>", { silent = true })

-- UndoTree 
vim.keymap.set("n", "<leader>u", function()
    vim.cmd("UndotreeToggle")
    vim.cmd("UndotreeFocus")
end, { silent = true})

-- Quickfix list 
vim.keymap.set("n", "<leader>co", ":copen<cr>zz", { silent = true, desc = "Open Quickfix "})
vim.keymap.set("n", "<leader>cc", ":cclose<cr>zz", { silent = true, desc = "Close Quickfix "})

local quickfix_group = vim.api.nvim_create_augroup("ViminatrixQuickfixKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = quickfix_group,
  pattern = "qf",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>cclose<cr>", {
      buffer = args.buf,
      silent = true,
      desc = "Close quickfix list",
    })
    vim.keymap.set("n", "<CR>", "<CR><cmd>cclose<cr>", {
      buffer = args.buf,
      silent = true,
      desc = "Open quickfix item and close list",
    })
  end,
})

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

-- Search word under cursor in workspace
vim.keymap.set("n", "<leader>sw", function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("silent grep! " .. vim.fn.fnameescape(word))
    vim.cmd("copen")
end, { desc = "Search word in workspace" })

-- Fuzzy search lines in current buffer -> quickfix 
vim.keymap.set("n", "<leader>/", function()
    vim.ui.input({ prompt = "Buffer search: " }, function(query)
        if not query or query == "" then return end
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local entries = {}

        for i, line in ipairs(lines) do
            entries[#entries + 1] = string.format("%4d: %s", i, line)
        end

        local matches = vim.fn.matchfuzzy(entries, query)
        if #matches == 0 then
            vim.notify("No matches: " .. query, vim.log.levels.INFO)
            return
        end 

        local qf_items = {}
        for _, m in ipairs(matches) do
            local lnum = tonumber(m:match("^%s*(%d+):"))
            if lnum then 
                qf_items[#qf_items + 1] = { bufnr = bufnr, lnum = lnum, text = lines[lnum] }
            end
        end

        vim.fn.setqflist({}, " ", { title = "Buffer: " .. query, items = qf_items })
        vim.cmd("copen")
        vim.cmd("cfirst")
    end)
end, { desc = "Search word in workspace" })

-- Swap between split buffers
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { silent = true, desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { silent = true, desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { silent = true, desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { silent = true, desc = "Move to right split" })
