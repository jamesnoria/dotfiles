return {
  "rmagatti/goto-preview",
  event = "LspAttach",
  config = function()
    require("goto-preview").setup({
      width = 120,
      height = 15,
      border = { "↗", "─", "┐", "│", "┘", "─", "└", "│" },
      default_mappings = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      post_close_hook = nil,
      references = {
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
    })

    -- Keymap
    vim.keymap.set("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { desc = "Preview definition" })
    vim.keymap.set("n", "gq", "<cmd>lua require('goto-preview').close_all_win()<CR>", { desc = "Close preview" })
  end,
}
