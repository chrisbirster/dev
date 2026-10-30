local function set_left_centering_spacer(enabled)
	vim.schedule(function()
		local no_neck_pain = _G.NoNeckPain
		if not no_neck_pain or not no_neck_pain.state or not no_neck_pain.state.enabled then
			return
		end

		local left = no_neck_pain.config and no_neck_pain.config.buffers.left
		if left and left.enabled ~= enabled then
			require("no-neck-pain").toggle_side("left")
		end
	end)
end

require("neo-tree").setup({
	close_if_last_window = true,
	open_files_do_not_replace_types = { "terminal", "quickfix", "qf" },
	event_handlers = {
		{
			event = "neo_tree_window_after_open",
			handler = function(args)
				if args.position == "left" then
					set_left_centering_spacer(false)
				end
			end,
		},
		{
			event = "neo_tree_window_after_close",
			handler = function(args)
				if args.position == "left" then
					set_left_centering_spacer(true)
				end
			end,
		},
	},
	filesystem = {
		hijack_netrw_behavior = "open_default",
		follow_current_file = {
			enabled = true,
			leave_dirs_open = false,
		},
		use_libuv_file_watcher = true,
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = true,
			never_show = { ".DS_Store" },
		},
	},
	window = {
		position = "left",
		width = 32,
		mappings = {
			["<space>"] = "none",
		},
	},
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", {
	silent = true,
	desc = "Toggle file explorer",
})
