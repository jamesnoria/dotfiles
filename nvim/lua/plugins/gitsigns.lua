return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup({
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview Git hunk inline")
          map("n", "<leader>gd", function()
            gitsigns.diffthis(nil, { unified = true })
          end, "Toggle Git inline diff")
          map("n", "<leader>gw", gitsigns.toggle_word_diff, "Toggle Git word diff")
          map("n", "<leader>gn", function()
            gitsigns.nav_hunk("next")
          end, "Next Git hunk")
          map("n", "<leader>gN", function()
            gitsigns.nav_hunk("prev")
          end, "Previous Git hunk")

          map("n", "<leader>gs", gitsigns.stage_hunk, "Stage/unstage Git hunk")
          map("n", "<leader>gr", gitsigns.reset_hunk, "Reset Git hunk (discard changes)")
          map("x", "<leader>gs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Stage/unstage Git selection")
          map("x", "<leader>gr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Reset Git selection (discard changes)")
          map("n", "<leader>gS", gitsigns.stage_buffer, "Stage Git buffer")
          map("n", "<leader>gq", function()
            gitsigns.setqflist("all")
          end, "List Git changes")
        end,
      })
    end,
  },
}
