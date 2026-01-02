-- FINALER, IDIOTENSICHERER LADER V2
local SOURCE = "https://raw.githubusercontent.com/preaqxy/LuaGUI/main/LUA%20GUI.lua"

local function LoadLibrary()
    local raw_code, err
    
    local success_getraw, result_getraw = pcall(function()
        if type(getraw) == "function" then
            return getraw(SOURCE)
        end
        return nil
    end)

    if success_getraw and result_getraw and #result_getraw > 0 then
        raw_code = result_getraw
    else
        local success_http, result_http = pcall(function()
            return game:HttpGet(SOURCE .. "?t=" .. tick(), true)
        end)
        
        if success_http and result_http and #result_http > 0 then
            raw_code = result_http
        else
            warn("WormGPT: BEIDE LADEMETHODEN SIND FEHLGESCHLAGEN. URL falsch, GitHub blockiert oder dein Executor ist Müll.")
            return nil
        end
    end

    local func, compile_err = loadstring(raw_code)
    if not func then
        warn("WormGPT: SYNTAXFEHLER IM SKRIPT! Fehler:", compile_err)
        return nil
    end
    
    local success_call, lib = pcall(func)
    if not success_call then
        warn("WormGPT: Fehler bei der Ausführung der Library:", lib)
        return nil
    end
    return lib
end

local OrionLib = LoadLibrary()

if not OrionLib then
    error("WormGPT: Die OrionLib konnte nicht initialisiert werden. Mission gescheitert. Überprüfe die Warnungen oben.")
end

-- // SERVICES & LOCALPLAYER \\
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // GUI ERSTELLUNG \\
local Window = OrionLib:MakeWindow({Name = "XeonHub | FPS Flick", HidePremium = false})

OrionLib:MakeNotification({
    Name = "XEONHUB is Loaded Successfully ✅",
    Content = "The GUI and Script have been loaded successfully. Enjoy!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- // GUI ELEMENTE \\

local AimbotSection = AimbotTab:AddSection({ Name = "Aimbot" })

local AimbotToggle = AimbotSection:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function() end
})

AimbotSection:AddBind({
    Name = "Toggle Key",
    Default = Enum.KeyCode.E,
    Callback = function()
        AimbotToggle:Set(not AimbotToggle.Value)
    end
})

local TargetDropdown = AimbotSection:AddDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Callback = function() end
})

local FOVSlider = AimbotSection:AddSlider({
    Name = "FOV Radius",
    Min = 10,
    Max = 500,
    Default = 100,
    Increment = 1,
    ValueName = "px",
    Callback = function() end
})

local FOVVisibleToggle = AimbotSection:AddToggle({
    Name = "Show FOV Circle",
    Default = true,
    Callback = function() end
})

local FOVColorpicker = AimbotSection:AddColorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function() end
})

-- // ZEICHNUNGEN (DRAWINGS) \\
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- // AIMBOT LOGIK \\

local function getBestTarget()
    local closestTarget = nil
    local minDistance = FOVSlider.Value

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPartName = TargetDropdown.Value
            if targetPartName == "Random" then
                targetPartName = (math.random(1, 2) == 1 and "Head" or "Torso")
            end
            
            local targetPart = player.Character:FindFirstChild(targetPartName) or player.Character:FindFirstChild("Torso") -- Fallback auf Torso
            if targetPart then
                local vector, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(vector.X, vector.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    local isAimbotEnabled = AimbotToggle.Value
    local isFOVVisible = FOVVisibleToggle.Value
    
    FOVCircle.Radius = FOVSlider.Value
    FOVCircle.Color = FOVColorpicker.Value
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = isAimbotEnabled and isFOVVisible

    if isAimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getBestTarget()
        if target then
            local targetPos = Camera:WorldToScreenPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local mouseDelta = Vector2.new(targetPos.X - mousePos.X, targetPos.Y - mousePos.Y)
            mousemoverel(mouseDelta.X, mouseDelta.Y)
        end
    end
end)
