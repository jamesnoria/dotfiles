return {
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({
        auto_save = true,
        auto_restore = true,
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        pre_restore_cmds = {
          function()
            -- cerrar neo-tree antes de restaurar para evitar que tome el foco
            pcall(vim.cmd, "Neotree close")
          end,
        },
        post_restore_cmds = {
          function()
            -- buscar buffers reales
            local real_bufs = {}
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
                table.insert(real_bufs, buf)
              end
            end
            -- solo redirigir el foco si hay buffers reales
            if #real_bufs > 0 then
              vim.api.nvim_set_current_buf(real_bufs[1])
            end
          end,
        },
      })
    end,
  },
}
