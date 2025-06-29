local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    UniquePets = {
        "Wild Wizard", "Mighty Monster", "Swift Samurai", "Tribal Overlord",
        "Infernal Dragon", "Ultra Birdie", "Magic Butterfly",
        "Aether Spirit Bunny", "Cybernetic Showdown Dragon", "Darkstar Hunter",
        "Hank", "Gold Warrior", "Sky Hawk", "Cool Guy", "Larry",
        "Screaming Bones", "Muscle Sensei", "Neon Guardian"
    },
    EpicPets = {
        "Blue Pheonix", "Blue Firecaster", "Golden Pheonix", "Red Firecaster",
        "Green Firecaster", "White Pheonix", "Dark Legends Manticore",
        "Ultimate Supernova Pegasus", "Lightning Strike Phantom",
        "Mask Of Gold", "A. Gnatomy", "Sir Flame", "Masked Marksman",
        "Golden Viking"
    },
    RarePets = {
        "Crimson Falcon", "Purple Dragon", "Orange Pegasus", "Purple Falcon",
        "Red Dragon", "White Pegasus", "Frostwave Legends", "Penguin Phantom",
        "Genesis Dragon", "Eternal Strike", "Leviathan", "Green-Fly", "Ice Ice",
        "Slitherman", "Mr. Serious", "Boy Wonder"
    },
    AdvancedPets = {
        "Dark Vampy", "Dark Golem", "Green Butterfly", "Yellow Butterfly",
        "Alien Girl", "Smiley Chops"
    },
    BasicPets = {
        "Blue Birdie", "Orange Hedgehog", "Red Kitty", "Blue Bunny",
        "Silver Dog"
    },
    MaxEquip = 8
}

local ALL_PETS = {}
for _, list in pairs({
    Config.UniquePets, Config.EpicPets, Config.RarePets, Config.AdvancedPets,
    Config.BasicPets
}) do for _, pet in ipairs(list) do table.insert(ALL_PETS, pet) end end

local RARITY_MAP = {
    ["Unique"] = Config.UniquePets,
    ["Epic"] = Config.EpicPets,
    ["Rare"] = Config.RarePets,
    ["Advanced"] = Config.AdvancedPets,
    ["Basic"] = Config.BasicPets,
    ["All"] = ALL_PETS
}

local SwitchPets = {}
SwitchPets.__index = SwitchPets

function SwitchPets.new(tab)
    local self = setmetatable({}, SwitchPets)
    self.tab = tab
    self.selectedPet = Config.UniquePets[1]
    self.selectedRarity = "Unique"
    self.section = self.tab:AddSection("Switch Pets")

    self.RarityDropdown = self.section:AddDropdown("SwitchPetRarityDropdown", {
        Title = "Select Rarity",
        Description = "Choose rarity to filter pets.",
        Values = {"All", "Unique", "Epic", "Rare", "Advanced", "Basic"},
        Multi = false,
        Default = "Unique"
    })
    self.RarityDropdown:OnChanged(function(value)
        self.selectedRarity = value
        self:updatePetDropdown()
    end)

    self.PetDropdown = self.section:AddDropdown("SwitchPetDropdown", {
        Title = "Select Pet",
        Description = "Choose a pet to Equip or Unequip",
        Values = RARITY_MAP[self.selectedRarity],
        Multi = false,
        Default = RARITY_MAP[self.selectedRarity][1]
    })
    self.PetDropdown:OnChanged(function(value) self.selectedPet = value end)

    self.section:AddButton({
        Title = "Equip Selected Pet (x" .. Config.MaxEquip .. ")",
        Description = "Equips up to 8 of the selected pet.",
        Callback = function() self:EquipSelectedPet() end
    })

    self.section:AddButton({
        Title = "Unequip Selected Pet",
        Description = "Unequips all of the selected pet.",
        Callback = function() self:UnequipSelectedPet() end
    })

    return self
end

function SwitchPets:updatePetDropdown()
    local pets = RARITY_MAP[self.selectedRarity] or ALL_PETS
    self.PetDropdown:SetValues(pets)
    self.PetDropdown:SetValue(pets[1])
    self.selectedPet = pets[1]
end

function SwitchPets:getUniqueFolder()
    local player = Players.LocalPlayer
    local petsFolder = player:FindFirstChild("petsFolder")
    return petsFolder and petsFolder:FindFirstChild("Unique")
end

function SwitchPets:getPetsByName(name)
    local uniqueFolder = self:getUniqueFolder()
    local pets = {}
    if uniqueFolder then
        for _, pet in ipairs(uniqueFolder:GetChildren()) do
            if pet.Name == name then table.insert(pets, pet) end
        end
    end
    return pets
end

function SwitchPets:EquipSelectedPet()
    local pets = self:getPetsByName(self.selectedPet)
    for i = 1, math.min(Config.MaxEquip, #pets) do
        ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pets[i])
    end
end

function SwitchPets:UnequipSelectedPet()
    local pets = self:getPetsByName(self.selectedPet)
    for _, pet in ipairs(pets) do
        ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
    end
end

return SwitchPets
