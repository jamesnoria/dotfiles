local map = vim.keymap.set

-- Utils
map("n", "<M-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("n", "<M-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })

map("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move block up" })
map("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move block down" })

map("n", "<leader>o", "o<Esc>") -- insert line below
map("n", "<leader>O", "O<Esc>") -- insert line above

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
  vim.lsp.buf.format({ async = true })
end)

-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })

-- Copy file path
map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path" })

-- Git blame toggle
map("n", "<leader>gb", "<cmd>GitBlameToggle<cr>", { desc = "Toggle Git Blame" })

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
