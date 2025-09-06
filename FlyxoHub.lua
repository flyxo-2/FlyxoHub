--[[ LinoriaLib Flyxo Hub ]]--

print("Remember to join our discord! (copied invite link to clipboard)")
setclipboard("https://discord.gg/UXgGqZ7w3v")

-- Carregar LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Janela principal
local Window = Library:CreateWindow({
    Title = 'Flyxo Hub',
    Center = true,
    AutoShow = true,
})

-- Tabs principais (na ordem que você pediu)
local Tabs = {
    Main = Window:AddTab('Main'),
    Skins = Window:AddTab('Skins'),
    Maps = Window:AddTab('Maps'),
    Others = Window:AddTab('Others'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Criar Groupboxes dentro das Tabs
local MainGroup = Tabs.Main:AddLeftGroupbox('Main Functions')
local SkinsGroup = Tabs.Skins:AddLeftGroupbox('Skins')
local MapsGroup = Tabs.Maps:AddLeftGroupbox('Maps')
local OthersGroup = Tabs.Others:AddLeftGroupbox('Other Tools')
local UIGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

------------------------------------------------------
-- Variáveis e Funções (iguais antes)
------------------------------------------------------
local player = game.Players.LocalPlayer
local target = game.Workspace:WaitForChild("Gubbies")

local variants = {"RegularGubby", "FatGubby", "PancakeGubby", "StormcellGubby"}
local function getGubby()
    for _, name in ipairs(variants) do
        if target:FindFirstChild(name) then
            return target[name]
        end
    end
    return nil
end

local voidDamage = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.DamageEvents.VoidDamage
local airstrikeDamage = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.DamageEvents.AirstrikeDamage
local smiteDamage = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.DamageEvents.SmiteDamage
local physicsDamage = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.DamageEvents.PhysicsDamage
local foodDamage = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.DamageEvents.FoodDamage
local purchaseGas = game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.PurchaseGas

local mainAnchored = false
local fuelRunning = false
local infDamageRunning = false
local autoFarmTask = nil
local moneyLoop = nil

local function anchorchildren(model)
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            child.Anchored = mainAnchored
        elseif #child:GetChildren() > 0 then
            anchorchildren(child)
        end
    end
end

------------------------------------------------------
-- Main Groupbox
------------------------------------------------------
MainGroup:AddToggle('AutoFarm', {Text = 'Auto Farm'}):OnChanged(function(value)
    infDamageRunning = value
    if infDamageRunning then
        autoFarmTask = task.spawn(function()
            while infDamageRunning do
                voidDamage:FireServer(Vector3.new(999,999,999))
                airstrikeDamage:FireServer(Vector3.new(999,999,999),3.11)
                smiteDamage:FireServer(Vector3.new(999,999,999))
                physicsDamage:FireServer(333.54, Vector3.new(999,999,999))
                foodDamage:FireServer("CherryBomb", Vector3.new(999,999,999))
                task.wait()
            end
        end)
    else
        if autoFarmTask then task.cancel(autoFarmTask) autoFarmTask = nil end
    end
end)

MainGroup:AddToggle('AutoRefillFuel', {Text = 'Auto Refill Fuel'}):OnChanged(function(value)
    fuelRunning = value
    if fuelRunning then
        task.spawn(function()
            while fuelRunning do
                purchaseGas:FireServer(10)
                task.wait()
            end
        end)
    end
end)

MainGroup:AddToggle('AnchorGubby', {Text = 'Anchor Gubby'}):OnChanged(function(value)
    mainAnchored = value
    local gubby = getGubby()
    if gubby then
        if gubby:FindFirstChild("RootPart") then
            gubby.RootPart.Anchored = mainAnchored
        end
        anchorchildren(gubby)
    end
end)

------------------------------------------------------
-- Skins Groupbox
------------------------------------------------------
local skinNames = {
    ["Pancake Gubby"] = "PancakeGubby",
    ["Regular Gubby"] = "RegularGubby",
    ["Round Gubby"] = "FatGubby",
    ["Stormcell Gubby"] = "StormcellGubby",
}
for displayName, internalName in pairs(skinNames) do
    SkinsGroup:AddButton(displayName, function()
        local skinValue = game.ReplicatedStorage.PlayerData[player.Name].EquippedItems:FindFirstChild("GubbySkin")
        if skinValue then
            skinValue.Value = internalName
        end
    end)
end

------------------------------------------------------
-- Maps Groupbox
------------------------------------------------------
local maps = {
    {"Happy Home (main map)", "HappyHome"},
    {"Green Screen", "GreenScreen"},
    {"Gubby Gardens", "GubbyGardens"},
    {"Blackrock Fields", "BlackrockFields"},
}
for _, map in ipairs(maps) do
    MapsGroup:AddButton(map[1], function()
        game:GetService("ReplicatedStorage").Networking.Server.RemoteEvents.ChangeScene:FireServer(map[2])
    end)
end

------------------------------------------------------
-- Others Groupbox
------------------------------------------------------
OthersGroup:AddButton('Burn Gubby', function()
    local gubby = getGubby()
    if gubby and gubby:FindFirstChild("GubbyEvents") then
        local e = gubby.GubbyEvents:FindFirstChild("Burn")
        if e then e:Fire() end
    end
end)

OthersGroup:AddButton('Knockout Gubby', function()
    local gubby = getGubby()
    if gubby and gubby:FindFirstChild("GubbyEvents") then
        local e = gubby.GubbyEvents:FindFirstChild("KnockOut")
        if e then e:Fire() end
    end
end)

OthersGroup:AddButton('Ragdoll Gubby', function()
    local gubby = getGubby()
    if gubby and gubby:FindFirstChild("GubbyEvents") then
        local e = gubby.GubbyEvents:FindFirstChild("Ragdoll")
        if e then e:Fire() end
    end
end)

OthersGroup:AddToggle('DisableMoneySFX', {Text = 'Disable Money SFX'}):OnChanged(function(value)
    if value then
        if moneyLoop then task.cancel(moneyLoop) end
        moneyLoop = task.spawn(function()
            while value do
                local soundsFolder = game.ReplicatedStorage.GameAssets.Sounds
                if soundsFolder:FindFirstChild("Money1") then soundsFolder.Money1:Destroy() end
                if soundsFolder:FindFirstChild("Money2") then soundsFolder.Money2:Destroy() end
                task.wait(0.1)
            end
        end)
    else
        if moneyLoop then task.cancel(moneyLoop) moneyLoop = nil end
    end
end)

OthersGroup:AddToggle('ZeroGravity', {Text = 'Zero Gravity'}):OnChanged(function(value)
    local zeroGravity = game.ReplicatedStorage.PlayerData[player.Name].Settings:FindFirstChild("ZeroGravity")
    if zeroGravity then zeroGravity.Value = value end
end)

------------------------------------------------------
-- UI Settings
------------------------------------------------------
UIGroup:AddButton('Unload', function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('FlyxoHub')
SaveManager:SetFolder('FlyxoHub/Configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
