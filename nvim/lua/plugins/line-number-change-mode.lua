return {
  "sethen/line-number-change-mode.nvim",
  event = "VeryLazy",
  config = function()
    require("line-number-change-mode").setup({
      mode = {
        i = {
          bg = "#42be65",
          fg = "#0c0c0c",
          bold = true,
        },
        n = {
          bg = "#78a9ff",
          fg = "#0c0c0c",
          bold = true,
        },
        R = {
          bg = "#ee5396",
          fg = "#0c0c0c",
          bold = true,
        },
        v = {
          bg = "#be95ff",
          fg = "#0c0c0c",
          bold = true,
        },
        V = {
          bg = "#be95ff",
          fg = "#0c0c0c",
          bold = true,
        },
      },
    })
  end,
}
