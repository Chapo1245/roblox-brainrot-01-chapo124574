-- EventService (server): the Bodega's chaos on a timer.
-- Three events, each real in code with visible effects:
--  1. Health Inspector Raid: an inspector walks the conveyor and
--     confiscates brainrots, shooing players away.
--  2. Cart Stampede: runaway shopping carts race across the plaza and
--     knock players down.
--  3. Golden Hour: 60 seconds of double income and golden spawns.

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local DataService = require(script.Parent.DataService)
local WorldBuilder = require(script.Parent.WorldBuilder)
local BrainrotSpawner = require(script.Parent.BrainrotSpawner)

local EventService = {}

local remotes = nil
local world = nil

function EventService.setup(remotesFolder, worldTable)
	remotes = remotesFolder
	world = worldTable
end

local function banner(title, subtitle)
	local remote = remotes:FindFirstChild("EventBanner")
	if remote then
		remote:FireAllClients(title, subtitle)
	end
end

local function buildInspector()
	local model = Instance.new("Model")
	model.Name = "HealthInspector"
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 5, 2)
	body.Color = Color3.fromRGB(255, 255, 255)
	body.Anchored = true
	body.Position = Vector3.new(-50, 3.5, -20)
	body.Parent = model
	model.PrimaryPart = body
	local hat = Instance.new("Part")
	hat.Name = "Hat"
	hat.Size = Vector3.new(2, 1, 2)
	hat.Color = Color3.fromRGB(40, 40, 40)
	hat.Anchored = true
	hat.Position = Vector3.new(-50, 6.5, -20)
	hat.Parent = model
	local weld = Instance.new("Weld")
	weld.Part0 = body
	weld.Part1 = hat
	weld.C0 = body.CFrame:Inverse() * hat.CFrame
	weld.Parent = body
	model.Parent = world.folder
	return model
end

-- The inspector walks the belt; brainrots near him are confiscated and
-- players near him get shooed back toward the plaza.
function EventService.healthInspectorRaid()
	banner("HEALTH INSPECTOR RAID!", "Hide your brainrots! The inspector is coming!")
	local inspector = buildInspector()
	local startX = world.conveyor.startPos.X
	local endX = world.conveyor.endPos.X
	for x = startX, endX, 2 do
		local pos = Vector3.new(x, 3.5, -20)
		inspector:PivotTo(CFrame.new(pos))
		-- Confiscate nearby conveyor brainrots.
		for i = #DataService.Conveyor, 1, -1 do
			local inst = DataService.Conveyor[i]
			if inst and math.abs(inst.x - x) < 8 then
				BrainrotSpawner.removeFromConveyor(inst)
			end
		end
		-- Shoo nearby players back.
		for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - pos).Magnitude < 7 then
				root.CFrame = CFrame.new(root.Position + Vector3.new(0, 2, 14))
			end
		end
		task.wait(0.25)
	end
	inspector:Destroy()
	banner("Raid over!", "The inspector left. Restock the belt!")
end

local function buildCart()
	local model = Instance.new("Model")
	model.Name = "RunawayCart"
	local basket = Instance.new("Part")
	basket.Name = "Basket"
	basket.Size = Vector3.new(4, 2.5, 3)
	basket.Color = Color3.fromRGB(200, 200, 210)
	basket.Anchored = true
	basket.Parent = model
	model.PrimaryPart = basket
	for _, dz in ipairs({ -1.2, 1.2 }) do
		for _, dx in ipairs({ -1.4, 1.4 }) do
			local wheel = Instance.new("Part")
			wheel.Name = "Wheel"
			wheel.Size = Vector3.new(0.6, 1, 1)
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Color = Color3.fromRGB(30, 30, 30)
			wheel.Anchored = true
			wheel.Position = Vector3.new(dx, -1.2, dz)
			wheel.Parent = model
			local weld = Instance.new("Weld")
			weld.Part0 = basket
			weld.Part1 = wheel
			weld.C0 = basket.CFrame:Inverse() * wheel.CFrame
			weld.Parent = basket
		end
	end
	model.Parent = world.folder
	return model
end

-- Three carts race across the plaza; touching one knocks a player down.
function EventService.cartStampede()
	banner("CART STAMPEDE!", "Runaway carts! Get out of the way!")
	local carts = {}
	for i = 1, 3 do
		local cart = buildCart()
		local z = -8 + (i - 1) * 10
		cart:PivotTo(CFrame.new(Vector3.new(-55, 2.5, z)))
		table.insert(carts, { model = cart, z = z, x = -55 })
		local basket = cart.PrimaryPart
		basket.Touched:Connect(function(hit)
			local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Sit = true
				local root = hit.Parent:FindFirstChild("HumanoidRootPart")
				if root then
					root.CFrame = CFrame.new(root.Position + Vector3.new(6, 4, 0))
				end
			end
		end)
	end
	for step = 1, 60 do
		for _, cart in ipairs(carts) do
			cart.x = cart.x + 2
			cart.model:PivotTo(CFrame.new(Vector3.new(cart.x, 2.5, cart.z)))
		end
		task.wait(0.1)
	end
	for _, cart in ipairs(carts) do
		cart.model:Destroy()
	end
end

-- Golden Hour: double income for 60s and three golden spawns on the belt.
function EventService.goldenHour()
	banner("GOLDEN HOUR!", "Double income for 60 seconds!")
	DataService.GoldenHourUntil = os.time() + GameConfig.GOLDEN_HOUR_DURATION
	for _, mut in ipairs(Catalog.MUTATIONS) do
		if mut.name == "Golden" then
			for _ = 1, 3 do
				BrainrotSpawner.spawnBrainrot(mut)
			end
		end
	end
end

local EVENTS = { "raid", "stampede", "golden" }

function EventService.start()
	task.spawn(function()
		while true do
			task.wait(math.random(GameConfig.EVENT_INTERVAL_MIN, GameConfig.EVENT_INTERVAL_MAX))
			local pick = EVENTS[math.random(1, #EVENTS)]
			if pick == "raid" then
				EventService.healthInspectorRaid()
			elseif pick == "stampede" then
				EventService.cartStampede()
			else
				EventService.goldenHour()
			end
		end
	end)
end

return EventService
