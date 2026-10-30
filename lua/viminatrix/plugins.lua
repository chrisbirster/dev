-- Neo-tree replaces the built-in netrw directory browser.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
    "https://github.com/shortcuts/no-neck-pain.nvim",
    "https://github.com/rose-pine/neovim",
    "https://github.com/laytan/cloak.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/mbbill/undotree",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    {
        src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
        version = vim.version.range("3"),
    },
    "https://github.com/ThePrimeagen/harpoon",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/rcarriga/nvim-dap-ui",
}, { load = true })
