local M = {}
--Auto load setup with default options if setup not called
local _setup_called = false

function M.setup(opts)
	if _setup_called then
		vim.notify("togglepy.nvim: setup() called again, should not happen by default", vim.log.levels.WARN)
	else
		_setup_called = true -- Prevent race condition
		vim.notify("togglepy.nvim: calling setup", vim.log.levels.INFO)
	end
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

-- TODO: update documentation for the plugin

return M
