-- In lightweight config, we won't have overseer available
local overseer_status = function()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return nil
  end

  return {
    "overseer",
    colored = true,
    symbols = {
      [overseer.STATUS.FAILURE] = "✗ ",
      [overseer.STATUS.CANCELED] = "⊘ ",
      [overseer.STATUS.SUCCESS] = "✓ ",
      [overseer.STATUS.RUNNING] = "R: ",
    },
    fmt = function(str)
      -- Animate the running indicator
      if str:find("R:") then
        local spinners = { "\\", "|", "/", "-" }
        local ms = vim.loop.now() % 400
        local frame = math.floor(ms / 100) + 1
        return str:gsub("R:", spinners[frame])
      end

      return str
    end,
  }
end

return {
  {
    "kevinhwang91/nvim-bqf",
    opts = { ft = "qf", preview = { winblend = 0 } },
  },
  {
    "stevearc/dressing.nvim",
    opts = {
      select = {
        backend = { "telescope" },
        telescope = {
          layout_strategy = "center",
          layout_config = {
            preview_cutoff = false,
          },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.api.nvim_set_var("lualine_tab_names", {})

      vim.api.nvim_create_user_command("LualineSetTabName", function()
        -- Function to set a custom tab name
        vim.ui.input({ prompt = "Tab name: " }, function(name)
          local tabnr = vim.fn.tabpagenr()
          local tab_names = vim.api.nvim_get_var("lualine_tab_names")
          tab_names[tabnr] = name
          vim.api.nvim_set_var("lualine_tab_names", tab_names)
        end)
      end, {})
    end,
    opts = {
      options = {
        theme = "tokyonight",
        always_show_tabline = false,
      },
      sections = {
        lualine_a = {
          {
            "filename",
            file_status = true,
            path = 1,

            symbols = {
              modified = " ●",
              readonly = "[x]",
              unnamed = "[No Name]",
              newfile = "[New]",
            },
            fmt = function(name)
              return name:gsub("packages/([^/]+)/", "")
            end,
          },
        },
        lualine_b = {
          function()
            local filepath = vim.fn.expand("%:p")
            local package_name = filepath:match("packages/([^/]+)/")
            package_name = package_name:gsub("jfc%-global%-", "")
            return package_name or ""
          end,
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { overseer_status() },
      },
      tabline = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "tabs",
            mode = 2,
            fmt = function(name, context)
              local tab_names = vim.api.nvim_get_var("lualine_tab_names")
              return tab_names[context.tabnr] or name
            end,
          },
        },
      },
    },
  },
  { "norcalli/nvim-colorizer.lua", config = true, cmd = { "ColorizerAttachToBuffer" } },
  {
    "m00qek/baleia.nvim",
    ft = { "terminal" },
    config = function()
      local baleia = require("baleia").setup()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "terminal",
        callback = function()
          baleia.once(vim.api.nvim_get_current_buf())
        end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      render_modes = true,
      sign = {
        enabled = false,
      },
    },
  },
}
