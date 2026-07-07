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
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

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
      })

      telescope.load_extension("fzf")
    end,
  },
}
