return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")
            if type(ts.install) == "function" then
                ts.setup({})

                local installed = {}
                local ok, parsers = pcall(ts.get_installed, "parsers")
                if ok and type(parsers) == "table" then
                    for _, parser in ipairs(parsers) do
                        installed[parser] = true
                    end
                end

                local ensure_parser = function(lang)
                    if installed[lang] then
                        return true
                    end

                    local ok_install = pcall(function()
                        ts.install({ lang }):wait(300000)
                    end)

                    if ok_install then
                        installed[lang] = true
                    end

                    return ok_install
                end

                local max_filesize = 100 * 1024
                local group = vim.api.nvim_create_augroup("AryanTreesitter", { clear = true })

                vim.api.nvim_create_autocmd("FileType", {
                    group = group,
                    callback = function(args)
                        local buf = args.buf
                        local ft = vim.bo[buf].filetype

                        if ft == "html" then
                            return
                        end

                        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "File larger than 100KB, treesitter disabled for performance",
                                vim.log.levels.WARN,
                                { title = "Treesitter" }
                            )
                            return
                        end

                        local lang = vim.treesitter.language.get_lang(ft) or ft
                        if lang == "" then
                            return
                        end

                        if ensure_parser(lang) and pcall(vim.treesitter.start, buf, lang) then
                            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end,
                })
            else
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "vimdoc",
                        "javascript",
                        "typescript",
                        "c",
                        "lua",
                        "rust",
                        "jsdoc",
                        "bash",
                        "go",
                        "templ",
                        "markdown",
                        "markdown_inline",
                    },

                    sync_install = false,
                    auto_install = true,

                    indent = {
                        enable = true,
                    },

                    highlight = {
                        enable = true,
                        disable = function(lang, buf)
                            if lang == "html" then
                                return true
                            end

                            local max_filesize = 100 * 1024
                            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                            if ok and stats and stats.size > max_filesize then
                                vim.notify(
                                    "File larger than 100KB treesitter disabled for performance",
                                    vim.log.levels.WARN,
                                    { title = "Treesitter" }
                                )
                                return true
                            end
                        end,
                        additional_vim_regex_highlighting = { "markdown" },
                    },
                })

                local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
                treesitter_parser_config.templ = {
                    install_info = {
                        url = "https://github.com/vrischmann/tree-sitter-templ.git",
                        files = { "src/parser.c", "src/scanner.c" },
                        branch = "master",
                    },
                }

                vim.treesitter.language.register("templ", "templ")
            end
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("treesitter-context").setup({
                enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false,      -- Enable multiwindow support.
                max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = "outer",     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = "cursor",          -- Line used to calculate context. Choices: 'topline', 'cursor'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            })
        end,
    },
}
