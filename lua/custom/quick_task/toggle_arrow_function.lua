local ts_utils = require("nvim-treesitter.ts_utils")
local utils = require("custom.utils")

local M = {}

local function prepare_return_statement(func_body)
  local bufnr = vim.api.nvim_get_current_buf()
  local func_body_text = vim.treesitter.get_node_text(func_body, bufnr)

  local lines = vim.split(func_body_text, "\n", { trimempty = true })
  lines[1] = "return " .. lines[1]
  table.insert(lines, 1, "{")
  table.insert(lines, "}")

  return lines
end

local function prepare_return_expression(func_body)
  local bufnr = vim.api.nvim_get_current_buf()
  local return_value_node = func_body:named_child(0):named_child(0)
  local return_value_text = vim.treesitter.get_node_text(return_value_node, bufnr)

  return vim.split(return_value_text, "\n", { trimempty = true })
end

function M.run(_)
  local bufnr = vim.api.nvim_get_current_buf()

  local current = ts_utils.get_node_at_cursor()
  while current ~= nil and current:type() ~= "arrow_function" do
    current = current:parent()
  end

  if current == nil then
    -- No enclosing className attribute found
    vim.api.nvim_notify(
      "Cursor is not inside an arrow function",
      vim.log.levels.ERROR,
      { title = "quick_task.lua" }
    )

    return
  end

  -- Get cursor position of the current window
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- Minus 1 because Treesitter uses 0-index while Nvim uses 1-index
  local cursor_range = { cursor_pos[1] - 1, cursor_pos[2], cursor_pos[1] - 1, cursor_pos[2] }

  local arrow_func = current
  if vim.treesitter.node_contains(arrow_func, cursor_range) then
    local func_body = arrow_func:field("body")[1]

    if func_body:type() == "statement_block" then
      if func_body:named_child_count() > 1 then
        vim.api.nvim_notify(
          "Cannot toggle arrow function with multiple statements",
          vim.log.levels.ERROR,
          { title = "quick_task.lua" }
        )
        return
      end

      if
        not utils.array_includes(
          { "return_statement", "expression_statement" },
          func_body:named_child(0):type()
        )
      then
        vim.api.nvim_notify(
          "Cannot toggle arrow function with non-return or expression statement",
          vim.log.levels.ERROR,
          { title = "quick_task.lua" }
        )
        return
      end

      local r1, r2, r3, r4 = func_body:range(false)
      vim.api.nvim_buf_set_text(bufnr, r1, r2, r3, r4, prepare_return_expression(func_body))
    else
      local r1, r2, r3, r4 = func_body:range(false)
      vim.api.nvim_buf_set_text(bufnr, r1, r2, r3, r4, prepare_return_statement(func_body))

      -- Reindent the inserted text
      vim.api.nvim_win_set_cursor(0, { r1 + 1, r2 })
      vim.cmd("normal! =a{")
    end

    return
  end
end

return M
