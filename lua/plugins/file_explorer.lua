return {
  {
    "stevearc/oil.nvim",
    opts = {
      columns = { "icon " },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      },
      float = {
        padding = 2,
        max_width = 80,
        max_height = 40,
        -- Get the relative path from the working directory
        get_win_title = function(winid)
          local src_buf = vim.api.nvim_win_get_buf(winid or 0)
          -- oil:///something/path/to/file
          local oil_path = vim.api.nvim_buf_get_name(src_buf)
          local _, path = oil_path:match("^(.*://)(.*)$")
          local cwd = vim.fn.getcwd()
          -- Remove the prefix
          return string.sub(path, #cwd + 1)
        end,
      },
      skip_confirm_for_simple_edits = true,
    },
    keys = {
      { "-", ":Oil --float<CR>", mode = "n", desc = "Open Oil for parent directory" },
    },
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  { "nanotee/zoxide.vim" },
}
