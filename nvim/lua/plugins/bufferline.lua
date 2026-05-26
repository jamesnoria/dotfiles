return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          show_buffer_close_icons = true,
          show_close_icon = false,
          always_show_bufferline = true,
          diagnostics = false,
          indicator = {
            style = "icon",
            icon = "▎",
          },
          color_icons = true,
          show_duplicate_prefix = true,
          modified_icon = "●",
          left_trunc_marker = "",
          right_trunc_marker = "",
          offsets = {},
        },
        highlights = {
          buffer_selected = {
            fg = "#ffffff",
            bg = "#1e1e1e",
            bold = true,
            italic = false,
          },
          indicator_selected = {
            fg = "#ffffff",
            bg = "#1e1e1e",
          },
          modified_selected = {
            fg = "#e5c07b",
            bg = "#1e1e1e",
          },
          duplicate_selected = {
            fg = "#ffffff",
            bg = "#1e1e1e",
            italic = false,
          },
        },
      })
    end,
  },
}
