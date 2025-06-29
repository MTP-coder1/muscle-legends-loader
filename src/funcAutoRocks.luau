local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local firetouchinterest = rawget(_G, "firetouchinterest") or getgenv().firetouchinterest

local AutoRocks = {}
AutoRocks.__index = AutoRocks

-- CONFIG (You can add more Rocks if needed)
local ROCK_CONFIGS = {
    { Title = "Rock Of Legends" },
    { Title = "Muscle King Mountain" },
    { Title = "Ancient Jungle Rock" }
}
local ROCK_NAMES = {}
for _, cfg in ipairs(ROCK_CONFIGS) do
    table.insert(ROCK_NAMES, cfg.Title)
end

local currFarmRock = nil
local farmThread = nil
local apEnabled = false
local apThread = nil

local function stopFarmRockThread()
    if farmThread and coroutine.status(farmThread) ~= "dead" then
        task.cancel(farmThread)
        farmThread = nil
    end
    currFarmRock = nil
    getgenv().autoFarm = false
end

local function startFarmRock(_, rockName)
    stopFarmRockThread()
    currFarmRock = rockName
    getgenv().autoFarm = true

    farmThread = task.spawn(function()
        local machinesFolder = Workspace:FindFirstChild("machinesFolder")
        if not machinesFolder then return end

        local player = LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local lHand = character:FindFirstChild("LeftHand")
        local rHand = character:FindFirstChild("RightHand")
        if not lHand or not rHand then return end

        local rock = nil
        for _, v in ipairs(machinesFolder:GetDescendants()) do
            if v:IsA("IntValue") and v.Name == "neededDurability" then
                local machine = v.Parent
                if machine and machine.Name == rockName then
                    rock = machine:FindFirstChild("Rock")
                    break
                end
            end
        end

        if not rock then return end

        while getgenv().autoFarm and currFarmRock == rockName do
            if apEnabled and firetouchinterest then
                firetouchinterest(rock, rHand, 0)
                firetouchinterest(rock, lHand, 1)
                firetouchinterest(rock, rHand, 1)
                firetouchinterest(rock, lHand, 0)
                task.wait(0.01)
            end
            task.wait(0.25)
        end

        if currFarmRock == rockName then
            currFarmRock = nil
            getgenv().autoFarm = false
        end
    end)
end

local function reEquipPunchTool()
    local player = LocalPlayer
    local tool = player.Backpack:FindFirstChild("Punch")
    if not tool then
        local punchTool = ReplicatedStorage:FindFirstChild("Punch")
        if punchTool then
            punchTool:Clone().Parent = player.Backpack
        end
    end
end

function AutoRocks.AddUI(tab)
    local self = setmetatable({}, AutoRocks)

    -- DROPDOWN FOR SELECTING ROCK
    self.Dropdown = tab:AddDropdown("AutoRocksDropdown", {
        Title = "Select Rock to Farm",
        Description = "Choose the rock you want to farm",
        Values = ROCK_NAMES,
        Default = "",
        Multi = false,
        Callback = function(selectedValue)
            for _, cfg in ipairs(ROCK_CONFIGS) do
                if cfg.Title == selectedValue then
                    startFarmRock(nil, cfg.Title)
                    return
                end
            end
        end
    })

    -- TOGGLE FOR ENABLING/DISABLING AUTO PUNCH FARM
    self.Toggle = tab:AddToggle("AutoRocksToggle", {
        Title = "Auto Farm Rock",
        Description = "Automatically Farms the Selected Rock.",
        Default = false,
        Callback = function(state)
            apEnabled = state

            if apThread and coroutine.status(apThread) ~= "dead" then
                task.cancel(apThread)
                apThread = nil
            end

            local player = LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()

            if apEnabled then
                local function equipPunchTool()
                    local punchTool = player.Backpack:FindFirstChild("Punch")
                    if punchTool then
                        character.Humanoid:EquipTool(punchTool)
                    end
                end

                equipPunchTool()

                apThread = task.spawn(function()
                    while apEnabled and task.wait(0.099) do
                        local hasPunchEquipped = character and character:FindFirstChild("Punch")
                        local punchInBackpack = player.Backpack:FindFirstChild("Punch")

                        if not hasPunchEquipped and punchInBackpack then
                            character.Humanoid:EquipTool(punchInBackpack)
                        end

                        local muscleEvent = player:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("punch", "leftHand")
                            muscleEvent:FireServer("punch", "rightHand")
                            task.wait(0.01)
                        end
                    end
                end)
            else
                if character and character:FindFirstChild("Punch") then
                    character.Humanoid:UnequipTools()
                end
            end
        end
    })

    task.spawn(function()
        local player = LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        while true do
            task.wait(0.1)
            if apEnabled and character and not character:FindFirstChild("Punch") then
                reEquipPunchTool()
            end
        end
    end)

    return self
end

return AutoRocks