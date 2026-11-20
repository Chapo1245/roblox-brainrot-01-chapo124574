-- InteractionService (server): what happens when a player clicks a brainrot.
-- Conveyor brainrot -> buy it. Someone else's base brainrot -> steal it.
-- Your own base brainrot -> a hint. One ClickDetector per model, wired
-- once at spawn; the dispatch reads the instance's live `where` field.

local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local BaseService = require(script.Parent.BaseService)

local InteractionService = {}

function InteractionService.attach(model, inst)
	local body = model.PrimaryPart
	if not body then
		return
	end
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 32
	click.Parent = body
	click.MouseClick:Connect(function(player)
		if inst.where == "conveyor" then
			local ok, msg = EconomyService.buyBrainrot(player, inst.uid)
			if not ok then
				EconomyService.notify(player, msg)
			end
		elseif inst.where == "base" then
			if inst.owner == player then
				EconomyService.notify(player, "That's yours! Sell it from your base panel.")
			else
				local ok, msg = BaseService.trySteal(player, inst.owner.UserId, inst.slot)
				if not ok then
					EconomyService.notify(player, msg)
				else
					EconomyService.notify(player, msg)
				end
			end
		end
	end)
end

return InteractionService
