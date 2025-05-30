local utils = require("custom.utils")
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    "olimorris/neotest-rspec",
    "rouge8/neotest-rust",
    "jfpedroza/neotest-elixir",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-plenary",
    "thenbe/neotest-playwright",
    "marilari88/neotest-vitest",
  },
  opts = {},
  cmd = { "TestSuite", "TestOutput", "TestSummary" },
  keys = {
    {
      "<leader>t",
      function()
        vim.cmd(":TimberClearLogs")
        require("neotest").run.run()
      end,
      mode = "n",
      desc = "Run the current test case under the cursor",
    },
    {
      "<leader>T",
      function()
        vim.cmd(":TimberClearLogs")
        local current_file = vim.fn.expand("%")
        require("neotest").run.run(current_file)
      end,
      mode = "n",
      desc = "Run all test cases in the current file",
    },
  },
  config = function()
    local neotest = require("neotest")
    local neotest_rspec = require("neotest-rspec")
    local neotest_rust = require("neotest-rust")({
      args = { "--no-capture" },
    })
    local neotest_elixir = require("neotest-elixir")({
      post_process_command = function(cmd)
        -- Redirect output to a file
        local shell_cmd = table.concat(cmd, " ")
        shell_cmd = shell_cmd .. " | tee /tmp/neotest_elixir.log"
        return { "bash", "-c", shell_cmd }
      end,
    })
    local neotest_jest = require("neotest-jest")
    local neotest_plenary = require("neotest-plenary")
    local neotest_playwright = require("neotest-playwright").adapter({
      options = {
        persist_project_selection = true,
        enable_dynamic_test_discovery = true,
      },
    })
    local neotest_vitest = require("neotest-vitest")({
      cwd = function(path)
        -- Find the cloest vite config file
        return require("neotest-vitest.util").root_pattern("{vite,vitest}.config.{js,ts,mjs,mts}")(
          path
        )
      end,
    })

    neotest.setup({
      adapters = {
        neotest_rspec,
        neotest_rust,
        neotest_elixir,
        neotest_jest,
        neotest_plenary,
        neotest_playwright,
        neotest_vitest,
      },
      consumers = {
        playwright = require("neotest-playwright.consumers").consumers,
        timber = require("timber.watcher.sources.neotest").consumer,
      },
    })

    vim.api.nvim_create_user_command("TestSuite", function()
      neotest.run.run(vim.fn.getcwd())
      neotest.summary.open()
    end, {})

    vim.api.nvim_create_user_command("TestOutput", function()
      -- Open test output in a new tab
      -- I hate it when you have to scroll to see the whole output
      neotest.output.open({
        enter = true,
        open_win = function()
          vim.cmd(":tabnew")
          return vim.api.nvim_tabpage_get_win(0)
        end,
      })
    end, {})

    vim.api.nvim_create_user_command("TestSummary", function()
      neotest.summary.toggle()
    end, {})
  end,
}
