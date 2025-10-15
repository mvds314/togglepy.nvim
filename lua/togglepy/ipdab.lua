local M = {}

function M.setup(opts)
	-- Default options
	opts = vim.tbl_deep_extend("force", {
		host = "localhost",
		port = 9000,
	}, opts or {})
	opts = opts or {}
	local dap_ok, dap = pcall(require, "dap")
	if not dap_ok then
		vim.notify("nvim-dap is required for togglepy.nvim", vim.log.levels.ERROR)
		return
	end

	dap.adapters.ipdb = {
		type = "server",
		host = opts.host,
		port = opts.port,
	}

	dap.configurations.python = dap.configurations.python or {}
	table.insert(dap.configurations.python, {
		name = "Attach to ipdb (manual %run)",
		type = "ipdb",
		request = "launch", -- important to say launch here!
		program = "${file}",
		justMyCode = false,
		cwd = vim.fn.getcwd(),
	})
end

-- TODO: configure the DAPui look and feel for this option

return M
