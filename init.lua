-- init.lua – Minimal, modern Neovim 0.11+ setup

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP & Mason
  { "williamboman/mason.nvim",           config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { "neovim/nvim-lspconfig" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
        ensure_installed = { "lua", "vim", "python", "javascript", "typescript", "go", "cpp", "c", "solidity", "toml", "yaml" },
      })
    end,
  },

  -- Git
  { "lewis6991/gitsigns.nvim", config = true },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },

  -- Floating terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<leader>t]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Catppuccin (Ashen theme)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = { nvimtree = true, gitsigns = true, treesitter = true, mason = true, toggleterm = true },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Auto-completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
})

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "ts_ls", "pyright", "gopls", "clangd", "solidity_ls", "taplo", "yamlls" },
  automatic_installation = true,
})

-- LSP setup
local lspconfig = require("lspconfig")

-- Default handler
local on_attach = function(_, bufnr)
  local map = vim.keymap.set
  map("n", "gh", "0",  { desc = "Line start", buffer = bufnr })
  map("n", "gl", "$",  { desc = "Line end", buffer = bufnr })
  map("n", "gs", "gg", { desc = "File top", buffer = bufnr })
  map("n", "ge", "G",  { desc = "File bottom", buffer = bufnr })
end

local capabilities = require("cmp_nvim_lsp").default_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  ts_ls = {},
  pyright = {},
  gopls = {},
  clangd = {},
  solidity_ls = {},
  taplo = {},
  yamlls = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  config.on_attach = on_attach
  lspconfig[server].setup(config)
end

-- Diagnostics
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Nvim-tree setup (Helix-style h/l)
require("nvim-tree").setup({
  hijack_cursor = true,
  update_focused_file = { enable = true },
  view = { width = 30, side = "left" },
  renderer = { icons = { show = { git = true, folder = true, file = true } } },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
      return { desc = "nvim-tree: "..desc, buffer = bufnr, noremap=true, silent=true, nowait=true }
    end

    -- Helix-style navigation
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
    vim.keymap.set("n", "l", api.node.open.edit,              opts("Open"))
    vim.keymap.set("n", "v", api.node.open.vertical,          opts("Open: Vertical Split"))
    vim.keymap.set("n", "s", api.node.open.horizontal,        opts("Open: Horizontal Split"))
    vim.keymap.set("n", "o", api.node.open.edit,              opts("Open"))

    -- Toggle + focus tree with <leader>f
    vim.keymap.set("n", "<leader>f", function()
      local view = require("nvim-tree.view")
      local lib  = require("nvim-tree.lib")
      if view.is_visible() then
        view.close()
      else
        require("nvim-tree").toggle()
        lib.focus()
      end
    end, opts("Toggle & Focus nvim-tree"))

    -- Make nvim-tree buffer modifiable
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  end,
})

on_attach = function(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = "nvim-tree: "..desc, buffer = bufnr, noremap=true, silent=true, nowait=true }
  end

  -- Helix-style navigation
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory")) -- go up
  vim.keymap.set("n", "l", api.node.open.edit,              opts("Open File"))       -- open file
  vim.keymap.set("n", "v", api.node.open.vertical,          opts("Open: Vertical Split"))
  vim.keymap.set("n", "s", api.node.open.horizontal,        opts("Open: Horizontal Split"))
  vim.keymap.set("n", "o", api.node.open.edit,              opts("Open"))            -- same as l

  -- Create/Delete/Rename
  vim.keymap.set("n", "a", api.fs.create,                   opts("Create File/Folder"))
  vim.keymap.set("n", "d", api.fs.remove,                   opts("Delete"))
  vim.keymap.set("n", "r", api.fs.rename,                   opts("Rename"))
  vim.keymap.set("n", "y", api.fs.copy.node,                opts("Copy"))
  vim.keymap.set("n", "x", api.fs.cut,                      opts("Cut"))
  vim.keymap.set("n", "p", api.fs.paste,                    opts("Paste"))

  -- Toggle / Focus
  vim.keymap.set("n", "<leader>f", function()
    local view = require("nvim-tree.view")
    local lib  = require("nvim-tree.lib")
    if view.is_visible() then
      view.close()
    else
      require("nvim-tree").toggle()
      lib.focus()
    end
  end, opts("Toggle & Focus nvim-tree"))

  -- Make buffer modifiable
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
end

local map  = vim.keymap.set
local opts = { noremap = true, silent = true } 

-- Helix-style navigation
map('n', 'gg', 'gg', opts) -- top of file
map('n', 'ge', 'G', opts)  -- end of file
map('n', 'gh', '^', opts)  -- beginning of line
map('n', 'gl', '$', opts)  -- end of line

-- General options
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = "yes"
vim.opt.termguicolors  = true
vim.opt.cursorline     = true
vim.opt.scrolloff      = 8
vim.opt.mouse          = "a"

