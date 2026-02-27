# File explorer: nvim-tree.
# nvim-web-devicons is pulled in automatically as a dependency.
{ ... }: {
  plugins.nvim-tree = {
    enable = true;

    settings = {
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
