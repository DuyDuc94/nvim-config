local utils = require("custom.utils")
local M = { count = nil }

local function duplicate(start_pos, end_pos, count, motion_type)
  local range
  if motion_type == "char" then
    range = { start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3] }
  elseif motion_type == "line" then
    range = { start_pos[2] - 1, 0, end_pos[2] - 1, vim.v.maxcol }
  end

  -- Get the text content
  local content = vim.api.nvim_buf_get_text(0, range[1], range[2], range[3], range[4], {})

  if motion_type == "char" then
    if count > 1 then
      content[1] = string.rep(content[1], count)
    end
  elseif motion_type == "line" then
    local original_content = vim.deepcopy(content)
    for _ = 2, count do
      vim.list_extend(content, original_content)
    end
  end

  -- Insert the duplicated text after the selection
  if motion_type == "char" then
    local line = vim.fn.getline(end_pos[2])
    -- Edge case when the line is empty. We need to insert from 0 index
    local end_col = line == "" and 0 or end_pos[3]
    -- For charwise, insert inline
    vim.api.nvim_buf_set_text(0, end_pos[2] - 1, end_col, end_pos[2] - 1, end_col, content)

    -- Highlight the inserted lines
    vim.highlight.range(
      0,
      M.hl_ns,
      "Timber.Insert",
      { end_pos[2] - 1, end_col },
      { end_pos[2] - 1, end_col + #content[1] },
      { regtype = "v", inclusive = false }
    )

    vim.api.nvim_win_set_cursor(0, { end_pos[2], end_pos[3] })
  elseif motion_type == "line" then
    -- For linewise, insert with a new line
    vim.api.nvim_buf_set_lines(0, end_pos[2], end_pos[2], false, content)

    -- Highlight the inserted lines
    vim.highlight.range(
      0,
      M.hl_ns,
      "Timber.Insert",
      { end_pos[2], 0 },
      { end_pos[2] + #content - 1, 0 },
      { regtype = "V", inclusive = false }
    )

    -- Move cursor to the inserted text
    local indent = vim.fn.indent(end_pos[2] + 1)
    vim.api.nvim_win_set_cursor(0, { end_pos[2] + 1, indent })

    -- Center the view if needed
    local last_visible = vim.fn.line("w$")
    if #content > 10 and end_pos[2] > last_visible - 20 then
      vim.cmd("normal! zz")
    end
  end

  M.insert_hl_timer:start(
    500,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_buf_clear_namespace(0, M.hl_ns, 0, -1)
    end)
  )
end

-- Function to duplicate text based on operator motion
function M.normal_duplicate(motion_type)
  local start_pos = vim.fn.getpos("'[")
  local end_pos = vim.fn.getpos("']")

  local count = M.count or 1
  duplicate(start_pos, end_pos, count, motion_type)
end

function M.duplicate()
  vim.go.operatorfunc = "v:lua.require'custom.duplicate_operator'.normal_duplicate"

  -- Reset count
  -- Learned from mini.operators: https://github.com/echasnovski/mini.operators/blob/main/lua/mini/operators.lua#L413
  M.count = vim.v.count1
  return vim.api.nvim_replace_termcodes('<Cmd>echon ""<CR>g@', true, true, true)
end

function M.visual_duplicate()
  local mode = vim.api.nvim_get_mode().mode
  local count = vim.v.count1

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "nx", true)

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  duplicate(start_pos, end_pos, count, mode == "v" and "char" or "line")
end

function M.setup()
  M.hl_ns = vim.api.nvim_create_namespace("custom.duplicate_operator")
  M.insert_hl_timer = vim.uv.new_timer()
end

return M
