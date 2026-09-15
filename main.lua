local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexsoftware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Onyx Hub | Muscle Legends",
    HidePremium = false,
    SaveConfig = false, -- Отключено для безопасности на мобилках
    IntroText = "Onyx Hub by herosinch"
})

OrionLib:MakeNotification({
    Name = "Onyx Hub загружен!",
    Content = "Оптимизировано для Delta. Автор: herosinch",
    Image = "rbxassetid://4483362458",
    Time = 5
})

-- ==================== СЕРВИСЫ ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== НАСТРОЙКИ (ФЛАГИ) ====================
local Settings = {
    TurboReps = false, TurboPunch = false, Rebirth = false,
    TurboSpeed = 50,
    SmartMachine = false, SelectedMachine = "Bench Press",
    KingLock = false,
    AutoEgg = false, SelectedEgg = "Blue Crystal", AutoEvolve = false,
    AutoQuest = false, AutoWheel = false,
    WalkSpeed = 16, JumpPower = 50
}

-- Anti-AFK (Защита от отключения для мобилок)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Базы данных игры
local Teleports = {
    ["Starter Island"] = Vector3.new(2, 8, 115),
    ["Tiny Island"] = Vector3.new(-34, 7, 1903),
    ["Legend Beach"] = Vector3.new(470, 7, -321),
    ["Frost Gym"] = Vector3.new(-2600, 4, -404),
    ["Mythical Gym"] = Vector3.new(2255, 7, 1071),
    ["Eternal Gym"] = Vector3.new(-6768, 7, -1287),
    ["Legend Gym"] = Vector3.new(4604, 991, -3887),
    ["Muscle King Gym"] = Vector3.new(-8646, 17, -5738),
    ["Jungle Gym"] = Vector3.new(-8659, 6, 2384),
    ["Industrial Gym"] = Vector3.new(-8700, 15, -8700)
}

local Crystals = {
    "Blue Crystal", "Green Crystal", "Frost Crystal", "Mythical Crystal", 
    "Inferno Crystal", "Legends Crystal", "Muscle Elite Crystal", "Industrial Crystal"
}

local MachinesList = {
    "Bench Press", "Squat Rack", "Pullup Bar", "Treadmill", "Deadlift", "Boulder"
}

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================
local function getTool(toolName)
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChild(toolName) or LocalPlayer.Backpack:FindFirstChild(toolName)
    if tool and tool.Parent == LocalPlayer.Backpack then
        pcall(function() char.Humanoid:EquipTool(tool) end)
    end
    return tool
end

