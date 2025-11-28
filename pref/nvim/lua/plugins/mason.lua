return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "helm-ls",
        "gopls",
        "tfsec",
        "prisma-language-server",
      })
    end,
  },
}
