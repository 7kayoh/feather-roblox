local MarketplaceService = game:GetService("MarketplaceService")
local Selection = game:GetService("Selection")
local Icons = require(script.Icons)
local Matcher = require(script.Matcher)
local Stylesheet = require(script.Stylesheet)
local WidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	false,
	200,
	300,
	200,
	300
)
local Widget = plugin:CreateDockWidgetPluginGui("Feathers", WidgetInfo)
local Toolbar = plugin:CreateToolbar("Feather icons")
local Trigger = Toolbar:CreateButton("Toggle Window", "Toggles the icon picker window", "rbxassetid://6521417285")
local matchObject = {}
local UI
local Search
local List

local function applyThemeToIcon(Icon: instance)
	local Theme = Stylesheet[settings().Studio.Theme.Name]
	Icon.Background.BackgroundColor3 = Theme.Accent
	Icon.Background.Cover.BackgroundColor3 = Theme.Elevated
	Icon.Container.Image.ImageColor3 = Theme.Icon
end

local function applyTheme()
	local Theme = Stylesheet[settings().Studio.Theme.Name]
	UI.BackgroundColor3 = Theme.Background
	Search.PlaceholderColor3 = Theme.Placeholder
	Search.TextColor3 = Theme.Text
	Search.Parent.Parent.Background.BackgroundColor3 = Theme.Accent
	Search.Parent.Parent.Background.Cover.BackgroundColor3 = Theme.Elevated
	UI.ScrollBarImageColor3 = Theme.ScrollBar
	applyThemeToIcon(script.Icon)
	for i,v in pairs(List:GetChildren()) do
		if v:IsA("Frame") then
			applyThemeToIcon(v)
		end
	end
end

local function init()
	UI = script.Parent.UI:Clone()
	Search = UI.Search.Container.TextBox
	List = UI.List
	applyTheme()
	for i,v in pairs(Icons) do
		coroutine.wrap(function()
			local Info = MarketplaceService:GetProductInfo(tonumber(table.pack(string.gsub(v, "http://www.roblox.com/asset/%?id=", ""))[1]), Enum.InfoType.Asset)
			local Icon = script.Icon:Clone()
			Icon.Name = string.gsub(Info.Name, "Images/", "")
			matchObject[#matchObject + 1] = Icon.Name
			Icon.Container.Image.Image = v
			
			Icon.Trigger.MouseEnter:Connect(function()
				Icon.Background.BackgroundColor3 = Stylesheet.PrimaryColor3
			end)
			
			Icon.Trigger.MouseLeave:Connect(function()
				Icon.Background.BackgroundColor3 = Stylesheet[settings().Studio.Theme.Name].Accent
			end)

			Icon.Trigger.MouseButton1Up:Connect(function()
				local object = Selection:Get()[1] 
				if object then
					local copy = Icon.Container.Image:Clone()
					copy.Name = Icon.Name
					copy.Size = UDim2.new(1, 0, 1, 0)
					copy.Position = UDim2.new(0, 0, 0, 0)
					copy.AnchorPoint = Vector2.new(0, 0)
					copy.Parent = object
				else
					warn("please select an object before putting an icon.")
				end
			end)

			Icon.Parent = List
		end)()
	end
	
	Search.Focused:Connect(function()
		Search.Parent.Parent.Background.BackgroundColor3 = Stylesheet.PrimaryColor3
	end)

	Search.FocusLost:Connect(function()
		Search.Parent.Parent.Background.BackgroundColor3 = Stylesheet[settings().Studio.Theme.Name].Accent
		local match
		local text = Search.Text
		for i,v in pairs(List:GetChildren()) do
			if v:IsA("Frame") then
				v.Visible = false
			end
		end

		if string.gsub(text, "%s", "") and string.len(string.gsub(text, "%s", "")) >= 1 then
			match = Matcher.new(matchObject, false, false)
			for i,v in pairs(match:match(text)) do
				List:FindFirstChild(v).Visible = true
			end
		else
			for i,v in pairs(List:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = true
				end
			end
		end
	end)

	List.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		UI.CanvasSize = UDim2.new(0, 0, 0, List.UIGridLayout.AbsoluteContentSize.Y + 114)
	end)
	
	Trigger.Click:Connect(function()
		Trigger:SetActive(not Widget.Enabled)
		Widget.Enabled = not Widget.Enabled
	end)
	
	Widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		Trigger:SetActive(Widget.Enabled)
	end)
	
	Widget.Title = "Feather icons picker"
	Trigger.ClickableWhenViewportHidden = true
	Widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Widget.ResetOnSpawn = false
	UI.Parent = Widget
end

init()

settings().Studio.ThemeChanged:Connect(applyTheme)