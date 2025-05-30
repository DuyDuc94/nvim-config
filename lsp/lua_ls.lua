return {
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim", "require" },
      },
      runtime = {
        version = "Lua 5.2",
      },
      workspace = {
        library = (function()
          -- Make the server aware of Neovim runtime files
          local paths = vim.api.nvim_get_runtime_file("", true)
          -- and plenary.nvim
          table.insert(paths, vim.fn.stdpath("data") .. "/lazy/plenary.nvim")

          return paths
        end)(),
      },
    },
  },
  filetypes = { "lua" },
}
