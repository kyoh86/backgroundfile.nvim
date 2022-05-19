local M = {}

---@type {force: boolean, timeout: integer}
local close_later_default_option = {
    force = true,
    timeout = 1000,
}

---@alias backgroundfile.Closer fun(win:window) @Close the window

---Get a closer to close the floatwin later
---
---@param opts {force: boolean, timeout: integer}? @Dictionary of options optional:
---         - force (boolean) optional: behave like `:close!`
---           The last window of a buffer with unwritten changes can be closed.
---           The buffer will become hidden, even if 'hidden' is not set. defaults to true
---         - timeout (integer): Time in ms to wait before closing. defaults to 1000 (ms)
---@return backgroundfile.Closer
function M.close_later(opts)
    local options = vim.tbl_extend("keep", opts or {}, close_later_default_option)
    return function(win)
        vim.defer_fn(function()
            vim.api.nvim_win_close(win, options.force)
        end, options.timeout)
    end
end

---Get a closer to close the floatwin on autocmd
---
---@param event  string|array @The event or events to close
---@param opts  {pattern: string, buffer: integer, nested: boolean}  @Dictionary of autocommand options:
---         - pattern (string|array) optional: pattern or patterns to match against |autocmd-pattern|.
---         - buffer (integer) optional: buffer number for buffer local autocommands |autocmd-buflocal|.
---           Cannot be used with {pattern}.
---         - nested (boolean) optional: defaults to false. Run nested autocommands |autocmd-nested|.
---@return backgroundfile.Closer
function M.close_on_autocmd(event, opts)
    local options = vim.tbl_extend("keep", opts, {
        force = true,
        once = true,
    })
    return function(win)
        options.callback = function()
            vim.api.nvim_win_close(win, options.force)
        end
        vim.api.nvim_create_autocmd(event, options)
    end
end

---@type {listed: boolean, closer: backgroundfile.Closer}
local open_default_option = {
    listed = true,
    closer = M.close_later(),
}

---Open a file in background floatwin.
---
---@param path string @The path of the file to open.
---@param opts {listed: boolean, closer: backgroundfile.Closer}? @Dictionary of options optional:
---         - listed (boolean) optional: sets 'buflisted'. defaults to true
---         - closer (function) optional: a Lua function to close the floatwin. They accept a window-ID.
---           defaults to backgroundfile.close_later()
---@return window
function M.open(path, opts)
    local options = vim.tbl_extend("keep", opts or {}, open_default_option)

    -- open deps.ts in background (floatwin)
    --- @type window
    local win = vim.api.nvim_open_win(vim.api.nvim_create_buf(options.listed, false), false, {
        relative = "editor",
        width = 1,
        height = 1,
        row = -1,
        col = -1,
        focusable = false,
    })
    vim.fn.win_execute(win, "edit! " .. vim.fn.fnameescape(path))

    -- close floatwin
    options.closer(win)

    return win
end

return M
