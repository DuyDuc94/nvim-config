local _utils = require("custom.utils")
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      "stevearc/dressing.nvim",
    },
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])

      local function add_keymap_hint_to_code_block()
        local ns_id = vim.api.nvim_create_namespace("codecompanion.code_blocks")
        local colors = require("tokyonight.colors").setup({ style = "storm" })
        vim.api.nvim_set_hl(0, "CodeCompanion.KeymapHint", {
          fg = colors.cyan,
          italic = true,
        })

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        local in_code_block = false

        for i, line in ipairs(lines) do
          if line:match("^```%s*(%w*)") then
            if not in_code_block then
              in_code_block = true
            else
              in_code_block = false
            end

            if in_code_block then
              vim.api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, {
                virt_text = { { "gy: copy", "CodeCompanion.KeymapHint" } },
                virt_text_pos = "eol",
              })
            end
          end
        end
      end

      -- Create an autocommand group
      local augroup = vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = true })

      -- Set up the autocommand for codecompanion filetype
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanion*",
        group = augroup,
        callback = function(request)
          if request.match == "CodeCompanionRequestFinished" then
            add_keymap_hint_to_code_block()
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>a",
        function()
          local wins = vim.api.nvim_list_wins()
          local companion_win = vim.iter(wins):find(function(winnr)
            local bufnr = vim.api.nvim_win_get_buf(winnr)
            return vim.fn.bufname(bufnr):match("CodeCompanion")
          end)

          if companion_win then
            vim.api.nvim_set_current_win(companion_win)
            vim.cmd("normal! G2o")
            vim.cmd("startinsert")
          else
            vim.cmd("CodeCompanionChat")
            vim.cmd("startinsert")
          end
        end,
        mode = "n",
        desc = "Toggle [A]I Chat Panel",
      },
      {
        "<leader>a",
        function()
          -- Exit visual mode
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Esc>", true, true, true),
            "nx",
            true
          )
          vim.cmd([['<,'>CodeCompanionChat Add]])
          vim.cmd("startinsert")
        end,
        mode = "x",
        desc = "Append the visual selection to the [A]I Chat Panel",
      },
    },
    opts = {
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = function()
                if not vim.g.codecompanion_gemini_api_key then
                  local key =
                      vim.fn.system('op read "op://Private/Google AI Studio API key/API key" --no-newline')

                  vim.g.codecompanion_gemini_api_key = key
                end

                _utils.log("🪵JY7" .. _utils.dump(vim.g.codecompanion_gemini_api_key) .. "JY7")
                return vim.g.codecompanion_gemini_api_key
              end,
            },
          })
        end,
      },
      prompt_library = {
        ["Proofreading"] = {
          strategy = "chat",
          description = "Proofreading input text",
          prompts = {
            {
              role = "system",
              content = [[
                I want you to act as a proofreader. I will provide you with texts and
                I would like you to review them for any spelling, grammar, or
                punctuation errors. Once you have finished reviewing the text,
                provide me with any necessary corrections or suggestions to improve the
                text. Highlight the corrected fragments (if any) using markdown backticks.

                When you have done that subsequently provide me with a slightly better
                version of the text, but keep close to the original text.

                Finally provide me with an ideal version of the text.

                Whenever I provide you with text, you reply in this format directly:

                ## Corrected text:

                {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there are no corrections made}

                ## Slightly better text

                {slightly better text}

                ## Ideal text

                {ideal text}
              ]],
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = "Proofread this text:",
            },
          },
        },
      },
      strategies = {
        chat = {
          adapter = "gemini",
          slash_commands = {
            buffer = {
              opts = {
                contains_code = true,
                provider = "telescope",
              },
            },
            file = {
              opts = {
                contains_code = true,
                max_lines = 5000,
                provider = "telescope",
              },
            },
          },
          keymaps = {
            close = {
              modes = {
                n = "q",
              },
              index = 3,
              callback = "keymaps.close",
              description = "Close Chat",
            },
            stop = {
              modes = {
                n = "<C-c>",
              },
              index = 4,
              callback = "keymaps.stop",
              description = "Stop Request",
            },
            system_prompt = {
              condition = function()
                return false
              end,
            },
          },
        },
        inline = {
          adapter = "gemini",
        },
      },
      display = {
        chat = {
          render_headers = false,
        },
        diff = {
          layout = "vertical",
          provider = "default",
        },
      },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = true,
  },
}
