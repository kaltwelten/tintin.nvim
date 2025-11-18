local _defaults = {
  delay_ms = 5,
  nc_blend_percent = 40,
}

local function _tintable(win)
  if
    win ~= vim.api.nvim_get_current_win() and
    vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() and
    vim.fn.win_gettype(win) == ''
  then
    local buftype = vim.bo[vim.api.nvim_win_get_buf(win)].buftype
    return buftype == '' or buftype == 'help'
  end
  return false
end

local function _create_overlay_config(win)
  local wininfo = vim.fn.getwininfo(win)[1]
  return {
    focusable = false,
    noautocmd = true,
    relative = 'editor',
    style = 'minimal',
    col = wininfo.wincol - 1,
    row = wininfo.winrow - 1,
    width = wininfo.width,
    height = wininfo.height,
    zindex = 2,
  }
end

local M = {}

function M.setup(opts)
  if M.loaded then return end
  M.loaded = true
  M.options = vim.tbl_deep_extend('force', {}, _defaults, opts or {})
  local overlay_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[overlay_buf].filetype = 'tintin'
  local overlays = {}
  vim.api.nvim_create_autocmd('WinEnter', {
    group = vim.api.nvim_create_augroup('tintin', { clear = true }),
    callback = function()
      for i, o in ipairs(overlays) do
        if vim.api.nvim_win_is_valid(o) then vim.api.nvim_win_close(o, false) end
        overlays[i] = nil
      end
      vim.defer_fn(function()
        for _, w in ipairs(vim.tbl_filter(function(w) return _tintable(w) end, vim.api.nvim_list_wins())) do
          local overlay = vim.api.nvim_open_win(overlay_buf, false, _create_overlay_config(w))
          vim.wo[overlay].winblend = M.options.nc_blend_percent
          overlays[#overlays + 1] = overlay
        end
      end, M.options.delay_ms)
    end,
  })
end

return M
