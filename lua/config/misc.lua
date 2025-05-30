local utils = require("custom.utils")

-- Highlight trailing whitespace
vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = "red", bg = "red", fg = "white" })
vim.api.nvim_set_hl(0, "SpecialKey", { ctermbg = "red", bg = "#ff0000" })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*" },
  callback = function()
    if not utils.array_includes({ "nofile", "terminal", "" }, vim.bo.buftype) then
      vim.cmd([[match ExtraWhitespace /\s\+$/]])
    end
  end,
})

local colors = require("tokyonight.colors").setup({ style = "storm" })
-- A shade from Tokyo Night Storm green: https://coolors.co/9ece6a
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2d4316" })
-- A shade from Tokyo Night Storm red: https://coolors.co/f7768e
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#630617" })
vim.api.nvim_set_hl(0, "DiffText", { bg = colors.blue0 })
