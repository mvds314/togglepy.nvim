# togglepy.nvim

A REPL for Python based on toggleterm.nvim.

## Introduction

`togglepy.nvim` is a Neovim plugin that provides a REPL-based workflow for Python, similar to the scientific programming development environments of MATLAB, R, and Python's Spyder IDE.

TODO: insert GIF showing the workflow

### Features

- Open an IPython REPL within Neovim (based on `toggleterm.nvim`) and easily switch to it.
- Send lines or visual selections to the REPL.
- Debug Python code with `ipdb`/`pdb` in the REPL.
- Keep track of the debugging session in Neovim (using `nvim-dap.nvim`, `nvim-dap-ui.nvim`, and the `ipdab` Python package).
- Switch between virtual environments (using `telescope.nvim`).

A key part of the workflow is toggling the REPL with `<C-\>` using `toggleterm.nvim`. Hence the name `togglepy.nvim`.

### Why?

Python is ideal for scientific programming with well-structured code. It is interpreted like MATLAB and R, but it also supports advanced programming features such as classes, modules, and unit testing.

Neovim excels at workflows for compiled languages like C, C++, and Java. However, scientific programming with Python often requires an interactive REPL for debugging, inspecting data structures, and iterating on code. `togglepy.nvim` integrates the REPL into your development workflow, making it an essential tool for Python development in Neovim.

## Setup

### Prerequisites

- Python with `ipython` and `ipdab` packages installed.
- Neovim with the following plugins:
  - `nvim-telescope/telescope.nvim`
  - `nvim-lua/plenary.nvim`
  - `nvim-treesitter/nvim-treesitter`
  - `akinsho/toggleterm.nvim`
  - `mfussenegger/nvim-dap`
  - `rcarriga/nvim-dap-ui`

### Installation

Set up with `lazy.nvim`:

```lua
require("lazy").setup({
  'user/togglepy.nvim',
  requires = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'akinsho/toggleterm.nvim',
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
  },
  config = function()
    local opts = { ipdab = { host = "localhost", port = 9000 },
                   repl = { terminal_direction = "vertical" },
                   keymaps = { window_navigation = true,
                               send_key = "<F9>",
                               run_key = "<F5>",
                               next_key = "<F10>",
                               step_in_key = "<F11>",
                               step_out_key = "<F12>",},
        }
    require('togglepy').setup(opts)
  end,
})
```

The `opts` table can contains options for the different components of the plugin, which in turn contain the fields:

- `host`: IP address where the DAP server should listen (default: `"localhost"`).
- `port`: Port where the DAP server should listen (default: `9000`).
- `terminal_direction`: Direction of the REPL terminal, either `"float"` or `"vertical"` (default: `"vertical"`).
- `window_navigation`: Whether to set up window navigation keymaps, i.e., '<C-w>h/j/k/l' for terminal mode
- `send_key`: Key to send the current line or visual selection to the REPL (default: `<F9>`).
- `run_key`: Key to run the current Python file in the REPL or to continue in debug mode (default: `<F5>`).
- `next_key`: Key to step over in the debugger (default: `<F10>`).
- `step_in_key`: Key to step into in the debugger (default: `<F11>`).
- `step_out_key`: Key to step out/return in the debugger (default: `<F12>`).

### Recommended Configuration

Set up the `<C-\>` key mapping to toggle the REPL with `toggleterm.nvim`:

```lua
require("lazy").setup({
  "akinsho/toggleterm.nvim",
  lazy = true,
  opts = {
    size = 99,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = false,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
  },
  keys = {
    { "<C-\\>", mode = { "i", "t", "n" }, "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    { "<C-\\>", mode = "n", function() vim.cmd("ToggleTerm " .. vim.v.count1) end, desc = "Toggle terminal <count>", expr = false },
  },
  cmd = "ToggleTerm",
})
```

## How It Works

When you open a Python file and use the `:TogglePyTerminal` command, a special `toggleterm` terminal is created that starts `ipython` by default. This terminal is remembered by `togglepy.nvim` until its buffer is closed and is used for all REPL interactions.

### Commands

- `:TogglePyTerminal`: Creates or toggles the IPython REPL terminal.
- `:TogglePyRunFile`: Saves all buffers, changes the working directory in the REPL to the file's location, and runs the current Python file using `%run -i your_script.py`.
- `:TogglePyPickEnv`: Searches for Python environments on your system and allows you to pick one with `telescope.nvim`.
- `:TogglePyClearEnvs`: Clears the list of found Python virtual environments.
- `:TogglePySwitchTerminalDirection`: Switches the REPL terminal direction between `float` and `vertical`.

### Key Bindings

- `<C-\>`: Toggle the REPL terminal.
- `<F9>`: Send the current line or visual selection to the REPL.
- `<F5>`: Run the current Python file in the REPL.
- `<F10>`: Step over in the debugger.
- `<F11>`: Step into in the debugger.
- `<S-F11>`: Step out/return in the debugger.

### Debugging

Use the `ipdab` Python package for seamless debugging integration. Replace `import pdb; pdb.set_trace()` with `import ipdab; ipdab.set_trace()`. This enables debugging with an arrow in Neovim to track your code execution.

### Autoreload

Enable the `autoreload` extension in IPython for automatic module reloading:

```python
# ~/.ipython/profile_default/startup/mystartup.py
get_ipython().run_line_magic("load_ext", "autoreload")
get_ipython().run_line_magic("autoreload", "2")
```

## Limitations

- Autoreload may not work in all cases, requiring a REPL restart.
- Debugging sessions are partially controlled by the Debug Adapter Protocol (DAP) due to the blocking nature of `pdb`/`ipdb`.

## Conclusion

`togglepy.nvim` integrates Python's REPL and debugging capabilities into Neovim, making it an essential tool for scientific programming and interactive development workflows.

## Development

Contributions are welcome! Please open issues or pull requests on the GitHub repository.

### TODOs

- [ ] Add tests
- [ ] Fix bug, when term exits ipy_term is not cleared
- [ ] Create a mapping for debugging Python files with ipython
- [ ] Consider to add switching environment logic to Telescope as a plugin
- [ ] Put finding environments in a subprocess to avoid blocking Neovim
- [ ] Make logic for multiple ipython terminals
