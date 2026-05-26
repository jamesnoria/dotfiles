return {
  {
    "f-person/git-blame.nvim",
    cmd = "GitBlameToggle",
    keys = {
      { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
    },
    config = function()
      -- Disable by default
      vim.g.gitblame_enabled = 0
      
      -- Customize message format
      vim.g.gitblame_message_template = '<author> • <date> • <summary>'
      vim.g.gitblame_date_format = '%r'
      
      -- Highlight groups
      vim.g.gitblame_highlight_group = "Comment"
    end,
  },
}
