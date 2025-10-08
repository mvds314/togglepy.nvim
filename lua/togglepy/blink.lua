local M = {}

-- Blink the current line
function M.current_line(ms)
  local ns = vim.api.nvim_create_namespace "blink_line_ns"
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1

  -- Get the highlight color from Visual group
  local hl_group = "IncSearch"
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
  if not ok or not hl.bg then
    return
  end

  local color = string.format("#%06x", hl.bg)

  -- Define temporary highlight group
  vim.api.nvim_set_hl(0, "BlinkLine", { bg = color })

  -- Place an extmark with the highlight
  local mark_id = vim.api.nvim_buf_set_extmark(0, ns, line, 0, {
    end_row = line + 1,
    hl_group = "BlinkLine",
    hl_eol = true,
  })

  -- Remove the highlight after a short delay
  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(0, ns, mark_id)
  end, ms)
end

function M.entire_file(ms)
  local ns = vim.api.nvim_create_namespace "blink_file_ns"
  local buf = 0
  local lines = vim.api.nvim_buf_line_count(buf)

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "IncSearch" })
  if not ok or not hl.bg then
    return
  end
  local color = string.format("#%06x", hl.bg)

  vim.api.nvim_set_hl(0, "BlinkFile", { bg = color })

  local mark_id = vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    end_row = lines,
    hl_group = "BlinkFile",
    hl_eol = true,
  })

  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(0) then
      pcall(vim.api.nvim_buf_del_extmark, 0, ns, mark_id)
      vim.cmd "redraw"
    end
  end, ms)
end

function M.selection(ms, start_line, end_line, start_col, end_col)
  local ns = vim.api.nvim_create_namespace "blink_selection_ns"
  local buf = 0
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- Validate end positions not out of range
  if start_line >= line_count then
    start_line = line_count - 1
  end
  if end_line >= line_count then
    end_line = line_count - 1
  end

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "IncSearch" })
  if not ok or not hl.bg then
    return
  end
  local color = string.format("#%06x", hl.bg)

  vim.api.nvim_set_hl(0, "BlinkSelection", { bg = color })
  local mark_id = nil
  if start_col == nil or end_col == nil then
    mark_id = vim.api.nvim_buf_set_extmark(buf, ns, start_line, 0, {
      end_row = end_line,
      hl_group = "BlinkSelection",
      hl_eol = true,
    })
  else
    mark_id = vim.api.nvim_buf_set_extmark(buf, ns, start_line, start_col, {
      end_row = end_line,
      end_col = end_col,
      hl_group = "BlinkSelection",
    })
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(buf, ns, mark_id)
  end, ms)
end

return M
