local M = {}
--Auto load setup with default options if setup not called
local _setup_called = false

function M.setup(opts)
	_setup_called = true
	opts = opts or {}
	local ipdab_opts = opts.ipdab or {}
	local repl_opts = opts.repl or {}
	local keymap_opts = opts.keymaps or {}
	-- local repl_opts = opts and opts.repl or {}
	require("togglepy.ipdab").setup(ipdab_opts)
	require("togglepy.repl").setup(repl_opts)
	-- Pass the keymap options to the keymaps module
	require("togglepy.keymaps").setup(keymap_opts)
end

-- Auto-setup with defaults if setup() wasn't called explicitly
vim.schedule(function()
	if not _setup_called then
		M.setup()
	end
end)

-- TODO: update documentation for the plugin

return M
