local M = {}

local current_dapui_config
local adjusted_dapui_config

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

	local dapui_ok, dapui = pcall(require, "dapui")
	if not dapui_ok then
		vim.notify("nvim-dap-ui is required for togglepy.nvim", vim.log.levels.ERROR)
		return
	end

	-- Save the original dapui configuration
	local dapui_config = require("dapui.config")
	-- Note we have the fields of dapui_config hardcoded here, as they cannot be retrieved programmatically
	for _, f in ipairs({
		"icons",
		"mappings",
		"element_mappings",
		"expand_lines",
		"force_buffers",
		"layouts",
		"floating",
		"controls",
		"render",
	}) do
		current_dapui_config = current_dapui_config or {}
		current_dapui_config[f] = vim.deepcopy(dapui_config[f])
	end
	adjusted_dapui_config = vim.deepcopy(current_dapui_config)
	adjusted_dapui_config.layouts.elements = {}

	-- TODO: continue here
	-- Set listeners to change the dapui layout based on the configuration used
	dap.listeners.after.event_initialized["dapui_config"] = function()
		local config = dap.session().config
		-- Maybe put the copy logic here
		if config.name == "Attach to ipdb (manual %run)" then
			dapui.setup(adjusted_dapui_config)
		else
			dapui.setup(current_dapui_config)
		end
		dapui.open()
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
