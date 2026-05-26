require("config.lazy")
require("config.keymaps")

-- Tab settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line numbers
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.cursorline = true

-- Show whitespace characters
vim.opt.list = true
vim.opt.listchars = {
  space = '·',
  trail = '•',
}

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function() return {} end,
    ["*"] = function() return {} end,
  },
}

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
  callback = function()
    if vim.bo.buftype == "" and vim.bo.modified then
      vim.cmd("silent! w")
      local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      if file ~= "" then
        print("Autosaved: " .. file)
      end
    end
  end,
  desc = "Auto save on focus lost / leave",
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Define diagnostic signs in the gutter
vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "▲", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "»", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "⚑", texthl = "DiagnosticSignHint" })

vim.keymap.set("n", "bd", function()
  local current = vim.api.nvim_get_current_buf()

  -- ir al siguiente buffer primero
  vim.cmd("bnext")

  -- cerrar el buffer original
  vim.cmd("bdelete " .. current)
end, { desc = "Close buffer safely" })

vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
end, { desc = "Clear search highlight" })
