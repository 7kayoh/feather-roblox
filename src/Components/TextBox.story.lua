local Packages = script.Parent.Parent.Packages
local Components = script.Parent

local Fusion = require(Packages.Fusion)
local Component = require(Components.TextBox)

local New = Fusion.New
local State = Fusion.State
local Children = Fusion.Children

return function(target)
    local textState = State("")
    local component = New "Frame" {
        BackgroundTransparency = 0.99,
        Size = UDim2.fromOffset(300, 200),
        Parent = target,

        [Children] = {
            Component {
                Text = textState,
                AnchorPoint = State(Vector2.new(0.5, 0.5)),
                Position = State(UDim2.fromScale(0.5, 0.5)),
                Width = State(UDim.new(0.7, 0))
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -14),
                Size = UDim2.fromOffset(0, 14),
                TextWrapped = false,
                TextXAlignment = Enum.TextXAlignment.Center,
                Text = textState,
            }
        }
    }

    return function()
        component:Destroy()
    end
end