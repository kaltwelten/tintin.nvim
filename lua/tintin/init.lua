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

local _loaded = false

local M = {}

function M.setup()
  if _loaded then return end
  local overlay_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'tintin', { buf = overlay_buf })
  local overlays = {}
  vim.api.nvim_create_autocmd('WinResized', {
    group = vim.api.nvim_create_augroup('tintin', { clear = true }),
    callback = function()
      for i, o in ipairs(overlays) do
        vim.api.nvim_win_close(o, false)
        overlays[i] = nil
      end
      vim.schedule(function()
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          if w ~= vim.api.nvim_get_current_win() and vim.fn.win_gettype(w) == '' then
            local buftype = vim.api.nvim_get_option_value('buftype', { buf = vim.api.nvim_win_get_buf(w) })
            if buftype == '' or buftype == 'help' then
              local overlay = vim.api.nvim_open_win(overlay_buf, false, _create_overlay_config(w))
              vim.api.nvim_set_option_value('winblend', 50, { win = overlay })
              overlays[#overlays + 1] = overlay
            end
          end
        end
      end)
    end,
  })
  _loaded = true
end

return M
