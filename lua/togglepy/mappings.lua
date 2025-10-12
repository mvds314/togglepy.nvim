local M = {}

function M.setup(opts)
	-- Set default options
	opts = vim.tbl_deep_extend("force", { window_navigation = true }, opts or {})
	-- Key mappings for navigating between Python buffers and toggply's IPython terminal
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function()
			if opts.window_navigation then
				vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", { noremap = true })
				vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", { noremap = true })
				vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", { noremap = true })
				vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", { noremap = true })
			end
		end,
	})
end

-- TODO: configure the DAPui look and feel for this option

return M
