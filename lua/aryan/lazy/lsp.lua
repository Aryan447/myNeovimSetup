return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                --"rust_analyzer",
                --"gopls",
                "ts_ls",
                "pyright",
                "tailwindcss",
                "ruby_lsp",
                "rubocop",
                --"cland",
                "jdtls", -- enabled
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,
                                    -- Put format options here
                                    -- NOTE: the value should be STRING!!
                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    }
                                },
                            }
                        }
                    }
                end,

                ["ruby_lsp"] = function()
                    require("lspconfig").ruby_lsp.setup({
                        capabilities = capabilities,
                        filetypes = { "ruby", "eruby" },
                        init_options = {
                            formatter = 'auto', -- Use Rubocop via Ruby LSP for formatting
                            linters = { 'rubocop' },
                        },
                    })
                end,


                ["jdtls"] = function()
                    local jdtls = require("jdtls")
                    local home = os.getenv("HOME")
                    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

                    -- workspace stored relative to your java_projects dir
                    local workspace_dir = home .. "/dev/java_projects/.jdtls-workspace/" .. project_name

                    -- create folder if it doesn't exist
                    vim.fn.mkdir(workspace_dir, "p")

                    local config = {
                        cmd = { "jdtls", "-data", workspace_dir },
                        root_dir = require("jdtls.setup").find_root({ ".git", "src", "bin" }) or vim.fn.getcwd(),
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        settings = {
                            java = {
                                eclipse = { downloadSources = true },
                                configuration = { updateBuildConfiguration = "disabled" },
                                autobuild = { enabled = false },
                            },
                        },
                    }

                    jdtls.start_or_attach(config)
                end,


                ["clangd"] = function()
                    local lspconfig = require("lspconfig")
                    -- local common = require("config.lsp.common-config") -- commented: optional external config

                    lspconfig.clangd.setup({
                        cmd = {
                            vim.fn.stdpath("data") .. "/lspinstall/cpp/clangd/bin/clangd",
                            "--background-index",
                            "--cross-file-rename",
                            "--header-insertion=never",
                        },
                        -- on_attach = common.common_on_attach, -- removed since 'common' not defined
                        capabilities = capabilities,
                        filetypes = { "c", "cpp", "h", "hpp", "objc" },
                        root_dir = lspconfig.util.root_pattern(".git", "compile_flags.txt", "compile_commands.json"),
                        handlers = {
                            ["textDocument/publishDiagnostics"] = vim.lsp.with(
                                vim.lsp.diagnostic.on_publish_diagnostics, {
                                    virtual_text = true,
                                    signs = true,
                                    underline = true,
                                    update_in_insert = false,
                                }
                            ),
                        },
                    })
                end,

                ["tailwindcss"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.tailwindcss.setup({
                        capabilities = capabilities,
                        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "heex", "erb", "eruby" },
                    })
                end,

            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
