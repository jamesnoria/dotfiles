local autosave_group = vim.api.nvim_create_augroup("user_autosave", { clear = true })
local relative_number_group = vim.api.nvim_create_augroup("user_relative_number", { clear = true })

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
  group = autosave_group,
  callback = function()
    if vim.bo.buftype == "" and vim.bo.modified then
      vim.cmd("silent! w")
      local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      if file ~= "" then
        vim.notify("Autosaved: " .. file, vim.log.levels.INFO)
      end
    end
  end,
  desc = "Auto save on focus lost / leave",
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = autosave_group,
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end

    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    if file == "" then
      return
    end

    vim.notify("Saved: " .. file, vim.log.levels.INFO)
  end,
  desc = "Notify when file is saved",
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = relative_number_group,
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = false
    end
  end,
  desc = "Disable relative numbers in insert mode",
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = relative_number_group,
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.relativenumber = true
    end
  end,
  desc = "Enable relative numbers outside insert mode",
})
