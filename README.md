# This is alpha. It may be dropped without notice

# backgroundfile.nvim

A neovim lib-plugin to open a file in background (hidden floatwin).

## Functions

### `open({path}, {*opts})`

Open a file in background floatwin.

Parameters:

- `{path}`:   the path of the file to open.
- `{*opts}`:  dictionary of options optional:
    - `listed` (boolean) optional: sets 'buflisted'. defaults to true
    - `closer` (function) optional: a Lua function to close the floatwin. They accept a window-ID.
      defaults to backgroundfile.close_later()

Returns window-ID of the floatwin

### `close_on_autocmd({event}, {opts})`

Get a closer to close the floatwin on autocmd.

Parameters:
- `{event}`:  (string|array) The event or events to close
- `{opts}`:   Dictionary of autocommand options:
    - `pattern` (stringarray) optional: pattern or patterns to match against autocmd-pattern.
    - `buffer` (integer) optional: buffer number for buffer local autocommands autocmd-buflocal.
      Cannot be used with {pattern}.
    - `nested` (boolean) optional: defaults to false. Run nested autocommands autocmd-nested.

### `close_later({*opts})`

Get a closer to close the floatwin later.

Parameters:
- `{*opts}`  Dictionary of options optional:
    - `force` (boolean) optional: behave like `:close!`
      The last window of a buffer with unwritten changes can be closed.
      The buffer will become hidden, even if 'hidden' is not set. defaults to true
    - `timeout` (integer): Time in ms to wait before closing. defaults to 1000 (ms)

## Examples

Open `foo.txt` and close the window in 10,000 ms later.

```lua
local backgroundfile = require("backgroundfile")
backgroundfile.open("foo.txt", {
    closer = backgroundfile.close_later({
        timeout = 10000,
    }),
})
```

Open `/tmp/bar.txt` and close the window on `FooBar` User autocmd.

```lua
local backgroundfile = require("backgroundfile")
backgroundfile.open("/tmp/bar.txt", {
    closer = backgroundfile.close_on_autocmd("User", {
        pattern = "FooBar",
    }),
})
```
