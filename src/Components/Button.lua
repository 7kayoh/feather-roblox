local Packages = script.Parent.Parent.Packages
local Util = script.Parent.Util

local Fusion = require(Packages.Fusion)
local themeProvider = require(Util.themeProvider)

local New = Fusion.New
local State = Fusion.State
local Computed = Fusion.Computed
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(params)
    local isPressed = State(false)
    local isHovered = State(false)

    return New "TextButton" {
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = params.AnchorPoint,
        BackgroundColor3 = Computed(function()
            local modifier = if params.Disabled:get()
                then Enum.StudioStyleGuideModifier.Disabled
                elseif isPressed:get()
                then Enum.StudioStyleGuideModifier.Pressed
                elseif isHovered:get() then Enum.StudioStyleGuideModifier.Hover
                else Enum.StudioStyleGuideModifier.Default
            return themeProvider:GetColor(Enum.StudioStyleGuideColor.Button, modifier):get()
        end),
        Position = params.Position,
        Size = UDim2.fromOffset(0, 24),
    
        [Children] = {
            New "UIStroke" {
                Color = Computed(function()
                    local modifier = if params.Disabled:get()
                        then Enum.StudioStyleGuideModifier.Disabled
                        elseif isPressed:get()
                        then Enum.StudioStyleGuideModifier.Pressed
                        elseif isHovered:get() then Enum.StudioStyleGuideModifier.Hover
                        else Enum.StudioStyleGuideModifier.Default
                    return themeProvider:GetColor(Enum.StudioStyleGuideColor.ButtonBorder, modifier):get()
                end),
                Thickness = 1
            },

            New "UIPadding" {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
            },

            New "TextLabel" {
                AutomaticSize = Enum.AutomaticSize.X,
                Font = Enum.Font.SourceSans,
                Text = params.Text,
                TextColor3 = Computed(function()
                    local modifier = if params.Disabled:get()
                        then Enum.StudioStyleGuideModifier.Disabled
                        elseif isPressed:get()
                        then Enum.StudioStyleGuideModifier.Pressed
                        elseif isHovered:get() then Enum.StudioStyleGuideModifier.Hover
                        else Enum.StudioStyleGuideModifier.Default
                    return themeProvider:GetColor(Enum.StudioStyleGuideColor.MainText, modifier):get()
                end),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
            }
        },

        [OnEvent "MouseButton1Down"] = function()
            isPressed:set(true)
        end,

        [OnEvent "MouseButton1Up"] = function()
            isPressed:set(false)
            if not params.Disabled:get() then
                params.OnInvoke()
            end
        end,

        [OnEvent "InputBegan"] = function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                isHovered:set(true)
            end
        end,

        [OnEvent "InputEnded"] = function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                isHovered:set(false)
            end
        end
    }
end