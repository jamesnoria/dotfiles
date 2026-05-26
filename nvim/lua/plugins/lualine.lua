return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = {
            normal   = { a = { fg = "#161619", bg = "#78a9ff", gui = "bold" }, b = { fg = "#f2f4f8", bg = "#2a2a2a" }, c = { fg = "#f2f4f8", bg = "#1a1a1a" } },
            insert   = { a = { fg = "#161616", bg = "#42be65", gui = "bold" }, b = { fg = "#f2f4f8", bg = "#2a2a2a" } },
            visual   = { a = { fg = "#161616", bg = "#be95ff", gui = "bold" }, b = { fg = "#f2f4f8", bg = "#2a2a2a" } },
            replace  = { a = { fg = "#161616", bg = "#ee5396", gui = "bold" }, b = { fg = "#f2f4f8", bg = "#2a2a2a" } },
            command  = { a = { fg = "#161616", bg = "#ffe97b", gui = "bold" }, b = { fg = "#f2f4f8", bg = "#2a2a2a" } },
            inactive = { a = { fg = "#888888", bg = "#1a1a1a" }, b = { fg = "#888888", bg = "#1a1a1a" }, c = { fg = "#888888", bg = "#1a1a1a" } },
          },
          globalstatus = true,
          section_separators = { left = "", right = "" },
          component_separators = { left = "|", right = "|" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { { "branch", icon = "⎇" }, "diff" },
          lualine_c = {
            {
              function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end,
              icon = "󰉋",
            },
            { "filename", path = 1 },
          },
          lualine_x = { 
            {
              function()
                local msg = "No LSP"
                local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                local clients = vim.lsp.get_clients()
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end
                return msg
              end,
              icon = "LSP:",
            },
            "diagnostics", 
            "encoding", 
            "fileformat" 
          },
          lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}
