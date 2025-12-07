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
	dap.listeners.after.event_stopped["ipdab_retain_terminal_focus"] = function()
		local repl = require("togglepy.repl")
		-- TODO: remove notify
		vim.notify("After stopped event received, checking to retain focus")
		if repl.ipy_term_has_focus() then
			--TODO: remove notify
			vim.notify("Terminal has focus, scheduling to retail it")
			vim.schedule(function()
				-- TODO: continue here, this does not work yet
				-- Reproduce, debug, attach dap, type next in terminal, focus of terminal is lost
				-- the problem is that the window get focus even when the terminal has on a breakpoint ->
				-- TODO: continue here like this
				-- this seems to get executed, but the terminal still loses focus -> test separately using the commented command below
				-- Test this with a sidepane terminal first
				-- Then test it with a floating terminal
				-- I don't understand why this logic is not correct
				-- Debug all the listeners, i.e., write custom listeners, and see when the focus is lost
				-- What I also don't understand is that on each break this code seems to run twice
				-- require("togglepy.repl").switch_to_ipy_term()
				repl.switch_to_ipy_term()
			end)
		end
	end
	-- TODO: remove these listeners after testing
	dap.listeners.after.event_continued["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Continued event received, terminal has focus")
		else
			vim.notify("Continued event received, terminal does not have focus")
		end
	end
	dap.listeners.before.event_continued["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Before Continued event received, terminal has focus")
		else
			vim.notify("Before Continued event received, terminal does not have focus")
		end
	end
	dap.listeners.before.event_stopped["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Before Stopped event received, terminal has focus")
		else
			vim.notify("Before Stopped event received, terminal does not have focus")
		end
	end
	dap.listeners.after.event_stopped["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("After Stopped event received, terminal has focus")
		else
			vim.notify("After Stopped event received, terminal does not have focus")
		end
	end
	dap.listeners.before.event_module["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Before Module event received, terminal has focus")
		else
			vim.notify("Before Module event received, terminal does not have focus")
		end
	end
	dap.listeners.after.event_module["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("After Module event received, terminal has focus")
		else
			vim.notify("After Module event received, terminal does not have focus")
		end
	end
	dap.listeners.before.event_thread["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Before Thread event received, terminal has focus")
		else
			vim.notify("Before Thread event received, terminal does not have focus")
		end
	end
	dap.listeners.after.event_thread["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("After Thread event received, terminal has focus")
		else
			vim.notify("After Thread event received, terminal does not have focus")
		end
	end
	dap.listeners.before.event_output["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("Before Output event received, terminal has focus")
		else
			vim.notify("Before Output event received, terminal does not have focus")
		end
	end
	dap.listeners.after.event_output["ipdab_check_terminal_focus"] = function()
		local has_focus = require("togglepy.repl").ipy_term_has_focus()
		if has_focus then
			vim.notify("After Output event received, terminal has focus")
		else
			vim.notify("After Output event received, terminal does not have focus")
		end
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
end

return M
