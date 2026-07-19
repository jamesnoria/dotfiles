return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterCyan",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
        },
      }

      local function set_rainbow_highlights()
        vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#ff6b6b" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#feca57" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#48dbfb" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#1dd1a1" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#ff9ff3" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#54a0ff" })
        vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#ff9f43" })
      end

      set_rainbow_highlights()

      local group = vim.api.nvim_create_augroup("user_rainbow_delimiters", { clear = true })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = set_rainbow_highlights,
        desc = "Apply custom rainbow delimiter colors",
      })
    end,
  },
}
