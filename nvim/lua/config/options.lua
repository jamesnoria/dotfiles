-- Tab settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Preserve the existing provider priority on WSL and unknown environments.
local is_wsl = vim.env.WSL_DISTRO_NAME ~= nil
  or vim.env.WSL_INTEROP ~= nil
  or vim.uv.os_uname().release:lower():find("microsoft", 1, true) ~= nil
local is_native_x11 = not is_wsl
  and vim.fn.has("linux") == 1
  and (vim.env.XDG_SESSION_TYPE == "x11"
    or (vim.env.XDG_SESSION_TYPE ~= "wayland"
      and (vim.env.WAYLAND_DISPLAY == nil or vim.env.WAYLAND_DISPLAY == "")
      and vim.env.DISPLAY ~= nil
      and vim.env.DISPLAY ~= ""))

if is_native_x11 and vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -quiet -in -selection clipboard",
      ["*"] = "xclip -quiet -in -selection primary",
    },
    paste = {
      ["+"] = "xclip -out -selection clipboard",
      ["*"] = "xclip -out -selection primary",
    },
    cache_enabled = 1,
  }
elseif is_native_x11 and vim.fn.executable("xsel") == 1 then
  vim.g.clipboard = {
    name = "xsel",
    copy = {
      ["+"] = "xsel --nodetach --clipboard --input",
      ["*"] = "xsel --nodetach --primary --input",
    },
    paste = {
      ["+"] = "xsel --clipboard --output",
      ["*"] = "xsel --primary --output",
    },
    cache_enabled = 1,
  }
elseif not is_native_x11 and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline",
    },
    cache_enabled = 0,
  }
end

vim.opt.clipboard = "unnamedplus"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

vim.opt.cursorline = true

-- Show whitespace characters
vim.opt.list = true
vim.opt.listchars = {
  space = "·",
  trail = "•",
}
