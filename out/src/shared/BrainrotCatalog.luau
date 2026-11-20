-- BrainrotCatalog (shared): the Bodega's cast, rarities and mutations.
-- Data only. Every system (spawner, shop, index, fuse) reads from here,
-- so the roster stays consistent across server and client.

local BrainrotCatalog = {}

-- Rarity ladder, cheapest first. `weight` is the conveyor spawn chance.
BrainrotCatalog.RARITIES = {
	{ name = "Common",    color = Color3.fromRGB(200, 200, 200), weight = 40 },
	{ name = "Rare",      color = Color3.fromRGB(80, 200, 90),   weight = 25 },
	{ name = "Epic",      color = Color3.fromRGB(70, 130, 255),  weight = 15 },
	{ name = "Legendary", color = Color3.fromRGB(170, 90, 230),  weight = 9 },
	{ name = "Mythic",    color = Color3.fromRGB(255, 120, 40),  weight = 5 },
	{ name = "Divine",    color = Color3.fromRGB(255, 210, 60),  weight = 3 },
	{ name = "Cosmic",    color = Color3.fromRGB(255, 70, 180),  weight = 1.5 },
	{ name = "Secret",    color = Color3.fromRGB(40, 40, 40),    weight = 1 },
	{ name = "Prismatic", color = Color3.fromRGB(120, 220, 255), weight = 0.5 },
}

-- Mutations roll on spawn (12% of brainrots). `mult` multiplies income.
BrainrotCatalog.MUTATIONS = {
	{ name = "Golden",  mult = 2,   color = Color3.fromRGB(255, 215, 0),   weight = 40 },
	{ name = "Spicy",   mult = 1.5, color = Color3.fromRGB(230, 60, 30),   weight = 25 },
	{ name = "Frozen",  mult = 1.5, color = Color3.fromRGB(160, 220, 255), weight = 15 },
	{ name = "Neon",    mult = 2.5, color = Color3.fromRGB(120, 255, 120), weight = 10 },
	{ name = "Shadow",  mult = 3,   color = Color3.fromRGB(90, 40, 140),   weight = 7 },
	{ name = "Diamond", mult = 5,   color = Color3.fromRGB(200, 245, 255), weight = 3 },
}

BrainrotCatalog.MUTATION_CHANCE = 0.12

