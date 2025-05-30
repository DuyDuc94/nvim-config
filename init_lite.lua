-- Init file suitable for buffers require minimal editing function.
-- Example use case: edit current command line in zsh-vi-mode

-- Randomize seed
math.randomseed(os.time())

-- Quickly write and quit Neovim with q (no need to type !)
vim.keymap.set("n", "q", ":wqa!<CR>", { desc = "Quickly quit Neovim with q" })

require("config.base") -- For Vim base configs
require("config.mappings") -- For key mappings
require("config.lazy").setup({
  bootstrap = false,
  update_check = false,
  plugins_spec = {
    { "colorscheme" },
    { "editing" },
    { "ui", packages = { "m00qek/baleia.nvim" } },
    { "text_object", packages = { "echasnovski/mini.ai" } },
    { "navigation", packages = { "folke/flash.nvim" } },
  },
})
