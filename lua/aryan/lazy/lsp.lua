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
                                runtime = {
                                    version = 'LuaJIT'
                                },
                                diagnostics = {
                                    globals = { 'vim' },
                                },
                                workspace = {
                                    library = {
                                        vim.env.VIMRUNTIME,
                                    },
                                    checkThirdParty = false,
                                },
                                telemetry = {
                                    enable = false,
                                },
                                format = {
                                    enable = true,
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
                        cmd = { "bundle", "exec", "ruby-lsp" },
                        filetypes = { "ruby", "eruby", "rakefile" },
                        init_options = {
                            formatter = 'auto',
                            linters = { 'rubocop' },
                            enabledFeatures = {
                                "documentHighlights",
                                "documentSymbols",
                                "foldingRanges",
                                "selectionRanges",
                                "semanticHighlighting",
                                "formatting",
                                "codeActions",
                                "diagnostics",
                                "onTypeFormatting",
                                "hover",
                                "completion",
                            },
                            featuresConfiguration = {
                                inlayHint = {
                                    enableAll = true,
                                },
                            },
                        },
                        settings = {},
                    })
                end,

                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        filetypes = {
                            "javascript",
                            "javascriptreact",
                            "typescript",
                            "typescriptreact",
                        },
                        settings = {
                            typescript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = 'all',
                                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                    includeInlayFunctionParameterTypeHints = true,
                                    includeInlayVariableTypeHints = true,
                                    includeInlayPropertyDeclarationTypeHints = true,
                                    includeInlayFunctionLikeReturnTypeHints = true,
                                    includeInlayEnumMemberValueHints = true,
                                }
                            },
                            javascript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = 'all',
                                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                    includeInlayFunctionParameterTypeHints = true,
                                    includeInlayVariableTypeHints = true,
                                    includeInlayPropertyDeclarationTypeHints = true,
                                    includeInlayFunctionLikeReturnTypeHints = true,
                                    includeInlayEnumMemberValueHints = true,
                                }
                            }
                        }
                    })
                end,

                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    diagnosticMode = "workspace",
                                    useLibraryCodeForTypes = true,
                                    typeCheckingMode = "basic",
                                }
                            }
                        }
                    })
                end,

                ["jdtls"] = function()
                    local jdtls = require("jdtls")
                    local home = os.getenv("HOME")
                    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
                    local workspace_dir = home .. "/dev/java_projects/.jdtls-workspace/" .. project_name

                    vim.fn.mkdir(workspace_dir, "p")

                    local config = {
                        cmd = { "jdtls", "-data", workspace_dir },
                        root_dir = require("jdtls.setup").find_root({ ".git", "src", "bin", "pom.xml", "build.gradle" }) or
                        vim.fn.getcwd(),
                        capabilities = capabilities,
                        settings = {
                            java = {
                                eclipse = { downloadSources = true },
                                configuration = { updateBuildConfiguration = "automatic" },
                                maven = { downloadSources = true },
                                implementationsCodeLens = { enabled = true },
                                referencesCodeLens = { enabled = true },
                                references = { includeDecompiledSources = true },
                                format = {
                                    enabled = true,
                                },
                            },
                            signatureHelp = { enabled = true },
                            completion = {
                                favoriteStaticMembers = {
                                    "org.hamcrest.MatcherAssert.assertThat",
                                    "org.hamcrest.Matchers.*",
                                    "org.hamcrest.CoreMatchers.*",
                                    "org.junit.jupiter.api.Assertions.*",
                                    "java.util.Objects.requireNonNull",
                                    "java.util.Objects.requireNonNullElse",
                                    "org.mockito.Mockito.*",
                                },
                            },
                            contentProvider = { preferred = "fernflower" },
                            extendedClientCapabilities = jdtls.extendedClientCapabilities,
                            sources = {
                                organizeImports = {
                                    starThreshold = 9999,
                                    staticStarThreshold = 9999,
                                },
                            },
                            codeGeneration = {
                                toString = {
                                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                                },
                                useBlocks = true,
                            },
                        },
                    }

                    jdtls.start_or_attach(config)
                end,

                ["clangd"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.clangd.setup({
                        cmd = {
                            "clangd",
                            "--background-index",
                            "--clang-tidy",
                            "--header-insertion=iwyu",
                            "--completion-style=detailed",
                            "--function-arg-placeholders",
                            "--fallback-style=llvm",
                        },
                        capabilities = capabilities,
                        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                        root_dir = lspconfig.util.root_pattern(
                            '.clangd',
                            '.clang-tidy',
                            '.clang-format',
                            'compile_commands.json',
                            'compile_flags.txt',
                            'configure.ac',
                            '.git'
                        ),
                        init_options = {
                            usePlaceholders = true,
                            completeUnimported = true,
                            clangdFileStatus = true,
                        },
                    })
                end,

                ["tailwindcss"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.tailwindcss.setup({
                        capabilities = capabilities,
                        filetypes = {
                            "html",
                            "css",
                            "scss",
                            "javascript",
                            "javascriptreact",
                            "typescript",
                            "typescriptreact",
                            "vue",
                            "svelte",
                            "heex",
                            "erb",
                            "eruby",
                        },
                        settings = {
                            tailwindCSS = {
                                experimental = {
                                    classRegex = {
                                        "class:\\s*['\"]([^'\"]*)['\"]",
                                    },
                                },
                            },
                        },
                    })
                end,

                ["gopls"] = function()
                    require("lspconfig").gopls.setup({
                        capabilities = capabilities,
                        settings = {
                            gopls = {
                                analyses = {
                                    unusedparams = true,
                                },
                                staticcheck = true,
                                gofumpt = true,
                            },
                        },
                    })
                end,

                ["rust_analyzer"] = function()
                    require("lspconfig").rust_analyzer.setup({
                        capabilities = capabilities,
                        settings = {
                            ['rust-analyzer'] = {
                                checkOnSave = {
                                    command = "clippy",
                                },
                                cargo = {
                                    allFeatures = true,
                                },
                            },
                        },
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
