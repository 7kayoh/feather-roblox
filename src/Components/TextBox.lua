local Packages = script.Parent.Parent.Packages
local Util = script.Parent.Util

local Fusion = require(Packages.Fusion)
local themeProvider = require(Util.themeProvider)

local New = Fusion.New
local State = Fusion.State
local Computed = Fusion.Computed
local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent

local PLACEHOLDER_TEXT_COLOR = Color3.fromRGB(102, 102, 102)

return function(params)
    local isFocused = State(false)
    local isHovered = State(false)
    local textBox = New "TextBox" {
        Font = Enum.Font.SourceSans,
        PlaceholderColor3 = PLACEHOLDER_TEXT_COLOR,
        PlaceholderText = "Find an icon...",
        Text = params.Text,
        TextColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Default),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(1, -18, 1, 0),

        [OnEvent "Focused"] = function()
            isFocused:set(true)
        end,

        [OnEvent "FocusLost"] = function()
            isFocused:set(false)
        end,

        [OnChange "Text"] = function(value)
            params.Text:set(value)
        end,
    }

    return New "Frame" {
        AnchorPoint = params.AnchorPoint,
        BackgroundColor3 = Computed(function()
            return themeProvider:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, if isFocused:get() then Enum.StudioStyleGuideModifier.Selected else Enum.StudioStyleGuideModifier.Default):get()
        end),
        Position = params.Position,
        Size = Computed(function()
            return UDim2.new(params.Width:get(), UDim.new(0, 24))
        end),
    
        [Children] = {
            New "UIStroke" {
                Color = Computed(function()
                    return themeProvider:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, if isFocused:get() then Enum.StudioStyleGuideModifier.Selected else Enum.StudioStyleGuideModifier.Default):get()
                end),
                Thickness = 1
            },

            textBox,
    
            New "TextButton" {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,

                [OnEvent "MouseButton1Click"] = function()
                    if textBox:IsFocused() then
                        return
                    end
                    textBox:CaptureFocus()
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
            },

            New "Frame" {
                BackgroundColor3 = Computed(function()
                    return themeProvider:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, if isHovered:get() then Enum.StudioStyleGuideModifier.Hover else Enum.StudioStyleGuideModifier.Default):get()
                end),
                BackgroundTransparency = Computed(function()
                    return if isHovered:get() then 0 else 1
                end),
                BorderSizePixel = 0,
                ZIndex = 0,
                Size = UDim2.fromScale(1, 1),
            }
        }
    }
end