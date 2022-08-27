local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Packages = script.Parent.Packages
local Components = script.Parent.Components
local Modules = script.Parent.Modules

local Matcher = require(Modules.matcher)
local Assets = require(Modules.asset)
local Fusion = require(Packages.Fusion)
local Icon = require(Components.Icon)
local VirtualScroller = require(Components.VirtualScroller)
local TextBox = require(Components.TextBox)
local Button = require(Components.Button)
local themeProvider = require(Components.Util.themeProvider)

local New = Fusion.New
local State = Fusion.State
local Children = Fusion.Children
local Compat = Fusion.Compat
local Computed = Fusion.Computed

local function getResult(query)
    local list = {}
    local candidates = {}
    for name, _ in (Assets.assets) do
        table.insert(list, name)
    end

    if query:gsub("%s", "") and query:gsub("%s", ""):len() >= 1 then
        local matchResult = Matcher.new(list, true, true):match(query)
        for _, name in (matchResult) do
            table.insert(candidates, {name, Assets.assets[name]})
        end
    else
        for _, name in list do
            table.insert(candidates, {name, Assets.assets[name]})
        end
        table.sort(candidates, function(a, b)
            return a[1]:byte() < b[1]:byte()
        end)
    end

    return candidates
end

local function apply(image)
    local currentSelection = Selection:Get()
    ChangeHistoryService:SetWaypoint("Before insertion/application of icon " .. image .. " to selections")
    for _, selectedObject in currentSelection do
        if selectedObject:IsA("ImageLabel") or selectedObject:IsA("ImageButton") then
            selectedObject.Image = image
        else
            New "ImageLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(50, 50),
                Image = image,
                Parent = selectedObject,
                [Children] = {
                    New "UIAspectRatioConstraint" {
                        AspectRatio = 1,
                    },
                },
            }
        end
    end
    ChangeHistoryService:SetWaypoint("After insertion/application of icon " .. image .. " to selections")
end

return function(target)
    local list = State(getResult(""))
    local textState = State("")
    local selectedIcon = State("")

    Compat(textState):onChange(function()
        list:set(getResult(textState:get()))
    end)

    local component = New "Frame" {
        BackgroundColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default),
        BorderColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default),
        BorderSizePixel = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -12, 1, -12),
        Parent = target,

        [Children] = {
            TextBox {
                Text = textState,
                Width = State(UDim.new(1, 0))
            },
            {
                VirtualScroller {
                    _debug = false,
        
                    Size = UDim2.new(1, 0, 1, - 70),
                    Position = UDim2.fromOffset(0, 30),
                    ItemHeight = State(25),
                    ItemCount = Computed(function()
                        return #list:get()
                    end),
                    RenderItem = function(i: number)
                        if list:get()[i] then
                            return Icon {
                                Name = list:get()[i][1],
                                Text = list:get()[i][1],
                                Image = list:get()[i][2],
                                SelectedIcon = selectedIcon,
                                LayoutOrder = i,
                                OnInvoke = function()
                                    selectedIcon:set(list:get()[i][2])
                                end,
                            }
                        end
                    end,
                },

                New "Frame" {
                    BackgroundColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default),
                    BorderColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
                    BorderSizePixel = 1,
                    Size = UDim2.new(1, 0, 1, -70),
                    Position = UDim2.fromOffset(0, 30),
                    ZIndex = 0,

                    [Children] = {
                        New "Frame" {
                            BackgroundColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground, Enum.StudioStyleGuideModifier.Default),
                            BorderColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default),
                            BorderSizePixel = 1,
                            AnchorPoint = Vector2.new(1, 0),
                            Size = UDim2.new(0, 12, 1, 0),
                            Position = UDim2.fromScale(1, 0),
                        }
                    }
                }
            },

            Button {
                Text = "Insert / Apply",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -8),
                Disabled = Computed(function()
                    return selectedIcon:get() == ""
                end),
                OnInvoke = function()
                    if selectedIcon:get() ~= "" then
                        apply(selectedIcon:get())
                    end
                end
            },

            New "TextLabel" {
                Text = "⚠️ Discontinued plugin. Use Lucide Icon Picker instead.",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -2),
                BackgroundTransparency = 1,
                TextColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.ErrorText, Enum.StudioStyleGuideModifier.Default),
                Font = Enum.Font.SourceSansBold,
                TextSize = 12,
            },
        },
    }

    return function()
        component:Destroy()
    end
end