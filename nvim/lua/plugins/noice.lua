return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        config = function()
          local notify = require("notify")

          notify.setup({
            stages = "fade_in_slide_out",
            timeout = 3000,
            background_colour = "#000000",
          })

          vim.notify = notify
        end,
      },
    },
    config = function()
      require("noice").setup({
        notify = {
          enabled = true,
        },
        messages = {
          enabled = true,
        },
        lsp = {
          progress = {
            enabled = true,
          },
        },
      })
    end,
  },
}
