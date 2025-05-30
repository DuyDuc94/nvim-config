local utils = require("custom.utils")

return {
  "Goose97/timber.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    -- A shade from Tokyo Night Storm blue2: https://coolors.co/0db9d7
    vim.api.nvim_set_hl(0, "Timber.LogStatement", { bg = "#05434D" })

    -- Create user commands
    vim.api.nvim_create_user_command("TimberClearLogs", function()
      require("timber.buffers").clear_captured_logs()
      require("timber.summary").clear()
    end, {})

    vim.api.nvim_create_user_command("TimberAllLogs", function()
      require("timber.actions").search_log_statements()
    end, {})

    vim.cmd([[cab tc TimberClearLogs]])
  end,
  keys = {
    {
      "gls",
      function()
        require("timber.actions").insert_log({
          templates = { before = "default", after = "default" },
          position = "surround",
        })
      end,
      mode = { "n", "v" },
      desc = "[G]o [L]og: Insert a surround log statements at the cursor position",
    },
    {
      "glc",
      function()
        require("timber.actions").clear_log_statements({ global = false })
      end,
      mode = "n",
      desc = "[G]o [L]og [D]elete: Clear all log statements in the current buffer",
    },
    {
      "<leader>l",
      function()
        require("timber.summary").toggle()
      end,
      mode = "n",
      desc = "Toggle log summary window",
    },
    {
      "gll",
      function()
        return require("timber.actions").insert_log({
          template = "pomelo",
          position = "below",
          operator = true,
        }) .. "_"
      end,
      mode = "n",
      expr = true,
      desc = "[G]o [L]og: Insert a special log statement for pomelo project",
    },
    {
      "gly",
      function()
        local bufnr = require("timber.buffers").open_float({ silent = true })

        if bufnr then
          local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          vim.fn.setreg(vim.v.register, table.concat(content, "\n"))
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end,
      mode = "n",
      desc = "[G]o [L]og [Y]ank: Yank the content of the log buffer",
    },
  },
  config = function()
    local js_like_single_log = [[console.log("%log_marker %log_target", %log_target)]]
    local js_like_batch_log =
      [[console.log("%log_marker", { %repeat<"%log_target": %log_target><, > })]]
    local js_like_plain_log = [[console.log("%log_marker %insert_cursor")]]

    local opts = {
      log_templates = {
        default = {
          javascript = js_like_single_log,
          typescript = js_like_single_log,
          jsx = js_like_single_log,
          tsx = js_like_single_log,
          lua = {
            [[_utils.log("%watcher_marker_start" .. _utils.dump(%log_target) .. "%watcher_marker_end")]],
            auto_import = [[local _utils = require("custom.utils")]],
          },
          elixir = {
            [[Logger.info(~s|%watcher_marker_start#{inspect(%log_target, pretty: true)}%watcher_marker_end\n|)]],
            auto_import = [[require Logger]],
          },
        },
        plain = {
          javascript = js_like_plain_log,
          typescript = js_like_plain_log,
          jsx = js_like_plain_log,
          tsx = js_like_plain_log,
          lua = [[utils.log("%log_marker %insert_cursor")]],
          elixir = {
            [[Logger.info(~s|%watcher_marker_start %insert_cursor %watcher_marker_end\n|)]],
            auto_import = [[require Logger]],
          },
        },
        pomelo = {
          elixir = {
            utils.format_indentation([[
              content = Test.Snapshot.content(%log_target)
              Logger.info(~s|%watcher_marker_start#{content}%watcher_marker_end\n|)
            ]]),
            auto_import = [[require Logger]],
          },
        },
      },
      batch_log_templates = {
        default = {
          javascript = js_like_batch_log,
          typescript = js_like_batch_log,
          jsx = js_like_batch_log,
          tsx = js_like_batch_log,
          lua = {
            [[_utils.log(string.format("%watcher_marker_start%repeat<\n  %log_target=%s><, >%watcher_marker_end", %repeat<_utils.dump(%log_target)><, >))]],
            auto_import = [[local _utils = require("custom.utils")]],
          },
          elixir = {
            [[Logger.info(~s|%watcher_marker_start#{inspect(%{%repeat<%log_target: %log_target><, >}, pretty: true)}%watcher_marker_end\n|)]],
            auto_import = [[require Logger]],
          },
        },
      },
      log_watcher = {
        enabled = true,
        sources = {
          smashburger_web_nextjs = {
            name = "NextJS server",
            type = "filesystem",
            path = "/tmp/smashburger_dev.log",
            buffer = {
              syntax = "javascript",
            },
          },
          nvim_debug = {
            name = "timber.nvim debug",
            type = "filesystem",
            path = "/tmp/nvim_debug.log",
            buffer = {
              syntax = "timber-lua",
            },
          },
          neotest_elixir = {
            name = "Neotest elixir adapter",
            type = "filesystem",
            path = "/tmp/neotest_elixir.log",
          },
          neotest = {
            name = "Neotest",
            type = "neotest",
            buffer = {
              syntax = "timber-lua",
            },
          },
          pomelo_debug = {
            name = "pomelo debug",
            type = "filesystem",
            path = "/Users/goose/Documents/workspace/personal/pomelo/log/pomelo.log",
            buffer = {
              syntax = "erlang",
            },
          },
          orange_debug = {
            name = "orange debug",
            type = "filesystem",
            path = "./log/orange.log",
            buffer = {
              syntax = "erlang",
            },
          },
        },
      },
    }

    require("timber").setup(opts)
  end,
}
