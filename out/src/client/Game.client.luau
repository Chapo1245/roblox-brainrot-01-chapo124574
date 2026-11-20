-- Game (client): boots the Bodega HUD and effects for the local player.
-- Waits for the server's Remotes folder, then hands control to the
-- HudController (cash, shop, base, quests, index, fuse) and the
-- EffectsController (event banners and toasts).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HudController = require(script.Parent.HudController)
local EffectsController = require(script.Parent.EffectsController)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

HudController.setup(remotes)
EffectsController.setup(remotes)
