local M = {}
-- Check if the OS is Windows
---@diagnostic disable-next-line: undefined-field
local is_windows = vim.loop.os_uname().version:match("Windows")
-- Stores the ipython terminal instance
local ipy_term = nil
-- Stores the preferred Python environment
local current_python_env = nil
-- Stores list with all Python environments
local python_envs = nil
-- Helpers for blinking text to be sent to the terminal
local blink = require("togglepy.blink")
local helpers = require("togglepy.helpers")
-- Local variable to store preferred terminal direction
local terminal_direction = "vertical"
-- Default search paths for Python environments on Linux/MacOS
local python_env_search_paths = {}
local add_miniconda = true
local add_system_path = true

M.setup = function(opts)
	-- Default options
	-- The problem is that no opts seem to be passed
	for k, v in ipairs(opts) do
		print("Option " .. k .. " = " .. tostring(v))
	end
	-- vim.notify("TogglePy setup called with " .. #opts.search_paths .. " search paths")
	opts = vim.tbl_deep_extend("force", {
		terminal_direction = "vertical",
		search_paths = {},
		add_miniconda = true,
		add_system_path = true,
	}, opts or {})
	local test = opts.test or 0
	-- vim.notify("TogglePy setup called with test=" .. tostring(test))
	-- Set the options as global variables in the module
	terminal_direction = opts.terminal_direction
	python_env_search_paths = vim.list_extend({}, opts.search_paths)
	-- vim.notify("We now have " .. #python_env_search_paths .. " search paths for Python envs")
	add_miniconda = opts.add_miniconda
	add_system_path = opts.add_system_path
end
--TODO: check the entire find Python env logic

M.repl_running = function()
	return ipy_term ~= nil
end

M.send = function(cmd, go_back)
	if not ipy_term then
		vim.notify("IPython terminal is not open", vim.log.levels.WARN)
		return
	else
		ipy_term:send(cmd, go_back)
	end
end

M.create_or_get_ipython_terminal = function(cmd)
	local Terminal = require("toggleterm.terminal").Terminal
	if not cmd then
		local python_env = current_python_env or "python"
		-- Ignore IPython warnings about running inside a virtual environment
		cmd = string.format('"%s" -W "ignore:.*interactiveshell.py:UserWarning" -m IPython', python_env)
	end
	if not ipy_term then
		ipy_term = Terminal:new({
			cmd = cmd,
			hidden = false, -- Register the terminal so it can be toggled
			direction = terminal_direction,
			close_on_exit = false,
			newline_chr = "\n", -- The character to use for newlines, set manually to avoid issues with adding extra newlines
			display_name = "IPython terminal",
			on_exit = function()
				ipy_term = nil
			end,
		})
	end
	if not ipy_term:is_open() then
		ipy_term:toggle()
	end
	return ipy_term
end

M.run_python_file_in_ipython_terminal = function()
	-- Check if the current buffer is a Python file
	if vim.bo.filetype ~= "python" then
		vim.notify("This only works for Python files", vim.log.levels.WARN)
		return
	end
	-- Initialize
	local file = vim.api.nvim_buf_get_name(0)
	-- Save the file before running it
	vim.cmd("wall")
	if file == "" then
		vim.notify("No file to run", vim.log.levels.ERROR)
		return
	end
	if vim.bo.filetype ~= "python" then
		vim.notify("This only works for Python files", vim.log.levels.WARN)
		return
	end
	-- Ignore IPython warnings about running inside a virtual environment
	local python_env = current_python_env or "python"
	local cmd = string.format('"%s" -W "ignore:.*interactiveshell.py:UserWarning" -m IPython', python_env)
	ipy_term = M.create_or_get_ipython_terminal(cmd)
	file = string.gsub(file, "[\r\n]+$", "")
	-- Note we clear the current line first by sending Ctrl+U, represented by \x15
	-- Change to the file's directory before running
	local file_dir = vim.fn.fnamemodify(file, ":h")
	ipy_term:send("\x15" .. string.format('cd "%s"', file_dir), true)
	local file_basename = vim.fn.fnamemodify(file, ":t")
	ipy_term:send("\x15" .. string.format("%%run %s", file_basename), true)
	-- ipy_term:send("\x15" .. string.format("%%run %s", file), false)
end

M.find_python_envs_on_linux = function(search_paths)
	-- Check if the OS is not Windows
	if is_windows then
		vim.notify("This function is not for Windows", vim.log.levels.ERROR)
	end
	-- Initialize search paths
	search_paths = vim.list_extend(search_paths or {}, {
		"/usr/bin",
		"/usr/local/bin",
		"~/.pyenv/versions",
	})
	-- Linux default locations
	if add_miniconda then
		table.insert(search_paths, "~/.conda/envs")
		table.insert(search_paths, "~/anaconda3/envs")
	end
	local find_cmd = [[find -L ]] .. table.concat(search_paths, " ") .. [[ -type f -name python 2>/dev/null;]]
	if add_system_path then
		find_cmd = find_cmd .. " which -a python 2>/dev/null"
	end
	local linux_handle = io.popen(find_cmd)
	-- Process the output
	local envs = {}
	if linux_handle then
		for line in linux_handle:lines() do
			table.insert(envs, line)
		end
		linux_handle:close()
	end
	return helpers.drop_duplicates(envs)
end

-- TODO: test this logic
M.find_python_envs_on_windows = function(search_paths)
	-- Check if the OS is Windows
	if not is_windows then
		vim.notify("This function is only for Windows", vim.log.levels.ERROR)
	end
	-- Initialize candidate folders to search for python executables
	search_paths = search_paths or {}
	-- TODO: continue here, why is this one set to 0 paths?
	vim.notify("Searching Python environments in " .. #search_paths .. " paths")
	-- Add miniconda paths
	if add_miniconda then
		-- Add all miniconda3 folders to search paths
		table.insert(search_paths, os.getenv("USERPROFILE") .. "\\AppData\\Local\\miniconda3")
		-- Add all miniconda3 envs folders to search paths
		local miniconda_envs = os.getenv("USERPROFILE") .. "\\AppData\\Local\\miniconda3\\envs"
		local envs_handle = io.popen('dir /b /ad "' .. miniconda_envs .. '" 2>nul')
		if envs_handle then
			for folder in envs_handle:lines() do
				table.insert(search_paths, folder)
			end
			envs_handle:close()
		end
	end
	-- Process candidate folders
	local envs = {}
	for _, dir in ipairs(search_paths) do
		local handle = io.popen('dir /b "' .. dir .. '\\python.exe" 2>nul')
		if handle then
			for line in handle:lines() do
				table.insert(envs, dir .. "\\" .. line)
			end
			handle:close()
		end
	end
	-- Also add python from PATH
	if add_system_path then
		local handle = io.popen("where python 2>nul")
		if handle then
			for line in handle:lines() do
				table.insert(envs, line)
			end
			handle:close()
		end
	end
	vim.notify("Found " .. tostring(#envs) .. " Python environments")
	return envs
end

M.find_python_envs = function()
	vim.notify("Searching for Python environments...")
	if is_windows then
		return M.find_python_envs_on_windows(python_env_search_paths)
	else
		return M.find_python_envs_on_linux(python_env_search_paths)
	end
end

-- TODO test this one, not used yet
M.pick_python_env_async = function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local search_cmd =
		[[which -a python python3 2>/dev/null; find -L ~/.pyenv/versions ~/.conda/envs ~/anaconda3/envs -type f -name python 2>/dev/null]]
	vim.system({ "bash", "-c", search_cmd }, { text = true }, function(obj)
		if obj.code == 0 and obj.stdout then
			local envs = {}
			for line in obj.stdout:gmatch("[^\r\n]+") do
				table.insert(envs, line)
			end
			pickers
				.new({}, {
					prompt_title = "Select Python Environment",
					finder = finders.new_table({ results = envs }),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr, _)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							current_python_env = selection[1]
							vim.notify("Selected Python: " .. current_python_env)
						end)
						return true
					end,
				})
				:find()
		else
			vim.notify("Failed to find Python environments", vim.log.levels.ERROR)
		end
	end)
end

M.pick_python_env = function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	vim.notify("Preparing Python environments...")
	-- Find python executables in common locations
	if not python_envs then
		vim.notify("None found yet, searching now...")
		python_envs = M.find_python_envs()
	end
	pickers
		.new({}, {
			prompt_title = "Select Python Environment",
			finder = finders.new_table({ results = python_envs }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					current_python_env = selection[1]
					vim.notify("Selected Python: " .. current_python_env)
				end)
				return true
			end,
		})
		:find()
end

M.in_debug_mode = function()
	if not ipy_term or not ipy_term.bufnr then
		vim.notify("IPython terminal is not open", vim.log.levels.WARN)
		return false
	end
	local lines = vim.api.nvim_buf_get_lines(ipy_term.bufnr, 0, -1, false)
	for i = #lines, 1, -1 do
		local line = lines[i]
		if line and line:match("%(Pdb%)") then
			return true
		elseif line and line:match("%(IPdb%)") then
			return true
		elseif line and line:match("%(ipdb%)") then
			return true
		elseif line and line:match("^ipdb>") then
			return true
		elseif line and line:match("^In %[%d+%]:") then
			return false
		end
	end
	vim.notify("Not in debug mode", vim.log.levels.WARN)
	return false
end

-------------------------------- Set up commands --------------------------------

-- Create a command to pick Python environments
vim.api.nvim_create_user_command("TogglePyPickEnv", function()
	M.pick_python_env()
end, { desc = "Pick Python environment" })
-- Create a command to clear Python environments
vim.api.nvim_create_user_command("TogglePyClearEnvs", function()
	python_envs = nil
	vim.notify("Cleared Python environments")
end, { desc = "Clear Python environments" })
-- Create a command to toggle the IPython terminal
vim.api.nvim_create_user_command("TogglePyTerminal", function()
	M.create_or_get_ipython_terminal(nil)
end, { desc = "Toggle IPython terminal" })
-- Command to switch terminal direction
vim.api.nvim_create_user_command("TogglePySwitchTerminalDirection", function()
	if terminal_direction == "float" then
		terminal_direction = "vertical"
	else
		terminal_direction = "float"
	end
	vim.notify("Terminal direction set to: " .. terminal_direction)
end, { desc = "Switch terminal split direction" })

-- These commands should only be available for Python files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		-- Run the current Python file in IPython terminal
		vim.api.nvim_create_user_command("TogglePyRunFile", function()
			if M.in_debug_mode() then
				vim.notify("Cannot run file while in debug mode", vim.log.levels.WARN)
				return
			else
				M.run_python_file_in_ipython_terminal()
			end
		end, { desc = "Run current Python file in IPython terminal" })
		-- Send current line to the IPython terminal
		vim.api.nvim_create_user_command("TogglePySendLine", function()
			if vim.bo.filetype ~= "python" then
				vim.notify("This only works for Python files", vim.log.levels.WARN)
				return
			end
			blink.current_line(50)
			vim.cmd("ToggleTermSendCurrentLine " .. vim.v.count1)
			vim.schedule(function()
				vim.cmd("stopinsert")
			end)
			helpers.move_to_next_non_empty_line()
		end, { desc = "Send current line to IPython terminal", range = true })
		-- Debug continue
		vim.api.nvim_create_user_command("TogglePyDebugContinue", function()
			if not M.repl_running() then
				vim.notify("IPython terminal is not open", vim.log.levels.WARN)
				return
			elseif not M.in_debug_mode() then
				vim.notify("Not in debug mode", vim.log.levels.WARN)
			else
				M.send("continue", false)
			end
		end, { desc = "Debug continue" })
		-- Debug next
		vim.api.nvim_create_user_command("TogglePyDebugNext", function()
			if not M.repl_running() then
				vim.notify("IPython terminal is not open", vim.log.levels.WARN)
				return
			elseif not M.in_debug_mode() then
				vim.notify("Not in debug mode", vim.log.levels.WARN)
			else
				M.send("next", false)
			end
		end, { desc = "Debug next" })
		-- Debug step
		vim.api.nvim_create_user_command("TogglePyDebugStep", function()
			if not M.repl_running() then
				vim.notify("IPython terminal is not open", vim.log.levels.WARN)
				return
			elseif not M.in_debug_mode() then
				vim.notify("Not in debug mode", vim.log.levels.WARN)
			else
				M.send("step", false)
			end
		end, { desc = "Debug step into" })
		-- Debug return
		vim.api.nvim_create_user_command("TogglePyDebugReturn", function()
			if not M.repl_running() then
				vim.notify("IPython terminal is not open", vim.log.levels.WARN)
				return
			elseif not M.in_debug_mode() then
				vim.notify("Not in debug mode", vim.log.levels.WARN)
			else
				M.send("return", false)
			end
		end, { desc = "Debug return/step out" })
	end,
})

return M
