local M = {}

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
		callback = function()
			if opts.window_navigation then
				-- Make switching between windows work in terminal mode
				vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", { noremap = true })
				vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", { noremap = true })
				vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", { noremap = true })
				vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", { noremap = true })
			end
			if opts.run_key then
				vim.keymap.set({ "n", "i", "v" }, "<F5>", function()
					if ipy_term == nil then
						vim.cmd("TogglePyRunFile")
					elseif not in_debug_mode() then
						vim.cmd("TogglePyRunFile")
					else
						vim.cmd("TogglePyDebugContinue")
					end
				end, { noremap = true, silent = true, desc = "Run/Continue" })
			end
		end,
	})
end

-- TODO: configure the DAPui look and feel for this option

return M
