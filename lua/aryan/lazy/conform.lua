return {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                python = { "black" },
                ruby= { "rubocop" },
                go = { "gofmt" }
            }
        })
    end
}

