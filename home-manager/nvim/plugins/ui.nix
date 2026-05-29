# File explorer: nvim-tree.
# nvim-web-devicons is pulled in automatically as a dependency.
{ ... }: {
  # Required by nvim-tree for file icons; enabled explicitly to avoid deprecation warning.
  plugins.web-devicons.enable = true;

  plugins.nvim-tree = {
    enable = true;

    settings = {
      on_attach.__raw = ''
        function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)

          local function grep_in_folder()
            local node = api.tree.get_node_under_cursor()
            if not node then return end
            local path = node.absolute_path
            if node.type ~= "directory" then
              path = vim.fn.fnamemodify(path, ":h")
            end
            require("fzf-lua").live_grep({ cwd = path })
          end

          vim.keymap.set("n", "<leader>g", grep_in_folder, {
            buffer = bufnr,
            noremap = true,
            silent = true,
            desc = "Live grep in folder",
          })
        end
      '';

      update_focused_file.enable = true;

      view = {
        width = 50;
        side  = "left";
      };

      renderer = {
        highlight_opened_files = "name";
        highlight_git          = true;
        full_name              = true;
        icons.show = {
          file   = false;
          folder = false;
          git    = false;
        };
      };

      git.enable = false;
    };
  };

  keymaps = [
    {
      mode    = "n";
      key     = "<leader>e";
      action  = ":NvimTreeToggle<CR>";
      options = { noremap = true; silent = true; };
    }
  ];
}
