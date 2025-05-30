local utils = require("custom.utils")

return {
  {
    "ThePrimeagen/harpoon",
    init = function()
      local colors = require("tokyonight.colors").setup({ style = "storm" })

      vim.api.nvim_set_hl(0, "HarpoonBorder", { fg = colors.blue })
    end,
    keys = {
      {
        "<leader><S-h>",
        ":lua require('harpoon.mark').add_file()<CR>",
        mode = "n",
        desc = "Add current buffer to Harpoon marks list",
      },
      {
        "<leader>h",
        ":lua require('harpoon.ui').toggle_quick_menu()<CR>",
        mode = "n",
        desc = "Toggle Harpoon menu",
      },
      {
        "<C-k>",
        ":lua require('harpoon.ui').nav_prev()<CR>",
        mode = "n",
        desc = "Navigate to previous buffer in marks list",
      },
      {
        "<C-j>",
        ":lua require('harpoon.ui').nav_next()<CR>",
        mode = "n",
        desc = "Navigate to next buffer in marks list",
      },
    },
    config = true,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    init = function()
      local colors = require("tokyonight.colors").setup({ style = "storm" })

      vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = colors.dark3 })
      vim.api.nvim_set_hl(0, "FlashLabel", { fg = colors.yellow, bold = true })
    end,
    keys = {
      {
        "<CR>",
        mode = "n",
        function()
          require("flash").jump()
        end,
        desc = "Enter Flash jump mode",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
    },
    opts = {
      label = {
        uppercase = false,
      },
      modes = {
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T" },
        },
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)
      require("flash.plugins.char").setup()
      for _, key in ipairs(opts.modes.char.keys) do
        -- We don't want flash to work in operator pending mode
        vim.keymap.del("o", key)
      end
    end,
  },
  {
    -- Inspired by unimpaired.vim
    -- The menemonic device is:
    -- d = diagnostic
    -- q = quickfix
    -- g = git hunks
    dir = vim.fn.stdpath("config") .. "/lua/custom/smart_cycle",
    main = "custom.smart_cycle",
    name = "custom.smart_cycle",
    event = "VeryLazy",
    dependencies = { "custom.lsp_handlers" },
    opts = {
      actions = {
        quickfix = {
          key = "q",
          next_command = function()
            utils.safe_cmd("cnext")
            require("custom.lsp_handlers").highlight_current_quickfix_entry()
          end,
          prev_command = function()
            utils.safe_cmd("cprevious")
            require("custom.lsp_handlers").highlight_current_quickfix_entry()
          end,
        },
        diagnostic = {
          key = "d",
          next_command = function()
            vim.diagnostic.goto_next({ wrap = false })
          end,
          prev_command = function()
            vim.diagnostic.goto_prev({ wrap = false })
          end,
        },
        git_hunk = {
          key = "g",
          next_command = function()
            require("gitsigns").next_hunk()
          end,
          prev_command = function()
            require("gitsigns").prev_hunk()
          end,
        },
      },
    },
    config = function(_, opts)
      local smart_cycle = require("custom.smart_cycle")
      smart_cycle.setup(opts)

      -- Override builtin n and N with smart cycle
      -- If we just performed an smart cycle action, n and N can cycle through them
      -- Search with / and ? will clear the last action, allow use to cycle through search result normally
      vim.keymap.set("n", "n", function()
        if smart_cycle.has_last_action() then
          smart_cycle.last_action_next()
        else
          -- Not sure why we need execute here
          pcall(function()
            vim.cmd([[:execute "normal! n"]])
          end)
        end
      end, { desc = "Repeat the last next action" })

      vim.keymap.set("n", "<S-n>", function()
        if smart_cycle.has_last_action() then
          smart_cycle.last_action_prev()
        else
          -- Not sure why we need execute here
          pcall(function()
            vim.cmd([[:execute "normal! N"]])
          end)
        end
      end, { desc = "Repeat the last prev action" })

      -- After search with / or ?, clear the last action
      vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function(args)
          if require("custom.utils").array_includes({ "/", "?" }, args["match"]) then
            smart_cycle.clear_last_action()
          end
        end,
      })

      vim.keymap.set("n", "*", function()
        smart_cycle.clear_last_action()
        vim.cmd([[ normal! *]])
      end)

      vim.keymap.set("n", "#", function()
        smart_cycle.clear_last_action()
        vim.cmd([[ normal! #]])
      end)

      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "quickfix",
        callback = function()
          smart_cycle.set_last_action("quickfix")
        end,
      })
    end,
  },
}
