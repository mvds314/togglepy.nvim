local M = {}

function M.move_to_next_non_empty_line()
	local bufnr = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(bufnr)
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	for line = current_line + 1, total_lines do
		local text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if text and text:match("%S") then
			vim.api.nvim_win_set_cursor(0, { line, 0 })
			return
		end
	end
end

-- Normalize a file path for comparison: resolve to an absolute path, use
-- forward slashes, strip a trailing slash, and lower-case on Windows (where
-- paths are case-insensitive).
function M.normalize_path(path)
	if not path or path == "" then
		return nil
	end
	local normalized = vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/$", "")
	---@diagnostic disable-next-line: undefined-field
	if vim.loop.os_uname().version:match("Windows") then
		normalized = normalized:lower()
	end
	return normalized
end

-- Compare two file paths for equality, ignoring path separator style and
-- (on Windows) case.
function M.paths_equal(a, b)
	local na, nb = M.normalize_path(a), M.normalize_path(b)
	return na ~= nil and na == nb
end

function M.drop_duplicates(list)
	local seen = {}
	local result = {}
	for _, item in ipairs(list) do
		if not seen[item] then
			seen[item] = true
			table.insert(result, item)
		end
	end
	return result
end

return M
