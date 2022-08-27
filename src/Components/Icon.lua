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
    local isHovered = State(false)
    local isActive = Computed(function()
        return params.SelectedIcon:get() == params.Image
    end)
    local contentColor = Computed(function()
        local modifier = if isActive:get()
            then Enum.StudioStyleGuideModifier.Selected
            elseif isHovered:get() then Enum.StudioStyleGuideModifier.Hover
            else Enum.StudioStyleGuideModifier.Default
        return themeProvider:GetColor(Enum.StudioStyleGuideColor.MainText, modifier):get()
    end)

    return New "Frame" {
        BackgroundColor3 = Computed(function()
		    local modifier = if isActive:get()
                then Enum.StudioStyleGuideModifier.Selected
                elseif isHovered:get() then Enum.StudioStyleGuideModifier.Hover
                else Enum.StudioStyleGuideModifier.Default
            return themeProvider:GetColor(Enum.StudioStyleGuideColor.Button, modifier):get()
        end),
        BackgroundTransparency = Computed(function()
            return if isHovered:get() or isActive:get() then 0 else 1
        end),
        Name = params.Name,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = params.LayoutOrder,
        Visible = true,
    
        [Children] = {
            New "ImageLabel" {
                Image = params.Image,
                ImageColor3 = contentColor,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
            },

            New "TextLabel" {
                Size = UDim2.fromOffset(0, 18),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 32, 0.5, 0),
                Text = Computed(function()
                    return params.Name
                end),
                Font = Enum.Font.SourceSans,
                TextSize = 18,
                TextColor3 = contentColor,
                TextXAlignment = Enum.TextXAlignment.Left,
            },
    
            New "TextButton" {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,

                [OnEvent "MouseButton1Click"] = function()
                    params.OnInvoke()
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
                BackgroundColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.DiffFilePathBorder, Enum.StudioStyleGuideModifier.Default),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.fromScale(0, 1),
            }
        },
    }
end