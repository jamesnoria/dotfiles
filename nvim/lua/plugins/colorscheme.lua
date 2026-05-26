return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = false,
          terminal_colors = true,
          dim_inactive = false,
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
      })
      vim.cmd("colorscheme carbonfox")
      
      -- Custom visual mode highlight (soft yellow)
      vim.api.nvim_set_hl(0, "Visual", { bg = "#4a4520", fg = "NONE" })
    end,
  },
}
