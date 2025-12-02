-- init.lua (minimal NVim setup)
-- Language support, git, file explorer, helix-like keymaps

-- Use lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Git
  { "lewis6991/gitsigns.nvim", config = true },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
})

-- LSP basic setup
local lsp = vim.lsp.config

lsp.lua_ls = {}
lsp.ts_ls = {}
lsp.pyright = {}

-- Apply
vim.lsp.start(lsp.lua_ls)
vim.lsp.start(lsp.ts_ls)
vim.lsp.start(lsp.pyright)

-- Treesitter setup
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
})

-- Helix-like keymaps
local map = vim.keymap.set
vim.g.mapleader = " "

map("n", "gh", "0")
map("n", "gl", "$")
map("n", "gs", "gg")
map("n", "ge", "G")
map("n", "<leader>e", ":NvimTreeToggle<CR>")
map("n", "<leader>g", ":Gitsigns toggle_signs<CR>")

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

