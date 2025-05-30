return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "VeryLazy" },
    keys = {
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_hunk()
        end,
        mode = "n",
        desc = "Git reset the current hunk",
      },
      {
        "<leader>gR",
        function()
          require("gitsigns").reset_buffer()
        end,
        mode = "n",
        desc = "Git reset current file",
      },
      {
        "<leader>gp",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        mode = "n",
        desc = "Preview git diff of the current line",
      },
    },
    config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      vim.api.nvim_create_user_command("GitsignsAllHunks", function()
        gitsigns.setqflist("all")
      end, {})
    end,
  },
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    cmd = { "DiffviewOpen" },
    init = function()
      vim.cmd([[cab do DiffviewOpen]])
      vim.cmd([[cab df DiffviewFileHistory]])
    end,
    config = function()
      local actions = require("diffview.actions")
      local opts = {
        view = {
          merge_tool = {
            layout = "diff3_mixed",
          },
        },
        file_history_panel = {
          win_config = {
            win_opts = {
              winhighlight = "CursorLine:Visual",
            },
          },
        },
        file_panel = {
          win_config = {
            win_opts = {
              winhighlight = "CursorLine:Visual",
            },
          },
        },
        keymaps = {
          view = {
            ["<tab>"] = false,
            ["<C-n>"] = actions.select_next_entry,
            ["<s-tab>"] = false,
            ["<C-p>"] = actions.select_prev_entry,
          },
          file_panel = {
            ["<tab>"] = false,
            ["<C-n>"] = actions.select_next_entry,
            ["<s-tab>"] = false,
            ["<C-p>"] = actions.select_prev_entry,
          },
          file_history_panel = {
            ["<tab>"] = false,
            ["<C-n>"] = actions.select_next_entry,
            ["<s-tab>"] = false,
            ["<C-p>"] = actions.select_prev_entry,
            ["o"] = actions.open_in_diffview,
            ["<S-o>"] = function()
              actions.copy_hash()
              local unnamed_content = vim.fn.getreg("+")
              vim.fn.system(string.format("gh browse %s", unnamed_content))
            end,
          },
        },
        enhanced_diff_hl = true,
      }

      require("diffview").setup(opts)
    end,
  },
  {
    "rickhowe/diffchar.vim",
  },
}
