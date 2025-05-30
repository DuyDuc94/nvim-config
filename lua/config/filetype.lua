-- Vim can detect the type of file that is edited
-- Vim's functionality can be extended by adding plugins
vim.cmd("filetype plugin on")

-- Extend filetype
vim.filetype.add({
  -- Detect and assign filetype based on the extension of the filename
  extension = {
    mdx = "mdx",
  },
})

vim.treesitter.language.register("markdown", "mdx")
