local M = {}

function M.dump(o, nest)
  nest = nest or 2
  if type(o) == "table" then
    local s = "{ " .. "\n" .. string.rep(" ", nest)
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v, nest + 2) .. "," .. "\n" .. string.rep(" ", nest)
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

function M.log(message)
  local log_file_path = "/tmp/nvim_debug.log"
  local log_file = io.open(log_file_path, "a")
  io.output(log_file)
  io.write(M.dump(message) .. "\n")
  io.close(log_file)
end

function M.array_includes(array, value)
  for _, v in ipairs(array) do
    if v == value then
      return true
    end
  end

  return false
end

function M.array_find(array, predicate)
  for i, value in ipairs(array) do
    if predicate(value) then
      return value, i
    end
  end

  return nil, nil
end

function M.wrap(func, ...)
  local args = { ... }
  return function()
    func(unpack(args))
  end
end

function M.get_key_by_value(t, value)
  for k, v in pairs(t) do
    if v == value then
      return k
    end
  end

  return nil
end

function M.get_visual_selection()
  -- Get the position of the start of the visual selection
  local v_start = vim.fn.getpos("v")
  -- Get the position of the current cursor, also the end of the visual selection
  -- For line visual mode, this doesn't work since the cursor can be anywhere
  local v_end = vim.fn.getpos(".")

  local function run(s_start, s_end)
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, s_start[2] - 1, s_end[2], false)

    lines[1] = string.sub(lines[1], s_start[3], -1)

    if n_lines == 1 then
      lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
      lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end

    return lines
  end

  if v_start[2] <= v_end[2] then
    return run(v_start, v_end), v_start, v_end
  else
    return run(v_end, v_start), v_end, v_start
  end
end

function M.merge_tables(t1, t2)
  if type(t1) == "table" and type(t2) == "table" then
    for k, v in pairs(t2) do
      if type(v) == "table" and type(t1[k] or false) == "table" then
        M.merge_tables(t1[k], v)
      else
        t1[k] = v
      end
    end
  end

  return t1
end

function M.highlight_current_line()
  local current_line = vim.fn.line(".")
  vim.api.nvim_set_hl(0, "Custom.CurrentLine", { link = "Search" })
  local ns_id = vim.api.nvim_create_namespace("custom.current_line_highlight")
  vim.api.nvim_buf_add_highlight(0, ns_id, "Custom.CurrentLine", current_line - 1, 0, -1)

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  end, 500)
end

function M.safe_cmd(cmd)
  local ok, result = pcall(vim.cmd, cmd)
  if not ok then
    -- Not sure about this line
    local extracted = string.match(result, "E%d+: .+$")
    vim.notify(extracted, vim.log.levels.ERROR)
  end
end

---Trim the redundant whitespaces from the input lines while preserving the indentation level.
---@param input string
---@return string
function M.format_indentation(input)
  input = input:gsub("%s+$", "")
  local lines = vim.split(input, "\n", { trimempty = false })
  local smallest_indent

  for _, line in ipairs(lines) do
    -- Count the number of leading whitespaces
    -- Don't consider indent of empty lines
    local leading_whitespaces = line:match("^%s*")
    if #leading_whitespaces ~= line:len() then
      smallest_indent = smallest_indent and math.min(smallest_indent, #leading_whitespaces)
        or #leading_whitespaces
    end
  end

  for i, line in ipairs(lines) do
    line = line:sub(smallest_indent + 1)
    lines[i] = line
  end

  return table.concat(lines, "\n")
end

return M
