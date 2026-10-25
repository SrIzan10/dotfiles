return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>sx",
      function()
        require("telescope.builtin").live_grep({
          additional_args = function()
            return { "--fixed-strings" }
          end,
        })
      end,
      desc = "Search Exact Text",
    },
  },
}
