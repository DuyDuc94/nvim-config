local yanky_state = { last_put = false, putting = false }

-- After yank, use p and P to cycle the yank ring. This will save us an extra keymap to remember
-- Inspired by f,t feature of flash.nvim
local function toggle_yank_flag()
  yanky_state.last_put = true
  local autocmd_id

  autocmd_id = vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    callback = function()
      if not yanky_state.putting then
        yanky_state.last_put = false
        vim.api.nvim_del_autocmd(autocmd_id)
      end
    end,
  })
end

return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    init = function()
      local colors = require("tokyonight.colors").setup({ style = "storm" })

      vim.api.nvim_set_hl(0, "NvimSurroundHighlight", { bg = colors.yellow, fg = colors.bg })
    end,
    opts = {
      keymaps = {
        normal = "gs",
        normal_cur = "gss",
      },
      aliases = {
        ["b"] = { "}", "]", ")" },
      },
    },
  },
  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    dependencies = { "gbprod/yanky.nvim" },
    init = function()
      local colors = require("tokyonight.colors").setup({ style = "storm" })

      vim.api.nvim_set_hl(0, "SubstituteExchange", { bg = colors.yellow, fg = colors.bg })
    end,
    keys = {
      {
        "s",
        function()
          require("substitute").operator()
        end,
        mode = "n",
        desc = "Substitute as operator",
      },
      {
        "ss",
        function()
          require("substitute").line()
        end,
        mode = "n",
        desc = "Substitute current line",
      },
      {
        "s",
        function()
          require("substitute").visual()
        end,
        mode = "x",
        desc = "Substitute current selected text",
      },
      {
        "x",
        function()
          require("substitute.exchange").operator()
        end,
        mode = "n",
        desc = "Exchange as operator",
      },
      {
        "xx",
        function()
          require("substitute.exchange").line()
        end,
        mode = "n",
        desc = "Exchange current line",
      },
      {
        "x",
        function()
          require("substitute.exchange").visual()
        end,
        mode = "x",
        desc = "Exchange current selected text",
      },
    },
    config = function()
      local opts = {
        on_substitute = function(event)
          yanky_state.putting = true

          require("yanky.integration").substitute()(event)
          toggle_yank_flag()

          vim.schedule(function()
            yanky_state.putting = false
          end)
        end,
      }

      require("substitute").setup(opts)
    end,
  },
  {
    "gbprod/yanky.nvim",
    init = function()
      local colors = require("tokyonight.colors").setup({ style = "storm" })

      vim.api.nvim_set_hl(0, "YankyYanked", { bg = colors.comment })
      vim.api.nvim_set_hl(0, "YankyPut", { bg = colors.comment })
    end,
    keys = {
      {
        "y",
        "<Plug>(YankyYank)",
        mode = { "n", "x" },
        desc = "Yank text",
      },
      {
        "p",
        function()
          yanky_state.putting = true
          local yanky = require("yanky")

          if yanky_state.last_put then
            yanky.cycle(yanky.direction.FORWARD)
          else
            yanky.put("p")
            vim.schedule(toggle_yank_flag)
          end

          vim.schedule(function()
            yanky_state.putting = false
          end)
        end,
        mode = { "n" },
        desc = "Put yanked text after cursor",
      },
      {
        "P",
        function()
          yanky_state.putting = true

          local yanky = require("yanky")
          if yanky_state.last_put then
            yanky.cycle(yanky.direction.BACKWARD)
          else
            yanky.put("P")
            vim.schedule(toggle_yank_flag)
          end

          vim.schedule(function()
            yanky_state.putting = false
          end)
        end,
        mode = { "n", "x" },
        desc = "Put yanked text before cursor",
      },
      {
        "]p",
        function()
          yanky_state.putting = true

          require("yanky").put("]p", false, require("yanky.wrappers").linewise())

          vim.schedule(function()
            toggle_yank_flag()
            yanky_state.putting = false
          end)
        end,
        desc = "Put indented after cursor (linewise)",
      },
      {
        "[p",
        function()
          yanky_state.putting = true

          require("yanky").put("[p", false, require("yanky.wrappers").linewise())

          vim.schedule(function()
            toggle_yank_flag()
            yanky_state.putting = false
          end)
        end,
        desc = "Put indented before cursor (linewise)",
      },
      {
        "gp",
        function()
          require("yanky.textobj").last_put()
        end,
        mode = { "o", "x" },
        desc = "Last put text object",
      },
    },
    opts = {
      textobj = {
        enabled = true,
      },
    },
  },
  {
    "johmsalas/text-case.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      default_keymappings_enabled = false,
    },
    config = function(_, opts)
      require("textcase").setup(opts)
      require("telescope").load_extension("textcase")
    end,
  },
  {
    "Goose97/alternative.nvim",
    event = "VeryLazy",
    opts = {
      rules = {
        "general.boolean_flip",
        "general.number_increment_decrement",
        "general.compare_operator_flip",
        "lua.if_condition_flip",
        "lua.ternary_to_if_else",
        "lua.wrap_it_test_in_describe",
        "javascript.if_condition_flip",
        "javascript.ternary_to_if_else",
        "javascript.arrow_function_implicit_return",
        "elixir.if_condition_flip",
        "elixir.if_expression_variants",
        "elixir.function_definition_variants",
        "elixir.pipe_first_function_argument",
      },
    },
  },
  {
    "Goose97/rearrange.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/duplicate_operator",
    main = "custom.duplicate_operator",
    name = "custom.duplicate_operator",
    event = "VeryLazy",
    keys = {
      {
        "gy",
        function()
          return require("custom.duplicate_operator").duplicate()
        end,
        mode = "n",
        desc = "[G]o [Y]ank Paste: Duplicate operator",
        expr = true,
        replace_keycodes = false,
      },
      {
        "gyy",
        "gy_",
        mode = "n",
        desc = "[G]o [Y]ank Paste: Duplicate current line",
        remap = true,
      },
      {
        "gy",
        function()
          require("custom.duplicate_operator").visual_duplicate()
        end,
        mode = "v",
        desc = "[G]o [Y]ank Paste: Duplicate the visual selection",
      },
    },
    config = true,
  },
}