-- The cast. Fields: id, name, rarity, income ($/s), price ($),
-- shape (Ball/Block/Cylinder/Wedge), size, color, accent, accessory, face, blurb.
-- Prices are ~20x income: a brainrot pays for itself in 20 seconds on its base.
BrainrotCatalog.BRAINROTS = {
	-- Common (9)
	{ id = "crumbly_carl", name = "Crumbly Carl", rarity = "Common", income = 5, price = 100, shape = "Block", size = Vector3.new(2, 1.6, 2), color = Color3.fromRGB(210, 170, 110), accent = Color3.fromRGB(150, 100, 50), accessory = "None", face = "Happy", blurb = "Fell off the bread truck. Still crumbs of hope." },
	{ id = "pea_pod_pete", name = "Pea Pod Pete", rarity = "Common", income = 8, price = 160, shape = "Cylinder", size = Vector3.new(1.4, 2.4, 1.4), color = Color3.fromRGB(110, 200, 80), accent = Color3.fromRGB(60, 140, 40), accessory = "Beanie", face = "Happy", blurb = "Three peas, one pod, zero regrets." },
	{ id = "pickle_pip", name = "Pickle Pip", rarity = "Common", income = 10, price = 200, shape = "Cylinder", size = Vector3.new(1.2, 2.2, 1.2), color = Color3.fromRGB(90, 160, 60), accent = Color3.fromRGB(140, 200, 90), accessory = "None", face = "Silly", blurb = "In a pickle about everything. Literally." },
	{ id = "mushroom_max", name = "Mushroom Max", rarity = "Common", income = 12, price = 240, shape = "Ball", size = Vector3.new(2, 2, 2), color = Color3.fromRGB(230, 90, 70), accent = Color3.fromRGB(255, 255, 255), accessory = "None", face = "Sleepy", blurb = "A fun guy. Do not eat him. He earns." },
	{ id = "salty_sam", name = "Salty Sam", rarity = "Common", income = 15, price = 300, shape = "Wedge", size = Vector3.new(2, 1.8, 2), color = Color3.fromRGB(200, 150, 80), accent = Color3.fromRGB(255, 255, 255), accessory = "Bandana", face = "Angry", blurb = "Salty about the price of salt." },
	{ id = "eggy_eddie", name = "Eggy Eddie", rarity = "Common", income = 18, price = 360, shape = "Ball", size = Vector3.new(1.8, 2.2, 1.8), color = Color3.fromRGB(255, 245, 220), accent = Color3.fromRGB(255, 200, 60), accessory = "None", face = "Wink", blurb = "Cracked under pressure. Still standing." },
	{ id = "jelly_jan", name = "Jelly Jan", rarity = "Common", income = 20, price = 400, shape = "Ball", size = Vector3.new(2, 1.6, 2), color = Color3.fromRGB(220, 80, 140), accent = Color3.fromRGB(255, 160, 200), accessory = "PartyHat", face = "Happy", blurb = "Wobbles to work every single day." },
	{ id = "noodle_ned", name = "Noodle Ned", rarity = "Common", income = 21, price = 420, shape = "Cylinder", size = Vector3.new(1.2, 2.6, 1.2), color = Color3.fromRGB(250, 220, 130), accent = Color3.fromRGB(200, 120, 40), accessory = "None", face = "Silly", blurb = "Allergic to forks. Eats with confidence." },
	{ id = "bean_boy_benny", name = "Bean Boy Benny", rarity = "Common", income = 24, price = 480, shape = "Ball", size = Vector3.new(1.8, 2, 1.8), color = Color3.fromRGB(190, 130, 70), accent = Color3.fromRGB(120, 80, 40), accessory = "Beanie", face = "Cool", blurb = "Spilled the beans. Now sells them." },
	{ id = "gravy_gus", name = "Gravy Gus", rarity = "Common", income = 25, price = 500, shape = "Cylinder", size = Vector3.new(1.6, 1.8, 1.6), color = Color3.fromRGB(150, 100, 50), accent = Color3.fromRGB(220, 180, 110), accessory = "None", face = "Happy", blurb = "Thick, rich, and always on top." },

	-- Rare (8)
	{ id = "banana_bandit", name = "Banana Bandit", rarity = "Rare", income = 35, price = 700, shape = "Ball", size = Vector3.new(1.6, 2.6, 1.6), color = Color3.fromRGB(255, 220, 40), accent = Color3.fromRGB(60, 60, 60), accessory = "Bandana", face = "Cool", blurb = "Steals potassium. Pays in cash." },
	{ id = "taco_titan", name = "Taco Titan", rarity = "Rare", income = 45, price = 900, shape = "Wedge", size = Vector3.new(2.4, 2, 2), color = Color3.fromRGB(240, 190, 80), accent = Color3.fromRGB(90, 180, 70), accessory = "None", face = "Angry", blurb = "Tuesdays fear him. So do Mondays." },
	{ id = "pizza_pete", name = "Pizza Pete", rarity = "Rare", income = 55, price = 1100, shape = "Cylinder", size = Vector3.new(2.4, 0.8, 2.4), color = Color3.fromRGB(250, 190, 90), accent = Color3.fromRGB(220, 60, 50), accessory = "ChefHat", face = "Happy", blurb = "Delivers himself in 30 minutes or less." },
	{ id = "donut_daisy", name = "Donut Daisy", rarity = "Rare", income = 60, price = 1200, shape = "Cylinder", size = Vector3.new(2.2, 1, 2.2), color = Color3.fromRGB(250, 170, 200), accent = Color3.fromRGB(255, 255, 255), accessory = "None", face = "Wink", blurb = "Hole hearted. Sprinkles included." },
	{ id = "sushi_sam", name = "Sushi Sam", rarity = "Rare", income = 65, price = 1300, shape = "Block", size = Vector3.new(2, 1.4, 2), color = Color3.fromRGB(255, 230, 200), accent = Color3.fromRGB(255, 120, 90), accessory = "Bandana", face = "Cool", blurb = "Raw talent. Wasabi temper." },
	{ id = "burrito_bob", name = "Burrito Bob", rarity = "Rare", income = 70, price = 1400, shape = "Cylinder", size = Vector3.new(1.8, 2.6, 1.8), color = Color3.fromRGB(220, 180, 110), accent = Color3.fromRGB(120, 180, 70), accessory = "Beanie", face = "Sleepy", blurb = "Wrapped tight. Unwraps fortunes." },
	{ id = "ketchup_king", name = "Ketchup King", rarity = "Rare", income = 75, price = 1500, shape = "Cylinder", size = Vector3.new(1.6, 2.4, 1.6), color = Color3.fromRGB(220, 40, 40), accent = Color3.fromRGB(255, 255, 255), accessory = "Crown", face = "Angry", blurb = "Rules the condiment aisle with an iron fist." },
	{ id = "popcorn_polly", name = "Popcorn Polly", rarity = "Rare", income = 80, price = 1600, shape = "Ball", size = Vector3.new(2, 2, 2), color = Color3.fromRGB(255, 245, 220), accent = Color3.fromRGB(250, 200, 60), accessory = "PartyHat", face = "Happy", blurb = "Pops off. Literally. Every movie night." },

	-- Epic (8)
	{ id = "pickle_pharaoh", name = "Pickle Pharaoh", rarity = "Epic", income = 110, price = 2200, shape = "Block", size = Vector3.new(2, 2.6, 2), color = Color3.fromRGB(80, 150, 50), accent = Color3.fromRGB(255, 210, 60), accessory = "Crown", face = "Cool", blurb = "Entombed in brine for 3,000 years. Worth it." },
	{ id = "ramen_ronin", name = "Ramen Ronin", rarity = "Epic", income = 140, price = 2800, shape = "Cylinder", size = Vector3.new(2, 2.4, 2), color = Color3.fromRGB(250, 220, 130), accent = Color3.fromRGB(200, 60, 40), accessory = "Bandana", face = "Angry", blurb = "A masterless bowl seeking broth and glory." },
	{ id = "waffle_wizard", name = "Waffle Wizard", rarity = "Epic", income = 170, price = 3400, shape = "Block", size = Vector3.new(2.2, 1.2, 2.2), color = Color3.fromRGB(210, 150, 80), accent = Color3.fromRGB(255, 220, 140), accessory = "TopHat", face = "Wink", blurb = "Casts syrup. Never misses." },
	{ id = "mango_maverick", name = "Mango Maverick", rarity = "Epic", income = 190, price = 3800, shape = "Ball", size = Vector3.new(2, 2.2, 2), color = Color3.fromRGB(255, 180, 40), accent = Color3.fromRGB(255, 90, 60), accessory = "Sunglasses", face = "Cool", blurb = "Sweet on the outside. Rebel within." },
	{ id = "avocado_ace", name = "Avocado Ace", rarity = "Epic", income = 200, price = 4000, shape = "Ball", size = Vector3.new(2, 2.4, 2), color = Color3.fromRGB(110, 170, 70), accent = Color3.fromRGB(220, 200, 110), accessory = "Sunglasses", face = "Cool", blurb = "Ripe for exactly four minutes a year." },
	{ id = "cupcake_cassie", name = "Cupcake Cassie", rarity = "Epic", income = 220, price = 4400, shape = "Cylinder", size = Vector3.new(1.8, 2.2, 1.8), color = Color3.fromRGB(250, 180, 220), accent = Color3.fromRGB(255, 255, 255), accessory = "PartyHat", face = "Happy", blurb = "Frosting first. Questions later." },
	{ id = "boba_baron", name = "Boba Baron", rarity = "Epic", income = 240, price = 4800, shape = "Ball", size = Vector3.new(2.2, 2.2, 2.2), color = Color3.fromRGB(200, 150, 100), accent = Color3.fromRGB(60, 40, 30), accessory = "TopHat", face = "Wink", blurb = "Pearls of wisdom. Tapioca of terror." },
	{ id = "chili_champion", name = "Chili Champion", rarity = "Epic", income = 250, price = 5000, shape = "Wedge", size = Vector3.new(2, 2.2, 2), color = Color3.fromRGB(230, 50, 30), accent = Color3.fromRGB(60, 180, 60), accessory = "Bandana", face = "Angry", blurb = "Won the cook-off. Burned the judges." },

	-- Legendary (7)
	{ id = "golden_gouda", name = "Golden Gouda", rarity = "Legendary", income = 350, price = 7000, shape = "Cylinder", size = Vector3.new(2.4, 1.6, 2.4), color = Color3.fromRGB(255, 210, 60), accent = Color3.fromRGB(255, 255, 255), accessory = "Crown", face = "Cool", blurb = "Aged 100 years. Still not sorry." },
	{ id = "truffle_tsar", name = "Truffle Tsar", rarity = "Legendary", income = 420, price = 8400, shape = "Ball", size = Vector3.new(2.2, 2, 2.2), color = Color3.fromRGB(90, 60, 40), accent = Color3.fromRGB(200, 170, 120), accessory = "TopHat", face = "Cool", blurb = "Smells like money. Tastes like power." },
	{ id = "caviar_count", name = "Caviar Count", rarity = "Legendary", income = 500, price = 10000, shape = "Ball", size = Vector3.new(1.8, 1.8, 1.8), color = Color3.fromRGB(40, 40, 50), accent = Color3.fromRGB(255, 210, 60), accessory = "TopHat", face = "Wink", blurb = "Tiny eggs. Enormous ego." },
	{ id = "saffron_sultan", name = "Saffron Sultan", rarity = "Legendary", income = 580, price = 11600, shape = "Wedge", size = Vector3.new(2.2, 2.4, 2.2), color = Color3.fromRGB(255, 160, 30), accent = Color3.fromRGB(180, 40, 80), accessory = "Crown", face = "Angry", blurb = "Worth more than gold, gram for gram." },
	{ id = "foie_gras_phantom", name = "Foie Gras Phantom", rarity = "Legendary", income = 620, price = 12400, shape = "Block", size = Vector3.new(2, 2, 2), color = Color3.fromRGB(220, 190, 150), accent = Color3.fromRGB(255, 255, 255), accessory = "None", face = "Sleepy", blurb = "Haunts the fine-dining aisle." },
	{ id = "wagyu_warlord", name = "Wagyu Warlord", rarity = "Legendary", income = 650, price = 13000, shape = "Block", size = Vector3.new(2.4, 2.2, 2.4), color = Color3.fromRGB(200, 90, 90), accent = Color3.fromRGB(255, 255, 255), accessory = "Bandana", face = "Angry", blurb = "Marbled like a general's map." },
	{ id = "lobster_lord", name = "Lobster Lord", rarity = "Legendary", income = 700, price = 14000, shape = "Wedge", size = Vector3.new(2.4, 2, 2.4), color = Color3.fromRGB(230, 60, 40), accent = Color3.fromRGB(255, 255, 255), accessory = "Crown", face = "Cool", blurb = "Pinches pennies. And fingers." },

	-- Mythic (5)
	{ id = "dragonfruit_duke", name = "Dragonfruit Duke", rarity = "Mythic", income = 1000, price = 20000, shape = "Ball", size = Vector3.new(2.2, 2.4, 2.2), color = Color3.fromRGB(230, 60, 120), accent = Color3.fromRGB(140, 220, 90), accessory = "Crown", face = "Cool", blurb = "Breathes fire. Tastes like kiwi." },
	{ id = "unicorn_udon", name = "Unicorn Udon", rarity = "Mythic", income = 1300, price = 26000, shape = "Cylinder", size = Vector3.new(1.8, 2.6, 1.8), color = Color3.fromRGB(255, 255, 255), accent = Color3.fromRGB(255, 120, 200), accessory = "PartyHat", face = "Happy", blurb = "One horn. Infinite noodles." },
	{ id = "phoenix_pepper", name = "Phoenix Pepper", rarity = "Mythic", income = 1600, price = 32000, shape = "Wedge", size = Vector3.new(2, 2.4, 2), color = Color3.fromRGB(255, 100, 30), accent = Color3.fromRGB(255, 220, 60), accessory = "None", face = "Angry", blurb = "Burns twice. Rises spicier." },
	{ id = "mooncake_monarch", name = "Mooncake Monarch", rarity = "Mythic", income = 1800, price = 36000, shape = "Cylinder", size = Vector3.new(2.4, 1.2, 2.4), color = Color3.fromRGB(200, 140, 60), accent = Color3.fromRGB(255, 220, 140), accessory = "Crown", face = "Sleepy", blurb = "Rules the harvest moon. And the bakery." },
	{ id = "wasabi_warlock", name = "Wasabi Warlock", rarity = "Mythic", income = 2000, price = 40000, shape = "Ball", size = Vector3.new(2, 2.2, 2), color = Color3.fromRGB(90, 200, 90), accent = Color3.fromRGB(255, 255, 255), accessory = "TopHat", face = "Angry", blurb = "One sniff clears sinuses and souls." },

	-- Divine (4)
	{ id = "celestial_croissant", name = "Celestial Croissant", rarity = "Divine", income = 2800, price = 56000, shape = "Wedge", size = Vector3.new(2.4, 2, 2.4), color = Color3.fromRGB(255, 220, 140), accent = Color3.fromRGB(255, 255, 255), accessory = "TopHat", face = "Wink", blurb = "Baked in the heavens. Flaky by design." },
	{ id = "ambrosia_apple", name = "Ambrosia Apple", rarity = "Divine", income = 3500, price = 70000, shape = "Ball", size = Vector3.new(2.2, 2.4, 2.2), color = Color3.fromRGB(255, 60, 60), accent = Color3.fromRGB(255, 215, 0), accessory = "Crown", face = "Happy", blurb = "One bite and the gods tip their hats." },
	{ id = "starfruit_saint", name = "Starfruit Saint", rarity = "Divine", income = 4500, price = 90000, shape = "Wedge", size = Vector3.new(2.4, 2.2, 2.4), color = Color3.fromRGB(255, 220, 80), accent = Color3.fromRGB(255, 255, 255), accessory = "Crown", face = "Cool", blurb = "Blesses every stall it passes." },
	{ id = "holy_honeycomb", name = "Holy Honeycomb", rarity = "Divine", income = 6000, price = 120000, shape = "Block", size = Vector3.new(2.2, 2, 2.2), color = Color3.fromRGB(255, 190, 40), accent = Color3.fromRGB(255, 240, 160), accessory = "TopHat", face = "Happy", blurb = "The bees pray to it. So do accountants." },

	-- Cosmic (3)
	{ id = "nebula_nacho", name = "Nebula Nacho", rarity = "Cosmic", income = 9000, price = 180000, shape = "Wedge", size = Vector3.new(2.4, 1.6, 2.4), color = Color3.fromRGB(150, 80, 255), accent = Color3.fromRGB(255, 120, 200), accessory = "Crown", face = "Silly", blurb = "Cheese from a collapsing star." },
	{ id = "quasar_quiche", name = "Quasar Quiche", rarity = "Cosmic", income = 13000, price = 260000, shape = "Cylinder", size = Vector3.new(2.4, 1.2, 2.4), color = Color3.fromRGB(120, 200, 255), accent = Color3.fromRGB(255, 255, 255), accessory = "TopHat", face = "Cool", blurb = "Spins at light speed. Serves at brunch." },
	{ id = "supernova_sorbet", name = "Supernova Sorbet", rarity = "Cosmic", income = 18000, price = 360000, shape = "Ball", size = Vector3.new(2.2, 2.2, 2.2), color = Color3.fromRGB(255, 120, 220), accent = Color3.fromRGB(160, 240, 255), accessory = "Crown", face = "Wink", blurb = "Exploded once. Still the coolest dessert." },

	-- Secret (2)
	{ id = "forbidden_fruit", name = "The Forbidden Fruit", rarity = "Secret", income = 30000, price = 600000, shape = "Ball", size = Vector3.new(2.4, 2.6, 2.4), color = Color3.fromRGB(180, 30, 60), accent = Color3.fromRGB(255, 215, 0), accessory = "Crown", face = "Angry", blurb = "Do not eat. Do not ask. Do buy." },
	{ id = "grandmas_secret_recipe", name = "Grandma's Secret Recipe", rarity = "Secret", income = 50000, price = 1000000, shape = "Block", size = Vector3.new(2.2, 2.4, 2.2), color = Color3.fromRGB(240, 220, 180), accent = Color3.fromRGB(200, 60, 60), accessory = "ChefHat", face = "Happy", blurb = "She will never tell. It earns forever." },

	-- Prismatic (1)
	{ id = "prismatic_pineapple", name = "The Prismatic Pineapple", rarity = "Prismatic", income = 100000, price = 2000000, shape = "Cylinder", size = Vector3.new(2.4, 3, 2.4), color = Color3.fromRGB(255, 210, 60), accent = Color3.fromRGB(120, 220, 255), accessory = "Crown", face = "Cool", blurb = "Every color. Every dollar. One pineapple." },
}

