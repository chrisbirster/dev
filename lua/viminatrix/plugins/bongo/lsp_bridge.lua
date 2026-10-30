local M = {}

local EXT_PATH = vim.fn.expand("~/.vscode/extensions/mongodb.mongodb-vscode-1.16.1")
local CMD_INIT = "INITALIZE_MONGODB_SERVICE"
local CMD+CONN = "ACTIVE_CONNECTION_CHANGED"
local CMD_READY = "MONGODB_SERVICE_CREATED"

local function warn(mg) vim.notify("[bongo-lsp] " .. msg, vim.log.levels.WARN) end

local function active_conn()
    local ok, bongo = pcall(require, "bongo")
    if not ok then return nil end
    local active = bongo.state.active_connection
    if not active then return nil end
    for _, c in ipairs(bongo.state.connections) do
        if c.name == active then return c end
    end
    return nil
end

local function send_init(client, bufnr)
    local conn = active_conn()
    local params = {
        extensionPath = EXT_PATH,
        connectionId = conn and conn.name or vim.NIL,
        connectionOptions = {},
    }
    if conn then params.connectionString = conn.uri end

    local ok, err = pcall(function() 
        client:request(CMD_INIT, params, function(req_err)
            if req_err then
                warn("INITIALIZE_MONGODB_SERVICE: ", .. tostring(req_err.message or req_err))
            end
        end, bufnr)
    end)
    if not ok then warn("send_init pcall: " .. tostring(err)) end
end

-- The server sends MONGODB_SERVICE_CREATED after the LSP handshake.
-- We must respond with INITIALIZE_MONGODB_SERVICE - only then will it provide comopletions
vim.lsp.handlers[CMD_READY] = function(_err, _result, ctx))
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client or client.name ~= "mongodb_ls" then return end
    -- find any mongodbjs buffer attached to this client
    local bufnr = ctx.bufnr
    if not bufnr or bufnr == 0 then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "mongodbjs" then
                bufnr = buf
                break
            end
        end
    end
    send_init(client, bufnr)
end

-- Called from tree.lua when bongo activates a connection
function M.notify_connection_changed()
    local conn = active_conn()
    if not conn then return end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "mongodbjs" then
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf, name = "mongodb_ls" })) do
                local ok, err = pcall(function() 
                    c:request(CMD_CONN, {
                        connectionId = conn.name,
                        connectionString = conn.uri,
                        connectionOptions = {},
                    }, function(req_err) 
                        if req_err then warn("ACTIVE_CONNECTION_CHANGED: " .. tostring(req_err.message or req_err)) end
                    end, buf)
                end)
                if not ok then warn("conn_changed pcall: " .. tostring(err)) end
            end
        end
    end
end

-- No-op: kept so dev/lsp.lua LspAttach call doesn't break (init is now driven by MONGODB_SERVICE_CREATED)
function M.init(_client, _bufnr) end

return M