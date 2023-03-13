---------------
-- About cmp --
---------------
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

require("luasnip/loaders/from_vscode").lazy_load()


-- https://github.com/hrsh7th/nvim-cmp/wiki/Language-Server-Specific-Samples
vim.opt.completeopt = "menu,menuone,noinsert,noselect"

local kind_icons = {
    	Text = "󰊄",
    	Method = "",
    	Function = "󰡱",
    	Constructor = "",
    	Field = "",
    	Variable = "󱀍",
    	Class = "",
    	Interface = "",
    	Module = "󰕳",
    	Property = "",
    	Unit = "",
    	Value = "",
    	Enum = "",
    	Keyword = "",
    	Snippet = "",
    	Color = "",
    	File = "",
    	Reference = "",
    	Folder = "",
    	EnumMember = "",
    	Constant = "",
    	Struct = "",
    	Event = "",
    	Operator = "",
    	TypeParameter = "",
    }
    -- find more here: https://www.nerdfonts.com/cheat-sheet ("cod-symbol_")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
		["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
		-- C-b (back) C-f (forward) for snippet placeholder navigation.
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
			vim_item.menu = ({
				nvim_lsp = 'λ',
				luasnip = '⋗',
				buffer = 'Ω',
				path = '💻',
				nvim_lua = "[NVIM_LUA]",
			})[entry.source.name]
			return vim_item
		end,
	},
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp', keyword_length = 3 },
		{ name = 'buffer', keyword_length = 3 },
		{ name = 'luasnip', keyword_length = 2 },
		{ name = 'omni', keyword_length = 3 },
		{ name = 'nvim_lua' }, -- nvim_lua ?
		{ name = 'emoji', insert = true }
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
})


--require("luasnip.loaders.from_lua").lazy_load()
