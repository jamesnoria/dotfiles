return {
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      symbol = "│",
      options = {
        try_as_border = true,
      },
      draw = {
        delay = 50,
      },
    },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)

      local group = vim.api.nvim_create_augroup("user_mini_indentscope", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "terminal",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
        desc = "Disable mini.indentscope in special buffers",
      })
    end,
  },
}
