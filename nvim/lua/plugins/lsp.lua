return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function get_global_tsserver_path()
        local npm_root = vim.fn.systemlist("npm root -g")[1]

        if vim.v.shell_error ~= 0 or not npm_root or npm_root == "" then
          return nil
        end

        local tsserver = npm_root .. "/typescript/lib/tsserver.js"
        if vim.fn.filereadable(tsserver) == 1 then
          return tsserver
        end

        return nil
      end

      for _, server in ipairs(opts.ensure_installed) do
        local config = {
          capabilities = capabilities,
        }

        if server == "ts_ls" then
          local tsserver_path = get_global_tsserver_path()

          config.init_options = {
            tsserver = {
              fallbackPath = tsserver_path,
            },
          }
        end

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end,
  },
}
