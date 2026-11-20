-- HudController (client): the whole ScreenGui over the 3D market.
-- Top bar (cash / income / rebirth), conveyor shop list, base panel,
-- and toggleable panels for quests, the index book and the Fuse-O-Matic.
-- Every number on screen comes from the server's StateSync snapshot.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage.Shared.BrainrotCatalog)

local HudController = {}

local screenGui = nil
local cashLabel = nil
local incomeLabel = nil
local rebirthLabel = nil
local goldenLabel = nil
local lockButton = nil
local conveyorList = nil
local baseList = nil
local questsPanel = nil
local questsList = nil
local indexPanel = nil
local indexList = nil
local fusePanel = nil
local fuseList = nil
local fuseButton = nil

local remotes = nil
local state = nil
local selectedFuse = {} -- uids picked for the fuse machine

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

local function makeButton(parent, text, size, position, color)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

local function makePanel(name, size, position)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.Size = size
	panel.Position = position
	panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	panel.BackgroundTransparency = 0.15
	panel.Parent = screenGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel
	return panel
end

local function formatMoney(amount)
	if amount >= 1000000 then
		return string.format("$%.2fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(math.floor(amount))
	end
end

-- Renders the conveyor rows: name, rarity, $/s, price, BUY button.
local function renderConveyor()
	for _, child in ipairs(conveyorList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not state then
		return
	end
	for _, item in ipairs(state.conveyor) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		row.Parent = conveyorList
		local nameLabel = makeLabel(row, item.name, UDim2.new(0.45, 0, 1, 0), Catalog.rarityColor(item.rarity), true)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		local info = "$" .. item.income .. "/s"
		if item.mutation then
			info = item.mutation .. " " .. info
		end
		makeLabel(row, info, UDim2.new(0.25, 0, 1, 0), Color3.fromRGB(120, 255, 120), false).Position = UDim2.new(0.45, 0, 0, 0)
		local buy = makeButton(row, formatMoney(item.price), UDim2.new(0.26, 0, 0.8, 0), UDim2.new(0.72, 0, 0.1, 0), Color3.fromRGB(60, 180, 80))
		buy.MouseButton1Click:Connect(function()
			remotes.BuyBrainrot:FireServer(item.uid)
		end)
	end
end

-- Renders the 8 base slots: brainrot name + income, or "Empty".
local function renderBase()
	for _, child in ipairs(baseList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not state then
		return
	end
	for i = 1, 8 do
		local slot = state.slots[i]
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		row.Parent = baseList
		makeLabel(row, "Slot " .. i, UDim2.new(0.2, 0, 1, 0), Color3.fromRGB(255, 255, 255), true).TextXAlignment = Enum.TextXAlignment.Left
		if slot then
			local label = makeLabel(row, slot.name .. "  $" .. slot.income .. "/s", UDim2.new(0.5, 0, 1, 0), Catalog.rarityColor(slot.rarity), false)
			label.Position = UDim2.new(0.2, 0, 0, 0)
			label.TextXAlignment = Enum.TextXAlignment.Left
			local sell = makeButton(row, "SELL", UDim2.new(0.24, 0, 0.8, 0), UDim2.new(0.74, 0, 0.1, 0), Color3.fromRGB(200, 80, 80))
			sell.MouseButton1Click:Connect(function()
				remotes.SellBrainrot:FireServer(slot.uid)
			end)
		else
			makeLabel(row, "Empty", UDim2.new(0.5, 0, 1, 0), Color3.fromRGB(150, 150, 150), false).Position = UDim2.new(0.2, 0, 0, 0)
		end
	end
end

-- Renders the quest list with progress and CLAIM buttons.
local function renderQuests()
	for _, child in ipairs(questsList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not state then
		return
	end
	for _, quest in ipairs(state.quests) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		row.Parent = questsList
		local label = makeLabel(row, quest.name .. ": " .. quest.desc, UDim2.new(0.55, 0, 1, 0), Color3.fromRGB(255, 255, 255), false)
		label.TextXAlignment = Enum.TextXAlignment.Left
		makeLabel(row, quest.progress .. "/" .. quest.target, UDim2.new(0.18, 0, 1, 0), Color3.fromRGB(255, 220, 100), true).Position = UDim2.new(0.55, 0, 0, 0)
		if quest.claimed then
			makeLabel(row, "DONE", UDim2.new(0.24, 0, 1, 0), Color3.fromRGB(120, 255, 120), true).Position = UDim2.new(0.74, 0, 0, 0)
		elseif quest.progress >= quest.target then
			local claim = makeButton(row, "CLAIM $" .. quest.reward, UDim2.new(0.24, 0, 0.8, 0), UDim2.new(0.74, 0, 0.1, 0), Color3.fromRGB(60, 180, 80))
			claim.MouseButton1Click:Connect(function()
				remotes.ClaimQuest:FireServer(quest.id)
			end)
		else
			makeLabel(row, "$" .. quest.reward, UDim2.new(0.24, 0, 1, 0), Color3.fromRGB(150, 150, 150), false).Position = UDim2.new(0.74, 0, 0, 0)
		end
	end
end

-- Renders the index book: all 48 brainrots, discovered ones in color.
local function renderIndex()
	for _, child in ipairs(indexList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not state then
		return
	end
	local discovered = {}
	for _, slot in ipairs(state.slots) do
		if slot then
			discovered[slot.defId] = true
		end
	end
	for _, def in ipairs(Catalog.BRAINROTS) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = discovered[def.id] and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(45, 45, 55)
		row.Parent = indexList
		local nameColor = discovered[def.id] and Catalog.rarityColor(def.rarity) or Color3.fromRGB(120, 120, 120)
		local label = makeLabel(row, def.name, UDim2.new(0.4, 0, 1, 0), nameColor, true)
		label.TextXAlignment = Enum.TextXAlignment.Left
		makeLabel(row, def.rarity, UDim2.new(0.25, 0, 1, 0), nameColor, false).Position = UDim2.new(0.4, 0, 0, 0)
		makeLabel(row, "$" .. def.income .. "/s", UDim2.new(0.3, 0, 1, 0), Color3.fromRGB(120, 255, 120), false).Position = UDim2.new(0.68, 0, 0, 0)
	end
end

-- Renders the fuse picker: click your base brainrots to pick 3.
local function renderFuse()
	for _, child in ipairs(fuseList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not state then
		return
	end
	for _, slot in ipairs(state.slots) do
		if slot then
			local picked = false
			for _, uid in ipairs(selectedFuse) do
				if uid == slot.uid then
					picked = true
				end
			end
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 40)
			row.BackgroundColor3 = picked and Color3.fromRGB(90, 60, 140) or Color3.fromRGB(50, 50, 65)
			row.Parent = fuseList
			local label = makeLabel(row, slot.name .. " (" .. slot.rarity .. ")", UDim2.new(0.65, 0, 1, 0), Catalog.rarityColor(slot.rarity), false)
			label.TextXAlignment = Enum.TextXAlignment.Left
			local pick = makeButton(row, picked and "PICKED" or "PICK", UDim2.new(0.3, 0, 0.8, 0), UDim2.new(0.68, 0, 0.1, 0), picked and Color3.fromRGB(150, 80, 220) or Color3.fromRGB(80, 80, 100))
			pick.MouseButton1Click:Connect(function()
				local found = nil
				for i, uid in ipairs(selectedFuse) do
					if uid == slot.uid then
						found = i
					end
				end
				if found then
					table.remove(selectedFuse, found)
				elseif #selectedFuse < 3 then
					table.insert(selectedFuse, slot.uid)
				end
				renderFuse()
			end)
		end
	end
	fuseButton.Text = "FUSE (" .. #selectedFuse .. "/3)"
end

local function refreshAll()
	if not state then
		return
	end
	cashLabel.Text = formatMoney(state.cash)
	incomeLabel.Text = "+" .. formatMoney(state.income) .. "/s"
	rebirthLabel.Text = "Rebirth " .. state.rebirthTier
	goldenLabel.Visible = state.goldenHour
	if os.time() < state.lockUntil then
		lockButton.Text = "LOCKED " .. (state.lockUntil - os.time()) .. "s"
	else
		lockButton.Text = "LOCK BASE"
	end
	renderConveyor()
	renderBase()
	renderQuests()
	renderIndex()
	renderFuse()
end

function HudController.setup(remotesFolder)
	remotes = remotesFolder
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BodegaHud"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Top bar.
	local topBar = makePanel("TopBar", UDim2.new(1, 0, 0, 48), UDim2.new(0, 0, 0, 0))
	cashLabel = makeLabel(topBar, "$150", UDim2.new(0.2, 0, 1, 0), Color3.fromRGB(120, 255, 120), true)
	cashLabel.Position = UDim2.new(0.02, 0, 0, 0)
	incomeLabel = makeLabel(topBar, "+$0/s", UDim2.new(0.2, 0, 1, 0), Color3.fromRGB(255, 220, 100), true)
	incomeLabel.Position = UDim2.new(0.24, 0, 0, 0)
	rebirthLabel = makeLabel(topBar, "Rebirth 0", UDim2.new(0.2, 0, 1, 0), Color3.fromRGB(255, 140, 255), true)
	rebirthLabel.Position = UDim2.new(0.46, 0, 0, 0)
	goldenLabel = makeLabel(topBar, "GOLDEN HOUR x2!", UDim2.new(0.2, 0, 1, 0), Color3.fromRGB(255, 210, 60), true)
	goldenLabel.Position = UDim2.new(0.68, 0, 0, 0)
	goldenLabel.Visible = false

	-- Conveyor shop, left.
	local shopPanel = makePanel("Shop", UDim2.new(0.28, 0, 0.5, 0), UDim2.new(0.01, 0, 0.1, 0))
	makeLabel(shopPanel, "ON THE BELT - CLICK TO BUY", UDim2.new(1, 0, 0, 30), Color3.fromRGB(255, 210, 60), true)
	conveyorList = Instance.new("ScrollingFrame")
	conveyorList.Size = UDim2.new(1, -8, 1, -38)
	conveyorList.Position = UDim2.new(0, 4, 0, 34)
	conveyorList.BackgroundTransparency = 1
	conveyorList.ScrollBarThickness = 4
	conveyorList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	conveyorList.Parent = shopPanel
	local shopLayout = Instance.new("UIListLayout")
	shopLayout.SortOrder = Enum.SortOrder.LayoutOrder
	shopLayout.Padding = UDim.new(0, 4)
	shopLayout.Parent = conveyorList

	-- Base panel, right.
	local basePanel = makePanel("Base", UDim2.new(0.28, 0, 0.5, 0), UDim2.new(0.71, 0, 0.1, 0))
	makeLabel(basePanel, "YOUR BASE", UDim2.new(1, 0, 0, 30), Color3.fromRGB(255, 210, 60), true)
	baseList = Instance.new("ScrollingFrame")
	baseList.Size = UDim2.new(1, -8, 1, -38)
	baseList.Position = UDim2.new(0, 4, 0, 34)
	baseList.BackgroundTransparency = 1
	baseList.ScrollBarThickness = 4
	baseList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	baseList.Parent = basePanel
	local baseLayout = Instance.new("UIListLayout")
	baseLayout.SortOrder = Enum.SortOrder.LayoutOrder
	baseLayout.Padding = UDim.new(0, 4)
	baseLayout.Parent = baseList

	-- Bottom buttons.
	local bottomBar = makePanel("BottomBar", UDim2.new(0.5, 0, 0, 52), UDim2.new(0.25, 0, 0.9, 0))
	lockButton = makeButton(bottomBar, "LOCK BASE", UDim2.new(0.18, 0, 0.8, 0), UDim2.new(0.01, 0, 0.1, 0), Color3.fromRGB(80, 120, 220))
	lockButton.MouseButton1Click:Connect(function()
		remotes.ToggleLock:FireServer()
	end)
	local fuseToggle = makeButton(bottomBar, "FUSE", UDim2.new(0.18, 0, 0.8, 0), UDim2.new(0.21, 0, 0.1, 0), Color3.fromRGB(150, 80, 220))
	local questToggle = makeButton(bottomBar, "QUESTS", UDim2.new(0.18, 0, 0.8, 0), UDim2.new(0.41, 0, 0.1, 0), Color3.fromRGB(220, 160, 60))
	local indexToggle = makeButton(bottomBar, "INDEX", UDim2.new(0.18, 0, 0.8, 0), UDim2.new(0.61, 0, 0.1, 0), Color3.fromRGB(60, 180, 120))
	local rebirthButton = makeButton(bottomBar, "REBIRTH", UDim2.new(0.18, 0, 0.8, 0), UDim2.new(0.81, 0, 0.1, 0), Color3.fromRGB(220, 60, 120))
	rebirthButton.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)

	-- Quests panel (hidden by default).
	questsPanel = makePanel("Quests", UDim2.new(0.4, 0, 0.45, 0), UDim2.new(0.3, 0, 0.25, 0))
	questsPanel.Visible = false
	makeLabel(questsPanel, "DAILY QUESTS", UDim2.new(1, 0, 0, 30), Color3.fromRGB(255, 210, 60), true)
	questsList = Instance.new("ScrollingFrame")
	questsList.Size = UDim2.new(1, -8, 1, -38)
	questsList.Position = UDim2.new(0, 4, 0, 34)
	questsList.BackgroundTransparency = 1
	questsList.ScrollBarThickness = 4
	questsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	questsList.Parent = questsPanel
	local questLayout = Instance.new("UIListLayout")
	questLayout.SortOrder = Enum.SortOrder.LayoutOrder
	questLayout.Padding = UDim.new(0, 4)
	questLayout.Parent = questsList
	questToggle.MouseButton1Click:Connect(function()
		questsPanel.Visible = not questsPanel.Visible
	end)

	-- Index panel (hidden by default).
	indexPanel = makePanel("Index", UDim2.new(0.4, 0, 0.5, 0), UDim2.new(0.3, 0, 0.22, 0))
	indexPanel.Visible = false
	makeLabel(indexPanel, "BRAINROT INDEX - 48 TO FIND", UDim2.new(1, 0, 0, 30), Color3.fromRGB(255, 210, 60), true)
	indexList = Instance.new("ScrollingFrame")
	indexList.Size = UDim2.new(1, -8, 1, -38)
	indexList.Position = UDim2.new(0, 4, 0, 34)
	indexList.BackgroundTransparency = 1
	indexList.ScrollBarThickness = 4
	indexList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	indexList.Parent = indexPanel
	local indexLayout = Instance.new("UIListLayout")
	indexLayout.SortOrder = Enum.SortOrder.LayoutOrder
	indexLayout.Padding = UDim.new(0, 2)
	indexLayout.Parent = indexList
	indexToggle.MouseButton1Click:Connect(function()
		indexPanel.Visible = not indexPanel.Visible
	end)

	-- Fuse panel (hidden by default).
	fusePanel = makePanel("Fuse", UDim2.new(0.4, 0, 0.45, 0), UDim2.new(0.3, 0, 0.25, 0))
	fusePanel.Visible = false
	makeLabel(fusePanel, "FUSE-O-MATIC: 3 SAME RARITY = 1 HIGHER", UDim2.new(1, 0, 0, 30), Color3.fromRGB(200, 140, 255), true)
	fuseList = Instance.new("ScrollingFrame")
	fuseList.Size = UDim2.new(1, -8, 1, -80)
	fuseList.Position = UDim2.new(0, 4, 0, 34)
	fuseList.BackgroundTransparency = 1
	fuseList.ScrollBarThickness = 4
	fuseList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	fuseList.Parent = fusePanel
	local fuseLayout = Instance.new("UIListLayout")
	fuseLayout.SortOrder = Enum.SortOrder.LayoutOrder
	fuseLayout.Padding = UDim.new(0, 4)
	fuseLayout.Parent = fuseList
	fuseButton = makeButton(fusePanel, "FUSE (0/3)", UDim2.new(0.5, 0, 0, 36), UDim2.new(0.25, 0, 1, -42), Color3.fromRGB(150, 80, 220))
	fuseButton.MouseButton1Click:Connect(function()
		if #selectedFuse == 3 then
			remotes.FuseBrainrots:FireServer(selectedFuse[1], selectedFuse[2], selectedFuse[3])
			selectedFuse = {}
		end
	end)
	fuseToggle.MouseButton1Click:Connect(function()
		fusePanel.Visible = not fusePanel.Visible
	end)

	remotes:WaitForChild("StateSync").OnClientEvent:Connect(function(snapshot)
		state = snapshot
		refreshAll()
	end)
end

return HudController
