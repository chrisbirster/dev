local dap = require("dap")
local dapui = require("dapui")

require("dap").set_log_level("DEBUG")

local js_debug = vim.fn.expand("$HOME/.local/share/nvim/js-debug/js-debug/src/dapDebugServer.js")

local js_adapter = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
        command = "node",
        args = { js_debug, "${port}"},
    },
    options = {
        initialize_timeout_sec = 20,
    },
}

dap.adapters["pwa-node"] = js_adapter
dap.adapters["node-terminal"] = js_adapter
dap.adapters["pwa-chrome"] = js_adapter

local function package_root()
    return vim.fs.root(0, { "package.json", ".git" }) or vim.fn.getcwd()
end

local function project_entrypoint()
    return vim.fs.joinpath(package_root(), "index.ts")
end

local function command_args()
    local input = vim.fn.input("Program arguments: ", "help")
    return require("dap.utils").splitstr(input)
end

local node_config = {
    {
       type = "pwa-node",
       request = "launch",
       name = "Node: Launch project entry",
       runtimeExecutable = "node",
       runtimeArgs = { "--enable-source-maps" },
       program = project_entrypoint,
       args = command_args,
       cwd = package_root,
       console = "internalConsole",
       sourceMaps = true,
       skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
       type = "pwa-node",
       request = "launch" ,
       name = "Node: Launch current file" ,
       runtimeExecutable = "node",
       runtimeArgs = { "--enable-source-maps" },
       program = "${file}",
       cwd = package_root,
       sourceMaps = true,
       skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
       type = "pwa-node",
       request = "attach" ,
       name = "Node: Attach to port 9229" ,
       address = "127.0.0.1",
       port = 9229,
       cwd = package_root,
       sourceMaps = true,
       skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
       type = "pwa-node",
       request = "attach" ,
       name = "Node: Pick process" ,
       processId = require("dap.utils").pick_process,
       cwd = package_root,
       sourceMaps = true,
       skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
}

dap.configurations.typescript = node_config
dap.configurations.javascript = node_config

local browser_config = {
    {
        type = "pwa-chrome",
        request = "launch",
        name = "Browser: Launch Vite app",
        url = function()
            return vim.fn.input("Vite URL: ", "http://localhost:5173")
        end,
        webRoot = package_root,
        runtimeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        sourceMaps = true,
        smartStep = true,
        skipFiles = {
            "<node_internals>/**",
            "**/node_modules/**",
            "**/@solid-refresh*",
        },
    },
}

dap.configurations.typescriptreact = browser_config
dap.configurations.javascriptreact = browser_config

dap.adapters.go = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
    },
}

dap.configurations.go = {
    {
        type = "go",
        name = "Go: Debug package",
        request = "launch",
        program = "${fileDirname}",
    },
    {
        type = "go",
        name = "Go: Debug test",
        request = "launch",
        mode = "test",
        program = "${fileDirname}",
    },
    {
        type = "go",
        name = "Go: Pick process",
        request = "attach",
        mode = "local",
        processId = require("dap.utils").pick_process,
    },
}

dapui.setup({
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.35 },
                { id = "stacks", size = 0.25 },
                { id = "breakpoints", size = 0.20 },
                { id = "watches", size = 0.20 },
            },
            size = 38,
            position = "right",
        },
    },
})

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

local dap_float_group = vim.api.nvim_create_augroup("ViminatrixDapFloat", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = dap_float_group,
    pattern = "dap-float",
    callback = function(args)
        local function close_float()
            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                vim.api.nvim_win_close(win, true)
            end
        end

        vim.keymap.set("n", "q", close_float, {
            buffer = args.buf,
            silent = true,
            desc = "Close DAP popup",
        })
        vim.keymap.set("n", "<Esc>", close_float, {
            buffer = args.buf,
            silent = true,
            desc = "Close DAP popup",
        })
    end,
})

-- Keymaps
local widgets = require("dap.ui.widgets");
vim.keymap.set({ "n", "v"}, "<leader>dh", function() widgets.hover() end, { desc = "DAP hover variable"})
vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "DAP continue"})
vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "DAP step over"})
vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "DAP step into"})
vim.keymap.set("n", "<leader>dO", function() dap.step_out() end, { desc = "DAP step out"})
vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint"})
vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional breakpoint"})
vim.keymap.set("n", "<leader>dr", function() dapui.toggle({ layout = 1}) end, { desc = "DAP toggle UI"})
vim.keymap.set("n", "<leader>de", function() dapui.float_element("repl", { enter = true }) end, { desc = "DAP floating REPL"})
vim.keymap.set("n", "<leader>dl", function() dapui.float_element("console", { enter = true }) end, { desc = "DAP floating console"})
vim.keymap.set("n", "<leader>dt", function() dap.terminate() end, { desc = "DAP terminate"})
