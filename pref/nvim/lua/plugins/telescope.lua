local telescope_symbols = {
  "method",
  "array",
  "boolean",
  "string",
  "constant",
  "field",
  "type",
  "variable",
  "class",
  "interface",
  "module",
  "property",
  "enum",
  "struct",
  "event",
  "operator",
  "typeParameter",
  "function",
}
return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = telescope_symbols,
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = telescope_symbols,
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
  },
}
