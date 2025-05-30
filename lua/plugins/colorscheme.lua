return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  init = function()
    vim.cmd.colorscheme("tokyonight-storm")

    local colors = require("tokyonight.colors").setup({ style = "storm" })
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg = colors.dark5 })
    vim.api.nvim_set_hl(0, "LineNr", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg = colors.dark5 })
  end,
  opts = {
    plugins = {
      cmp = true,
      flash = false,
      gitsigns = true,
      grug_far = true,
      lazy = true,
      neotest = true,
      notify = true,
      telescope = true,
      treesitter = true,
      yanky = false,
    },
  },
}
