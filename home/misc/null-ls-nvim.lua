-- null-ls.nvim configuration
-- ++++++ https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/
local null_ls = require("null-ls")
null_ls.setup({
	debug = true,
	sources = {
--		null_ls.builtins.diagnostics.vale,
		null_ls.builtins.diagnostics.statix,
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.diagnostics.deadnix,
		null_ls.builtins.code_actions.shellcheck,
		null_ls.builtins.diagnostics.shellcheck,
		null_ls.builtins.formatting.shellharden,
		null_ls.builtins.formatting.alejandra,
		null_ls.builtins.formatting.nixfmt,
		null_ls.builtins.formatting.shfmt,
		null_ls.builtins.completion.luasnip,
		null_ls.builtins.formatting.latexindent.with({ timeout_ms = 10000 })
	}
})
