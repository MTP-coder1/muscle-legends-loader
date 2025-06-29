local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    EventFolder = "rEvents",
    EventName = "sellPetEvent",
    PetsFolder = "petsFolder"
}

local DeletePackPets = {}
DeletePackPets.__index = DeletePackPets

function DeletePackPets.new(tab)
    local self = setmetatable({}, DeletePackPets)
    self.Button = tab:AddButton({
        Title = "Delete All Pets",
        Description = "Deletes (sells) all pets.",
        Callback = function()
            local rEvents = ReplicatedStorage:WaitForChild(CONFIG.EventFolder)
            local sellPetEvent = rEvents:WaitForChild(CONFIG.EventName)
            local petsFolder = LocalPlayer:WaitForChild(CONFIG.PetsFolder)

            for _, rarityFolder in pairs(petsFolder:GetChildren()) do
                for _, pet in pairs(rarityFolder:GetChildren()) do
                    sellPetEvent:FireServer("sellPet", pet)
                end
            end
        end
    })

    return self
end

return
