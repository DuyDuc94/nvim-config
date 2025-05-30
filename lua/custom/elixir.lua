local M = {}

local function insert_pipe_new_line()
  local current_line = vim.fn.line(".")
  local indent = vim.fn.indent(current_line)
  vim.api.nvim_buf_set_lines(
    0,
    current_line,
    current_line,
    false,
    { string.rep(" ", indent) .. "|> " }
  )

  vim.api.nvim_win_set_cursor(0, { current_line + 1, indent + 3 })
  vim.cmd("startinsert!")
end

local function insert_pipe_current_line(line)
  local current_line = vim.fn.line(".")
  vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, false, { line .. " |> " })

  vim.cmd("startinsert!")
end

function M.insert_pipe()
  -- If the current line starts with a pipe, we go to the next line
  local line = vim.api.nvim_get_current_line()
  if vim.trim(line):match("^|>") then
    insert_pipe_new_line()
  else
    insert_pipe_current_line(line)
  end
end

return M
