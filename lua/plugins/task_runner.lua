return {
  "stevearc/overseer.nvim",
  keys = {
    { "<leader>d", ":OverseerRun<CR>", desc = "Open overseer task selection" },
    {
      "<leader>D",
      function()
        local overseer = require("overseer")
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.notify("No tasks found", vim.log.levels.WARN)
        else
          overseer.run_action(tasks[1], "restart")
        end
      end,
      desc = "Restart last overseer task",
    },
  },
  opts = {
    strategy = { "jobstart", use_terminal = false },
    templates = {},
    actions = {
      ["custom open float"] = {
        run = function(task)
          task:open_output("float")
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "q", ":close<CR>", { buffer = bufnr })
        end,
      },
      ["restart task"] = {
        run = function(task)
          task:restart()
        end,
      },
    },
    task_list = {
      bindings = {
        ["o"] = ":OverseerQuickAction custom open float<CR>",
        ["r"] = ":OverseerQuickAction restart task<CR>",
      },
    },
  },
  config = function(_, opts)
    require("overseer").setup(opts)
    require("plugins.task_runner.custom_tasks")
  end,
}
