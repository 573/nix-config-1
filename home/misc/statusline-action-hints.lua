require('lualine').setup {
  sections = {
    lualine_x = { require("statusline-action-hints").statusline },
  }
}
