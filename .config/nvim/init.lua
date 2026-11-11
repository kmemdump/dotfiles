vim.cmd([[
set notimeout
set encoding=utf-8
set relativenumber nu
set clipboard+=unnamedplus
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab
set expandtab
set history=1000
set incsearch
set errorbells
set noswapfile
set scrolloff=8
set signcolumn=yes
set colorcolumn=120
set nowrap
]])

-- set ignorecase smartcase

vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct

-- Register filetypes
vim.filetype.add({
    filename = {
        ['.clang-format'] = 'yaml',
        ['.prettierrc']   = 'yaml',
        ['.aliasrc']      = 'sh',
        ['.bashrc']       = 'sh',
        ['.envrc']        = 'sh',
    },
    -- If you want to match a pattern rather than an exact filename:
    -- pattern = {
    --   ['.*/.github/workflows/.*%.txt'] = 'yaml',
    -- },
})

-- Mappings
vim.keymap.set('n', '<Leader>q', '<cmd>enew<bar>bd #<CR>')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end

-- Autocommands
vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focus = false,
            scope = 'line',
        })
    end,
})
-- Adjust how fast CursorHold triggers (default is 4000ms, 250ms is snappier)
vim.o.updatetime = 250

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text" },
    callback = function()
        vim.opt_local.colorcolumn = "80"
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        if ft ~= "markdown" and ft ~= "text" then
            return
        end
        -- Sync textwidth to match the colorcolumn value
        local cc = vim.wo.colorcolumn
        if cc ~= "" and tonumber(cc) then
            -- Save the entire window view (scroll state + cursor position)
            local view = vim.fn.winsaveview()
            local original_tw = vim.bo.textwidth
            vim.bo.textwidth = tonumber(cc)
            -- Reformat the entire file to the new width
            vim.cmd("normal! gggqG")
            -- Restore original textwidth if you don't want it persisting
            vim.bo.textwidth = original_tw
            -- Restore the view
            vim.fn.winrestview(view)
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Save the entire window view (scroll state + cursor position)
        local view = vim.fn.winsaveview()
        -- Remove trailing whitespace
        vim.cmd([[%s/\s\+$//e]])
        -- Restore the view
        vim.fn.winrestview(view)
    end,
})

-- Lazy Plugins
vim.opt.rtp:prepend(lazypath)
-- Example using a list of specs with the default options

-- List Plugins
require('lazy').setup({
    { 'morhetz/gruvbox' },
    { 'folke/tokyonight.nvim' },
    { 'rebelot/kanagawa.nvim' },
    { 'sainnhe/everforest' },
    { 'folke/which-key.nvim' },
    { 'folke/neoconf.nvim',   cmd = 'Neoconf' },
    { 'folke/neodev.nvim' },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },              -- Required
            { 'williamboman/mason.nvim' },            -- Optional
            { 'williamboman/mason-lspconfig.nvim', }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'hrsh7th/cmp-buffer' },   -- Required
            {
                'L3MON4D3/LuaSnip',
                dependencies = {
                    'saadparwaiz1/cmp_luasnip',
                    "rafamadriz/friendly-snippets"
                },
            }, -- Required
        }
    },
    { 'tpope/vim-fugitive' },
    { 'tpope/vim-commentary' },
    { 'tpope/vim-surround' },
    { 'ThePrimeagen/harpoon' },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "lewis6991/async.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("refactoring").setup({})
        end,
    },
    { 'hrsh7th/nvim-cmp' },
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = { 'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        }
    },
    { 'catgoose/nvim-colorizer.lua' },
    {
        'echasnovski/mini.nvim',
        version = '*',
        dependencies = {
            "lewis6991/gitsigns.nvim",
            "nvim-tree/nvim-web-devicons",
        }
    },
    {
        'folke/trouble.nvim',
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        }
    },
    {
        'dmtrKovalenko/fff',
        build = function()
            -- downloads a prebuilt binary or falls back to cargo build
            require("fff.download").download_or_build_binary()
        end,
        -- for nixos:
        -- build = "nix run .#release",
        opts = {
            debug = {
                enabled = true,
                show_scores = true,
            },
        },
        lazy = false, -- the plugin lazy-initialises itself
        keys = {
            { "ff", function() require('fff').find_files() end, desc = 'FFFind files' },
            { "fg", function() require('fff').live_grep() end,  desc = 'LiFFFe grep' },
            {
                "fz",
                function() require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end,
                desc = 'Live fffuzy grep',
            },
            {
                "fw",
                function() require('fff').live_grep_under_cursor() end,
                mode = { 'n', 'x' },
                desc = 'Search current word / selection',
            },
        },
    }
})

-- Setup Plugins

---- Color Scheme
vim.opt.termguicolors = true

vim.g.everforest_background = 'hard'
vim.g.everforest_transparent_background = 1
vim.g.everforest_better_performance = 1
vim.o.background = 'dark'
vim.cmd.colorscheme('everforest')

require('neoconf').setup({
    -- override any of the default settings here
})
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require('neodev').setup({
    -- add any options here, or leave empty to use the default settings
})

require 'colorizer'.setup()
require('mini.statusline').setup()

local harpoon = require('harpoon')
harpoon.setup()
vim.keymap.set("n", "<leader>ha", function() require('harpoon.mark').add_file() end)
vim.keymap.set("n", "<leader>hm", function() require('harpoon.ui').toggle_quick_menu() end)
vim.keymap.set("n", "<leader>hh", function() require('harpoon.ui').nav_file(1) end)
vim.keymap.set("n", "<leader>hj", function() require('harpoon.ui').nav_file(2) end)
vim.keymap.set("n", "<leader>hk", function() require('harpoon.ui').nav_file(3) end)
vim.keymap.set("n", "<leader>hl", function() require('harpoon.ui').nav_file(4) end)
require("telescope").load_extension('harpoon')

local telescope = require('telescope')
telescope.setup {
    defaults = {
        layout_strategy = "vertical",
        layout_config = {
            vertical = {
                preview_cutoff = 0,
            } },
    },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { buffer = bufnr })

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        --     "rust_analyzer",
        "html",
        "cssls",
        "ts_ls",
        "jsonls",
        "yamlls",
        "bashls",
        "clangd",
        "marksman",
        --      "gopls",
    }
})
require('nvimcmp')
require('treesitter')
require('lspzero')
