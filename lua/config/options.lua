-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.formatoptions:append("t")
vim.opt.guicursor = {
  "n-v-c:block", -- Normal, Visual, Command: block
  "i-ci-ve:hor25", -- Insert, Insert command: vertical bar 25%
  "r-cr:hor20", -- Replace: horizontal bar 20%
  "o:hor50", -- Operator pending: horizontal bar
  "a:blinkwait700-blinkoff400-blinkon250", -- blinking style
}
