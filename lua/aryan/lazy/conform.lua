return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                python = { "black" },
                ruby = { "rubocop" },
                go = { "gofmt" },
                c = { "clang-format" },
                cpp = { "clang-format" },
            },

            formatters = {
                ["clang-format"] = {
                    prepend_args = { "-style=file", "-fallback-style=LLVM" },
                },
            },
        })
    end,
}
