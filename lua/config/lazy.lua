-- Bootstrap lazy.nvim
local utils = require("custom.utils")
local M = {}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local function ensure_lazy_installed()
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out =
      vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
end

local function get_plugin_list(plugin_source_file)
  local spec = require("plugins/" .. plugin_source_file)

  -- lazy.nvim supports return a single spec or a table of spec
  return type(spec[1]) == "table" and spec or { spec }
end

local function make_plugins_spec(plugins_spec)
  local specs = {}

  for _, spec in ipairs(plugins_spec) do
    local plugin_source_file = spec[1]
    local filter_packages = spec["packages"]
    local plugin_list = get_plugin_list(plugin_source_file)

    if filter_packages then
      plugin_list = vim.tbl_filter(function(plugin)
        local plugin_name = plugin[1] or plugin.name
        return utils.array_includes(filter_packages, plugin_name)
      end, plugin_list)
    end

    vim.list_extend(specs, plugin_list)
  end

  return specs
end

M.setup = function(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    bootstrap = true,
    plugins_spec = "all",
    update_check = true,
  })

  local plugins_spec = opts.plugins_spec == "all" and {
    { import = "plugins" },
  } or make_plugins_spec(opts.plugins_spec)

  if opts.bootstrap then
    ensure_lazy_installed()
  end

  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({
    spec = plugins_spec,
    install = { colorscheme = { "habamax" } },
    checker = { enabled = opts.update_check, frequency = 3600 * 24 * 5 },
  })
end

return M
