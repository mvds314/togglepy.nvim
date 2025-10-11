local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", { noremap = true })
	vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", { noremap = true })
	vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", { noremap = true })
	vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", { noremap = true })
end

-- TODO: configure the DAPui look and feel for this option

return M
