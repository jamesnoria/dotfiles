return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
      },
    },
    keys = {
      { "<C-e>", function() require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true, hidden = true, respect_gitignore = false }) end, desc = "File browser" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      telescope.setup({
        defaults = {
          case_mode = "smart_case",
          mappings = {
            i = {
              ["<C-c>"] = actions.close,
            },
            n = {
              ["<C-c>"] = actions.close,
              ["q"] = actions.close,
            },
          },
        },
        extensions = {
          file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            hidden = true,
            respect_gitignore = false,
            mappings = {
              ["i"] = {
                ["<C-n>"] = fb_actions.create,
                ["<C-r>"] = fb_actions.rename,
                ["<C-d>"] = fb_actions.remove,
                ["<C-y>"] = fb_actions.copy,
                ["<C-x>"] = fb_actions.move,
              },
              ["n"] = {
                ["n"] = fb_actions.create,
                ["r"] = fb_actions.rename,
                ["d"] = fb_actions.remove,
                ["y"] = fb_actions.copy,
                ["x"] = fb_actions.move,
              },
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },
}
