local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    EquipDelay = 2, -- Delay to switch To Tribal Overlord
    RebirthDelay = 0.1, -- [ Default]
    ThreadCount = 10 -- [ Strength Gain Speed ]
}

local PackRebirth = {}
PackRebirth.__index = PackRebirth

function PackRebirth.new(tab)
    local self = setmetatable({}, PackRebirth)
    self.tab = tab
    self.Enabled = false
    self.AutoRebirthEnabled = false
    self.EquipDelay = Config.EquipDelay
    self.RebirthDelay = Config.RebirthDelay
    self.ThreadCount = Config.ThreadCount
    self.thread = nil

    local section = self.tab:AddSection("Auto Rebirth (Swift → Tribal)")

    self.Toggle = section:AddToggle("PackRebirthToggle", {
        Title = "Auto Rebirth (Swift & Tribal)",
        Description = "Automatically rebirths using Swift Samurai and Tribal Overlord pets.",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:TogglePackRebirth(state)
    end)

    return self
end

function PackRebirth:getPetsByName(name)
    local player = Players.LocalPlayer
    local pets = {}
    local uniqueFolder = player:FindFirstChild("petsFolder") and player.petsFolder:FindFirstChild("Unique")
    if uniqueFolder then
        for _, pet in ipairs(uniqueFolder:GetChildren()) do
            if pet.Name:match(name) then
                table.insert(pets, pet)
            end
        end
    end
    return pets
end

function PackRebirth:equipPet(pet)
    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
end

function PackRebirth:unequipPet(pet)
    ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
end

function PackRebirth:rebirth()
    ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
end

function PackRebirth:startLoop()
    self.Enabled = true
    self.thread = task.spawn(function()
        local player = Players.LocalPlayer
        while self.Enabled and self.AutoRebirthEnabled do
            local stats = player:WaitForChild("leaderstats")
            local strength = stats:WaitForChild("Strength")
            local rebirths = stats:WaitForChild("Rebirths")
            local requiredStrength = rebirths.Value * 2500

            local swifts = self:getPetsByName("Swift Samurai")
            local tribals = self:getPetsByName("Tribal Overlord")

            for _, pet in ipairs(swifts) do
                self:equipPet(pet)
            end

            local lastStrength = strength.Value
            local lastCheck = tick()

            while self.Enabled and self.AutoRebirthEnabled and strength.Value < requiredStrength do
                for i = 1, self.ThreadCount do
                    task.spawn(function()
                        ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    end)
                end
                task.wait(self.RebirthDelay)
                if tick() - lastCheck >= self.EquipDelay then
                    lastCheck = tick()
                    for _, pet in ipairs(tribals) do
                        self:equipPet(pet)
                    end
                end
            end

            task.wait(1)
        end
    end)
end

function PackRebirth:stopLoop()
    self.Enabled = false
    if self.thread then
        task.cancel(self.thread)
        self.thread = nil
    end
end

function PackRebirth:TogglePackRebirth(state)
    self.AutoRebirthEnabled = state
    if state then
        local player = Players.LocalPlayer
        local stats = player:WaitForChild("leaderstats")
        local rebirths = stats:WaitForChild("Rebirths")
        local swifts = self:getPetsByName("Swift Samurai")
        if #swifts == 0 then
            warn("No Swift Samurai pets found! Please equip at least one Swift Samurai pet.")
            self.Toggle:SetState(false)
            return
        end
        local tribals = self:getPetsByName("Tribal Overlord")
        if #tribals == 0 then
            warn("No Tribal Overlord pets found! Please equip at least one Tribal Overlord pet.")
            self.Toggle:SetState(false)
            return
        end
        if rebirths.Value <= 0 then
            warn("Rebirths must be greater than 0 to use Auto Rebirth.")
            self.Toggle:SetState(false)
            return
        end
        self:startLoop()
    else
        self:stopLoop()
    end
end

return PackRebirth
