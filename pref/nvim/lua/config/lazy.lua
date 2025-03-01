local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = { -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
    }, -- import any extras modules here
    -- import/override with your plugins
    -- { import = "lazyvim.plugins.extras.coding.copilot" },
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.editor.aerial" },
    { import = "lazyvim.plugins.extras.editor.dial" },
    { import = "lazyvim.plugins.extras.editor.illuminate" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },
    { import = "lazyvim.plugins.extras.editor.navic" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    -- { import = "lazyvim.plugins.extras.lang.ansible" },
    -- { import = "lazyvim.plugins.extras.lang.astro" },
    -- { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.git" },
    { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.lang.markdown" },
    -- { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    -- { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.ui.treesitter-rewrite" },
    { import = "lazyvim.plugins.extras.util.project" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    { import = "plugins" },
    --    {
    --      "CopilotC-Nvim/CopilotChat.nvim",
    --      branch = "canary",
    --      dependencies = {
    --        { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    --        { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    --      },
    --      opts = {
    --        debug = true, -- Enable debugging
    --        -- See Configuration section for rest
    --      },
    --      -- See Commands section for default commands if you want to lazy load on them
    --    },
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && npm install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
    },
    {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    {
      "barrett-ruth/live-server.nvim",
      build = "pnpm add -g live-server",
      cmd = { "LiveServerStart", "LiveServerStop" },
      config = true,
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  checker = {
    enabled = true,
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require("mason").setup()
