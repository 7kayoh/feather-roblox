local storybook = require(script.Parent["Plugin.story"]) -- hehe lazy me !!!
local dockWidgetPluginInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    true,
    200,
    300,
    200,
    300
)

local function init()
    local widget = plugin:CreateDockWidgetPluginGui("LucideIcons", dockWidgetPluginInfo)
    widget.Title = "Icon Picker"
    widget.Name = "feather-icon-picker-plugin"
    widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local component = storybook(widget)

    local widgetToolbar = plugin:CreateToolbar("Lucide Icons")
    local widgetAction = plugin:CreatePluginAction("toggleFeather-v2", "Feather Icon Picker", "Toggles the icon picker", "rbxassetid://7073055533", true)
    local widgetTrigger = widgetToolbar:CreateButton("toggleFeather-v2", "Shows/hides the icon picker", "rbxassetid://7073055533", "Picker")
    widgetTrigger.ClickableWhenViewportHidden = true

    widgetTrigger.Click:Connect(function()
        widget.Enabled = not widget.Enabled
        widgetTrigger:SetActive(widget.Enabled)
    end)

    widgetAction.Triggered:Connect(function()
        widget.Enabled = not widget.Enabled
        widgetTrigger:SetActive(widget.Enabled)
    end)

    widget:BindToClose(function()
        widgetTrigger:SetActive(false)
        widget.Enabled = false
    end)

    plugin.Unloading:Connect(function()
        component()
	end)
end

init()