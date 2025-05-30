local function load_project_snippets()
  local cwd = vim.fn.getcwd()
  local project = vim.fn.fnamemodify(cwd, ":t")
  project = string.gsub(project, "\\.", "")

  local config_path = vim.fn.stdpath("config")
  local project_snippets_path =
    string.format("%s/lua/plugins/snippets/%s.lua", config_path, project)

  if vim.fn.filereadable(project_snippets_path) == 1 then
    require(string.format("plugins.snippets.%s", project))
  end
end

return {
  {
    "L3MON4D3/LuaSnip",
    event = { "InsertEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()

      local ls = require("luasnip")
      -- Mappings
      -- Cycle between choices
      vim.keymap.set("i", "<C-j>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { desc = "LuaSnip: next choice" })

      vim.keymap.set("i", "<C-k>", function()
        if ls.choice_active() then
          ls.change_choice(-1)
        end
      end, { desc = "LuaSnip: previous choice" })

      -- Common snippets
      require("plugins.snippets.common.elixir")
      require("plugins.snippets.common.eruby")
      require("plugins.snippets.common.javascript_like")

      load_project_snippets()
    end,
  },
}
