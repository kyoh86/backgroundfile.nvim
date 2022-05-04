local M = {}

M.close_later_default_option = {
    force = true,
    timeout = 1000,
}

-- Get a closer to close the floatwin later
--
-- {*opts}  Dictionary of options optional:
--          - force (boolean) optional: behave like `:close!`
--            The last window of a buffer with unwritten changes can be closed.
--            The buffer will become hidden, even if 'hidden' is not set. defaults to true
--          - timeout (integer): Time in ms to wait before closing. defaults to 1000 (ms)
function M.close_later(opts)
    local options = vim.tbl_extend("keep", opts or {}, M.close_later_default_option)
    return function(win)
        vim.defer_fn(function()
            vim.api.nvim_win_close(win, options.force)
        end, opts.timeout)
    end
end

-- Get a closer to close the floatwin on autocmd
--
-- {event}  (string|array) The event or events to close
-- {opts}   Dictionary of autocommand options:
--          - pattern (string|array) optional: pattern or patterns to match against |autocmd-pattern|.
--          - buffer (integer) optional: buffer number for buffer local autocommands |autocmd-buflocal|.
--            Cannot be used with {pattern}.
--          - nested (boolean) optional: defaults to false. Run nested autocommands |autocmd-nested|.
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

M.open_default_option = {
    listed = true,
    closer = M.close_later(),
}

-- Open a file in background floatwin.
--
-- {path}   The path of the file to open.
-- {*opts}  Dictionary of options optional:
--          - listed (boolean) optional: sets 'buflisted'. defaults to true
--          - closer (function) optional: a Lua function to close the floatwin. They accept a window-ID.
--            defaults to backgroundfile.close_later()
function M.open(path, opts)
    local options = vim.tbl_extend("keep", opts or {}, M.open_default_option)

    -- open deps.ts in background (floatwin)
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
