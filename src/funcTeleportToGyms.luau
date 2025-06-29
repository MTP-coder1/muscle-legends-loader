local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Config = {
    Gyms = {
        ["Beach"] = {
            part = "legendsBeachGradientPart",
            offset = Vector3.new(0, 3, 0)
        },
        ["Tiny Island"] = {
            part = "areaTeleportParts",
            subpart = "beachToTinyIsland",
            offset = Vector3.new(0, 3, 0)
        },
        ["Frozen Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToFrostGym",
            offset = Vector3.new(0, 3, 0)
        },
        ["Mythical Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToMysticalGym",
            offset = Vector3.new(0, 3, 0)
        },
        ["Eternal Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToEternalGym",
            offset = Vector3.new(0, 3, 0)
        },
        ["Legends Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToLegendsGym",
            offset = Vector3.new(0, 3, 0)
        },
        ["Muscle King Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToMuscleKing",
            offset = Vector3.new(0, 3, 0)
        },
        ["Jungle Gym"] = {
            part = "areaTeleportParts",
            subpart = "beachToJungleGym",
            offset = Vector3.new(0, 3, 0)
        }
    }
}

local TeleportToGyms = {}
TeleportToGyms.__index = TeleportToGyms

function TeleportToGyms.new(tab)
    local self = setmetatable({}, TeleportToGyms)
    self.tab = tab
    self.selectedGym = nil

    local gymNames = {}
    for name, _ in pairs(Config.Gyms) do
        table.insert(gymNames, name)
    end

    table.sort(gymNames)

    local section = self.tab:AddSection("Teleport To Gyms")

    self.GymDropdown = section:AddDropdown("GymDropdown", {
        Title = "Select Gym",
        Values = gymNames,
        Multi = false,
        Default = nil
    })
    self.GymDropdown:OnChanged(function(value)
        self.selectedGym = value
    end)

    section:AddButton({
        Title = "Teleport to Selected Gym",
        Description = "Teleports you to the chosen GYM location.",
        Callback = function()
            self:TeleportToGym(self.selectedGym)
        end
    })

    return self
end

function TeleportToGyms:TeleportToGym(gymName)
    if not gymName then
        return
    end
    local gym = Config.Gyms[gymName]
    local character = Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not gym or not hrp then
        return
    end

    if gymName == "Beach" then
        local part = Workspace:FindFirstChild(gym.part)
        if part then
            hrp.CFrame = part.CFrame + gym.offset
        end
    else
        local areaParts = Workspace:FindFirstChild(gym.part)
        local subpart = areaParts and areaParts:FindFirstChild(gym.subpart)
        if subpart then
            hrp.CFrame = subpart.CFrame + gym.offset
        end
    end
end