local function getFreeMachine(machineName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(v.Name, machineName) then
            local seat = v:FindFirstChild("interactSeat") or v:FindFirstChildWhichIsA("Seat", true) or v:FindFirstChildWhichIsA("VehicleSeat", true)
            if seat and not seat.Occupant then return seat end
        end
    end
    return nil
end

local function breakMachineWelds(seat)
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        for _, anim in pairs(humanoid:GetPlayingAnimationTracks()) do anim:Stop() end
    end
    
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("Weld") or obj:IsA("WeldConstraint") then pcall(function() obj:Destroy() end) end
    end
    
    if seat then
        for _, obj in pairs(seat:GetChildren()) do
            if obj.Name == "SeatWeld" then pcall(function() obj:Destroy() end) end
        end
    end
end

-- ==================== СОЗДАНИЕ ВКЛАДОК ====================
local FarmTab = Window:MakeTab({Name = "Авто-Фарм", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MachineTab = Window:MakeTab({Name = "Тренажеры", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local KingTab = Window:MakeTab({Name = "Царь Горы", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PetsTab = Window:MakeTab({Name = "Питомцы", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local QuestTab = Window:MakeTab({Name = "Квесты & Рулетка", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Телепорты", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "Игрок", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PerfTab = Window:MakeTab({Name = "Оптимизация", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- ==================== ВКЛАДКА: АВТО-ФАРМ ====================
FarmTab:AddSection({Name = "Турбо-Фарм (Спам пакетами)"})

FarmTab:AddSlider({
    Name = "Скорость Турбо-фарма", Min = 10, Max = 200, Default = 50, Color = Color3.fromRGB(255,255,255), Increment = 10, ValueName = "Reps/sec",
    Callback = function(Value) Settings.TurboSpeed = Value end    
})

FarmTab:AddToggle({
    Name = "Турбо Тренировка (Возьми снаряд)", Default = false,
    Callback = function(Value)
        Settings.TurboReps = Value
        if Value then
            task.spawn(function()
                while Settings.TurboReps do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                        for i = 1, math.clamp(Settings.TurboSpeed / 10, 1, 20) do
                            pcall(function() ReplicatedStorage.rEvents.muscleEvent:FireServer("rep") end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Турбо Удары (Punch)", Default = false,
    Callback = function(Value)
        Settings.TurboPunch = Value
        if Value then
            task.spawn(function()
                while Settings.TurboPunch do
                    local tool = getTool("Punch")
                    if tool then
                        for i = 1, math.clamp(Settings.TurboSpeed / 10, 1, 20) do
                            pcall(function() ReplicatedStorage.rEvents.muscleEvent:FireServer("punch", "rightHand") end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end    
})

FarmTab:AddSection({Name = "Перерождение"})
FarmTab:AddToggle({
    Name = "Авто-Ребертх", Default = false,
    Callback = function(Value)
        Settings.Rebirth = Value
        if Value then
            task.spawn(function()
                while Settings.Rebirth do
                    pcall(function() ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest") end)
                    task.wait(2)
                end
            end)
        end
    end    
})

-- ==================== ВКЛАДКА: УМНЫЕ ТРЕНАЖЕРЫ ====================
MachineTab:AddSection({Name = "Отвязка от тренажера (Бегай и качайся)"})

MachineTab:AddDropdown({
    Name = "Выбрать тренажер", Default = "Bench Press", Options = MachinesList,
    Callback = function(Value) Settings.SelectedMachine = Value end    
})

MachineTab:AddToggle({
    Name = "Включить Умный Тренажер", Default = false,
    Callback = function(Value)
        Settings.SmartMachine = Value
        if Value then
            task.spawn(function()
                while Settings.SmartMachine do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                            local seat = getFreeMachine(Settings.SelectedMachine)
                            if seat then
                                char.HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
                                task.wait(0.2)
                                seat:Sit(char.Humanoid)
                                task.wait(0.3)
                                breakMachineWelds(seat)
                            end
                            ReplicatedStorage.rEvents.muscleEvent:FireServer("rep")
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end    
})

-- ==================== ВКЛАДКА: ЦАРЬ ГОРЫ ====================
KingTab:AddSection({Name = "Скрытый захват из под текстур"})

KingTab:AddToggle({
    Name = "Включить захват King Gym", Default = false,
    Callback = function(Value)
        Settings.KingLock = Value
        if Value then
            task.spawn(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local safeCFrame = CFrame.new(Teleports["Muscle King Gym"]) * CFrame.new(0, -15, 0)
                    local bp = Instance.new("BodyPosition", char.HumanoidRootPart)
                    bp.Position = safeCFrame.Position
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    while Settings.KingLock do
                        pcall(function() char.HumanoidRootPart.CFrame = safeCFrame end)
                        task.wait(0.5)
                    end
                    pcall(function() bp:Destroy() end)
                end
            end)
        end
    end    
})

-- ==================== ВКЛАДКА: ПИТОМЦЫ ====================
PetsTab:AddSection({Name = "Открытие и Прокачка"})

PetsTab:AddDropdown({
    Name = "Выбрать кристалл", Default = "Blue Crystal", Options = Crystals,
    Callback = function(Value) Settings.SelectedEgg = Value end    
})

PetsTab:AddToggle({
    Name = "Авто-открытие кристалла", Default = false,
    Callback = function(Value)
        Settings.AutoEgg = Value
        task.spawn(function()
            while Settings.AutoEgg do
                pcall(function() ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", Settings.SelectedEgg) end)
                task.wait(0.5)
            end
        end)
    end    
})

PetsTab:AddToggle({
    Name = "Авто-Эволюция питомцев", Default = false,
    Callback = function(Value)
        Settings.AutoEvolve = Value
        task.spawn(function()
            while Settings.AutoEvolve do
                pcall(function()
                    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
                    if petsFolder then
                        for _, pet in pairs(petsFolder:GetChildren()) do
                            ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", pet.Name)
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end    
})

-- ==================== ВКЛАДКА: КВЕСТЫ & РУЛЕТКА ====================
QuestTab:AddSection({Name = "Автоматизация событий"})

QuestTab:AddToggle({
    Name = "Авто-Сбор Квестов", Default = false,
    Callback = function(Value)
        Settings.AutoQuest = Value
        task.spawn(function()
            while Settings.AutoQuest do
                pcall(function()
                    for _, quest in pairs(LocalPlayer.Quests:GetDescendants()) do
                        if quest:IsA("Folder") and quest:FindFirstChild("requirements") then
                            ReplicatedStorage.rEvents.questsEvent:FireServer("collectQuest", quest)
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end    
})

QuestTab:AddToggle({
    Name = "Авто-Колесо Фортуны", Default = false,
    Callback = function(Value)
        Settings.AutoWheel = Value
        task.spawn(function()
            while Settings.AutoWheel do
                pcall(function()
                    local wheel = ReplicatedStorage:FindFirstChild("fortuneWheelChances") or workspace:FindFirstChild("fortuneWheelChances")
                    if wheel then ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", wheel:FindFirstChild("Fortune Wheel")) end
                end)
                task.wait(5)
            end
        end)
    end    
})

-- ==================== ВКЛАДКА: ТЕЛЕПОРТЫ ====================
TeleportTab:AddSection({Name = "Быстрое перемещение"})

for name, coords in pairs(Teleports) do
    TeleportTab:AddButton({
        Name = name,
        Callback = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(coords)
            end
        end    
    })
end

-- ==================== ВКЛАДКА: ИГРОК ====================
PlayerTab:AddSection({Name = "Модификации персонажа"})

PlayerTab:AddSlider({
    Name = "Скорость бега", Min = 16, Max = 250, Default = 16, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "Speed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        task.spawn(function()
            while task.wait(0.5) do
                pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed end)
            end
        end)
    end    
})

PlayerTab:AddSlider({
    Name = "Размер персонажа", Min = 1, Max = 10, Default = 1, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "Size",
    Callback = function(Value)
        pcall(function() ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", Value) end)
    end    
})

-- ==================== ВКЛАДКА: ОПТИМИЗАЦИЯ ====================
PerfTab:AddSection({Name = "Режимы для AFK фарма"})

PerfTab:AddButton({
    Name = "Включить Ultra Black (Снизить нагрузку)",
    Callback = function()
        local sg = Instance.new("ScreenGui", game.CoreGui)
        sg.Name = "UltraBlackScreen_Onyx"
        sg.IgnoreGuiInset = true
        
        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 200, 0, 50)
        btn.Position = UDim2.new(0.5, -100, 0.5, -25)
        btn.Text = "ВЕРНУТЬ ИГРУ"
        
        RunService:Set3dRenderingEnabled(false)
        
        btn.MouseButton1Click:Connect(function()
            RunService:Set3dRenderingEnabled(true)
            sg:Destroy()
        end)
    end    
})

-- ==================== ИНИЦИАЛИЗАЦИЯ ОРИОНА ====================
OrionLib:Init()
