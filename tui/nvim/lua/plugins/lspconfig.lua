return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["*"] = {
					keys = {
						-- Only set this keymap for servers that support code actions
						{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", has = "codeAction" },
						-- Multiple capabilities
						{
							"<leader>cR",
							function()
								Snacks.rename.rename_file()
							end,
							desc = "Rename File",
							has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
						},
						{ "<F2>", vim.lsp.buf.rename, desc = "Rename Symbol", mode = "n" },
					},
				},
				-- ty у Efterklang; у тебя Python обслуживает basedpyright, а ty mason включил бы сам
				ty = { enabled = false },
			},
		},
	},
}
