vim.lsp.enable({
  "typescript_language_server",
  "rust_analyzer",
  "lua_ls",
  "astro",
  "tailwindcss",
  "lexical",
})

return {
  -- Manager plugin for LSP servers, DAP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      local mason = require("mason")
      mason.setup(opts)

      local ensure_installed = { "prettier", "biome", "stylua" }
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
      end, {})
    end,
  },
  {
    "stevearc/aerial.nvim",
    keys = {
      {
        "<leader>o",
        mode = "n",
        ":AerialToggle left<CR>",
        desc = "[A]erial: Toggle aerial.nvim panel",
      },
    },
    opts = {
      keymaps = {
        ["o"] = "actions.jump",
        ["<CR>"] = "actions.scroll",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/lsp_handlers",
    main = "custom.lsp_handlers",
    name = "custom.lsp_handlers",
    dependencies = { "custom.smart_cycle" },
    config = true,
  },
}
