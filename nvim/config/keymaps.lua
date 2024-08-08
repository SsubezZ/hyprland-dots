-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<leader>rr", ":RunCode<CR>", { desc = "Run code" })
map("n", "<leader>rf", ":RunFile<CR>", { desc = "Run file" })
map("n", "<leader>rp", ":RunProject<CR>", { desc = "Run Project" })
