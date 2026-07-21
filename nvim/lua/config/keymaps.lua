local map = vim.keymap.set

-- Utils
map("n", "<M-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("n", "<M-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })

map("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move block up" })
map("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move block down" })

map("n", "<leader>o", "o<Esc>") -- insert line below
map("n", "<leader>O", "O<Esc>") -- insert line above
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

map("n", "<leader>z", "u", { desc = "Undo" })
map("n", "<leader>y", "<C-r>", { desc = "Redo" })

-- Copiar en visual mode
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("n", "<C-c>", '"+yy', { desc = "Copy line to clipboard" })

-- Pegar en normal mode
map("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Guardar
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Salir
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })

map("n", "<leader>bd", function()
  local current = vim.api.nvim_get_current_buf()

  -- ir al siguiente buffer primero
  vim.cmd("bnext")

  -- cerrar el buffer original
  vim.cmd("bdelete " .. current)
end, { desc = "Close buffer safely" })

map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
end, { desc = "Clear search highlight" })

-- Splits
map("n", "<leader>vs", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>hs", "<cmd>split<cr>", { desc = "Horizontal split" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>")
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>")
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })

-- Diagnostics navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file" })

-- Copy file path
map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path" })

-- Preview image with chafa
map("n", "<leader>pi", function()
  local file = vim.fn.expand("%:p")
  local ext = vim.fn.expand("%:e"):lower()

  if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or ext == "webp" then
    vim.cmd("terminal chafa --size 80x40 " .. vim.fn.shellescape(file))
  else
    vim.notify("Not an image file", vim.log.levels.WARN)
  end
end, { desc = "Preview image" })
