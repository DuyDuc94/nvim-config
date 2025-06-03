return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          function()
            return os.date("%H:%M")
          end,
        },
      }
      return opts
    end,
  },
}