-- Lookups, built once.
local byId = {}
local byRarity = {}
for _, def in ipairs(BrainrotCatalog.BRAINROTS) do
	byId[def.id] = def
	byRarity[def.rarity] = byRarity[def.rarity] or {}
	table.insert(byRarity[def.rarity], def)
end
BrainrotCatalog.byId = byId
BrainrotCatalog.byRarity = byRarity

function BrainrotCatalog.getById(id)
	return byId[id]
end

function BrainrotCatalog.rarityColor(rarityName)
	for _, r in ipairs(BrainrotCatalog.RARITIES) do
		if r.name == rarityName then
			return r.color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

function BrainrotCatalog.rarityIndex(rarityName)
	for i, r in ipairs(BrainrotCatalog.RARITIES) do
		if r.name == rarityName then
			return i
		end
	end
	return 1
end

function BrainrotCatalog.nextRarity(rarityName)
	local idx = BrainrotCatalog.rarityIndex(rarityName)
	return BrainrotCatalog.RARITIES[math.min(idx + 1, #BrainrotCatalog.RARITIES)].name
end

-- Weighted roll over a {name, weight} style table. Returns the picked entry.
local function rollWeighted(list)
	local total = 0
	for _, entry in ipairs(list) do
		total = total + entry.weight
	end
	local roll = math.random() * total
	for _, entry in ipairs(list) do
		roll = roll - entry.weight
		if roll <= 0 then
			return entry
		end
	end
	return list[1]
end

function BrainrotCatalog.rollRarity()
	return rollWeighted(BrainrotCatalog.RARITIES).name
end

function BrainrotCatalog.rollMutation()
	if math.random() > BrainrotCatalog.MUTATION_CHANCE then
		return nil
	end
	return rollWeighted(BrainrotCatalog.MUTATIONS)
end

-- Rolls one brainrot definition: rarity first, then a random member of it.
function BrainrotCatalog.rollBrainrot()
	local rarity = BrainrotCatalog.rollRarity()
	local pool = byRarity[rarity]
	return pool[math.random(1, #pool)]
end

-- Final income of a brainrot instance: base x mutation x rebirth bonus.
function BrainrotCatalog.incomeFor(def, mutation, rebirthTier)
	local mult = 1
	if mutation then
		mult = mult * mutation.mult
	end
	mult = mult * (1 + 0.25 * (rebirthTier or 0))
	return math.floor(def.income * mult)
end

return BrainrotCatalog
