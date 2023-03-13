-- osc52 copy function - https://github.com/ojroques/nvim-osc52/blob/27b922a/README.md#advanced-usages
function copy()
  if vim.v.event.operator == 'y' and vim.v.event.regname == 'c' then
    require('osc52').copy_register('c')
  end
end

vim.api.nvim_create_autocmd('TextYankPost', {callback = copy})

-- nvim-osc52 clipboard provider - https://github.com/ojroques/nvim-osc52/blob/27b922a/README.md#using-nvim-osc52-as-clipboard-provider
local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
end

vim.g.clipboard = {
  name = 'osc52',
  copy = {['+'] = copy, ['*'] = copy},
  paste = {['+'] = paste, ['*'] = paste},
}

-- Now the '+' register will copy to system clipboard using OSC52
vim.keymap.set('n', '<leader>c', '"+y')
vim.keymap.set('n', '<leader>cc', '"+yy')

-- osc52 keymap - https://github.com/ojroques/nvim-osc52/blob/27b922a/README.md#usages
vim.keymap.set("n", "<leader>c", require("osc52").copy_operator, {expr = true})
vim.keymap.set("n", "<leader>cc", "<leader>c_", {remap = true})
vim.keymap.set("x", "<leader>c", require("osc52").copy_visual)

