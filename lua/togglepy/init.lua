local M = {}
--Auto load setup with default options if setup not called
local _setup_called = false

function M.setup(opts)
	_setup_called = true
	require("togglepy.ipdab").setup(opts)
end

-- Auto-setup with defaults if setup() wasn't called explicitly
vim.schedule(function()
	if not _setup_called then
		require("togglepy.ipdab").setup()
	end
end)

return M
