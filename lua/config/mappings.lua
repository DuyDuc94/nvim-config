local utils = require("custom.utils")

local keymap = vim.keymap
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Move cursor to the middle of the screen and highlight line
keymap.set("n", "zz", function()
  vim.cmd("normal! zz")
  utils.highlight_current_line()
end)

-- Jump to the first non-blank character of the line
keymap.set("", "<S-h>", "^")

-- Jump to the end of the line
keymap.set("", "<S-l>", "$")

-- Handle Tab
keymap.set("v", "<Tab>", ">gv")
keymap.set("v", "<S-Tab>", "<gv")
keymap.set("n", "<Tab>", ">>")
keymap.set("n", "<S-Tab>", "<<")

-- Kitty can distinguish between <C-I> and <Tab>.
-- This enables <C-I> for navigating jumplist, as it intended to be used.
keymap.set("n", "<C-i>", "<C-i>", { remap = false })

-- Window resizing with Ctrl+- and Ctrl+=
keymap.set("n", "<C-->", ":vertical resize -5<CR>", { silent = true })
keymap.set("n", "<C-=>", ":vertical resize +5<CR>", { silent = true })

-- Quick moves
keymap.set("", "<S-j>", "5j")
keymap.set("", "<S-k>", "5k")
keymap.set("", "<S-d>", "<C-d>")
keymap.set("", "<S-u>", "<C-u>")

-- Remap join
keymap.set("n", "gj", ":normal! <S-j><CR>")

-- Show all diagnostics on current line in floating window
keymap.set("n", "<leader>e", function()
  require("timber.buffers").open_float({ silent = true })
  vim.diagnostic.open_float()
end)
keymap.set("n", "<leader>E", function()
  vim.diagnostic.open_float()
  vim.cmd([[:execute "normal! \<C-w>w\<C-w>T"]])
end)

keymap.set("n", "<leader>j", vim.lsp.buf.code_action, { desc = "Code action" })

keymap.set("", "<leader>k", function()
  vim.lsp.buf.hover({
    border = "single",
    -- Silent when hover doesn't have any info.
    -- Useful if we use multple LSPs inside a buffer. This will prevent other LSPs from
    -- reporting false alert.
    silent = true,
  })
end, { desc = "Hover" })

keymap.set("n", "grr", require("custom.lsp_handlers").references, { desc = "Find references" })
keymap.set("n", "gd", require("custom.lsp_handlers").definition, { desc = "Go to definition" })

-- Remove search highlight
keymap.set("n", "<esc>", function()
  require("custom.lsp_handlers").remove_references_highlight()
  vim.cmd("noh")
end, { desc = "Remove search highlight" })

-- After making the first change, g. will repeat the change at the next identical word
-- After that, we can dot repeat
keymap.set("n", "g.", function()
  local before_change = vim.fn.getreg("@")
  local after_change = vim.fn.getreg(".")

  vim.fn.setreg("/", before_change)
  vim.cmd("normal! cgn" .. after_change)
end)

-- Replace current text under selection
keymap.set("v", "<leader>r", '"zy:%s/\\V<C-r>z//g<left><left>')

-- Replay q macro
keymap.set("n", "<S-q>", "@q")

-- Using mark m
keymap.set("n", "<S-m>", "'m")

-- Quickfix
keymap.set("n", "<leader>q", function()
  local qf_exists = vim.fn.getqflist({ winid = 0 }).winid ~= 0
  if qf_exists then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end, { desc = "Toggle quickfix window" })

-- Elixir specific
keymap.set({ "n", "i" }, "<C-l>", function()
  require("custom.elixir").insert_pipe()
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
  end,
})

-- I always make this typo
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
