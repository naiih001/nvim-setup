-- init.lua (minimal NVim setup with Ashen theme)

-- Plugin manager
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

  -- Git signs
  { "lewis6991/gitsigns.nvim", config = true },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Floating terminal
  { "akinsho/toggleterm.nvim", version = "*", config = function()
      require("toggleterm").setup{
          size = 20,
          open_mapping = [[<leader>t]],
          direction = 'float',
      }
    end
  },

  -- Ashen theme (Catppuccin)
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function()
      require("catppuccin").setup({
        flavour = "mocha",           -- Ashen-like dark flavor
        transparent_background = false,
        integrations = {
          nvimtree = true,
          gitsigns = true,
          treesitter = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
  end },
})

-- LSP
local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({})
lspconfig.ts_ls.setup({})
lspconfig.pyright.setup({})

-- Treesitter
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
})

-- nvim-tree with Helix-like h/l bindings
require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    local function opts(desc)
      return { desc = 'nvim-tree: '..desc, buffer = bufnr, noremap=true, silent=true, nowait=true }
    end

    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  end
})

-- Helix-like keymaps
local map = vim.keymap.set
vim.g.mapleader = " "
map("n", "gh", "0")
map("n", "gl", "$")
map("n", "gs", "gg")
map("n", "ge", "G")
map("n", "<leader>f", ":NvimTreeToggle<CR>")
map("n", "<leader>g", ":Gitsigns toggle_signs<CR>")
map("n", "<leader>vt", ":vsplit | terminal<CR>")

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

