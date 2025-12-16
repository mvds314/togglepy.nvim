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
				-- the problem is that the window gets focus even when the terminal has on a breakpoint ->
				-- TODO: continue here like this
				-- this seems to get executed, but the terminal still loses focus -> test separately using the commented command below
				-- Test this with a sidepane terminal first
				-- Then test it with a floating terminal
				-- I don't understand why this logic is not correct
				-- Debug all the listeners, i.e., write custom listeners, and see when the focus is lost
				-- What I also don't understand is that on each break this code seems to run twice -> this is due to double stop notification
				-- require("togglepy.repl").switch_to_ipy_term()
				-- repl.switch_to_ipy_term()
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

	dap.listeners.after.event_initialized["ipdab_check_terminal_focus"] = function(mysession)
		-- vim.notify(vim.inspect(mysession), vim.log.levels.INFO)
		-- vim.notify(vim.inspect(getmetatable(mysession)), vim.log.levels.INFO)
		-- Override the jump_to_frame function
		-- local session_mt = getmetatable(mysession)

		local session_mt = getmetatable(dap.session())
		-- Continue here
		-- Plan is to override mysession.listeners.after.event_stopped -> make sure my own logic runs as planned

		-- 	if session_mt then
		-- 		local original_jump_to_frame = session_mt.__index.jump_to_frame -- Save the original function
		--
		-- 		-- Override the jump_to_frame function globally
		-- 		session_mt.__index.jump_to_frame = function(self, frame, preserve_focus_hint, stopped)
		-- 			vim.notify("Executing overridden jump_to_frame")
		--
		-- 			-- Save the current window and cursor position
		-- 			local current_win = vim.api.nvim_get_current_win()
		-- 			local current_buf = vim.api.nvim_get_current_buf()
		-- 			local current_cursor = vim.api.nvim_win_get_cursor(current_win)
		--
		-- 			-- Call the original jump_to_frame function
		-- 			original_jump_to_frame(self, frame, preserve_focus_hint, stopped)
		-- 			-- Restore the cursor to the original window and position
		-- 			if vim.api.nvim_win_is_valid(current_win) and vim.api.nvim_buf_is_valid(current_buf) then
		-- 				vim.notify("Restoring focus to the original window after jump_to_frame")
		-- 				vim.api.nvim_set_current_win(current_win)
		-- 				vim.api.nvim_win_set_cursor(current_win, current_cursor)
		-- 			else
		-- 				vim.notify("Not restoring focus to the original window after jump_to_frame")
		-- 			end
		-- 		end
		-- 		debug.setmetatable(dap.session(), session_mt)
		-- 		vim.notify("Overriding metatable")
		-- 	else
		-- 		vim.notify("Failed to retrieve the Session metatable", vim.log.levels.ERROR)
		-- 	end
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
