return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
      bind_to_cwd = true,
      cwd_target = {
        sidebar = "global",
        current = "global",
      },
      window = {
        position = "left",
        mappings = {
          ["m"] = { "move", config = { show_path = "relative" } },
        },
      },
    },
  },
}
