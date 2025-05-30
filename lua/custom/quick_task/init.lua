local M = {}
local utils = require("custom.utils")

local tasks = {}

function M.setup(opts)
  tasks = opts.tasks
end

local function prepare_context()
  local task_context = {}

  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" then
    local selected_text, v_start, v_end = utils.get_visual_selection()
    task_context.selected_text = selected_text
    task_context.selected_range = { v_start, v_end }
  end

  task_context.filetype = vim.bo.filetype
  task_context.mode = mode

  return task_context
end

function M.prompt_task()
  local task_specs = {}

  for _, task in pairs(tasks) do
    table.insert(task_specs, task)
  end

  -- Preserve the original context
  local context = prepare_context()

  vim.ui.select(task_specs, {
    prompt = "Select task:",
    format_item = function(spec)
      -- Pad the label to the right
      return spec.name
    end,
  }, function(choice)
    if choice == nil then
      return
    end

    local cmd = choice.cmd

    if type(cmd) == "function" then
      cmd(context)
    elseif type(cmd) == "string" then
      local ok, result = pcall(vim.cmd, cmd)
      if not ok then
        -- Not sure about this line
        local extracted = string.match(result, "E%d+: .+$")
        vim.notify(extracted, vim.log.levels.ERROR)
      end
    end
  end)
end

return M
