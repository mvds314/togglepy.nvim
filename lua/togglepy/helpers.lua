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
