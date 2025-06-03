return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			preset = {
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = ":lua Snacks.dashboard.pick('files')",
					},
					{
						icon = "󰈔 ",
						key = "n",
						desc = "New File",
						action = ":ene | startinsert",
					},
					{
						icon = "󰈢 ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "i",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{
						icon = " ",
						key = "s",
						desc = "Restore Session",
						action = ":lua require('persistence').load()",
					},
					{
						icon = "󰊢 ",
						key = "g",
						desc = "Git Folder",
						action = ":lua Snacks.dashboard.pick('files', {cwd = '~/Gits'})",
					},
					{
						icon = " ",
						key = "h",
						desc = "hyprland-dots",
						action = ":lua Snacks.dashboard.pick('files', {cwd = '~/Gits/hyprland-dots'})",
					},
					{
						icon = "󰒲 ",
						key = "l",
						desc = "Lazy",
						action = ":Lazy",
					},
					{
						icon = " ",
						key = "x",
						desc = "Lazy Extras",
						action = ":LazyExtras",
					},
					{
						icon = " ",
						key = "q",
						desc = "Quit",
						action = ":q",
					},
				},
				header = [[
  █████ ██ ███████ ████████ ██   ██ ██ █████ █████
  ██ ██ ██ ██      ██    ██ ██   ██ ██ ██ ██ ██ ██
  ██ ██ ██ █████   ██    ██ ██   ██ ██ ██ ██ ██ ██
  ██ ██ ██ ██      ██    ██ ██   ██ ██ ██ ██ ██ ██
  ██ █████ ███████ ████████ ███████ ██ ██ █████ ██]],
				-- ███    ██ ███████  ██████  ██    ██ ██ ███    ███
				-- ████   ██ ██      ██    ██ ██    ██ ██ ████  ████
				-- ██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██
				-- ██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██
				-- ██   ████ ███████  ██████    ████   ██ ██      ██]],
			},
			sections = {
				{ section = "header", gap = 1 },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
	},
}
