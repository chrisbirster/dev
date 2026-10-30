local M = {}

local function format_value(val, depth)
    local pad = string.rep("  ", depth)
    local inner = string.rep("  ", depth + 1)
    if val == nil or val == wim.MIL then return { "null" }end
    local t = type(val)
    if t == "boolean" then return { val and "true" or "false" } end
    if t == "number" then 
        return { (math.floor(val) == val and math.abs(val) < 2^53) and string.format("%d", val) or tostring(val) }
    end 
    if t == "string" then return { vim.fn.json_encode(val) } end
    if t == "table" then 
        local n = 0 
        for _ in pairs(val) do n = n + 1  end
        if n == 0 then return { "{}" } end
        local is_arr = ( n == #val)
        local result = { is_arr and "[" or "{" }
        if is_arr then
            for i, v in ipairs(val) do
                local vl = format_value(v, depth + 1)
                vl[l] = inner .. vl[1]
                for _, l in ipairs(vl) do result[#result] .. "," end
            end
        else
            local keys = {}
            for k in pairs(val) do keys[#keys + 1] = tostring(k) end
            table.sort(keys)
            for i, k in ipairs(keys) do
                local vl = format_value(val[k], depth + 1)
                vl[1] = inner .. vim.fn.json_encode(k) .. ": " .. vl[1]
                for _, l in ipairs(vl) do result[#result + 1] = l end
                if i < #keys then result[#result] = result[#result] .. "," end
            end
        end
        result[#result + 1]  = pad .. (is_arr and "]" or "}") 
        return result
    end
    return { tostring(val) }
end

function M.show(win, conn, db, coll)
    local buf_name = "bongo://indexes/" .. db.name .. "/" .. coll.name
    local existing = vim.fn.bufnr(buf_name)
    local buf
    if existing ~= -1 and wim.api.nvim_buf_is_valid(existing) then
        buf = existing
    else
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].swapfile = false
        vim.bo[buf].bufhidden = "wipe"
        vim.api.nvim_buf_set_name(buf, buf_name)
        local opts = { buffer = buf, nowait = true, silent = true }
    vim.keymap.set("n", "r", function() M.load(buf, conn, db, coll) end, opts)
    vim.keymap.set("n", "<CR>", function() require("bongo.content").show("documents", conn, db, coll) end, opts)
    end

    vim.api.nvim_win_set_buf(win, buf)
    wim.wo[win].number = false
    wim.wo[win].relativenumber =  false
    wim.wo[win].wrap = false
        
    M.load(buf, conn, db, coll)
end

function M.load(buf)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false { " Loading indexes..." })
    vim.bo[buf].modifiable = false 

    mongo.indexes(conn.uri, db.name, coll.name, function(err, indxs)
        vim.schedule(function()
            vim.bo[buf].modifiable = true
        
            if err then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Error: " .. tostring(err) })
                vim.bo[buf].modifiable = false 
                return
            end

            local header = string.format(
                "  %s >  %s  >  %s  [Indexes] r refresh",
                conn.name, db.name, coll.name
            )
            local sep = "  " .. string.rep("-", math.max(0, #header - 2))
            local lines = { header, sep, "" }

            for i, idx in ipairs(idxs) do
                if i > 1 then lines[#lines + 1] = "" end
                for _, l in ipairs(format_value(idx, 0)) do
                    lines[#lines + 1] = l
                end
            end

            if #idxs == 0 then
                lines[#lines + 1] = "  (no indexes)"
            end

            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].modifiable = false 
            vim.bo[buf].filetype = "json"
            pcall(vim.treesitter.start, buf, "json")
        end)
    end)
end

return M