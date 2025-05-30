Config = {
	dominantHand = 1,
	sittingExperience = false,
	recoil = true,
	hapticFeedback = true,
	twoHandedAiming = true,
	virtualGunstock = false,
	scopeBrightnessAmplifier = 1.0,
	scopeDiameter = 0.03,
	scopeMagnifier = 0.6,
	scopeTextureSize = 1024,
	cylinderDepth = 0.00015,
	indoor = false,

	-- Gesture enable/disable settings
	gestures = {
		flashlight = true,
		primaryWeapon = true,
		secondaryWeapon = true,
		sidearmWeapon = true,
		meleeWeapon = true,
		boltAction = true,
		grenade = true,
		inventory = true,
		scanner = true,
		pda = true,
		reload = true,
		modeSwitch = true
	},
}

TwoHandedStateActive = false

local configFilePath = "settings.json"

-- Helper to get only config fields (exclude functions and internal fields)
local function get_config_fields(self)
	local t = {}
	for k, v in pairs(self) do
		if type(v) ~= "function" and string.sub(k, 1, 1) ~= "_" then
			t[k] = v
		end
	end
	return t
end

function Config:update_from_table(tbl)
	for k, v in pairs(tbl) do
		if self[k] ~= nil then
			if type(v) == "table" and type(self[k]) == "table" then
				-- Handle nested tables (like gestures)
				for nested_k, nested_v in pairs(v) do
					if self[k][nested_k] ~= nil then
						self[k][nested_k] = nested_v
					end
				end
			else
				self[k] = v
			end
		end
	end
end

function Config:load()
	local loaded = nil
	pcall(function()
		loaded = json.load_file(configFilePath)
	end)
	if loaded then
		self:update_from_table(loaded)
	end
end

function Config:save()
	local t = get_config_fields(self)
	pcall(function()
		json.dump_file(configFilePath, t, 4)
	end)
end

Config:load()
