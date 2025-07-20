local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    SpoofSpins = 9999, -- [ Default: 9999 ] -- Amount of spins to spoof
    SpoofPetCapacity = 99999, -- [ Default: 99999 ] -- Amount of pet capacity to spoof
    SpoofInventory = true -- [ Default: false ] -- Whether to spoof pet inventory
}

local SpoofItems = {}
SpoofItems.__index = SpoofItems

function SpoofItems.new(tab)
    local self = setmetatable({}, SpoofItems)
    self.tab = tab
    self.spoofing = false
    self._originalSpins = nil
    self._originalPetCapacity = nil
    self._originalPetValues = {}

    local section = self.tab:AddSection("Spoof Items")

    self.SpinsInput = section:AddInput("SpoofSpinsInput", {
        Title = "Spoof Spins",
        Default = tostring(Config.SpoofSpins),
        Placeholder = "Enter spin amount",
        Numeric = true,
        Finished = true,
        Callback = function(value)
            local num = tonumber(value)
            if num then
                Config.SpoofSpins = num
            end
        end
    })

    self.PetCapacityInput = section:AddInput("SpoofPetCapacityInput", {
        Title = "Spoof Pet Capacity",
        Default = tostring(Config.SpoofPetCapacity),
        Placeholder = "Enter pet capacity",
        Numeric = true,
        Finished = true,
        Callback = function(value)
            local num = tonumber(value)
            if num then
                Config.SpoofPetCapacity = num
            end
        end
    })

    self.Toggle = section:AddToggle("SpoofItemsToggle", {
        Title = "Enable Spoofing",
        Description = "Spoofs spins and pet inventory (visual only).",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleSpoof(state)
    end)

    return self
end

function SpoofItems:ToggleSpoof(state)
    self.spoofing = state
    if state then
        local spins = LocalPlayer:FindFirstChild("freeWheelSpins")
        if spins then
            self._originalSpins = self._originalSpins or spins.Value
            spins.Value = Config.SpoofSpins
        end
        local petCap = LocalPlayer:FindFirstChild("maxPetCapacity")
        if petCap then
            self._originalPetCapacity = self._originalPetCapacity or petCap.Value
            petCap.Value = Config.SpoofPetCapacity
        end
        if Config.SpoofInventory then
            local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
            if petsFolder then
                for _, pet in ipairs(petsFolder:GetDescendants()) do
                    if (pet:IsA("IntValue") or pet:IsA("NumberValue")) and not self._originalPetValues[pet] then
                        self._originalPetValues[pet] = pet.Value
                        pet.Value = 999
                    end
                end
            end
        end
    else
        local spins = LocalPlayer:FindFirstChild("freeWheelSpins")
        if spins and self._originalSpins then
            spins.Value = self._originalSpins
            self._originalSpins = nil
        end
        local petCap = LocalPlayer:FindFirstChild("maxPetCapacity")
        if petCap and self._originalPetCapacity then
            petCap.Value = self._originalPetCapacity
            self._originalPetCapacity = nil
        end
        if Config.SpoofInventory then
            for pet, originalValue in pairs(self._originalPetValues) do
                if pet and pet.Parent then
                    pet.Value = originalValue
                end
            end
            self._originalPetValues = {}
        end
    end
end

return SpoofItems
