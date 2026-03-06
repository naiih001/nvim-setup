-- init.lua – Minimal, modern Neovim 0.11+ setup

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<A-l", 'copliot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
	silent = true,
	desc = "Copilot accept",
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- LSP & Mason
	{ "williamboman/mason.nvim", config = true },
	{ "williamboman/mason-lspconfig.nvim", config = true },
	{ "neovim/nvim-lspconfig" },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("nvim-treesitter.config").setup({
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = {
					"lua",
					"vim",
					"python",
					"javascript",
					"typescript",
					"go",
					"cpp",
					"c",
					"solidity",
					"toml",
					"yaml",
				},
			})
		end,
	},

	-- Oil nvim
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				default_file_explorer = true, -- replaces netrw
				keymaps = {
					["<CR>"] = "actions.select",
					["<BS>"] = "actions.parent", -- go up a directory
					["-"] = "actions.parent",
					["q"] = "actions.close",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
				},
				view_options = {
					show_hidden = false,
				},
			})
		end,
	},

	-- Comment plugin
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Dap
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- nice UI for debugger
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- open/close dapui automatically
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	-- Git
	{ "lewis6991/gitsigns.nvim", config = true },

	-- Floating terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<leader>tt]],
				direction = "float",
				float_opts = { border = "curved" },
			})
		end,
	},

	{
		"ficcdaf/ashen.nvim",
		priority = 1000,
		config = function()
			vim.cmd("colorscheme ashen")
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
	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					c = { "clang_format" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})
		end,
	},
	-- Rust plugin
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				server = {
					settings = {
						["rust-analyzer"] = {
							checkOnSave = true,
						},
					},
				},
			}
		end,
	},
	-- Copilot
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.keymap.set("i", "<A-l>", 'copilot#Accept("")', {
				expr = true,
				replace_keycodes = false,
				silent = true,
				desc = "Copilot accept",
			})
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter", -- Load only when entering insert mode
		dependencies = { "hrsh7th/nvim-cmp" }, -- Optional but recommended for cmp integration
		config = function()
			local autopairs = require("nvim-autopairs")

			autopairs.setup({
				check_ts = true, -- Use Treesitter to detect context (smarter pairing)
				ts_config = {
					lua = { "string", "source" }, -- Don't add pairs inside these Treesitter nodes
					javascript = { "string", "template_string" },
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>", -- Alt+e to fast-wrap selected text (optional)
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			-- Integrate with nvim-cmp (so it doesn't interfere with completion)
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
})

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "ts_ls", "pyright", "gopls", "solidity_ls", "taplo", "yamlls" },
	automatic_installation = true,
})

-- LSP capabilities (for cmp-nvim-lsp integration)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Your servers + custom settings (same as before)
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

-- Apply configs (nvim-lspconfig defaults are auto-merged!)
for server, config in pairs(servers) do
	config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
	vim.lsp.config(server, config)
end

-- Enable all servers (auto-attach on matching filetypes)
vim.lsp.enable(vim.tbl_keys(servers))

-- LSP keymaps on attach (better than old on_attach)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local opts = { buffer = ev.buf, noremap = true, silent = true }
		local map = vim.keymap.set
		api = vim.api

		-- Your basic navigation (you already have these globally, but ok)
		map("n", "gh", "^", opts)
		map("n", "gl", "$", opts)

		-- Useful LSP actions
		map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = ev.buf })
		map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = ev.buf })
		map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", buffer = ev.buf })
		map("n", "gr", vim.lsp.buf.references, { desc = "Find references", buffer = ev.buf })
		map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", buffer = ev.buf })
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = ev.buf })
		map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = ev.buf })

		map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open Oil file explorer" })
	end,
})

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 4,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	float = {
		border = "rounded",
		source = true,
	},
})

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helix-style navigation
map("n", "gg", "gg", opts) -- top of file
map("n", "ge", "G", opts) -- end of file
map("n", "gh", "^", opts) -- beginning of line
map("n", "gl", "$", opts) -- end of line

local function nvim_tree_toggle_focus()
	local api = require("nvim-tree.api")
	local view = require("nvim-tree.view")

	if view.is_visible() then
		-- if the nvim-tree buffer is the current buffer, close it
		if vim.bo.filetype == "NvimTree" or vim.bo.filetype == "nvimtree" then
			api.tree.close()
		else
			-- tree is visible but we are in another buffer: focus the tree
			api.tree.focus()
		end
	else
		-- tree not visible: open and focus it
		api.tree.toggle({ focus = true })
	end
end

map("n", "<leader>f", nvim_tree_toggle_focus, { desc = "Toggle/Focus/Close nvim-tree", noremap = true, silent = true })

-- General options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.mouse = "a"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
