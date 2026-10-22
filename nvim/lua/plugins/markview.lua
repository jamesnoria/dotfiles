return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("markview").setup({
        preview = {
          modes = { "n", "no", "c" },
          hybrid_modes = { "n" },
          callbacks = {
            on_enable = function(_, wins)
              for _, win in ipairs(wins) do
                vim.wo[win].conceallevel = 2
                vim.wo[win].concealcursor = "c"
              end
            end,
          },
        },
      })
    end,
  },
}
