local M = {}
--Auto load setup with default options if setup not called
local _setup_called = false

function M.setup(opts)
	_setup_called = true
	local ipdab_opts = opts and opts.ipdab or {}
	-- local repl_opts = opts and opts.repl or {}
	require("togglepy.ipdab").setup(ipdab_opts)
	require("togglepy.repl")
end

-- Auto-setup with defaults if setup() wasn't called explicitly
vim.schedule(function()
	if not _setup_called then
		require("togglepy.ipdab").setup()
		require("togglepy.repl")
	end
end)

-- TODO: write documentation for the plugin

return M
