local function setup_lsp_progress()
  ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
  local progress = vim.defaulttable()

  vim.api.nvim_create_autocmd("LspProgress", {
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params
      .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      if not client or type(value) ~= "table" then
        return
      end
      local p = progress[client.id]

      for i = 1, #p + 1 do
        if i == #p + 1 or p[i].token == ev.data.params.token then
          p[i] = {
            token = ev.data.params.token,
            msg = ("[%3d%%] %s%s"):format(
              value.kind == "end" and 100 or value.percentage or 100,
              value.title or "",
              value.message and (" **%s**"):format(value.message) or ""
            ),
            done = value.kind == "end",
          }
          break
        end
      end

      local msg = {} ---@type string[]
      progress[client.id] = vim.tbl_filter(function(v)
        return table.insert(msg, v.msg) or not v.done
      end, p)

      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, {
        id = "lsp_progress",
        title = client.name,
        opts = function(notif)
          notif.icon = #progress[client.id] == 0 and "✔"
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end

local function open_snacks_scratch(opts)
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines
  local width = math.floor(screen_width * 0.8)
  local height = math.floor(screen_height * 0.8)
  local base_opts = { win = { width = width, height = height } }
  base_opts = vim.tbl_extend("force", base_opts, opts or {})

  -- Open the last opened scratch buffer if it exists
  if vim.g.last_opened_scratch then
    base_opts.file = vim.g.last_opened_scratch
  end

  require("snacks").scratch.open(base_opts)
end

---Select snacks scratch buffer of current working directory
local function select_snacks_scratch()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  local widths = { 0, 0 }
  local items = require("snacks").scratch.list()

  local to_select = {}
  local cwd = vim.fn.getcwd()

  for _, item in ipairs(items) do
    if cwd == item.cwd then
      item.branch = item.branch and ("branch:%s"):format(item.branch) or ""
      widths[1] = math.max(widths[1], vim.api.nvim_strwidth(item.name))
      widths[2] = math.max(widths[2], vim.api.nvim_strwidth(item.branch))
      table.insert(to_select, item)
    end
  end

  pickers
      .new({
        layout_config = {
          vertical = {
            preview_height = 0.7,
          },
        },
        layout_strategy = "vertical",
      }, {
        prompt_title = "Select Scratch Buffer",
        finder = finders.new_table({
          results = to_select,
          entry_maker = function(item)
            local content = vim
                .iter({ item.name, item.branch })
                :enumerate()
                :map(function(i, part)
                  return part .. string.rep(" ", widths[i] - vim.api.nvim_strwidth(part))
                end)
                :join(string.rep(" ", 2))

            return {
              value = item,
              display = content,
              ordinal = item.name,
              path = item.file,
            }
          end,
        }),
        previewer = previewers.new_buffer_previewer({
          title = "Scratch Content",
          define_preview = function(self, entry)
            local lines = vim.fn.readfile(entry.path)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            if entry.value.ft then
              vim.bo[self.state.bufnr].filetype = entry.value.ft
            end
          end,
        }),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            if selection then
              vim.g.last_opened_scratch = selection.value.file
              open_snacks_scratch({
                file = selection.value.file,
                name = selection.value.name,
                ft = selection.value.ft,
              })
            end
          end)

          return true
        end,
      })
      :find()
end

return {
  { "nvim-lua/plenary.nvim" },
  {
    "folke/snacks.nvim",
    lazy = "VeryLazy",
    init = function()
      vim.notify = require("snacks").notifier.notify
      setup_lsp_progress()
      vim.env.LG_CONFIG_FILE = vim.fn.expand("~") .. '/.dotfiles/system/lazygit/config.yml'
    end,
    keys = {
      {
        "<leader>n",
        function()
          open_snacks_scratch()
        end,
        desc = "Toggle [N]ote Buffer",
      },
      {
        "<leader>N",
        function()
          select_snacks_scratch()
        end,
        desc = "Select [N]ote",
      },
      {
        "<leader>z",
        function()
          require("snacks").zen()
        end,
        desc = "Select [N]ote",
      },
      {
        "<leader>G",
        function()
          require("snacks").lazygit()
        end,
        desc = "Open Lazy[g]it",
      },
    },
    opts = {
      notifier = {
        enabled = true,
        timeout = 2000,
      },
      scratch = {
        name = "Note",
        ft = "markdown",
        filekey = { cwd = true, branch = false, count = false },
        win_by_ft = {
          markdown = {
            keys = {
              delete = {
                "<C-d>",
                function(self)
                  local filepath = vim.api.nvim_buf_get_name(self.buf)
                  vim.api.nvim_buf_delete(self.buf, { force = true })
                  local success, err = os.remove(filepath)
                  if not success then
                    vim.notify("Failed to delete scratch: " .. err, vim.log.levels.ERROR)
                  end
                end,
                desc = "Delete",
                mode = "n",
              },
              new = {
                "<C-n>",
                function(self)
                  vim.ui.input({ prompt = "Note name" }, function(input)
                    if input ~= nil and input ~= "" then
                      vim.api.nvim_buf_delete(self.buf, { force = true })
                      open_snacks_scratch({ name = input })
                    end
                  end)
                end,
                desc = "New",
                mode = "n",
              },
              list = {
                "<C-f>",
                function(self)
                  vim.api.nvim_buf_delete(self.buf, { force = true })
                  select_snacks_scratch()
                end,
                desc = "List",
                mode = "n",
              },
              q = {
                "q",
                function(self)
                  self:close()
                end,
                desc = "Close",
                mode = "n",
              },
            },
          },
        },
      },
      zen = {
        toggles = {
          dim = false,
        },
      },
      styles = {
        notification = {
          wo = { wrap = true },
        },
      },
      lazygit = {
        config = {
          gui = {
            nerdFontsVersion = "",
          },
        },
      },
    },
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/quick_task",
    main = "custom.quick_task",
    name = "custom.quick_task",
    event = "VeryLazy",
    dependencies = { "custom.lsp_handlers", "folke/snacks.nvim" },
    opts = {
      tasks = {
        wrap_classnames = {
          name = "jsx.wrap_classnames",
          description = "Wrap JSX element className attribute in classNames function",
          cmd = require("custom.quick_task.wrap_classnames").run,
        },
        toggle_arrow_function = {
          name = "jsx.toggle_arrow_function",
          description = "Toggle Javasript arrow function between with and withour braces versions",
          cmd = require("custom.quick_task.toggle_arrow_function").run,
        },
        lsp_rename = {
          name = "lsp.rename",
          description = "Rename the symbol under the cursor using LSP function",
          cmd = vim.lsp.buf.rename,
        },
        lsp_callsites = {
          name = "lsp.callsites",
          description = "Load all callsites of the symbol under the cursor into the quickfix list",
          cmd = vim.lsp.buf.incoming_calls,
        },
        github_open_file = {
          name = "github.open_file",
          description = "Open the current file in Github",
          cmd = function(context)
            local opts = {}
            if context.mode == "v" or context.mode == "V" then
              local start_line = context.selected_range[1][2]
              local end_line = context.selected_range[2][2]
              opts.line_start = start_line
              opts.line_end = end_line
            else
              opts.url_patterns = {
                ["github%.com"] = {
                  file = "/blob/{branch}/{file}",
                },
              }
            end

            require("snacks").gitbrowse(opts)
          end,
        },
        github_open_repo = {
          name = "github.open_repo",
          description = "Open the current repo in Github",
          cmd = function()
            require("snacks").gitbrowse({ what = "repo" })
          end,
        },
        github_open_pr = {
          name = "github.open_pr",
          description = "Open the PR of the current branch in Github",
          cmd = function()
            vim.cmd("!gh pr view --web")
          end,
        },
        text_case_open_telescope = {
          name = "text_case.change",
          description = "Change text case",
          cmd = "TextCaseOpenTelescopeQuickChange",
        },
        timber_toggle_comment = {
          name = "timber.toggle_comment",
          description = "Toggle comment log statements",
          cmd = function()
            require("timber.actions").toggle_comment_log_statements({ global = false })
          end,
        },
        timber_toggle_comment_all = {
          name = "timber.toggle_comment_all",
          description = "Toggle all comment log statements",
          cmd = function()
            require("timber.actions").toggle_comment_log_statements({ global = true })
          end,
        },
        system_set_tab_name = {
          name = "system.set_tab_name",
          description = "Set custom tab name to display in lualine",
          cmd = "LualineSetTabName",
        },
      },
    },
    keys = {
      {
        "<leader>s",
        function()
          require("custom.quick_task").prompt_task()
        end,
        mode = { "n", "v" },
        desc = "Ask for task to perform",
      },
    },
  },
}
