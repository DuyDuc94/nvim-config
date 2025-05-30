local config = {
  encoding = "utf-8",
  autoread = true,
  autoindent = true,
  foldmethod = "indent",
  updatetime = 100,
  foldlevelstart = 99,
  hlsearch = true,
  ignorecase = true,
  smartcase = true,
  background = "dark",
  termguicolors = true,
  list = true,
  number = true,
  listchars = { tab = "▸ ", trail = "·" },
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  colorcolumn = "120",
  grepprg = "rg --vimgrep --no-heading --smart-case",
  -- Global clipboard
  clipboard = "unnamedplus",
  relativenumber = true,
  complete = "",
}

for i, v in pairs(config) do
  vim.opt[i] = v
end

vim.opt.diffopt:append({ "algorithm:patience" })
vim.opt.diffopt:append({ "linematch:60" })

vim.opt.clipboard = "unnamedplus"

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
