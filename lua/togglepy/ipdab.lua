local M = {}

function M.setup(opts)
	-- Default options
	opts = vim.tbl_deep_extend("force", {
		host = "localhost",
		port = 9000,
	}, opts or {})
	opts = opts or {}

	-- Require dap
	local dap_ok, dap = pcall(require, "dap")
	if not dap_ok then
		vim.notify("nvim-dap is required for togglepy.nvim", vim.log.levels.ERROR)
		return
	end

	dap.adapters.ipdab = {
		type = "server",
		host = opts.host,
		port = opts.port,
	}

	dap.configurations.python = dap.configurations.python or {}
	table.insert(dap.configurations.python, {
		name = "Attach to ipdab (manual %run)",
		type = "ipdab",
		request = "launch", -- important to say launch here!
		program = "${file}",
		justMyCode = false,
		cwd = vim.fn.getcwd(),
	})

	-- Toggle breakpoint at the cursor's line, delegating to nvim-dap so
	-- breakpoints are sent to ipdab via the DAP `setBreakpoints` request.
	vim.api.nvim_create_user_command("TogglePyToggleBreakpoint", function()
		dap.toggle_breakpoint()
	end, { desc = "Toggle breakpoint" })
end

return M
