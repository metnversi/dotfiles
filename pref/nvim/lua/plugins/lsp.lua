return {
  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "K", "<cmd>Lspsaga hover_doc<cr>" }
    end,
    opts = {
      servers = {
        gopls = {
          filetypes = { "gotmpl" },
        },
        yamlls = {
          filetypes = { "helm", "gotmpl", "yaml" },
        },
        terraformls = {
          root_dir = require("lspconfig").util.root_pattern(".terraform", ".tf", ".git"),
        },
      },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          sign = false,
        },
        ui = {
          title = true,
        },
      })
    end,
  },
}
