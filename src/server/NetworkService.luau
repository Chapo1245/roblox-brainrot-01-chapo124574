-- NetworkService (server): owns every RemoteEvent/RemoteFunction.
-- Created once at boot in ReplicatedStorage/Remotes; the client finds them
-- with WaitForChild. No remotes are defined anywhere else.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkService = {}

local REMOTE_NAMES = {
	"BuyBrainrot", -- client -> server (uid)
	"StealBrainrot", -- client -> server (ownerUserId, slotIndex)
	"ToggleLock", -- client -> server ()
	"FuseBrainrots", -- client -> server (uid, uid, uid)
	"ClaimQuest", -- client -> server (questId)
	"Rebirth", -- client -> server ()
	"SellBrainrot", -- client -> server (uid)
	"StateSync", -- server -> client (snapshot table)
	"EventBanner", -- server -> client (title, subtitle)
	"Notify", -- server -> client (message text)
}

function NetworkService.setup()
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in ipairs(REMOTE_NAMES) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
	return folder
end

function NetworkService.get(folder, name)
	return folder:WaitForChild(name)
end

return NetworkService
