local M = { references_highlight = false }

local function quickfix_entry_match_current_buf(item)
  if item.bufnr then
    return item.bufnr == vim.api.nvim_get_current_buf()
  end

  local user_data = item.user_data
  -- Get the current file path
  local file_path = vim.fn.expand("%:~:.")
  return user_data and user_data.uri and string.find(user_data.uri, file_path)
end

local function highlight_current_buf_quickfix_entries(qflist_items)
  for _, item in ipairs(qflist_items) do
    if quickfix_entry_match_current_buf(item) then
      local range = item.user_data.range

      vim.highlight.range(
        0,
        M.hl_lsp_reference,
        "Custom.LspHandlers.References",
        { range.start.line, range.start.character },
        { range["end"].line, range["end"].character },
        { regtype = "v", inclusive = false }
      )
    end
  end

  M.references_highlight = true
end

function M.references(options)
  options = options or {}

  -- Highlight the matches in the current buffer
  -- Also, move to the first match and highlight it
  options.on_list = function(opts)
    vim.fn.setqflist({}, " ", {
      items = opts.items,
      context = "custom.lsp_handlers.references",
    })

    vim.cmd("cfirst")
    vim.cmd("normal! zz")

    M.highlight_current_quickfix_entry()
    highlight_current_buf_quickfix_entries(opts.items)

    require("custom.smart_cycle").set_last_action("quickfix")
  end

  vim.lsp.buf.references(nil, options)
end

---Highlight the ranges of the quickfix list items for the current buffer
function M.highlight_current_quickfix_entry()
  local qflist = vim.fn.getqflist({ idx = 0, items = 0, context = 0 })

  if qflist.context ~= "custom.lsp_handlers.references" then
    return
  end

  if not M.references_highlight then
    highlight_current_buf_quickfix_entries(qflist.items)
  end

  vim.api.nvim_buf_clear_namespace(0, M.hl_lsp_cur_reference, 0, -1)

  local current_item = qflist.items[qflist.idx]

  if quickfix_entry_match_current_buf(current_item) then
    local range = current_item.user_data.range

    vim.highlight.range(
      0,
      M.hl_lsp_cur_reference,
      "Custom.LspHandlers.CurReferences",
      { range.start.line, range.start.character },
      { range["end"].line, range["end"].character },
      { regtype = "v", inclusive = false, priority = vim.highlight.priorities.user + 1 }
    )
  end
end

function M.remove_references_highlight()
  if M.references_highlight then
    vim.api.nvim_buf_clear_namespace(0, M.hl_lsp_reference, 0, -1)
    vim.api.nvim_buf_clear_namespace(0, M.hl_lsp_cur_reference, 0, -1)
    M.references_highlight = false
  end
end

---Find a class name inside a className attribute
---@param class_name_string string
---@param cursor_index_inside_string number
---@return string|nil
local function find_subclass_name(class_name_string, cursor_index_inside_string)
  -- If the cursor is in a whitespace, skip
  if
    string.sub(class_name_string, cursor_index_inside_string, cursor_index_inside_string) == " "
  then
    return nil
  end

  local space_before, space_after = 0, #class_name_string

  for i = cursor_index_inside_string - 1, 1, -1 do
    if string.sub(class_name_string, i, i) == " " then
      space_before = i + 1
      break
    end
  end

  for i = cursor_index_inside_string + 1, #class_name_string do
    if string.sub(class_name_string, i, i) == " " then
      space_after = i - 1
      break
    end
  end

  return class_name_string:sub(space_before, space_after)
end

---@return boolean success
local function go_to_css_class_definition()
  local utils = require("custom.utils")
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.getpos(".")[3]

  -- Check if the cursor is inside a string
  local before = string.find(line, "[\"'`]", 0)

  if not before then
    return false
  end

  local start_quote = string.sub(line, before, before)
  local after = string.find(line, start_quote, col + 1)

  if not after then
    return false
  end

  if not vim.list_contains({ "jsx", "tsx" }, vim.bo.filetype) then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)

  if not lang then
    return false
  end

  local parser = vim.treesitter.get_parser(bufnr, lang)
  local parsed_tree = parser:parse({ start_row = 0, end_row = -1 })[1]

  local query = vim.treesitter.query.parse(
    lang,
    [[
      (jsx_attribute
        (property_identifier) @attr_id
        (_) @attr_value (#contain-cursor? @attr_value)
        (#eq? @attr_id "className")) @attr
    ]]
  )

  -- There's should be only one match
  for _, _ in query:iter_matches(parsed_tree:root(), bufnr) do
    -- Exclude the quote
    local class_name_string = string.sub(line, before + 1, after - 1)

    local cursor_index_inside_string = col - before
    local sub_class_name = find_subclass_name(class_name_string, cursor_index_inside_string)
    -- This is rg syntax
    vim.cmd(
      string.format('silent! grep "\\.%s" --type css --type sass --type less', sub_class_name)
    )
    local success = #vim.fn.getqflist() > 0

    if success then
      vim.cmd("normal! zz")
      utils.highlight_current_line()
      require("custom.smart_cycle").set_last_action("quickfix")
    end

    return success
  end

  return false
end

function M.definition()
  local handlers = {
    {
      name = "css_class",
      handler = function()
        local result = go_to_css_class_definition()
        if result then
          vim.cmd("normal zz")
        end
        return result
      end,
    },
    {
      name = "lsp",
      handler = function()
        local function on_list(options)
          local items = options.items

          if #items == 1 then
            local item = items[1]
            local bufnr = item.bufnr or vim.fn.bufadd(item.filename)

            -- Save position in jumplist
            vim.cmd("normal! m'")

            vim.bo[bufnr].buflisted = true
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, bufnr)
            vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
            vim.api.nvim_win_call(win, function()
              vim.cmd("normal zz")
            end)
          elseif #items > 1 then
            vim.fn.setqflist({}, " ", options)
            vim.cmd("botright copen")
          end
        end

        vim.lsp.buf.definition({ on_list = on_list })
      end,
    },
  }

  for _, handler in ipairs(handlers) do
    local result = handler.handler()
    if result then
      break
    end
  end
end

function M.setup()
  M.hl_lsp_reference = vim.api.nvim_create_namespace("custom.lsp_handlers.reference")
  M.hl_lsp_cur_reference = vim.api.nvim_create_namespace("custom.lsp_handlers.cur_reference")

  vim.api.nvim_set_hl(0, "Custom.LspHandlers.References", { link = "Search" })
  vim.api.nvim_set_hl(0, "Custom.LspHandlers.CurReferences", { link = "CurSearch" })

  vim.treesitter.query.add_predicate("contain-cursor?", function(match, _, _, predicate)
    local node = match[predicate[2]]

    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Minus 1 because Treesitter usile Nvim uses 1-index
    local cursor_range = { cursor_pos[1] - 1, cursor_pos[2], cursor_pos[1] - 1, cursor_pos[2] }
    return vim.treesitter.node_contains(node, cursor_range)
  end, { force = true })
end

return M
