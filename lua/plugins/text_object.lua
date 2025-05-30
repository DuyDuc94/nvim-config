local function find_quote()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local next_quote = line:find("['\"`]", col + 1)

  if next_quote then
    return line:sub(next_quote, next_quote)
  else
    -- Abort the operator
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    return ""
  end
end

return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {
      custom_textobjects = {
        f = false,
        t = false,
        ["a"] = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line("$"),
            col = math.max(vim.fn.getline("$"):len(), 1),
          }
          return { from = from, to = to, vis_mode = "V" }
        end,
        ["?"] = false,
      },
      mappings = {
        goto_left = "",
        goto_right = "",
      },
      n_lines = 500,
    },
    config = function(_, opts)
      local mini_ai = require("mini.ai")

      -- q will jump to the next quote in operator pending mode and visual mode
      vim.keymap.set("o", "q", function()
        return "t" .. find_quote()
      end, { expr = true, noremap = true })

      vim.keymap.set("v", "q", function()
        return "t" .. find_quote()
      end, { expr = true, noremap = true })

      mini_ai.setup(opts)
    end,
  },
  {
    "echasnovski/mini.indentscope",
    init = function()
      vim.g.miniindentscope_disable = true
    end,
    opts = {
      options = {
        indent_at_cursor = false,
      },
    },
  },
}
