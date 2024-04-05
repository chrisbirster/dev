return {
  { "akinsho/org-bullets.nvim", enabled = false, config = true, ft = { "org" } },
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", lazy = true },
    },
    event = "VeryLazy",
    config = function()
      -- Load treesitter grammar for org
      require("orgmode").setup_ts_grammar()

      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = { "~/shared/orgs/**/*" },
        org_default_notes_file = "~shared/orgs/OrgAgenda/Daily Agenda.org",
        org_capture_templates = {
          t = {
            description = "Todo",
            template = "* TODO %?\n  DEADLINE: %T",
            target = "~/shared/orgs/todos.org",
          },
          w = {
            description = "Work todo",
            template = "* TODO %?\n  DEADLINE: %T",
            target = "~/shared/orgs/work.org",
          },
        },
        mappings = {
          org = {
            org_toggle_checkbox = '<leader>,',
          }
        }
      })
    end,
  },
}
