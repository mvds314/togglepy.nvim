Can this be different per configuration?

# Copilot (b1483fda-8f4f-4cb7-b393-991e75df9759) ───

Yes, you can customize the `nvim-dap-ui` components and layouts to be different per configuration by dynamically adjusting the `dapui` setup or behavior based on the active configuration.

Here’s how you can achieve this:

### 1. **Use DAP Listeners to Detect the Active Configuration**
You can use `dap.listeners` to detect when a debugging session starts and check the active configuration. Based on the configuration, you can modify the `dapui` layout or decide which components to show.

For example:

```lua
local dap = require("dap")
local dapui = require("dapui")

-- Open specific layouts based on the configuration
dap.listeners.after.event_initialized["dapui_config"] = function()
    local config = dap.session().config
    if config.name == "Attach to ipdb (manual %run)" then
        -- Open DAP UI with specific components for this configuration
        dapui.open({ reset = true }) -- Reset ensures a clean state
    else
        -- Default behavior for other configurations
        dapui.open()
    end
end

-- Close DAP UI when debugging ends
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
```

### 2. **Dynamically Adjust Layouts**
If you want to dynamically adjust the layout (e.g., show different components for different configurations), you can modify the `dapui` setup dynamically before opening it:

```lua
dap.listeners.after.event_initialized["dapui_config"] = function()
    local config = dap.session().config
    if config.name == "Attach to ipdb (manual %run)" then
        dapui.setup({
            layouts = {
                {
                    elements = { "scopes", "watches" },
                    size = 40,
                    position = "left",
                },
                {
                    elements = { "repl" },
                    size = 10,
                    position = "bottom",
                },
            },
        })
    else
        dapui.setup({
            layouts = {
                {
                    elements = { "scopes", "breakpoints", "stacks" },
                    size = 40,
                    position = "left",
                },
                {
                    elements = { "repl", "console" },
                    size = 10,
                    position = "bottom",
                },
            },
        })
    end
    dapui.open()
end
```

### 3. **Per-Configuration Customization**
If you want to define specific layouts or components for each configuration, you can store them in a table and apply them dynamically:

```lua
local dapui = require("dapui")

local layouts_by_config = {
    ["Attach to ipdb (manual %run)"] = {
        layouts = {
            {
                elements = { "scopes", "watches" },
                size = 40,
                position = "left",
            },
            {
                elements = { "repl" },
                size = 10,
                position = "bottom",
            },
        },
    },
    default = {
        layouts = {
            {
                elements = { "scopes", "breakpoints", "stacks" },
                size = 40,
                position = "left",
            },
            {
                elements = { "repl", "console" },
                size = 10,
                position = "bottom",
            },
        },
    },
}

dap.listeners.after.event_initialized["dapui_config"] = function()
    local config = dap.session().config
    local layout = layouts_by_config[config.name] or layouts_by_config.default
    dapui.setup(layout)
    dapui.open()
end
```

### Summary
By using `dap.listeners` and dynamically adjusting the `dapui` setup, you can customize the components and layouts shown in `nvim-dap-ui` for each configuration. This allows you to tailor the debugging experience to the specific needs of each configuration.

I put some switching logic in place for the dapui config. What events should I use, I also want to put it back after debugging. How do I do that?

# Copilot (978bb6f5-9d4f-47a6-b3d4-82364ba97f78) ───

To implement switching logic for `dapui` configuration and ensure it reverts back after debugging, you can use the following `nvim-dap` events:

### Events to Use:
1. **`event_initialized`**: Triggered when a debugging session starts. Use this to apply your custom `dapui` configuration.
2. **`event_terminated`**: Triggered when the debugging session ends. Use this to revert the `dapui` configuration to its original state.
3. **`event_exited`**: Triggered when the debugging session exits. Also use this to revert the configuration.

### Implementation:
You can use `dap.listeners` to hook into these events and dynamically adjust the `dapui` configuration.

Here’s an example:

```lua
local dap = require("dap")
local dapui = require("dapui")

-- Save the original dapui configuration
local original_config = vim.deepcopy(require("dapui.config"))

-- Define custom configurations for specific debugging scenarios
local custom_configs = {
  ["Attach to ipdb (manual %run)"] = {
    layouts = {
      {
        elements = { "scopes", "watches" },
        size = 40,
        position = "left",
      },
      {
        elements = { "repl" },
        size = 10,
        position = "bottom",
      },
    },
  },
}

-- Listener for when debugging starts
dap.listeners.after.event_initialized["dapui_config"] = function()
  local config = dap.session().config
  local custom_config = custom_configs[config.name]
  if custom_config then
    dapui.setup(custom_config)
  end
  dapui.open()
end

-- Listener for when debugging ends
local function reset_dapui()
  dapui.setup(original_config)
  dapui.close()
end

dap.listeners.before.event_terminated["dapui_config"] = reset_dapui
dap.listeners.before.event_exited["dapui_config"] = reset_dapui
```

### Explanation:
1. **Save Original Configuration**: The `original_config` is saved using `vim.deepcopy` to ensure you can revert to the default state.
2. **Custom Configurations**: Define `custom_configs` for specific debugging scenarios.
3. **Apply Custom Configurations**: Use `event_initialized` to detect the start of a debugging session and apply the appropriate configuration.
4. **Revert to Original Configuration**: Use `event_terminated` and `event_exited` to revert the configuration and close `dapui` when debugging ends.

### Notes:
- Ensure `dapui.setup` is called with the correct configuration before opening or closing `dapui`.
- Use `vim.deepcopy` to avoid modifying the original configuration directly.
- Test the logic with different debugging configurations to ensure it behaves as expected.


