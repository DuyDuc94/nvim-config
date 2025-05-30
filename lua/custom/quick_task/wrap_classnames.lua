local utils = require("custom.utils")
local M = {}

-- Returns true iff the file has already imported classnames
local function classnames_imported()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang then
    vim.notify(string.format("Treesitter is not installed for lang %s", lang), vim.log.levels.ERROR)
    return
  end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  local parsed_tree = parser:parse({ start_row = 0, end_row = -1 })[1]

  local query = vim.treesitter.query.parse(
    lang,
    [[
      (import_statement
        source: (string (string_fragment) @source)
        (#eq? @source "classnames"))
    ]]
  )

  local matches = query:iter_matches(parsed_tree:root(), bufnr)
  return matches() ~= nil
end

-- selected=nil: {classNames(<original>)}
-- selected=A: {classNames(<original - selected>, A)}
local function construct_classnames_string(original, selected)
  if selected == nil then
    return string.format('{classNames("%s")}', original)
  else
    local split = vim.split(original, " ", { trimempty = true })
    local to_remove = vim.split(selected, " ", { trimempty = true })
    local result = {}

    for _, class in ipairs(split) do
      if not utils.array_includes(to_remove, class) then
        table.insert(result, class)
      end
    end

    return string.format('{classNames("%s", "%s")}', table.concat(result, " "), vim.trim(selected))
  end
end

local function prepend_import_statement()
  -- Add import statement at the top of the file
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { [[ import classNames from "classnames" ]] })
end

function M.run(context)
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)

  if not lang then
    vim.notify(string.format("Treesitter is not installed for lang %s", lang), vim.log.levels.ERROR)
    return
  end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  local parsed_tree = parser:parse({ start_row = 0, end_row = -1 })[1]

  local query = vim.treesitter.query.parse(
    lang,
    [[
      (jsx_attribute
        (property_identifier) @attr_id
        (string)  @attr_value
        (#eq? @attr_id "className")) @attr
    ]]
  )

  if context.mode == "v" and #context.selected_text > 1 then
    vim.api.nvim_notify(
      "Cannot wrap multiple lines",
      vim.log.levels.ERROR,
      { title = "quick_task.lua" }
    )
    return
  end

  for _, match in query:iter_matches(parsed_tree:root(), bufnr) do
    local attr_node = match[utils.get_key_by_value(query.captures, "attr")]

    -- Get cursor position of the current window
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Minus 1 because Treesitter uses 0-index while Nvim uses 1-index
    local cursor_range = { cursor_pos[1] - 1, cursor_pos[2], cursor_pos[1] - 1, cursor_pos[2] }

    if vim.treesitter.node_contains(attr_node, cursor_range) then
      local class_name_string = match[utils.get_key_by_value(query.captures, "attr_value")]
      local node_text = vim.treesitter.get_node_text(class_name_string, bufnr)
      local r1, r2, r3, r4 = class_name_string:range(false)
      local after_string = construct_classnames_string(
        string.sub(node_text, 2, -2),
        context.mode == "v" and context.selected_text[1] or nil
      )

      vim.api.nvim_buf_set_text(bufnr, r1, r2, r3, r4, { after_string })

      -- Set cursor position to the end of the inserted text to prepare
      -- for typing the next class name
      vim.api.nvim_win_set_cursor(0, { r1 + 1, r2 + after_string:len() - 2 })

      -- Import className if not already imported
      if not classnames_imported() then
        prepend_import_statement()
      end

      return
    end
  end

  -- No enclosing className attribute found
  vim.api.nvim_notify(
    "Cursor is not inside a className attribute",
    vim.log.levels.ERROR,
    { title = "quick_task.lua" }
  )
end

return M
