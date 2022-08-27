local Packages = script.Parent.Parent.Packages
local Components = script.Parent

local Fusion = require(Packages.Fusion)
local Component = require(Components.Icon)

local New = Fusion.New
local State = Fusion.State
local Children = Fusion.Children

return function(target)
    local list = State({})

    local component = New "Frame" {
        BackgroundTransparency = 0.99,
        Size = UDim2.fromOffset(300, 200),
        Parent = target,

        [Children] = {
            New "UIListLayout" {
                FillDirection = Enum.FillDirection.Vertical,
            },

            Component {
                Text = "dummy-demo-icon {" .. 1 .. "}",
                Image = "rbxassetid://7733655834",
                LayoutOrder = 1,
                OnInvoke = function()
                    print(1)
                end,
            },

            Component {
                Text = "dummy-demo-icon {" .. 2 .. "}",
                Image = "rbxassetid://7733655834",
                LayoutOrder = 2,
                OnInvoke = function()
                    print(2)
                end,
            },

            Component {
                Text = "dummy-demo-icon {" .. 3 .. "}",
                Image = "rbxassetid://7733655834",
                LayoutOrder = 3,
                OnInvoke = function()
                    print(3)
                end,
            },
        },
    }
--[[
    for i = 1, 3 do
        local newList = list:get()
        table.insert(newList, Component {
            Text = "dummy-demo-icon {" .. i .. "}",
            Image = "rbxassetid://7733655834",
            LayoutOrder = i,
            OnInvoke = function()
                print(i)
            end,
        })
        list:set(newList)
    end--]]

    return function()
        component:Destroy()
    end
end