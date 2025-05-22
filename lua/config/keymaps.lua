-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(modes, lhs, rhs, opts)
  vim.keymap.set(modes, lhs, rhs, opts)
end
local function normal_map(lhs, rhs, opts)
  map("n", lhs, rhs, opts)
end
local function insert_map(lhs, rhs, opts)
  map("i", lhs, rhs, opts)
end
local function visual_map(lhs, rhs, opts)
  map("v", lhs, rhs, opts)
end
local function terminal_map(lhs, rhs, opts)
  map("t", lhs, rhs, opts)
end
