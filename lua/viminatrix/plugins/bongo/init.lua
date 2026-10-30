local M = {}

M.state = {
    connections = {},
    playgrounds = {},
    active_connection = nil,
}

function M.setup()
    local store = require("bongo.store")
    store.ensure_dirs()

    local saved = store.load_connections()
    for _, c in ipairs(saved) do
        local dbs = {}
        for _, db_name in ipairs(c.databases or {}) do
            dbs[#dbs + 1] = { name = db_name, expanded = false, collections = nil }
        end

        M.state.connections[#M.state.connections + 1] = {
            name = c.name,
            uri = c.uri,
            stored_databases = c.databases or {},
            databases = dbs,
            expanded = false,
        }
    end

    M.state.playgrounds = store.list_playgrounds()

    require("bongo.tree").init(M.state)

    vim.keymap.set("n", "<leader>mo", M.toggle, { desc = "Toggle MongoDB explorer "})
end

function M.toggle()
    local tree = require("bongo.tree")
    if tree.is_open() then
        tree.close()
    else
        tree.open()
    end
end

return M