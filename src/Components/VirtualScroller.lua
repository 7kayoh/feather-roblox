local Packages = script.Parent.Parent.Packages
local Util = script.Parent.Util

local Fusion = require(Packages.Fusion)
local themeProvider = require(Util.themeProvider)

local Compat = Fusion.Compat
local State = Fusion.State
local Computed = Fusion.Computed
local ComputedPairs = Fusion.ComputedPairs

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

local Spring = Fusion.Spring

--[[
see also:
- https://blog.logrocket.com/virtual-scrolling-core-principles-and-basic-implementation-in-react/
- https://github.com/WICG/virtual-scroller
--]]

-- Component
--[[
	props = {
		Visible, Size, Position = you know what these do
		ItemCount: state<number> = how many items are in the scroller
		ItemHeight: state<number> = how many pixels tall each item is
		RenderItem(index: number): function = Takes the index of what item it is, returns Instance(s) to mount in the list (aka a component with an index as the prop)
	}
]]

return function(props)
	local WindowSize = State(Vector2.new())
	local CanvasPosition = State(Vector2.new())

	local numItems = props.ItemCount
	local itemHeight = props.ItemHeight

	local Items = Computed(function()
		local canvasPos,windowSize,height = CanvasPosition:get(), WindowSize:get(), itemHeight:get()

		local minIndex = 0
		local maxIndex = -1
		if numItems:get() > 0 then
			minIndex = 1 + math.floor(canvasPos.y / height)
			maxIndex = math.ceil((canvasPos.y + windowSize.y) / height)
			-- Add extra on either side for seamless load
			minIndex = math.clamp(minIndex-1, 1, numItems:get())
			maxIndex = math.clamp(maxIndex+1, 1, numItems:get())
		end

		-- Dict for stable keys
		local items = table.create(maxIndex - minIndex + 1)
		for i = minIndex, maxIndex do
			items[i] = true
		end

		return items
	end)

	local fullCanvasSize = Computed(function()
		return numItems:get() * itemHeight:get()
	end)

	local Frame; Frame = New "ScrollingFrame" {
		ClipsDescendants = not props._debug,
		Visible = props.Visible == nil and true or props.Visible,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.new(),
		BorderSizePixel = props.BorderSizePixel or 0,
		BorderColor3 = Color3.fromRGB(10,10,13),
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		BackgroundTransparency = 1,
		ScrollBarImageColor3 = themeProvider:GetColor(Enum.StudioStyleGuideColor.ScrollBar, Enum.StudioStyleGuideModifier.Default),
		ScrollBarThickness = 12,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		CanvasSize = Computed(function()
			return UDim2.fromOffset(0, fullCanvasSize:get())
		end),

		[OnChange "AbsoluteWindowSize"] = function()
			WindowSize:set(Frame.AbsoluteWindowSize)
		end,

		[OnChange "CanvasPosition"] = function()
			-- Exit if the canvas hasn't moved enough to warrant rendering new items
			local distance = (CanvasPosition:get(false) - Frame.CanvasPosition).Magnitude
			local minimum = itemHeight:get(false)

			if distance < minimum then return end

			CanvasPosition:set(Frame.CanvasPosition)
		end,

		[Children] = {
			ComputedPairs(Items, function(i)
				return New "Frame" {
					Name = "Index_"..i,
					LayoutOrder = i,
					Size = Computed(function()
						return UDim2.new(1, 0, 0, itemHeight:get())
					end),
					Position = Computed(function()
						return UDim2.new(0, 0, 0, (i-1)*itemHeight:get())
					end),
					BackgroundTransparency = props._debug and 0.5 or 1,
					BackgroundColor3 = Color3.fromRGB(math.random(10,255), math.random(10,255), math.random(10,255)),

					[Children] = props.RenderItem(i),
				}
			end),
		},
	}

	return Frame
end
