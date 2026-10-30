local M = {}

local function run_job(cmd_str, callback)
    local stdout_lines = {}
    local stderr_lines = {}

    vim.fn.jobstart({ "bash", "-c", cmd_str}, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data) 
            for _, line in ipairs(data) do
                if line ~= "" then stdout_lines[#stdout_lines + 1] = line end
            end
        end,
        on_stderr = function(_, data) 
            for _, line in ipairs(data) do
                if line ~= "" then stderr_lines[#stdout_lines + 1] = line end
            end
        end,
        on_exit = function(_, code) 
            if code ~= 0 then
                callback(table.concat(stderr_lines, "\n"), nil)
            else
                callback(nil, stdout_lines)
            end
        end,
    })
end

local function mongosh(uri, eval_script, callback)
    local cmd = string.format(
        "source ~/.nvm/nvm.sh 2>/dev/null; mongosh %s --quiet --norc --eval %s",
        vim.fn.shellescape(uri),
        vim.fn.shellescape(eval_script)
    )
    run_job(cmd, callback)
end

-- Find the first line that looks like JSON (starts with [ or {)
local function first_json(lines)
    for _, l in ipairs(lines) do 
        local trimmed = l:match("^%s*(.+)$")
        if trimmed and (trimmed:sub(1, 1) == "[" or trimmed:sub(1, 1) == "{") then
            return trimmed
        end
    end
    return nil
end

function M.list_databases(uri, callback)
    -- authorizedDatabases:true returns on dbs the current user can access (no admin role needed)
    local script = "print(JSON.stringify(db.adminCommand({ listDatabases:1, nameOnly:true, authorizedDatabases:true}).databases.map(function(d){return d.name})))"
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        if not json then callback("No database list returned", nil) return end
        local ok, result = pcall(vim.fn.json_decode, json)
        if not ok then callback("Parse error: " .. json, nil) return end
        callback(nil, result)
    end)
end

function M.list_collections(uri, callback)
    -- authorizedDatabases:true returns on dbs the current user can access (no admin role needed)
    local script = "print(JSON.stringify(db.getSiblingDB(%s).getCollectionNames()))", 
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        if not json then callback("No collection list returned", nil) return end
        local ok, result = pcall(vim.fn.json_decode, json)
        if not ok then callback("Parse error: " .. json, nil) return end
        callback(nil, result)
    end)
end

function M.count(uri, db_name, coll, query, callback)
    local script = string.format(
        "print(db.getSiblingDB(%s)[%s].countDocuments(%s))",
        vim.fn.json_encode(db_name),
        vim.fn.json_encode(coll),
        query or "{}"
    )
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        local n = tonumber(table.concat(lines, ""))
        callback(nil, n or 0)
    end)
end

function M.find(uri, db_name, coll, query, limit, skip, callback)
    local script = string.format(
        "print(JSON.stringify(db.getSiblingDB(%s)[%s].find(%s).skip(%d).limit(%d).toArray()))",
        vim.fn.json_encode(db_name),
        vim.fn.json_encode(coll),
        query or "{}",
        skip or 0,
        limit or 50
    )
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        if not json then callback("No documents returned", nil) return end
        local ok, result = pcall(vim.fn.json_decode, json)
        if not ok then callback("Parse error: " .. json, nil) return end
        callback(nil, result)
    end)
end

function M.indexes(uri, db_name, coll, callback)
    local script = string.format(
        "print(JSON.stringify(db.getSiblingDB(%s)[%s].getIndexes()))",
        vim.fn.json_encode(db_name),
        vim.fn.json_encode(coll),
    )
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        if not json then callback("No index data returned", nil) return end
        local ok, result = pcall(vim.fn.json_decode, json)
        if not ok then callback("Parse error: " .. json, nil) return end
        callback(nil, result)
    end)
end

function M.collection_counts(uri, db_name, coll_names, callback)
    local script = string.format(
        "var _d=db.getSiblingDB(%s);print(JSON.stringify(%s.map(function(c){return{name:c, count:_d[c].estimatedDocumentCount()}})))",
        vim.fn.json_encode(db_name),
        vim.fn.json_encode(coll),
    )
    mongosh(uri, script, function(err, lines)
        if err then callback(err, nil) return end
        local json = first_json(lines)
        if not json then callback("No count data", nil) return end
        local ok, result = pcall(vim.fn.json_decode, json)
        if not ok then callback("Parse error: " .. json, nil) return end
        callback(nil, result)
    end)
end

function M.run(uri, code, callback)
    local tmpfile = vim.fn.tempname() .. ".js"
    vim.fn.writefile(vim.split(code, "\n", { plain = true }), tmpfile)
    local cmd = string.format(
        "source ~/.nvm/nvm.sh 2>/dev/null; mongosh %s --quiet --norc %s; rm -f %s",
        vim.fn.shellescape(uri),
        vim.fn.shellescape(tmpfile),
        vim.fn.shellescape(tmpfile)
    )
    run_job(cmd, callback)
end

function M.run_file(uri, code, callback)
    local tmpfile = vim.fn.tempname() .. ".js"
    vim.fn.writefile(vim.split(code, "\n", { plain = true }), tmpfile)
    local cmd = string.format(
        "source ~/.nvm/nvm.sh 2>/dev/null; mongosh %s --quiet --norc %s",
        vim.fn.shellescape(uri),
        vim.fn.shellescape(path)
    )
    run_job(cmd, callback)
end

return M