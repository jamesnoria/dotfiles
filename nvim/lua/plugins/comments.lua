return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
          enable_autocmd = false,
        },
      },
    },
    config = function()
      local ft = require("Comment.ft")
      local utils = require("Comment.utils")
      local ts_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()

      require("Comment").setup({
        pre_hook = function(ctx)
          if vim.bo.buftype ~= "" then
            return "%s"
          end

          local ok, commentstring = pcall(ts_hook, ctx)
          if ok and commentstring and commentstring ~= "" then
            return commentstring
          end

          if vim.bo.commentstring ~= "" then
            return vim.bo.commentstring
          end

          local fallback = ft.get(vim.bo.filetype, ctx.ctype or utils.ctype.linewise)
          if fallback and fallback ~= "" then
            return fallback
          end

          return "%s"
        end,
      })
    end,
  },
}
