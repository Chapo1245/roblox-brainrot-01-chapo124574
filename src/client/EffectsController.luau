-- EffectsController (client): event banners and toast notifications.
-- The server fires EventBanner for big moments and Notify for small ones.

local Players = game:GetService("Players")

local EffectsController = {}

local screenGui = nil
local bannerFrame = nil
local bannerTitle = nil
local bannerSubtitle = nil
local toastFrame = nil

local function makeLabel(parent, text, size, color, bold)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.Parent = parent
	return label
end

function EffectsController.setup(remotes)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BodegaEffects"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Big center banner for events.
	bannerFrame = Instance.new("Frame")
	bannerFrame.Size = UDim2.new(0.6, 0, 0.18, 0)
	bannerFrame.Position = UDim2.new(0.2, 0, 0.08, 0)
	bannerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	bannerFrame.BackgroundTransparency = 0.2
	bannerFrame.Visible = false
	bannerFrame.Parent = screenGui
	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 12)
	bannerCorner.Parent = bannerFrame
	bannerTitle = makeLabel(bannerFrame, "", UDim2.new(1, 0, 0.55, 0), Color3.fromRGB(255, 210, 60), true)
	bannerSubtitle = makeLabel(bannerFrame, "", UDim2.new(1, 0, 0.4, 0), Color3.fromRGB(255, 255, 255), false)
	bannerSubtitle.Position = UDim2.new(0, 0, 0.55, 0)

	-- Toast stack, bottom center.
	toastFrame = Instance.new("Frame")
	toastFrame.Size = UDim2.new(0.4, 0, 0.3, 0)
	toastFrame.Position = UDim2.new(0.3, 0, 0.62, 0)
	toastFrame.BackgroundTransparency = 1
	toastFrame.Parent = screenGui
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = toastFrame

	remotes:WaitForChild("EventBanner").OnClientEvent:Connect(function(title, subtitle)
		EffectsController.showBanner(title, subtitle)
	end)
	remotes:WaitForChild("Notify").OnClientEvent:Connect(function(message)
		EffectsController.toast(message)
	end)
end

function EffectsController.showBanner(title, subtitle)
	bannerTitle.Text = title
	bannerSubtitle.Text = subtitle
	bannerFrame.Visible = true
	task.delay(4, function()
		bannerFrame.Visible = false
	end)
end

function EffectsController.toast(message)
	local toast = Instance.new("TextLabel")
	toast.Text = message
	toast.Size = UDim2.new(1, 0, 0, 28)
	toast.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	toast.BackgroundTransparency = 0.3
	toast.TextColor3 = Color3.fromRGB(255, 255, 255)
	toast.TextScaled = true
	toast.Font = Enum.Font.Gotham
	toast.Parent = toastFrame
	task.delay(4, function()
		toast:Destroy()
	end)
end

return EffectsController
