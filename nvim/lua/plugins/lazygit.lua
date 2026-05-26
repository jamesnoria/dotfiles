return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
  },
  config = function()
    vim.g.lazygit_floating_window_scaling_factor = 0.9
    
    -- Allow Ctrl-hjkl to pass through to tmux when in lazygit terminal
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*lazygit*",
      callback = function()
        vim.keymap.set("t", "<C-h>", "<C-h>", { buffer = true })
        vim.keymap.set("t", "<C-j>", "<C-j>", { buffer = true })
        vim.keymap.set("t", "<C-k>", "<C-k>", { buffer = true })
        vim.keymap.set("t", "<C-l>", "<C-l>", { buffer = true })
      end,
    })
  end,
}
