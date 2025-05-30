return {
  "mfussenegger/nvim-lint",
  init = function()
    vim.api.nvim_create_user_command("Lint", function()
      require("lint").try_lint()
    end, {})
  end,
  config = function()
    require("lint").linters_by_ft = {
      markdown = { "vale" },
      mdx = { "vale" },
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
    }
  end,
}
