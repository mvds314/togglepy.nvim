local M = {}

local original_dapui_config
local adjusted_dapui_config

local function copy_dapui_config()
	local dapui_config = require("dapui.config")
	-- Note we have the fields of dapui_config hardcoded here, as they cannot be retrieved programmatically
	local copy_of_config
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
		copy_of_config = copy_of_config or {}
		copy_of_config[f] = vim.deepcopy(dapui_config[f])
	end
	return copy_of_config
end

local function reset_dapui()
	local dapui = require("dapui")
	if original_dapui_config ~= nil then
		dapui.setup(original_dapui_config)
		original_dapui_config = nil
	end
	dapui.close()
end

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
	-- Require dapui
	local dapui_ok, dapui = pcall(require, "dapui")
	if not dapui_ok then
		vim.notify("nvim-dap-ui is required for togglepy.nvim", vim.log.levels.ERROR)
		return
	end
	-- Set listeners to change the dapui layout based on the configuration used
	dap.listeners.after.event_initialized["dapui_config"] = function()
		-- Store the original config globally, and temporarily switch to a modified one
		local config = dap.session().config
		if config.name == "Attach to ipdb (manual %run)" then
			if original_dapui_config == nil then
				original_dapui_config = copy_dapui_config()
			end
			adjusted_dapui_config = vim.deepcopy(original_dapui_config)
			adjusted_dapui_config.layouts.elements = {}
			dapui.setup(adjusted_dapui_config)
		elseif original_dapui_config ~= nil then
			-- Restore the original config
			dapui.setup(original_dapui_config)
			original_dapui_config = nil
		end
		dapui.open()
	end

	dap.listeners.before.event_terminated["dapui_config"] = reset_dapui
	dap.listeners.before.event_exited["dapui_config"] = reset_dapui

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
