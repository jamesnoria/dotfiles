return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "bash",
        "html",
        "css",
        "yaml"
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
