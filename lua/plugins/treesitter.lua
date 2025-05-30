local utils = require("custom.utils")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Configs
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "typescript",
          "tsx",
          "astro",
          "html",
          "css",
          "markdown",
          "elixir",
          "eex",
          "heex",
          "go",
          "gomod",
          "ruby",
          "rust",
          "python",
          "query",
          "svelte",
          "terraform",
          "json",
          "dart",
          "yaml",
          "jinja"
        },
        highlight = { enable = true },
        autopairs = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    opts = {
      filetypes = { "html", "xml", "tsx", "jsx", "typescriptreact", "eex", "eruby", "astro" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "VeryLazy" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Configs
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            disable = { "dart" },

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              ["af"] = {
                query = "@function.outer",
                desc = "Select outer part of a function region",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "Select inner part of a function region",
              },
              ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ["@function.outer"] = "v", -- charwise
              ["@class.outer"] = "v",    -- linewise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = function(args)
              local query_string = args["query_string"]
              if utils.array_includes({ "@function.inner", "@class.inner" }, query_string) then
                return false
              end

              return true
            end,
          },
        },
      })
    end,
  },
  {
    "RRethy/nvim-treesitter-textsubjects",
    event = { "VeryLazy" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Configs
      require("nvim-treesitter-textsubjects").configure({
        keymaps = {
          ["<CR>"] = "textsubjects-smart",
        },
      })
    end,
  },
}
