local repo = "loctvl842/monokai-pro.nvim"

return {
  repo,
  lazy = false, -- load ngay khi khởi động (hoặc bạn có thể set event để lazy load)
  priority = 1000, -- đảm bảo theme được load sớm nhất
  config = function()
    require("monokai-pro").setup({
      transparent_background = false,
      terminal_colors = true,
      devicons = true,
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
        type = { italic = false },
        storageclass = { italic = true },
        structure = { italic = false },
        parameter = { italic = false },
        annotation = { italic = false },
        tag_attribute = { italic = false },
      },
      filter = "spectrum", -- hoặc "classic", "octagon", "machine", "ristretto", "spectrum"
    })

    -- set colorscheme
    vim.cmd.colorscheme("monokai-pro")
  end,
}
