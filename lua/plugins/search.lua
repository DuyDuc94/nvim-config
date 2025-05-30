--- Send selected entries to quickfix list. If no files are selected, send all entries
local send_to_qf = function(prompt_bufnr)
  local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require("telescope.actions").send_selected_to_qflist(prompt_bufnr)
  else
    require("telescope.actions").send_to_qflist(prompt_bufnr)
  end

  vim.cmd([[copen]])
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
    },
    opts = {
      defaults = {
        mappings = {
          n = {
            ["<C-n>"] = require("telescope.actions").move_selection_worse,
            ["<C-p>"] = require("telescope.actions").move_selection_better,
            ["o"] = require("telescope.actions.layout").toggle_preview,
            ["<C-q>"] = send_to_qf,
          },
          i = {
            ["<C-n>"] = require("telescope.actions").move_selection_worse,
            ["<C-p>"] = require("telescope.actions").move_selection_better,
            ["<C-q>"] = send_to_qf,
          },
        },
      },
      pickers = {
        buffers = {
          mappings = {
            n = {
              ["<C-d>"] = require("telescope.actions").delete_buffer,
            },
            i = {
              ["<C-d>"] = require("telescope.actions").delete_buffer,
            },
          },
          previewer = false,
          layout_config = {
            height = 0.4,
          },
        },
        find_files = {
          prompt_title = "Find Files (o = preview)",
          previewer = false,
          layout_strategy = "horizontal",
          layout_config = {
            height = 0.4,
            preview_width = 0.6,
          },
        },
      },
      extentions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      -- Support fuzzy search
      telescope.load_extension("fzy_native")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>p", builtin.find_files)
      vim.keymap.set("n", "<leader>P", builtin.buffers)
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    config = true,
    cmd = "GrugFar",
  },
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    config = function()
      local opts = {
        winopts = {
          preview = {
            vertical = "up:60%",
            horizontal = "right:50%",
            layout = "flex",
            flip_columns = 160,
          },
          treesitter = { enabled = false },
        },
        grep = {
          fzf_opts = {
            ["--delimiter"] = ":",
            ["--nth"] = "2..",
            ["--layout"] = "default",
          },
          rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob "!*test.ts" --glob "!*test.tsx" -e]],
        },
        tags = {
          fzf_opts = {
            ["--nth"] = "1..",
            ["--layout"] = "default",
          },
        },
        keymap = {
          fzf = {
            ["ctrl-n"] = "up",
            ["ctrl-p"] = "down",
            ["tab"] = "toggle+up",
            ["shift-tab"] = "toggle+down",
          },
        },
        actions = {
          files = {
            ["enter"] = require("fzf-lua.actions").file_edit_or_qf,
            ["ctrl-q"] = {
              fn = require("fzf-lua.actions").file_sel_to_qf,
              prefix = "select-all+",
            },
            ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
          },
        },
      }

      require("fzf-lua").setup(opts)
    end,
    keys = {
      {
        "<leader>f",
        [[:FzfLua grep search=""<CR>]],
        mode = "n",
        desc = "Fuzzy search lines accross all files",
      },
      {
        "<leader>f",
        [[:FzfLua grep_visual<CR>]],
        mode = "v",
        desc = "Grep the visual selection",
      },
      {
        "<leader><S-f>",
        [[:FzfLua tags<CR>]],
        mode = "n",
        desc = "Fuzzy search tags",
      },
      {
        "<leader><S-f>",
        [[:FzfLua tags_grep_visual<CR>]],
        mode = "v",
        desc = "Search tags for the visual selection",
      },
    },
  },
}
