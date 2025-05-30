return {
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = {
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<C-f>"] = { "scroll_documentation_up", "fallback" },
        ["<C-b>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = {},
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
      cmdline = {
        keymap = {
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
          ["<CR>"] = {},
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = { preselect = false },
          },
        },
      },
      completion = {
        keyword = {
          range = "full",
        },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        accept = {
          dot_repeat = true,
          auto_brackets = {
            enabled = true,
            kind_resolution = {
              blocked_filetypes = { "codecompanion" },
            },
            semantic_token_resolution = {
              enabled = false,
            },
          },
        },
        menu = {
          border = "single",
          winhighlight = "Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = "single",
          },
        },
      },
      signature = { enabled = true },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
        providers = {
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
            enabled = true,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            opts = {
              get_bufnrs = function()
                return { vim.api.nvim_get_current_buf() }
              end,
            },
          },
          cmdline = {
            min_keyword_length = function(ctx)
              -- when typing a command, only show when the keyword is 3 characters or longer
              if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
                return 3
              end

              return 0
            end,
          },
          snippets = {
            -- Prioritize snippets over other sources
            score_offset = 10,
          },
        },
      },
      snippets = { preset = "luasnip" },
    },
    opts_extend = { "sources.default" },
  },
}
