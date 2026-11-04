local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp.default_keymaps({ buffer = bufnr, preserve_mappings = false })
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { buffer = bufnr })
end)

lsp.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 10000,
    },
    servers = {
        ['lua_ls'] = { 'lua' },
        ['rust_analyzer'] = { 'rust' },
        ['html'] = { 'html' },
        ['cssls'] = { 'css', 'scss', 'less' },
        ['ts_ls'] = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        ['jsonls'] = { "json", "jsonc" },
        ['bashls'] = { "sh" },
        ['gopls'] = { "go", "gomod", "gowork", "gotmpl" },
        ['clangd'] = { "c", "h", "cpp" }
        -- if you have a working setup with null-ls
        -- you can specify filetypes it can format.
        -- ['null-ls'] = {'javascript', 'typescript'},
    }
})

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('lua_ls',
    { settings = { Lua = { diagnostics = { globals = { 'vim' } } } } }
)
vim.lsp.config('gopls', {})
vim.lsp.config('ts_ls', {})
vim.lsp.config('jsonls', {})
vim.lsp.config('bashls', {})
vim.lsp.config('html', {})
vim.lsp.config('cssls', {})

lsp.setup()
