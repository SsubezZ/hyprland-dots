-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/maina/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.wrap = true
opt.relativenumber = false

vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang", [".*%.rasi"] = "rasi" },
})
