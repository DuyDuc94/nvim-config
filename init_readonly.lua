-- Init file suitable for read only buffer.
-- Example use case: Kitty scrollback buffer explorer

-- Randomize seed
math.randomseed(os.time())

-- Quickly quit Neovim with q (no need to type !)
vim.keymap.set("n", "q", ":qa!<CR>", { desc = "Quickly quit Neovim with q" })

require("config.base") -- For Vim base configs
require("config.mappings") -- For key mappings
require("config.lazy").setup({
  bootstrap = false,
  update_check = false,
  plugins_spec = {
    { "colorscheme" },
    { "ui", packages = { "m00qek/baleia.nvim" } },
    { "editing", packages = { "gbprod/yanky.nvim" } },
    { "text_object", packages = { "echasnovski/mini.ai" } },
    { "navigation", packages = { "folke/flash.nvim" } },
  },
})
