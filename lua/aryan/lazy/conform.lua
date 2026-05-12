return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            lsp_format = "never",
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                python = { "black" },
                -- ruby = { "rubocop" },
                go = { "gofmt" },
                c = { "clang-format" },
                cpp = { "clang-format" },
            },

            formatters = {
                ["clang-format"] = {
                    prepend_args = {
                        '--style={BasedOnStyle: LLVM, IndentWidth: 4, UseTab: Never, ColumnLimit: 80, BinPackArguments: false, BinPackParameters: false, AllowShortFunctionsOnASingleLine: None, BreakBeforeBinaryOperators: NonAssignment, BreakStringLiterals: false, PointerAlignment: Left, SortIncludes: true}',
                    },
                },
            },
        })
    end,
}
