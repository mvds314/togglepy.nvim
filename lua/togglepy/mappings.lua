local M = {}

local repl = require("togglepy.repl")
local blink = require("togglepy.blink")

-- TODO: add mapping settings to documentation

-- TODO: set these defaults everywhere else too
function M.setup(opts)
	-- Set default options
	opts = vim.tbl_deep_extend("force", {
		window_navigation = true,
		send_key = "<F9>",
		run_key = "<F5>",
		next_key = "<F10>",
		step_in_key = "<F11>",
		step_out_key = "<F12>",
	}, opts or {})
	-- Key mappings for navigating between Python buffers and toggply's IPython terminal
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(args)
			local buf = args.buf or nil
			if opts.window_navigation then
				-- Make switching between windows work in terminal mode
				vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", { noremap = true, desc = "Go to left window" })
				vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", { noremap = true, desc = "Go to lower window" })
				vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", { noremap = true, desc = "Go to upper window" })
				vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", { noremap = true, desc = "Go to right window" })
			end
			-- Define Run/continue key mapping
			if opts.run_key then
				if buf then
					vim.keymap.set({ "n", "i", "v" }, opts.run_key, function()
						if not repl.in_debug_mode() then
							vim.cmd("TogglePyRunFile")
						else
							vim.cmd("TogglePyDebugContinue")
						end
					end, { buf = buf, noremap = true, silent = true, desc = "Run/Continue" })
				else
					vim.notify("Buffer not found for key mapping " .. opts.run_key, vim.log.levels.ERROR)
				end
			end
			-- Define debug next key mapping
			if opts.next_key then
				vim.keymap.set("n", opts.next_key, function()
					vim.cmd("TogglePyDebugNext")
				end, { noremap = true, silent = true, desc = "Debug next" })
			end
			-- Define step in and step key mappings
			if opts.step_in_key then
				if buf then
					vim.keymap.set("n", opts.step_in_key, function()
						vim.cmd("TogglePyDebugStep")
					end, { buffer = buf, noremap = true, silent = true, desc = "Debug step in" })
				else
					vim.notify("Buffer not found for key mapping " .. opts.step_in_key, vim.log.levels.ERROR)
				end
			end
			-- Define step out/return key mapping
			if opts.step_out_key then
				if buf then
					vim.keymap.set("n", opts.step_out_key, function()
						vim.cmd("TogglePyDebugReturn")
					end, { buffer = buf, noremap = true, silent = true, desc = "Step out/return" })
				else
					vim.notify("Buffer not found for key mapping " .. opts.step_out_key, vim.log.levels.ERROR)
				end
			end
			-- Define send to terminal mappings
			if opts.send_key then
				if not buf then
					vim.notify("Buffer not found for key mapping " .. opts.send_key, vim.log.levels.ERROR)
				end
				vim.keymap.set("n", opts.send_key, function()
					-- Ensure the REPL is running
					if not repl.repl_running() then
						local current_win = vim.api.nvim_get_current_win()
						vim.cmd("TogglePyTerminal")
						if vim.api.nvim_win_is_valid(current_win) then
							vim.api.nvim_set_current_win(current_win)
						end
					end
					-- Send and blink the current line
					vim.cmd("TogglePySendLine")
				end, { buffer = buf, noremap = true, silent = true, desc = "Send current line to IPython terminal" })
				vim.keymap.set(
					"v",
					opts.send_key,
					function()
						-- Ensure the REPL is running
						if not repl.repl_running() then
							local current_win = vim.api.nvim_get_current_win()
							vim.cmd("TogglePyTerminal")
							if vim.api.nvim_win_is_valid(current_win) then
								vim.api.nvim_set_current_win(current_win)
							end
						end
						-- Get the visual selection range
						local start_pos = vim.fn.getpos("v")
						local end_pos = vim.fn.getpos(".")
						if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
							start_pos, end_pos = end_pos, start_pos
						end
						local start_line = start_pos[2] - 1
						local start_col = start_pos[3] - 1
						local end_line = end_pos[2] - 1
						local end_col = end_pos[3]
						-- blink the selection
						blink.selection(50, start_line, end_line, start_col, end_col)
						-- Send the visual selection to the REPL
						vim.cmd("ToggleTermSendVisualSelection " .. vim.v.count1)
					end,
					{ buffer = buf, noremap = true, silent = true, desc = "Send visual selection to IPython terminal" }
				)
			end
		end,
	})
end

return M
