local parsers = {
  "lua",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "bash",
  "html",
  "css",
  "yaml",
  "markdown",
  "markdown_inline",
  "vim",
  "vimdoc",
  "dockerfile",
  "toml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter").install(parsers):wait(300000)
    end,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "json",
          "bash",
          "sh",
          "html",
          "css",
          "yaml",
          "markdown",
          "vim",
          "vimdoc",
          "dockerfile",
          "toml",
        },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      if vim.bo.filetype ~= "" then
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  },
}
