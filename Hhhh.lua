-- ============================================= --
-- HUSSIN V1 PREMIUM - النسخة المعدلة
-- مع أزرار بحجم 58x58 ولون أسود (غير شفافة)
-- تنظيم 3 أعمدة
-- RESET و TP MODE جنب بعض في الأعلى
-- JUMP موجود فقط في الإعدادات
-- CARRY SPEED يدوي (زر في الأزرار الجانبية) - WhaleHub Booster
-- AUTO CARRY SPEED (زر في الإعدادات) - WhaleHub Booster
-- RAG و SHIELD موجودين فقط في الإعدادات
-- AIMBOT على حرف E في الكيبورد (يوقف WhaleHub تلقائياً)
-- الإعدادات باللون الأسود مع صورة خلفية
-- جميع السرعات تستخدم WhaleHub Booster (LinearVelocity)
-- ============================================= --

-- ====== حماية بـ Whitelist ======
local allowedUsers = {
    "knhfgg66",
    "Mohammad45130",
    "Hugeudddde",
    "RTFDQ3",
    "Yara12345338",
    "m211am",
    
}

local function checkWhitelist()
    local player = game:GetService("Players").LocalPlayer
    for _, name in ipairs(allowedUsers) do
        if player.Name == name or player.DisplayName == name then
            return true
        end
    end
    player:Kick("⚠️ هذا السكربت غير مصرح لك باستخدامه")
    return false
end
if not checkWhitelist() then return end

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

-- ====== حذف الواجهات القديمة ======
if CoreGui:FindFirstChild("HUSSIN_Settings") then
    CoreGui.HUSSIN_Settings:Destroy()
end
if CoreGui:FindFirstChild("FearHub_UI") then
    CoreGui.FearHub_UI:Destroy()
end

-- ====== CONFIG FILE ======
local CONFIG_FILE = "HussinConfig.json"

-- ====== نظام WhaleHub Booster - سرعة آمنة (LinearVelocity) ======
local boostEnabled = false
local boostConn = nil
local currentSpeed = 29
local lvAttachment = nil
local linearVelocity = nil
local boostMode = "normal" -- "normal" or "steal"

local function destroyLV()
    if linearVelocity and linearVelocity.Parent then
        linearVelocity:Destroy()
    end
    if lvAttachment and lvAttachment.Parent then
        lvAttachment:Destroy()
    end
    linearVelocity = nil
    lvAttachment = nil
end

local function setupLV(hrp)
    destroyLV()
    lvAttachment = Instance.new("Attachment")
    lvAttachment.Name = "HussinBoostAtt"
    lvAttachment.Parent = hrp
    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "HussinBoostLV"
    linearVelocity.Attachment0 = lvAttachment
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    linearVelocity.MaxForce = math.huge
    linearVelocity.PlaneVelocity = Vector2.zero
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.Parent = hrp
end

local function applyBoost()
    if not LP.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not linearVelocity or linearVelocity.Parent ~= hrp then
        setupLV(hrp)
    end
end

local function removeBoost()
    if linearVelocity and linearVelocity.Parent then
        linearVelocity.VectorVelocity = Vector3.zero
    end
    destroyLV()
end

local function startBoost()
    if boostConn then boostConn:Disconnect() end
    applyBoost()
    boostConn = RunService.Heartbeat:Connect(function()
        if not boostEnabled then return end
        if not LP.Character then return end
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end
        if not linearVelocity or linearVelocity.Parent ~= hrp then
            setupLV(hrp)
        end
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local flat = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            linearVelocity.PlaneVelocity = Vector2.new(flat.X * currentSpeed, flat.Z * currentSpeed)
        else
            linearVelocity.PlaneVelocity = Vector2.zero
        end
    end)
end

local function stopBoost()
    if boostConn then
        boostConn:Disconnect()
        boostConn = nil
    end
    removeBoost()
end

local function toggleBoost()
    boostEnabled = not boostEnabled
    if boostEnabled then
        startBoost()
    else
        stopBoost()
    end
    return boostEnabled
end

-- ============================================================
-- المتغيرات الأساسية
-- ============================================================
local infJumpOn = false
local antiRagOn = false
local autoLeftEnabled = false
local autoRightEnabled = false
local medusaEnabled = false
local laggerEnabled = false
local carrySpeedEnabled = false
local autoCarrySpeedEnabled = false
local h

-- ====== ANTI-LAG ======
local antiLagEnabled = false

-- ====== STRETCH REZ ======
local stretchRezEnabled = false
local stretchRezConn = nil
local stretchFovConn = nil
local stretchFOV = 120

-- ====== SKY COLORS ======
local activeSky = nil
local activeColorCorr = nil
local origLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}

-- ====== PLAYER ESP ======
local playerESPEnabled = false
local playerESPObjects = {}
local playerESPConns = {}

-- ====== Name Tag ======
local nameTagEnabled = true
local playerName = "discord.gg"

-- ====== إعدادات السرعة ======
local SpeedState = {
    normalSpeed = 53,
    carrySpeed = 29,
    laggerSpeed = 10.1,
    laggerSteal = 8,
    isLaggerMode = false,
    speedActive = true,
}

local speedConnection = nil
local character, humanoid, humanoidRootPart = nil, nil, nil

-- ====== MEDUSA ======
local resetRemote = nil
local RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local medusaDebounce = false
local medusaConns = {}
local isResetting = false

-- ====== AUTO STEAL ======
local STEAL_RADIUS = 61
local STEAL_DURATION = 1.3
local autoStealEnabled = true
local isStealing = false
local StealData = {}
local progressBarBg = nil
local progressFill = nil
local percentLabel = nil
local bannerFrame = nil
local infoLabel = nil
local stealConn = nil
local lp = LP

-- ====== AUTO TP ======
local autoTPEnabled = false
local autoTPHeight = 20
local autoTPConn = nil

-- ====== NUKE OPTIMIZER ======
local nukeEnabled = false
local nukeConns = {}
local nukeThreads = {}

-- ====== REMOVE ACCESSORIES ======
local removeAccEnabled = false
local removeAccConn = nil
local removedAccessories = {}

-- ====== ANTI-LAG V2 ======
local antiLagV2Enabled = false
local antiLagV2Conn = nil
local antiLagDefBrightness, antiLagDefFog, antiLagDefDiffuse, antiLagDefSpecular = nil, nil, nil, nil

-- ============================================================
-- دوال السرعة (جميعها تستخدم WhaleHub Booster)
-- ============================================================
local function startSpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(function()
        if not humanoid or not humanoidRootPart then return end
        if not SpeedState.speedActive then return end
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude == 0 then return end
        
        local speedToUse
        
        if SpeedState.isLaggerMode then
            local isSteal = humanoid.WalkSpeed < 25
            speedToUse = isSteal and SpeedState.laggerSteal or SpeedState.laggerSpeed
            -- LAGGER يستخدم النظام القديم (Velocity) لأنه لا يتعارض مع Aimbot
            humanoidRootPart.Velocity = Vector3.new(
                moveDirection.X * speedToUse,
                humanoidRootPart.Velocity.Y,
                moveDirection.Z * speedToUse
            )
            return
        else
            if autoCarrySpeedEnabled then
                local isSteal = humanoid.WalkSpeed < 25
                if isSteal then
                    speedToUse = SpeedState.carrySpeed
                    boostMode = "steal"
                else
                    speedToUse = SpeedState.normalSpeed
                    boostMode = "normal"
                end
            elseif carrySpeedEnabled then
                speedToUse = SpeedState.carrySpeed
                boostMode = "steal"
            else
                speedToUse = SpeedState.normalSpeed
                boostMode = "normal"
            end
        end
        
        -- تطبيق السرعة باستخدام WhaleHub Booster
        currentSpeed = speedToUse
        
        if not boostEnabled then
            boostEnabled = true
            startBoost()
        end
        
        -- تحديث السرعة مباشرة
        if moveDirection.Magnitude > 0.1 then
            local flat = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
            if linearVelocity then
                linearVelocity.PlaneVelocity = Vector2.new(flat.X * currentSpeed, flat.Z * currentSpeed)
            end
        end
    end)
end

local function stopSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    -- إيقاف WhaleHub إذا كان شغال
    if boostEnabled then
        boostEnabled = false
        stopBoost()
    end
end

-- ====== CARRY SPEED MANUAL (زر جانبي) ======
local function toggleCarrySpeed()
    carrySpeedEnabled = not carrySpeedEnabled
    
    if carrySpeedEnabled then
        currentSpeed = SpeedState.carrySpeed
        boostMode = "steal"
        if not boostEnabled then
            boostEnabled = true
            startBoost()
        end
        print("[HUSSIN] 🚀 CARRY SPEED ON (WhaleHub): " .. currentSpeed)
    else
        currentSpeed = SpeedState.normalSpeed
        boostMode = "normal"
        print("[HUSSIN] 🚀 CARRY SPEED OFF - العادية: " .. currentSpeed)
    end
    
    return carrySpeedEnabled
end

-- ====== LAGGER FUNCTION ======
local function toggleLagger()
    laggerEnabled = not laggerEnabled
    print("[HUSSIN] 🚀 LAGGER: " .. tostring(laggerEnabled))
    
    if laggerEnabled then
        SpeedState.isLaggerMode = true
        -- إيقاف WhaleHub عند تشغيل LAGGER
        if boostEnabled then
            boostEnabled = false
            stopBoost()
        end
    else
        SpeedState.isLaggerMode = false
        -- إعادة تشغيل WhaleHub إذا كانت السرعة مفعلة
        if carrySpeedEnabled or autoCarrySpeedEnabled then
            boostEnabled = true
            startBoost()
        end
    end
    autoSave()
end

-- ============================================================
-- AIMBOT (يوقف WhaleHub تلقائياً)
-- ============================================================
local batAimbotOn = false
local _aimbotTarget = nil
local _hittingCooldown = false
local SWING_CD = 0.35
local HIT_DIST = 8
local CHASE_SPEED = 58
local aimbotConn = nil

local BAT_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

local function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, name in ipairs(BAT_SLAP_LIST) do
        local t = char:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(BAT_SLAP_LIST) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(t) end) end
                return t
            end
        end
    end
    return nil
end

local function trySwing()
    if _hittingCooldown then return end
    _hittingCooldown = true
    pcall(function()
        local char = LP.Character
        if char then
            local bat = findBat()
            if bat then
                if bat.Parent ~= char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(bat) end) end
                end
                pcall(function() bat:Activate() end)
                local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                if ev then pcall(function() ev:FireServer() end) end
                local rf = bat:FindFirstChildWhichIsA("RemoteFunction")
                if rf then pcall(function() rf:InvokeServer() end) end
            end
        end
    end)
    task.delay(SWING_CD, function() _hittingCooldown = false end)
end

local function getClosestPlayerAimbot()
    local char = LP.Character
    if not char then return nil, math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local ph = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and ph and ph.Health > 0 then
                local d = (root.Position - tr.Position).Magnitude
                if d < dist then dist = d; closest = p end
            end
        end
    end
    return closest, dist
end

local function startBatAimbot()
    if aimbotConn then return end
    
    -- ====== إيقاف WhaleHub Booster عند تشغيل AIMBOT ======
    if boostEnabled then
        boostEnabled = false
        stopBoost()
        print("[HUSSIN] 🎯 WhaleHub موقف مؤقتاً لـ AIMBOT")
    end
    
    -- إيقاف Auto Left/Right
    if autoLeftEnabled then
        autoLeftEnabled = false
        stopAutoLeft()
        if buttonRefs and buttonRefs.left then
            buttonRefs.left.setActive(false)
            buttonRefs.left.btn.Text = "AUTO\nLEFT"
        end
    end
    if autoRightEnabled then
        autoRightEnabled = false
        stopAutoRight()
        if buttonRefs and buttonRefs.right then
            buttonRefs.right.setActive(false)
            buttonRefs.right.btn.Text = "AUTO\nRIGHT"
        end
    end
    
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end
    
    aimbotConn = RunService.RenderStepped:Connect(function()
        if not batAimbotOn then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        
        local targetPlr, targetDist = getClosestPlayerAimbot()
        if not targetPlr or not targetPlr.Character then return end
        local target = targetPlr.Character:FindFirstChild("HumanoidRootPart")
        if not target then return end
        
        _aimbotTarget = target
        
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z).Unit
        
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = math.clamp(yVel, -70, 110)
        
        local desiredVel = Vector3.new(flatDir.X * CHASE_SPEED, yVel, flatDir.Z * CHASE_SPEED)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
        end
        
        if targetDist <= HIT_DIST then trySwing() end
    end)
    
    print("[HUSSIN] 🎯 AIMBOT: ON")
end

local function stopBatAimbot()
    if aimbotConn then
        pcall(function() aimbotConn:Disconnect() end)
        aimbotConn = nil
    end
    _aimbotTarget = nil
    
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    _hittingCooldown = false
    
    -- ====== إعادة تشغيل WhaleHub إذا كانت السرعة مفعلة ======
    if carrySpeedEnabled or autoCarrySpeedEnabled then
        boostEnabled = true
        startBoost()
        print("[HUSSIN] 🚀 WhaleHub تم إعادة تشغيله")
    end
    
    print("[HUSSIN] 🎯 AIMBOT: OFF")
end

local function toggleBatAimbot()
    batAimbotOn = not batAimbotOn
    if batAimbotOn then
        startBatAimbot()
    else
        stopBatAimbot()
    end
    return batAimbotOn
end

-- ====== BAT MOD (TP MODE) ======
local tpBatToggled = false
local tpBatHittingCooldown = false
local tpBatHRP = nil
local tpBatH = nil
local tpBatConn = nil
local tpBatAimbotConn = nil

local function getBatForTP()
    local char = LP.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Bat")
    if tool then return tool end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        tool = bp:FindFirstChild("Bat")
        if tool then
            tool.Parent = char
            return tool
        end
    end
    return nil
end

local function tryHitTPBat()
    if tpBatHittingCooldown then return end
    tpBatHittingCooldown = true
    pcall(function()
        local bat = getBatForTP()
        if bat then
            bat:Activate()
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
            local rf = bat:FindFirstChildWhichIsA("RemoteFunction")
            if rf then pcall(function() rf:InvokeServer() end) end
        end
    end)
    task.delay(0.08, function() tpBatHittingCooldown = false end)
end

local function getClosestPlayerForTPBat()
    if not tpBatHRP then return nil, math.huge end
    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (tpBatHRP.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
        end
    end
    return closest, closestDist
end

local function startTPBatMod()
    if tpBatConn then tpBatConn:Disconnect(); tpBatConn = nil end
    if tpBatAimbotConn then tpBatAimbotConn:Disconnect(); tpBatAimbotConn = nil end
    
    tpBatConn = RunService.Heartbeat:Connect(function()
        if not tpBatToggled then return end
        if not tpBatH or not tpBatHRP then
            local char = LP.Character
            if char then
                tpBatH = char:FindFirstChildOfClass("Humanoid")
                tpBatHRP = char:FindFirstChild("HumanoidRootPart")
            end
            if not tpBatH or not tpBatHRP then return end
        end
        
        local target, dist = getClosestPlayerForTPBat()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(tpBatHRP, "PhysicsRepRootPart", targetRoot)
                    end
                end)
                local targetPos = targetRoot.Position + Vector3.new(0, 0.9, 0)
                if (tpBatHRP.Position - targetPos).Magnitude > 5 then
                    tpBatHRP.CFrame = CFrame.new(targetPos)
                end
                local cam = workspace.CurrentCamera
                if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, targetRoot.Position) end
                tryHitTPBat()
            end
        end
    end)
    
    tpBatAimbotConn = RunService.RenderStepped:Connect(function()
        if not tpBatToggled then return end
        if not tpBatH or not tpBatHRP then return end
        local target, dist = getClosestPlayerForTPBat()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local cam = workspace.CurrentCamera
                if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, targetRoot.Position) end
                tryHitTPBat()
            end
        end
    end)
end

local function stopTPBatMod()
    if tpBatConn then tpBatConn:Disconnect(); tpBatConn = nil end
    if tpBatAimbotConn then tpBatAimbotConn:Disconnect(); tpBatAimbotConn = nil end
end

local function toggleBatMod()
    tpBatToggled = not tpBatToggled
    if tpBatToggled then
        local char = LP.Character
        if char then
            tpBatHRP = char:FindFirstChild("HumanoidRootPart")
            tpBatH = char:FindFirstChildOfClass("Humanoid")
        end
        startTPBatMod()
    else
        stopTPBatMod()
    end
    return tpBatToggled
end

-- ============================================================
-- NUKE OPTIMIZER
-- ============================================================
local function nukeStart()
    if nukeEnabled then return end
    nukeEnabled = true
    
    local XMin, XMax = -560, -240
    local ClothingClasses = {"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
    local BASE_NAMES = {"baseplate","spawnlocation","spawn location","spawn"}
    
    local function SafeDestroy(obj)
        if obj and obj.Name == "Overhead" then return end
        pcall(function() obj:Destroy() end)
    end
    
    local function IsClothing(obj)
        for _, c in ipairs(ClothingClasses) do
            if obj:IsA(c) then return true end
        end
        return false
    end
    
    local function IsCharacterPart(obj)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and obj:IsDescendantOf(plr.Character) then
                return true
            end
        end
        return false
    end
    
    local function IsOutOfRange(obj)
        if obj:IsA("BasePart") then
            local x = obj.Position.X
            return x < XMin or x > XMax
        end
        return false
    end
    
    local function IsBase(obj)
        if not obj:IsA("BasePart") then return false end
        local nl = obj.Name:lower()
        for _, n in ipairs(BASE_NAMES) do
            if nl:find(n, 1, true) then return true end
        end
        return false
    end
    
    local function IsInBase(obj)
        local p = obj.Parent
        while p and p ~= workspace do
            if IsBase(p) then return true end
            p = p.Parent
        end
        return false
    end
    
    local function MakeTransparent(obj)
        pcall(function()
            if IsBase(obj) and not IsCharacterPart(obj) then
                obj.Transparency = 1
                obj.CastShadow = false
            end
        end)
    end
    
    local function StripObject(obj)
        pcall(function()
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                SafeDestroy(obj)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
                SafeDestroy(obj)
            elseif obj:IsA("SurfaceAppearance") then
                SafeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance = 0
            end
        end)
    end
    
    local function CleanObject(obj)
        pcall(function()
            if obj:IsA("SurfaceAppearance") then
                SafeDestroy(obj)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                    SafeDestroy(obj)
                end
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                SafeDestroy(obj)
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                SafeDestroy(obj)
            elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                SafeDestroy(obj)
            elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
                SafeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance = 0
            end
        end)
    end
    
    local function ApplyGreySky()
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") then obj:Destroy() end
            end
            local sky = Instance.new("Sky")
            sky.SkyboxBk = ""
            sky.SkyboxDn = ""
            sky.SkyboxFt = ""
            sky.SkyboxLf = ""
            sky.SkyboxRt = ""
            sky.SkyboxUp = ""
            sky.CelestialBodiesShown = false
            sky.Name = "_NukeSky"
            sky.Parent = Lighting
        end)
    end
    
    local function OptimizeLighting()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(60, 60, 60)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or
               v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
                v:Destroy()
            end
        end
        ApplyGreySky()
    end
    
    local function ApplyTerrain()
        pcall(function()
            local T = workspace.Terrain
            T.Decoration = false
            T.WaterWaveSize = 0
            T.WaterWaveSpeed = 0
            T.WaterReflectance = 0
            T.WaterTransparency = 1
        end)
    end
    
    local function OptimizeCharacter(char)
        if not char then return end
        task.spawn(function()
            task.wait(0.3)
            if not nukeEnabled then return end
            for _, obj in ipairs(char:GetDescendants()) do
                if IsClothing(obj) then
                    SafeDestroy(obj)
                else
                    CleanObject(obj)
                end
            end
        end)
    end
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
    
    pcall(function()
        if setfpscap then setfpscap(999) end
    end)
    
    table.insert(nukeThreads, task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        OptimizeLighting()
        ApplyTerrain()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not nukeEnabled then return end
            if IsBase(obj) then
                MakeTransparent(obj)
            elseif IsClothing(obj) then
                SafeDestroy(obj)
            elseif IsInBase(obj) then
            elseif IsCharacterPart(obj) then
            elseif IsOutOfRange(obj) then
                SafeDestroy(obj)
            else
                CleanObject(obj)
                StripObject(obj)
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            MakeTransparent(obj)
        end
    end))
    
    table.insert(nukeConns, workspace.DescendantAdded:Connect(function(obj)
        if not nukeEnabled then return end
        task.defer(function()
            if not nukeEnabled then return end
            if IsBase(obj) then
                MakeTransparent(obj)
                return
            end
            if IsClothing(obj) then
                SafeDestroy(obj)
            elseif IsInBase(obj) then
            elseif IsCharacterPart(obj) then
            elseif IsOutOfRange(obj) then
                SafeDestroy(obj)
            else
                CleanObject(obj)
                StripObject(obj)
            end
        end)
    end))
    
    table.insert(nukeConns, Lighting.DescendantAdded:Connect(function(obj)
        if not nukeEnabled then return end
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
            SafeDestroy(obj)
        end
    end))
    
    for _, plr in ipairs(Players:GetPlayers()) do
        OptimizeCharacter(plr.Character)
        table.insert(nukeConns, plr.CharacterAdded:Connect(OptimizeCharacter))
    end
    
    table.insert(nukeConns, Players.PlayerAdded:Connect(function(plr)
        table.insert(nukeConns, plr.CharacterAdded:Connect(OptimizeCharacter))
    end))
    
    table.insert(nukeThreads, task.spawn(function()
        while nukeEnabled do
            task.wait(15)
            pcall(function() collectgarbage("collect") end)
        end
    end))
    
    print("[HUSSIN] 🚀 Nuke Optimizer: ON")
end

local function nukeStop()
    nukeEnabled = false
    for _, c in ipairs(nukeConns) do
        pcall(function() c:Disconnect() end)
    end
    nukeConns = {}
    nukeThreads = {}
    print("[HUSSIN] 🚀 Nuke Optimizer: OFF")
end

-- ============================================================
-- REMOVE ACCESSORIES
-- ============================================================
local function removeAccDo()
    if not removeAccEnabled then return end
    local char = LP.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            if not removedAccessories[obj] then
                removedAccessories[obj] = true
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

local function removeAccStart()
    if removeAccEnabled then return end
    removeAccEnabled = true
    removeAccDo()
    removeAccConn = LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if removeAccEnabled then removeAccDo() end
    end)
    print("[HUSSIN] 🎭 Remove Accessories: ON")
end

local function removeAccStop()
    removeAccEnabled = false
    if removeAccConn then
        removeAccConn:Disconnect()
        removeAccConn = nil
    end
    removedAccessories = {}
    print("[HUSSIN] 🎭 Remove Accessories: OFF")
end

-- ============================================================
-- ANTI-LAG V2
-- ============================================================
local function applyAntiLagV2Obj(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _, t in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
    end)
end

local function enableAntiLagV2()
    if antiLagV2Enabled then return end
    antiLagV2Enabled = true
    
    antiLagDefBrightness = antiLagDefBrightness or Lighting.Brightness
    antiLagDefFog = antiLagDefFog or Lighting.FogEnd
    antiLagDefDiffuse = antiLagDefDiffuse or Lighting.EnvironmentDiffuseScale
    antiLagDefSpecular = antiLagDefSpecular or Lighting.EnvironmentSpecularScale
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
            or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") then
                e.Enabled = false
            end
        end)
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        applyAntiLagV2Obj(obj)
    end
    
    if antiLagV2Conn then antiLagV2Conn:Disconnect() end
    antiLagV2Conn = workspace.DescendantAdded:Connect(function(obj)
        if antiLagV2Enabled then applyAntiLagV2Obj(obj) end
    end)
    
    print("[HUSSIN] ⚡ Anti-Lag V2: ON")
end

local function disableAntiLagV2()
    if not antiLagV2Enabled then return end
    antiLagV2Enabled = false
    
    if antiLagV2Conn then
        antiLagV2Conn:Disconnect()
        antiLagV2Conn = nil
    end
    
    pcall(function()
        Lighting.GlobalShadows = true
        if antiLagDefBrightness then Lighting.Brightness = antiLagDefBrightness end
        if antiLagDefFog then Lighting.FogEnd = antiLagDefFog end
        if antiLagDefDiffuse then Lighting.EnvironmentDiffuseScale = antiLagDefDiffuse end
        if antiLagDefSpecular then Lighting.EnvironmentSpecularScale = antiLagDefSpecular end
        for _, e in pairs(Lighting:GetChildren()) do
            pcall(function()
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = true
                end
            end)
        end
    end)
    
    print("[HUSSIN] ⚡ Anti-Lag V2: OFF")
end

local function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < autoTPHeight then return end
    end
    hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z) * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

local function startAutoTP()
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
    autoTPConn = task.spawn(function()
        while autoTPEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
    end)
end

local function stopAutoTP()
    autoTPEnabled = false
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
end

local function toggleAutoTP()
    autoTPEnabled = not autoTPEnabled
    if autoTPEnabled then
        startAutoTP()
    else
        stopAutoTP()
    end
    autoSave()
end

-- ============================================================
-- BACKGROUND IMAGES
-- ============================================================
local BG_IMAGES = {
    [1] = "111530810423203",
    [2] = "121253258902365",
    [3] = "106051123817603",
}
local backgroundIndex = 0
local backgroundEnabled = false

-- ============================================================
-- SAVE / LOAD SYSTEM
-- ============================================================
local function saveConfig()
    local cfg = {
        normalSpeed = SpeedState.normalSpeed,
        carrySpeed = SpeedState.carrySpeed,
        laggerSpeed = SpeedState.laggerSpeed,
        laggerSteal = SpeedState.laggerSteal,
        isLaggerMode = SpeedState.isLaggerMode,
        speedActive = SpeedState.speedActive,
        autoStealEnabled = autoStealEnabled,
        STEAL_RADIUS = STEAL_RADIUS,
        STEAL_DURATION = STEAL_DURATION,
        infJumpOn = infJumpOn,
        antiRagOn = antiRagOn,
        batAimbotOn = batAimbotOn,
        tpBatToggled = tpBatToggled,
        medusaEnabled = medusaEnabled,
        laggerEnabled = laggerEnabled,
        carrySpeedEnabled = carrySpeedEnabled,
        autoCarrySpeedEnabled = autoCarrySpeedEnabled,
        antiLagEnabled = antiLagEnabled,
        stretchRezEnabled = stretchRezEnabled,
        stretchFOV = stretchFOV,
        playerESPEnabled = playerESPEnabled,
        backgroundIndex = backgroundIndex,
        backgroundEnabled = backgroundEnabled,
        activeSky = activeSky,
        autoTPEnabled = autoTPEnabled,
        autoTPHeight = autoTPHeight,
        nukeEnabled = nukeEnabled,
        removeAccEnabled = removeAccEnabled,
        antiLagV2Enabled = antiLagV2Enabled,
    }
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(cfg))
        end
    end)
end

local function loadConfig()
    local success, data = pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end
        return nil
    end)
    if success and data then
        if type(data.normalSpeed) == "number" then SpeedState.normalSpeed = data.normalSpeed end
        if type(data.carrySpeed) == "number" then SpeedState.carrySpeed = data.carrySpeed end
        if type(data.laggerSpeed) == "number" then SpeedState.laggerSpeed = data.laggerSpeed end
        if type(data.laggerSteal) == "number" then SpeedState.laggerSteal = data.laggerSteal end
        if type(data.isLaggerMode) == "boolean" then SpeedState.isLaggerMode = data.isLaggerMode end
        if type(data.speedActive) == "boolean" then SpeedState.speedActive = data.speedActive end
        if type(data.autoStealEnabled) == "boolean" then autoStealEnabled = data.autoStealEnabled end
        if type(data.STEAL_RADIUS) == "number" then STEAL_RADIUS = data.STEAL_RADIUS end
        if type(data.STEAL_DURATION) == "number" then STEAL_DURATION = data.STEAL_DURATION end
        if type(data.infJumpOn) == "boolean" then infJumpOn = data.infJumpOn end
        if type(data.antiRagOn) == "boolean" then antiRagOn = data.antiRagOn end
        if type(data.batAimbotOn) == "boolean" then batAimbotOn = data.batAimbotOn end
        if type(data.tpBatToggled) == "boolean" then tpBatToggled = data.tpBatToggled end
        if type(data.medusaEnabled) == "boolean" then medusaEnabled = data.medusaEnabled end
        if type(data.laggerEnabled) == "boolean" then laggerEnabled = data.laggerEnabled end
        if type(data.carrySpeedEnabled) == "boolean" then carrySpeedEnabled = data.carrySpeedEnabled end
        if type(data.autoCarrySpeedEnabled) == "boolean" then autoCarrySpeedEnabled = data.autoCarrySpeedEnabled end
        if type(data.antiLagEnabled) == "boolean" then antiLagEnabled = data.antiLagEnabled end
        if type(data.stretchRezEnabled) == "boolean" then stretchRezEnabled = data.stretchRezEnabled end
        if type(data.stretchFOV) == "number" then stretchFOV = data.stretchFOV end
        if type(data.playerESPEnabled) == "boolean" then playerESPEnabled = data.playerESPEnabled end
        if type(data.backgroundIndex) == "number" then backgroundIndex = data.backgroundIndex end
        if type(data.backgroundEnabled) == "boolean" then backgroundEnabled = data.backgroundEnabled end
        if data.activeSky then activeSky = data.activeSky end
        if type(data.autoTPEnabled) == "boolean" then autoTPEnabled = data.autoTPEnabled end
        if type(data.autoTPHeight) == "number" then autoTPHeight = data.autoTPHeight end
        if type(data.nukeEnabled) == "boolean" then nukeEnabled = data.nukeEnabled end
        if type(data.removeAccEnabled) == "boolean" then removeAccEnabled = data.removeAccEnabled end
        if type(data.antiLagV2Enabled) == "boolean" then antiLagV2Enabled = data.antiLagV2Enabled end
        return true
    end
    return false
end

loadConfig()

local function autoSave()
    task.spawn(saveConfig)
end

-- ============================================================
-- AUTO STEAL
-- ============================================================
local function updateTopBar()
    if not infoLabel then return end
    local fps = 60
    local ping = 0
    local framesCount = 0
    local last = tick()
    RunService.RenderStepped:Connect(function()
        framesCount = framesCount + 1
        if tick() - last >= 1 then
            fps = framesCount
            framesCount = 0
            last = tick()
        end
        local network = Stats:FindFirstChild("Network")
        if network and network:FindFirstChild("ServerStatsItem") then
            local dataPing = network.ServerStatsItem:FindFirstChild("Data Ping")
            if dataPing then ping = math.floor(dataPing:GetValue()) end
        end
        infoLabel.Text = "HUSSIN Hub | Ping: " .. ping .. "ms | FPS: " .. fps
    end)
end

local function setupUI()
    local sg = LP.PlayerGui:FindFirstChild("HUSSIN_Steal")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "HUSSIN_Steal"
        sg.ResetOnSpawn = false
        sg.Parent = LP.PlayerGui
    end

    if not progressBarBg then
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 260, 0, 70)
        container.Position = UDim2.new(0.5, -130, 0, 35)
        container.BackgroundTransparency = 1
        container.Parent = sg
        container.Active = false

        bannerFrame = Instance.new("Frame")
        bannerFrame.Size = UDim2.new(1, 0, 0, 30)
        bannerFrame.Position = UDim2.new(0, 0, 0, 0)
        bannerFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        bannerFrame.BackgroundTransparency = 0.85
        bannerFrame.BorderSizePixel = 0
        bannerFrame.Parent = container
        Instance.new("UICorner", bannerFrame).CornerRadius = UDim.new(0, 8)

        local bannerStroke = Instance.new("UIStroke", bannerFrame)
        bannerStroke.Color = Color3.fromRGB(0, 170, 0)
        bannerStroke.Thickness = 1.5

        infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.GothamBold
        infoLabel.TextSize = 14
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.Text = "HUSSIN Hub | Ping: 0ms | FPS: 0"
        infoLabel.TextXAlignment = Enum.TextXAlignment.Center
        infoLabel.Parent = bannerFrame

        progressBarBg = Instance.new("Frame")
        progressBarBg.Size = UDim2.new(1, 0, 0, 14)
        progressBarBg.Position = UDim2.new(0, 0, 0, 34)
        progressBarBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        progressBarBg.BackgroundTransparency = 0.25
        progressBarBg.Visible = true
        progressBarBg.Parent = container
        Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0, 10)

        progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        progressFill.Parent = progressBarBg
        Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 10)

        percentLabel = Instance.new("TextLabel")
        percentLabel.Size = UDim2.new(1, 0, 1, 0)
        percentLabel.BackgroundTransparency = 1
        percentLabel.Font = Enum.Font.GothamBold
        percentLabel.TextSize = 11
        percentLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        percentLabel.Text = "0%"
        percentLabel.Parent = progressBarBg

        updateTopBar()
    end
end

local function getHRP()
    local c = LP.Character
    if c then return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
    return nil
end

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

local function findNearestPrompt()
    local hrp = getHRP()
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearest, dist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            local base = pod:FindFirstChild("Base")
            if not base then continue end
            local spawn = base:FindFirstChild("Spawn")
            if not spawn then continue end
            local d = (spawn.Position - hrp.Position).Magnitude
            if d <= STEAL_RADIUS and d < dist then
                local att = spawn:FindFirstChild("PromptAttachment")
                if att then
                    for _, p in ipairs(att:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.ActionText and p.ActionText:find("Steal") then
                            nearest, dist = p, d
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function updateProgressBar(p)
    if progressFill then
        progressFill.Size = UDim2.new(p, 0, 1, 0)
    end
    if percentLabel then
        percentLabel.Text = math.floor(p * 100) .. "%"
    end
end

local function executeSteal(prompt)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                if c.Function then table.insert(StealData[prompt].hold, c.Function) end
            end
            for _, c in ipairs(getconnections(prompt.Triggered)) do
                if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
            end
        end
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    local startTime = tick()
    task.spawn(function()
        for _, f in ipairs(data.hold) do pcall(f) end
        while tick() - startTime < STEAL_DURATION do
            local elapsed = tick() - startTime
            local p = math.clamp(elapsed / STEAL_DURATION, 0, 1)
            updateProgressBar(p)
            task.wait()
        end
        updateProgressBar(1)
        for _, f in ipairs(data.trigger) do pcall(f) end
        task.wait(0.05)
        updateProgressBar(0)
        data.ready = true
        isStealing = false
    end)
end

local function startAutoStealLoop()
    if stealConn then return end
    setupUI()
    stealConn = RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then return end
        if isStealing then return end
        local success, prompt = pcall(findNearestPrompt)
        if success and prompt then
            pcall(executeSteal, prompt)
        end
    end)
end

local function stopAutoStealLoop()
    if stealConn then
        stealConn:Disconnect()
        stealConn = nil
    end
    isStealing = false
    updateProgressBar(0)
end

task.spawn(function()
    task.wait(1)
    if autoStealEnabled then startAutoStealLoop() end
end)

-- ============================================================
-- ANTI-LAG (الأصلي)
-- ============================================================
local function _applyAntiLagObj(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _,t in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
    end)
end

local function enableAntiLag()
    if antiLagEnabled then return end
    antiLagEnabled = true
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(80, 80, 80)
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
    
    for _,e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
            or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") then
                e.Enabled = false
            end
        end)
    end
    
    for _,obj in ipairs(workspace:GetDescendants()) do
        _applyAntiLagObj(obj)
    end
    autoSave()
end

local function disableAntiLag()
    if not antiLagEnabled then return end
    antiLagEnabled = false
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 1000
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end)
    autoSave()
end

-- ============================================================
-- STRETCH REZ
-- ============================================================
local function applyStretchFOV(val)
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = val end)
    end
end

local function enableStretchRez()
    stretchRezEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    if stretchRezConn then stretchRezConn:Disconnect() end
    if stretchFovConn then stretchFovConn:Disconnect() end
    
    stretchFovConn = RunService.RenderStepped:Connect(function()
        if stretchRezEnabled then
            applyStretchFOV(stretchFOV)
        end
    end)
    
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then
            if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
            return
        end
        if cam then
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.7, 0, 0, 0, 1)
        end
    end)
    autoSave()
end

local function disableStretchRez()
    stretchRezEnabled = false
    if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
    if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
    pcall(function()
        workspace.CurrentCamera.FieldOfView = 70
    end)
    autoSave()
end

-- ============================================================
-- SKY COLORS
-- ============================================================
local function clearColorCorr()
    if activeColorCorr then
        pcall(function() activeColorCorr:Destroy() end)
        activeColorCorr = nil
    end
end

local function restoreLighting()
    clearColorCorr()
    pcall(function()
        Lighting.Ambient = origLighting.Ambient
        Lighting.Brightness = origLighting.Brightness
        Lighting.ClockTime = origLighting.ClockTime
        Lighting.FogColor = origLighting.FogColor
        Lighting.FogEnd = origLighting.FogEnd
        Lighting.GlobalShadows = origLighting.GlobalShadows
        Lighting.EnvironmentDiffuseScale = origLighting.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = origLighting.EnvironmentSpecularScale
    end)
end

local function applySky(kind)
    if kind == nil or kind == "none" then
        restoreLighting()
        activeSky = nil
        autoSave()
        return
    end
    
    clearColorCorr()
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Parent = Lighting
    activeColorCorr = cc
    
    if kind == "blue" then
        Lighting.Ambient = Color3.fromRGB(30, 60, 120)
        Lighting.FogColor = Color3.fromRGB(40, 80, 160)
        cc.TintColor = Color3.fromRGB(140, 180, 255)
        cc.Saturation = 0.4
        cc.Contrast = 0.1
    elseif kind == "green" then
        Lighting.Ambient = Color3.fromRGB(40, 100, 60)
        Lighting.FogColor = Color3.fromRGB(50, 140, 80)
        cc.TintColor = Color3.fromRGB(160, 255, 180)
        cc.Saturation = 0.5
        cc.Contrast = 0.1
    elseif kind == "night" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.2
        Lighting.Ambient = Color3.fromRGB(20, 20, 35)
        cc.TintColor = Color3.fromRGB(180, 180, 220)
        cc.Saturation = -0.2
        cc.Contrast = 0.1
    elseif kind == "day" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        cc.TintColor = Color3.fromRGB(255, 255, 255)
        cc.Saturation = 0.1
        cc.Contrast = 0
    elseif kind == "sunset" then
        Lighting.ClockTime = 17.5
        Lighting.Brightness = 1.8
        Lighting.Ambient = Color3.fromRGB(180, 120, 80)
        Lighting.FogColor = Color3.fromRGB(200, 130, 80)
        cc.TintColor = Color3.fromRGB(255, 180, 120)
        cc.Saturation = 0.3
        cc.Contrast = 0.15
    elseif kind == "pink" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 1.6
        Lighting.Ambient = Color3.fromRGB(200, 100, 150)
        Lighting.FogColor = Color3.fromRGB(220, 120, 180)
        cc.TintColor = Color3.fromRGB(255, 150, 200)
        cc.Saturation = 0.2
        cc.Contrast = 0.1
    end
    activeSky = kind
    autoSave()
end

-- ============================================================
-- PLAYER ESP
-- ============================================================
local function createPlayerESP(player)
    if player == LP then return end
    if not player.Character then return end
    
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    
    if not hrp or not head then return end
    
    if playerESPObjects[player] then
        for _, obj in ipairs(playerESPObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        playerESPObjects[player] = nil
    end
    
    local objects = {}
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = hrp
    box.Color3 = Color3.fromRGB(0, 100, 255)
    box.Transparency = 0.5
    box.ZIndex = 0
    box.AlwaysOnTop = true
    box.Parent = hrp
    table.insert(objects, box)
    
    local line = Instance.new("SelectionBox")
    line.Adornee = hrp
    line.Color3 = Color3.fromRGB(0, 150, 255)
    line.LineThickness = 0.08
    line.Transparency = 0.3
    line.Parent = hrp
    table.insert(objects, line)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = head
    table.insert(objects, billboard)
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (" .. player.Name .. ")"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    table.insert(objects, nameLabel)
    
    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 11
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    table.insert(objects, distLabel)
    
    local speedLabel = Instance.new("TextLabel", billboard)
    speedLabel.Size = UDim2.new(1, 0, 0, 16)
    speedLabel.Position = UDim2.new(0, 0, 0, 38)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: 0"
    speedLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 11
    speedLabel.TextStrokeTransparency = 0
    speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    table.insert(objects, speedLabel)
    
    local speedConn = RunService.Heartbeat:Connect(function()
        if not playerESPEnabled or not player.Character or not hrp or not hrp.Parent then
            speedConn:Disconnect()
            return
        end
        
        local myChar = LP.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp and hrp then
            local dist = (myHrp.Position - hrp.Position).Magnitude
            distLabel.Text = math.floor(dist) .. "m"
        end
        
        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
        if vel then
            local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
            speedLabel.Text = string.format("Speed: %.1f", speed)
        end
    end)
    table.insert(objects, speedConn)
    
    playerESPObjects[player] = objects
end

local function removePlayerESP(player)
    if playerESPObjects[player] then
        for _, obj in ipairs(playerESPObjects[player]) do
            pcall(function() 
                if obj:IsA("RBXScriptConnection") then
                    obj:Disconnect()
                else
                    obj:Destroy()
                end
            end)
        end
        playerESPObjects[player] = nil
    end
end

local function togglePlayerESP(state)
    playerESPEnabled = state
    
    if state then
        for player, _ in pairs(playerESPObjects) do
            removePlayerESP(player)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                createPlayerESP(player)
            end
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if playerESPEnabled and player ~= LP then
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if playerESPEnabled and player.Character then
                        createPlayerESP(player)
                    end
                end)
                if player.Character then
                    task.wait(0.5)
                    createPlayerESP(player)
                end
            end
        end)
        table.insert(playerESPConns, playerAddedConn)
        
        local playerRemovedConn = Players.PlayerRemoving:Connect(function(player)
            removePlayerESP(player)
        end)
        table.insert(playerESPConns, playerRemovedConn)
        
        local characterAddedConn = LP.CharacterAdded:Connect(function()
            task.wait(1)
            if playerESPEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP then
                        removePlayerESP(player)
                        task.wait(0.1)
                        createPlayerESP(player)
                    end
                end
            end
        end)
        table.insert(playerESPConns, characterAddedConn)
        
    else
        for _, conn in ipairs(playerESPConns) do
            pcall(function() conn:Disconnect() end)
        end
        playerESPConns = {}
        
        for player, _ in pairs(playerESPObjects) do
            removePlayerESP(player)
        end
        playerESPObjects = {}
    end
    autoSave()
end

-- ============================================================
-- دوال الشخصية
-- ============================================================
local function onCharacterAdded(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if boostEnabled then
        task.wait(0.3)
        applyBoost()
    end
end

if LP.Character then onCharacterAdded(LP.Character) end
LP.CharacterAdded:Connect(onCharacterAdded)

-- ============================================================
-- AUTO LEFT
-- ============================================================
local AP_L1 = Vector3.new(-476.47, -6.28, 92.73)
local AP_L2 = Vector3.new(-483.12, -4.95, 94.81)
local alConn = nil
local alPhase = 1

local function stopAutoLeft()
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    autoLeftEnabled = false
end

local function startAutoLeft()
    if alConn then alConn:Disconnect() end
    alPhase = 1
    alConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local spd = 60
        if alPhase == 1 then
            local tgt = Vector3.new(AP_L1.X, hrp.Position.Y, AP_L1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP_L2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP_L1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP_L2.X, hrp.Position.Y, AP_L2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                autoLeftEnabled = false
                if alConn then alConn:Disconnect(); alConn = nil end
                alPhase = 1
                return
            end
            local d = AP_L2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

-- ============================================================
-- AUTO RIGHT
-- ============================================================
local AP_R1 = Vector3.new(-476.16, -6.52, 25.62)
local AP_R2 = Vector3.new(-483.06, -5.03, 25.48)
local arConn = nil
local arPhase = 1

local function stopAutoRight()
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    autoRightEnabled = false
end

local function startAutoRight()
    if arConn then arConn:Disconnect() end
    arPhase = 1
    arConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local spd = 60
        if arPhase == 1 then
            local tgt = Vector3.new(AP_R1.X, hrp.Position.Y, AP_R1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP_R2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP_R1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP_R2.X, hrp.Position.Y, AP_R2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                autoRightEnabled = false
                if arConn then arConn:Disconnect(); arConn = nil end
                arPhase = 1
                return
            end
            local d = AP_R2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UIS.JumpRequest:Connect(function()
    if infJumpOn then
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if infJumpOn then
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and UIS:IsKeyDown(Enum.KeyCode.Space) and root.Velocity.Y < 30 then
                root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
            end
        end
    end
end)

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not antiRagOn then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Physics or 
       st == Enum.HumanoidStateType.Ragdoll or 
       st == Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- DROP
-- ============================================================
local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED = 160
local _dropConn = nil
local dropActive = false

local function doDrop()
    if dropActive then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    dropActive = true
    local t0 = tick()
    if _dropConn then _dropConn:Disconnect() end
    _dropConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r or not dropActive then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            dropActive = false
            return
        end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            pcall(function()
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {c}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
                if rr then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    local off = ((hum and hum.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero
                end
            end)
            dropActive = false
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end

-- ============================================================
-- TP DOWN
-- ============================================================
local function doTpDown()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    local hipHeight = hum.HipHeight or 2
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { char }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -500, 0), rayParams)
    if rayResult then
        local newY = rayResult.Position.Y + hipHeight + 0.1
        root.CFrame = CFrame.new(root.Position.X, newY, root.Position.Z)
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
    end
end

-- ============================================================
-- RESET & MEDUSA
-- ============================================================
pcall(function()
    local orig
    orig = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
        if not resetRemote and self.Name:sub(1, 3) == "RE/" then
            resetRemote = self
        end
        return orig(self, ...)
    end))
end)

task.spawn(function()
    task.wait(1.5)
    if not resetRemote then
        for _, d in pairs(game:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name:sub(1, 3) == "RE/" then
                resetRemote = d
                break
            end
        end
    end
end)

local function doReset()
    if isResetting then return end
    if not resetRemote then return end
    isResetting = true
    local char = LP.Character
    if not char then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        task.wait(0.1)
        isResetting = false
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        task.wait(0.1)
        isResetting = false
        return
    end
    pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
    task.wait(0.2)
    isResetting = false
end

local function doInstaReset()
    if not resetRemote then return end
    local char = LP.Character
    if not char then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        return
    end
    local resetDetected = false
    local c = {}
    table.insert(c, hum.Died:Connect(function() resetDetected = true end))
    table.insert(c, char.AncestryChanged:Connect(function(_, p) if not p then resetDetected = true end end))
    table.insert(c, hum:GetPropertyChangedSignal("Health"):Connect(function() if hum.Health <= 0 then resetDetected = true end end))
    task.spawn(function()
        for i = 1, 60 do
            if resetDetected then break end
            pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
            task.wait()
        end
        for _, v in pairs(c) do v:Disconnect() end
    end)
end

local function cleanRagdoll(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum then
        local s = hum:GetState()
        if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
        end
        workspace.CurrentCamera.CameraSubject = hum
    end
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            d:Destroy()
        elseif d:IsA("Motor6D") and d.Enabled == false then
            d.Enabled = true
        end
    end
end

local function startMedusaLoops(char)
    local antiConn = RunService.Heartbeat:Connect(function()
        if not medusaEnabled then return end
        if not LP.Character then return end
        local c = LP.Character
        local hum = c:FindFirstChildOfClass("Humanoid")
        local root = c:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown)
        local endTime = LP:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then ragdolled = true end
        if ragdolled then
            pcall(function() LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            cleanRagdoll(c)
        end
    end)
    table.insert(medusaConns, antiConn)
    local medusaConn = RunService.Heartbeat:Connect(function()
        if not medusaEnabled or medusaDebounce then return end
        if not LP.Character then return end
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Anchored and part.Transparency == 1 then
                medusaDebounce = true
                doInstaReset()
                task.delay(0.4, function() medusaDebounce = false end)
                break
            end
        end
    end)
    table.insert(medusaConns, medusaConn)
    local descConn = char.DescendantAdded:Connect(function(part)
        if not medusaEnabled then return end
        if part:IsA("BasePart") then
            table.insert(medusaConns, part:GetPropertyChangedSignal("Anchored"):Connect(function()
                if not medusaEnabled or medusaDebounce then return end
                if part.Anchored and part.Transparency == 1 then
                    medusaDebounce = true
                    doInstaReset()
                    task.delay(0.4, function() medusaDebounce = false end)
                end
            end))
        end
    end)
    table.insert(medusaConns, descConn)
end

local function stopMedusa()
    for _, c in pairs(medusaConns) do
        pcall(function() c:Disconnect() end)
    end
    medusaConns = {}
    medusaDebounce = false
end

local function setupMedusa(char)
    stopMedusa()
    if not medusaEnabled then return end
    task.wait(0.1)
    startMedusaLoops(char)
end

-- ============================================================
-- NAME TAG
-- ============================================================
local function createNameTag()
    local oldTag = LP.PlayerGui:FindFirstChild("NameTag")
    if oldTag then oldTag:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NameTag"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LP.PlayerGui
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = playerName
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 20
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not nameTagEnabled then
            if gui then gui:Destroy() end
            if conn then conn:Disconnect() end
            return
        end
        local char = LP.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
        if onScreen then
            frame.Position = UDim2.new(0, pos.X - 100, 0, pos.Y - 50)
            frame.Visible = true
        else
            frame.Visible = false
        end
    end)
    
    return gui
end

-- ============================================================
-- الواجهة الرئيسية
-- ============================================================
local function CreateMainGUI()
    local WHITE = Color3.fromRGB(255,255,255)
    local MAUVE_PALE = Color3.fromRGB(220, 200, 240)
    local DARK = Color3.fromRGB(10, 8, 15)

    local gui = Instance.new("ScreenGui")
    gui.Name = "HUSSIN_V1"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.IgnoreGuiInset = true
    gui.Parent = LP:WaitForChild("PlayerGui")

    local titleBar = Instance.new("Frame", gui)
    titleBar.Size = UDim2.new(0, 160, 0, 30)
    titleBar.Position = UDim2.new(0.5, -80, 0, 8)
    titleBar.BackgroundColor3 = DARK
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

    local titleLbl = Instance.new("TextLabel", titleBar)
    titleLbl.Size = UDim2.new(0.7, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "HUSSIN V1"
    titleLbl.TextColor3 = WHITE
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local settingsBtn = Instance.new("TextButton", titleBar)
    settingsBtn.Size = UDim2.new(0, 26, 0, 26)
    settingsBtn.Position = UDim2.new(1, -34, 0.5, -13)
    settingsBtn.BackgroundTransparency = 1
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = MAUVE_PALE
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.TextSize = 16
    settingsBtn.BorderSizePixel = 0
    settingsBtn.ZIndex = 5
    settingsBtn.MouseButton1Click:Connect(function()
        CreateSettingsGUI()
    end)

    -- ====== الأزرار الجانبية ======
    local btnContainer = Instance.new("Frame", gui)
    btnContainer.Name = "BtnContainer"
    btnContainer.Size = UDim2.new(0, 200, 0, 310)
    btnContainer.Position = UDim2.new(1, -210, 0.35, -100)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Active = false

    local grid = Instance.new("UIGridLayout", btnContainer)
    grid.CellSize = UDim2.new(0, 58, 0, 58)
    grid.CellPadding = UDim2.new(0, 8, 0, 8)
    grid.StartCorner = Enum.StartCorner.TopLeft
    grid.SortOrder = Enum.SortOrder.LayoutOrder

    local btnData = {
        {id="reset", label="RESET", topRow=true},
        {id="tp", label="TP\nMODE", topRow=true},
        {id="drop", label="DROP"},
        {id="carry", label="CARRY\nSPEED"},
        {id="aimbot", label="AIMBOT"},
        {id="batmod", label="BAT\nMODE"},
        {id="lagger", label="LAGGER"},
        {id="left", label="AUTO\nLEFT"},
        {id="right", label="AUTO\nRIGHT"},
    }

    local buttonRefs = {}

    for _, data in ipairs(btnData) do
        local btn = Instance.new("TextButton", btnContainer)
        btn.Size = UDim2.new(0, 58, 0, 58)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Text = data.label
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.TextWrapped = true
        btn.TextScaled = false
        btn.LineHeight = 1.2
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(30, 132, 73)
        btnStroke.Thickness = 1.2
        btnStroke.Transparency = 0.3

        local isActive = false

        local function setActive(active)
            isActive = active
            if active then
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 132, 73),
                    BackgroundTransparency = 0
                }):Play()
                btnStroke.Color = Color3.fromRGB(30, 132, 73)
                btnStroke.Thickness = 1.5
                btnStroke.Transparency = 0
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0
                }):Play()
                btnStroke.Color = Color3.fromRGB(30, 132, 73)
                btnStroke.Thickness = 1.2
                btnStroke.Transparency = 0.3
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        
        if data.id == "lagger" and laggerEnabled then
            setActive(true)
            btn.Text = "ON"
        end
        if data.id == "tp" and tpBatToggled then
            setActive(true)
            btn.Text = "ON"
        end
        if data.id == "aimbot" and batAimbotOn then
            setActive(true)
            btn.Text = "ON"
        end
        if data.id == "left" and autoLeftEnabled then
            setActive(true)
            btn.Text = "ON"
        end
        if data.id == "right" and autoRightEnabled then
            setActive(true)
            btn.Text = "ON"
        end
        if data.id == "carry" and carrySpeedEnabled then
            setActive(true)
            btn.Text = "ON"
        end

        buttonRefs[data.id] = {btn = btn, setActive = setActive, isActive = isActive}

        btn.MouseButton1Click:Connect(function()
            if data.id == "drop" then
                doDrop()
                btn.Text = "✓"
                task.delay(0.4, function() btn.Text = "DROP" end)
            elseif data.id == "tp" then
                local newState = toggleBatMod()
                setActive(newState)
                btn.Text = newState and "ON" or "TP\nMODE"
            elseif data.id == "reset" then
                doReset()
                btn.Text = "✓"
                task.delay(0.4, function() btn.Text = "RESET" end)
            elseif data.id == "left" then
                autoLeftEnabled = not autoLeftEnabled
                setActive(autoLeftEnabled)
                if autoLeftEnabled then
                    if autoRightEnabled then
                        autoRightEnabled = false
                        stopAutoRight()
                        if buttonRefs.right then buttonRefs.right.setActive(false) end
                        if buttonRefs.right then buttonRefs.right.btn.Text = "AUTO\nRIGHT" end
                    end
                    startAutoLeft()
                else
                    stopAutoLeft()
                end
                btn.Text = autoLeftEnabled and "ON" or "AUTO\nLEFT"
            elseif data.id == "right" then
                autoRightEnabled = not autoRightEnabled
                setActive(autoRightEnabled)
                if autoRightEnabled then
                    if autoLeftEnabled then
                        autoLeftEnabled = false
                        stopAutoLeft()
                        if buttonRefs.left then buttonRefs.left.setActive(false) end
                        if buttonRefs.left then buttonRefs.left.btn.Text = "AUTO\nLEFT" end
                    end
                    startAutoRight()
                else
                    stopAutoRight()
                end
                btn.Text = autoRightEnabled and "ON" or "AUTO\nRIGHT"
            elseif data.id == "aimbot" then
                local newState = toggleBatAimbot()
                setActive(newState)
                btn.Text = newState and "ON" or "AIMBOT"
            elseif data.id == "batmod" then
                local newState = toggleBatMod()
                setActive(newState)
                btn.Text = newState and "ON" or "BAT\nMODE"
            elseif data.id == "lagger" then
                toggleLagger()
                setActive(laggerEnabled)
                btn.Text = laggerEnabled and "ON" or "LAGGER"
            elseif data.id == "carry" then
                local newState = toggleCarrySpeed()
                setActive(newState)
                btn.Text = newState and "ON" or "CARRY\nSPEED"
            end
        end)
    end

    print("[HUSSIN V1] ✅ تم التحميل")
end

-- ============================================================
-- نافذة الإعدادات
-- ============================================================
function CreateSettingsGUI()
    if CoreGui:FindFirstChild("HUSSIN_Settings") then
        CoreGui.HUSSIN_Settings:Destroy()
    end

    local WHITE = Color3.fromRGB(255, 255, 255)
    local TEXT_DIM = Color3.fromRGB(180, 180, 190)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local DARK = Color3.fromRGB(8, 8, 8)
    local DARK_CARD = Color3.fromRGB(15, 15, 15)
    local BORDER = Color3.fromRGB(40, 40, 45)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HUSSIN_Settings"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 340, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -270)
    MainFrame.BackgroundColor3 = BLACK
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Active = false
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local BgImage = Instance.new("ImageLabel", MainFrame)
    BgImage.Name = "SettingsBgImage"
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.Position = UDim2.new(0, 0, 0, 0)
    BgImage.BackgroundTransparency = 1
    BgImage.Image = "rbxassetid://113878558661506"
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.ZIndex = 0
    BgImage.ImageTransparency = 0.5
    Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 12)

    local Overlay = Instance.new("Frame", MainFrame)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 1
    Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 12)

    local borderGlow = Instance.new("Frame", MainFrame)
    borderGlow.Size = UDim2.new(1, 8, 1, 8)
    borderGlow.Position = UDim2.new(0, -4, 0, -4)
    borderGlow.BackgroundColor3 = BORDER
    borderGlow.BackgroundTransparency = 0.1
    borderGlow.BorderSizePixel = 0
    borderGlow.ZIndex = 0
    Instance.new("UICorner", borderGlow).CornerRadius = UDim.new(0, 14)

    local shadow = Instance.new("Frame", MainFrame)
    shadow.Size = UDim2.new(1, -4, 1, -4)
    shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 2
    TopBar.Parent = MainFrame

    local LogoFrame = Instance.new("ImageLabel")
    LogoFrame.Size = UDim2.new(0, 34, 0, 34)
    LogoFrame.Position = UDim2.new(0, 10, 0, 8)
    LogoFrame.BackgroundColor3 = DARK
    LogoFrame.BackgroundTransparency = 0.2
    LogoFrame.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LP.UserId .. "&width=420&height=420&format=png"
    LogoFrame.ZIndex = 3
    LogoFrame.Parent = TopBar
    Instance.new("UICorner", LogoFrame).CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 160, 0, 20)
    Title.Position = UDim2.new(0, 52, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "HUSSIN V1"
    Title.TextColor3 = WHITE
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 160, 0, 16)
    Subtitle.Position = UDim2.new(0, 52, 0, 28)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = LP.Name .. " | Settings"
    Subtitle.TextColor3 = TEXT_DIM
    Subtitle.TextSize = 10
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 24)
    CloseBtn.Position = UDim2.new(1, -38, 0, 8)
    CloseBtn.BackgroundColor3 = DARK
    CloseBtn.BackgroundTransparency = 0.2
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = TEXT_DIM
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    
    local closeStroke = Instance.new("UIStroke", CloseBtn)
    closeStroke.Color = BORDER
    closeStroke.Thickness = 0.8
    closeStroke.Transparency = 0.2
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(closeStroke, TweenInfo.new(0.15), {Transparency = 0, Thickness = 1.5}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(closeStroke, TweenInfo.new(0.15), {Transparency = 0.2, Thickness = 0.8}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -12, 0, 28)
    TabContainer.Position = UDim2.new(0, 6, 0, 56)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.Parent = TabContainer

    local tabs = {"SPEED", "COMBAT", "SETTINGS", "AUTO", "VISUAL"}
    local TabButtons = {}
    local ContentPages = {}
    local lo = 0
    local function LO() lo = lo + 1; return lo end

    local function CreateTab(text, active)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 56, 1, 0)
        btn.BackgroundColor3 = active and DARK or DARK_CARD
        btn.BackgroundTransparency = active and 0.1 or 0.3
        btn.Text = text
        btn.TextColor3 = active and WHITE or TEXT_DIM
        btn.TextSize = 8
        btn.Font = Enum.Font.GothamBold
        btn.Parent = TabContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = BORDER
        btnStroke.Thickness = 0.8
        btnStroke.Transparency = active and 0.1 or 0.5
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = active and 0.05 or 0.15}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = active and 0.1 or 0.3}):Play()
        end)
        return btn
    end

    for i, tabName in ipairs(tabs) do
        local isActive = (i == 1)
        local btn = CreateTab(tabName, isActive)
        TabButtons[tabName] = btn
    end

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, 400)
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame

    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = BORDER
        page.ScrollBarImageTransparency = 0.3
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = ContentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)
        layout.Parent = page
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 5)
        padding.Parent = page
        
        ContentPages[name] = page
        return page
    end

    local function CreateSection(title, parentPage)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.BackgroundTransparency = 1
        Section.Parent = parentPage
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, 0, 0, 16)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = TEXT_DIM
        TitleLabel.TextSize = 10
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Section
        
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 4)
        Layout.Parent = Section
        
        return Section
    end

    local function CreateToggle(parentPage, label, defaultVal, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 28)
        Row.BackgroundColor3 = DARK
        Row.BackgroundTransparency = 0.1
        Row.Parent = parentPage
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)
        
        local rowStroke = Instance.new("UIStroke", Row)
        rowStroke.Color = BORDER
        rowStroke.Thickness = 0.5
        rowStroke.Transparency = 0.3

        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(0, 120, 1, 0)
        LabelText.Position = UDim2.new(0, 12, 0, 0)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label
        LabelText.TextColor3 = WHITE
        LabelText.TextSize = 11
        LabelText.Font = Enum.Font.Gotham
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = Row

        local Switch = Instance.new("Frame")
        Switch.Size = UDim2.new(0, 38, 0, 18)
        Switch.Position = UDim2.new(1, -48, 0.5, -9)
        Switch.BackgroundColor3 = defaultVal and DARK or DARK_CARD
        Switch.BackgroundTransparency = 0.1
        Switch.Parent = Row
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

        local switchStroke = Instance.new("UIStroke", Switch)
        switchStroke.Color = defaultVal and BORDER or DARK
        switchStroke.Thickness = 1
        switchStroke.Transparency = 0.3

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Knob.BackgroundColor3 = defaultVal and WHITE or TEXT_DIM
        Knob.Parent = Switch
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local isOn = defaultVal
        
        local clickDetector = Instance.new("TextButton")
        clickDetector.Size = UDim2.new(1, 0, 1, 0)
        clickDetector.BackgroundTransparency = 1
        clickDetector.Text = ""
        clickDetector.Parent = Switch
        
        clickDetector.MouseButton1Click:Connect(function()
            isOn = not isOn
            Switch.BackgroundColor3 = isOn and DARK or DARK_CARD
            switchStroke.Color = isOn and BORDER or DARK
            TweenService:Create(Knob, TweenInfo.new(0.2), {
                Position = isOn and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }):Play()
            if callback then callback(isOn) end
            autoSave()
        end)

        return Row
    end

    local function CreateInput(parentPage, label, value, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 28)
        Row.BackgroundColor3 = DARK
        Row.BackgroundTransparency = 0.1
        Row.Parent = parentPage
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)
        
        local rowStroke = Instance.new("UIStroke", Row)
        rowStroke.Color = BORDER
        rowStroke.Thickness = 0.5
        rowStroke.Transparency = 0.3

        local LabelText = Instance.new("TextLabel")
        LabelText.Size = UDim2.new(0, 120, 1, 0)
        LabelText.Position = UDim2.new(0, 12, 0, 0)
        LabelText.BackgroundTransparency = 1
        LabelText.Text = label
        LabelText.TextColor3 = WHITE
        LabelText.TextSize = 11
        LabelText.Font = Enum.Font.Gotham
        LabelText.TextXAlignment = Enum.TextXAlignment.Left
        LabelText.Parent = Row

        local InputBox = Instance.new("TextBox")
        InputBox.Size = UDim2.new(0, 60, 0, 20)
        InputBox.Position = UDim2.new(1, -70, 0.5, -10)
        InputBox.BackgroundColor3 = DARK_CARD
        InputBox.BackgroundTransparency = 0.1
        InputBox.TextColor3 = TEXT_DIM
        InputBox.Text = value
        InputBox.TextSize = 11
        InputBox.Font = Enum.Font.Gotham
        InputBox.Parent = Row
        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)
        
        local boxStroke = Instance.new("UIStroke", InputBox)
        boxStroke.Color = BORDER
        boxStroke.Thickness = 0.5
        boxStroke.Transparency = 0.2
        
        InputBox.FocusLost:Connect(function()
            local n = tonumber(InputBox.Text)
            if n and callback then callback(n) end
            autoSave()
        end)
    end

    -- ====== SPEED PAGE ======
    local SpeedPage = CreatePage("SPEED")
    SpeedPage.Visible = true

    local NormalSection = CreateSection("NORMAL SPEED", SpeedPage)
    CreateInput(NormalSection, "Normal Speed", tostring(SpeedState.normalSpeed), function(v)
        if v >= 10 and v <= 200 then SpeedState.normalSpeed = v end
    end)
    CreateInput(NormalSection, "Carry Speed", tostring(SpeedState.carrySpeed), function(v)
        if v >= 10 and v <= 200 then SpeedState.carrySpeed = v end
    end)

    local LaggerSection = CreateSection("LAGGER SPEED", SpeedPage)
    CreateInput(LaggerSection, "Lagger Speed", tostring(SpeedState.laggerSpeed), function(v)
        if v >= 1 and v <= 200 then SpeedState.laggerSpeed = v end
    end)
    CreateInput(LaggerSection, "Lagger Steal", tostring(SpeedState.laggerSteal), function(v)
        if v >= 1 and v <= 200 then SpeedState.laggerSteal = v end
    end)
    CreateToggle(LaggerSection, "Lagger Mode", SpeedState.isLaggerMode, function(on)
        SpeedState.isLaggerMode = on
    end)
    CreateToggle(LaggerSection, "Speed Active", SpeedState.speedActive, function(on)
        SpeedState.speedActive = on
        if on then startSpeed() else stopSpeed() end
    end)

    -- ====== COMBAT PAGE ======
    local CombatPage = CreatePage("COMBAT")
    
    local BatSection = CreateSection("AUTO BAT", CombatPage)
    CreateToggle(BatSection, "Auto Bat (AIMBOT)", batAimbotOn, function(on)
        batAimbotOn = on
        if on then startBatAimbot() else stopBatAimbot() end
        autoSave()
    end)

    local BatModSection = CreateSection("TP BAT", CombatPage)
    CreateToggle(BatModSection, "Enable Bat Mod", tpBatToggled, function(on)
        tpBatToggled = on
        if on then
            local char = LP.Character
            if char then
                tpBatHRP = char:FindFirstChild("HumanoidRootPart")
                tpBatH = char:FindFirstChildOfClass("Humanoid")
            end
            startTPBatMod()
        else
            stopTPBatMod()
        end
        autoSave()
    end)

    -- ====== SETTINGS PAGE ======
    local SettingsPage = CreatePage("SETTINGS")
    local SettingsSection = CreateSection("GENERAL SETTINGS", SettingsPage)
    
    CreateToggle(SettingsSection, "Auto Carry Speed", autoCarrySpeedEnabled, function(on)
        autoCarrySpeedEnabled = on
        autoSave()
    end)
    
    CreateToggle(SettingsSection, "Anti-Lag", antiLagEnabled, function(on)
        if on then enableAntiLag() else disableAntiLag() end
    end)
    
    CreateToggle(SettingsSection, "Infinite Jump", infJumpOn, function(on)
        infJumpOn = on
    end)
    
    CreateToggle(SettingsSection, "Anti Ragdoll", antiRagOn, function(on)
        antiRagOn = on
    end)
    
    CreateToggle(SettingsSection, "Medusa Shield", medusaEnabled, function(on)
        medusaEnabled = on
        if on then 
            if LP.Character then setupMedusa(LP.Character) end 
        else 
            stopMedusa() 
        end
    end)
    
    CreateToggle(SettingsSection, "Player ESP", playerESPEnabled, function(on)
        togglePlayerESP(on)
    end)

    -- ====== الميزات الجديدة ======
    local NukeSection = CreateSection("OPTIMIZERS", SettingsPage)
    CreateToggle(NukeSection, "Nuke Optimizer", nukeEnabled, function(on)
        if on then nukeStart() else nukeStop() end
        autoSave()
    end)

    CreateToggle(NukeSection, "Remove Accessories", removeAccEnabled, function(on)
        if on then removeAccStart() else removeAccStop() end
        autoSave()
    end)

    CreateToggle(NukeSection, "Anti-Lag V2", antiLagV2Enabled, function(on)
        if on then enableAntiLagV2() else disableAntiLagV2() end
        autoSave()
    end)

    -- ====== AUTO PAGE ======
    local AutoPage = CreatePage("AUTO")
    AutoPage.Visible = false

    local AutoSection = CreateSection("AUTO STEAL", AutoPage)
    CreateToggle(AutoSection, "Auto Steal", autoStealEnabled, function(on)
        autoStealEnabled = on
        if on then startAutoStealLoop() else stopAutoStealLoop() end
    end)
    CreateInput(AutoSection, "Steal Radius", tostring(STEAL_RADIUS), function(v)
        if v >= 10 and v <= 300 then STEAL_RADIUS = v end
    end)
    CreateInput(AutoSection, "Steal Duration", tostring(STEAL_DURATION), function(v)
        if v >= 0.3 and v <= 5 then STEAL_DURATION = v end
    end)

    local AutoTPSection = CreateSection("AUTO TP", AutoPage)
    CreateToggle(AutoTPSection, "Auto TP", autoTPEnabled, function(on)
        toggleAutoTP()
    end)
    CreateInput(AutoTPSection, "TP Height", tostring(autoTPHeight), function(v)
        if v >= 2 and v <= 500 then 
            autoTPHeight = v
            autoSave()
        end
    end)

    -- ====== VISUAL PAGE ======
    local VisualPage = CreatePage("VISUAL")
    VisualPage.Visible = false

    local BgSection = CreateSection("BACKGROUND IMAGE", VisualPage)
    
    local BgRow = Instance.new("Frame")
    BgRow.Size = UDim2.new(1, 0, 0, 56)
    BgRow.BackgroundColor3 = DARK
    BgRow.BackgroundTransparency = 0.1
    BgRow.BorderSizePixel = 0
    BgRow.LayoutOrder = LO()
    BgRow.Parent = VisualPage
    Instance.new("UICorner", BgRow).CornerRadius = UDim.new(0, 5)

    local function makeBgPreview(imgId, posX, idx)
        local Preview = Instance.new("Frame", BgRow)
        Preview.Size = UDim2.new(0, 58, 0, 36)
        Preview.Position = UDim2.new(0, posX, 0.5, -18)
        Preview.BackgroundColor3 = DARK_CARD
        Preview.BackgroundTransparency = 0.1
        Preview.BorderSizePixel = 0
        Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 5)
        local Stroke = Instance.new("UIStroke", Preview)
        Stroke.Color = backgroundIndex == idx and BORDER or DARK
        Stroke.Thickness = backgroundIndex == idx and 1.5 or 0.8

        local Img = Instance.new("ImageLabel", Preview)
        Img.Size = UDim2.new(1, 0, 1, 0)
        Img.BackgroundTransparency = 1
        Img.Image = "rbxassetid://" .. imgId
        Img.ScaleType = Enum.ScaleType.Crop
        Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 5)

        local Btn = Instance.new("TextButton", Preview)
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        
        Btn.MouseButton1Click:Connect(function()
            backgroundIndex = idx
            BgImage.Image = "rbxassetid://" .. imgId
            BgImage.Visible = true
            Overlay.Visible = true
            for _, child in ipairs(BgRow:GetChildren()) do
                if child:IsA("Frame") and child ~= BgRow then
                    local st = child:FindFirstChildOfClass("UIStroke")
                    if st then
                        local num = tonumber(child.Position.X.Offset / 58 + 1)
                        st.Color = (num == idx) and BORDER or DARK
                        st.Thickness = (num == idx) and 1.5 or 0.8
                    end
                end
            end
            autoSave()
        end)
        return Preview, Stroke, Btn
    end

    makeBgPreview(BG_IMAGES[1], 8, 1)
    makeBgPreview(BG_IMAGES[2], 70, 2)
    makeBgPreview(BG_IMAGES[3], 132, 3)

    local nonePreview = Instance.new("Frame", BgRow)
    nonePreview.Size = UDim2.new(0, 50, 0, 36)
    nonePreview.Position = UDim2.new(0, 194, 0.5, -18)
    nonePreview.BackgroundColor3 = DARK_CARD
    nonePreview.BackgroundTransparency = 0.1
    nonePreview.BorderSizePixel = 0
    Instance.new("UICorner", nonePreview).CornerRadius = UDim.new(0, 5)
    local noneStroke = Instance.new("UIStroke", nonePreview)
    noneStroke.Color = backgroundIndex == 0 and BORDER or DARK
    noneStroke.Thickness = backgroundIndex == 0 and 1.5 or 0.8

    local noneText = Instance.new("TextLabel", nonePreview)
    noneText.Size = UDim2.new(1, 0, 1, 0)
    noneText.BackgroundTransparency = 1
    noneText.Text = "✕"
    noneText.TextColor3 = TEXT_DIM
    noneText.TextSize = 14
    noneText.Font = Enum.Font.GothamBold

    local noneBtn = Instance.new("TextButton", nonePreview)
    noneBtn.Size = UDim2.new(1, 0, 1, 0)
    noneBtn.BackgroundTransparency = 1
    noneBtn.Text = ""

    noneBtn.MouseButton1Click:Connect(function()
        backgroundIndex = 0
        BgImage.Visible = false
        Overlay.Visible = false
        for _, child in ipairs(BgRow:GetChildren()) do
            if child:IsA("Frame") and child ~= BgRow then
                local st = child:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = DARK
                    st.Thickness = 0.8
                end
            end
        end
        noneStroke.Color = BORDER
        noneStroke.Thickness = 1.5
        autoSave()
    end)

    local StretchSection = CreateSection("STRETCH REZ", VisualPage)
    CreateToggle(StretchSection, "Stretch Rez", stretchRezEnabled, function(on)
        stretchRezEnabled = on
        if on then enableStretchRez() else disableStretchRez() end
    end)

    local fovRow = Instance.new("Frame", VisualPage)
    fovRow.Size = UDim2.new(1, 0, 0, 36)
    fovRow.BackgroundColor3 = DARK
    fovRow.BackgroundTransparency = 0.1
    fovRow.Parent = VisualPage
    Instance.new("UICorner", fovRow).CornerRadius = UDim.new(0, 5)

    local fovLabel = Instance.new("TextLabel", fovRow)
    fovLabel.Size = UDim2.new(0.35, 0, 1, 0)
    fovLabel.Position = UDim2.new(0, 12, 0, 0)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "Stretch FOV"
    fovLabel.TextColor3 = WHITE
    fovLabel.TextSize = 10
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left

    local btnFrame = Instance.new("Frame", fovRow)
    btnFrame.Size = UDim2.new(0, 150, 0, 24)
    btnFrame.Position = UDim2.new(1, -162, 0.5, -12)
    btnFrame.BackgroundTransparency = 1

    local function makeFOVBtn(val, x)
        local btn = Instance.new("TextButton", btnFrame)
        btn.Size = UDim2.new(0, 44, 0, 24)
        btn.Position = UDim2.new(0, x, 0, 0)
        btn.BackgroundColor3 = DARK_CARD
        btn.BackgroundTransparency = 0.1
        btn.BorderSizePixel = 0
        btn.Text = tostring(val)
        btn.TextColor3 = TEXT_DIM
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        
        if val == stretchFOV then
            btn.BackgroundColor3 = DARK
            btn.TextColor3 = WHITE
        end
        
        btn.MouseButton1Click:Connect(function()
            stretchFOV = val
            if stretchRezEnabled then applyStretchFOV(val) end
            for _, b in ipairs(btnFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    local v = tonumber(b.Text)
                    TweenService:Create(b, TweenInfo.new(0.15), {
                        BackgroundColor3 = (v == val) and DARK or DARK_CARD,
                        TextColor3 = (v == val) and WHITE or TEXT_DIM
                    }):Play()
                end
            end
            autoSave()
        end)
        return btn
    end

    makeFOVBtn(90, 0)
    makeFOVBtn(120, 53)
    makeFOVBtn(180, 106)

    local gap1 = Instance.new("Frame", VisualPage)
    gap1.Size = UDim2.new(1, 0, 0, 6)
    gap1.BackgroundTransparency = 1
    gap1.BorderSizePixel = 0
    gap1.LayoutOrder = LO()

    -- ====== SKY COLORS ======
    local SkySection = CreateSection("SKY COLORS", VisualPage)

    local skyOptions = {
        {"Blue Sky", "blue"},
        {"Green Sky", "green"},
        {"Night Mode", "night"},
        {"Day Mode", "day"},
        {"Sunset", "sunset"},
        {"Pink Sky", "pink"},
    }

    local skyRow1 = Instance.new("Frame", VisualPage)
    skyRow1.Size = UDim2.new(1, 0, 0, 32)
    skyRow1.BackgroundTransparency = 1
    skyRow1.LayoutOrder = LO()

    local skyLayout1 = Instance.new("UIListLayout", skyRow1)
    skyLayout1.FillDirection = Enum.FillDirection.Horizontal
    skyLayout1.Padding = UDim.new(0, 4)
    skyLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local skyRow2 = Instance.new("Frame", VisualPage)
    skyRow2.Size = UDim2.new(1, 0, 0, 32)
    skyRow2.BackgroundTransparency = 1
    skyRow2.LayoutOrder = LO()

    local skyLayout2 = Instance.new("UIListLayout", skyRow2)
    skyLayout2.FillDirection = Enum.FillDirection.Horizontal
    skyLayout2.Padding = UDim.new(0, 4)
    skyLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function createSkyBtn(opt, parent)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 68, 0, 26)
        btn.BackgroundColor3 = DARK_CARD
        btn.BackgroundTransparency = 0.1
        btn.BorderSizePixel = 0
        btn.Text = opt[1]
        btn.TextColor3 = TEXT_DIM
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = BORDER
        stroke.Thickness = 0.5
        stroke.Transparency = 0.3
        
        if activeSky == opt[2] then
            btn.BackgroundColor3 = DARK
            btn.TextColor3 = WHITE
        end
        
        btn.MouseButton1Click:Connect(function()
            if activeSky == opt[2] then
                applySky(nil)
                activeSky = nil
                for _, b in ipairs(skyRow1:GetChildren()) do
                    if b:IsA("TextButton") then
                        TweenService:Create(b, TweenInfo.new(0.15), {
                            BackgroundColor3 = DARK_CARD,
                            TextColor3 = TEXT_DIM
                        }):Play()
                    end
                end
                for _, b in ipairs(skyRow2:GetChildren()) do
                    if b:IsA("TextButton") then
                        TweenService:Create(b, TweenInfo.new(0.15), {
                            BackgroundColor3 = DARK_CARD,
                            TextColor3 = TEXT_DIM
                        }):Play()
                    end
                end
            else
                applySky(opt[2])
                activeSky = opt[2]
                for _, b in ipairs(skyRow1:GetChildren()) do
                    if b:IsA("TextButton") then
                        local isActive = (b.Text == opt[1])
                        TweenService:Create(b, TweenInfo.new(0.15), {
                            BackgroundColor3 = isActive and DARK or DARK_CARD,
                            TextColor3 = isActive and WHITE or TEXT_DIM
                        }):Play()
                    end
                end
                for _, b in ipairs(skyRow2:GetChildren()) do
                    if b:IsA("TextButton") then
                        local isActive = (b.Text == opt[1])
                        TweenService:Create(b, TweenInfo.new(0.15), {
                            BackgroundColor3 = isActive and DARK or DARK_CARD,
                            TextColor3 = isActive and WHITE or TEXT_DIM
                        }):Play()
                    end
                end
            end
            autoSave()
        end)
        return btn
    end

    for i = 1, 3 do
        createSkyBtn(skyOptions[i], skyRow1)
    end

    for i = 4, 6 do
        createSkyBtn(skyOptions[i], skyRow2)
    end

    local resetSkyBtn = Instance.new("TextButton", VisualPage)
    resetSkyBtn.Size = UDim2.new(0.4, 0, 0, 26)
    resetSkyBtn.Position = UDim2.new(0.3, 0, 0, 0)
    resetSkyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    resetSkyBtn.BackgroundTransparency = 0.1
    resetSkyBtn.BorderSizePixel = 0
    resetSkyBtn.Text = "↺ Reset"
    resetSkyBtn.TextColor3 = Color3.fromRGB(200, 150, 150)
    resetSkyBtn.Font = Enum.Font.GothamBold
    resetSkyBtn.TextSize = 9
    resetSkyBtn.LayoutOrder = LO()
    Instance.new("UICorner", resetSkyBtn).CornerRadius = UDim.new(0, 5)

    resetSkyBtn.MouseEnter:Connect(function()
        TweenService:Create(resetSkyBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(60, 25, 25)
        }):Play()
    end)
    resetSkyBtn.MouseLeave:Connect(function()
        TweenService:Create(resetSkyBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        }):Play()
    end)

    resetSkyBtn.MouseButton1Click:Connect(function()
        applySky(nil)
        activeSky = nil
        for _, b in ipairs(skyRow1:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.15), {
                    BackgroundColor3 = DARK_CARD,
                    TextColor3 = TEXT_DIM
                }):Play()
            end
        end
        for _, b in ipairs(skyRow2:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.15), {
                    BackgroundColor3 = DARK_CARD,
                    TextColor3 = TEXT_DIM
                }):Play()
            end
        end
        autoSave()
    end)

    -- ====== التبديل بين التبويبات ======
    local function SetActiveTab(activeBtn, tabName)
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = DARK_CARD
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = TEXT_DIM
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = DARK
                stroke.Thickness = 0.8
                stroke.Transparency = 0.5
            end
        end
        activeBtn.BackgroundColor3 = DARK
        activeBtn.BackgroundTransparency = 0.1
        activeBtn.TextColor3 = WHITE
        local stroke = activeBtn:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = BORDER
            stroke.Thickness = 1.5
            stroke.Transparency = 0.1
        end

        for pName, pFrame in pairs(ContentPages) do
            pFrame.Visible = (pName == tabName)
        end
    end

    for tabName, btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            SetActiveTab(btn, tabName)
        end)
    end

    local Footer = Instance.new("Frame", MainFrame)
    Footer.Size = UDim2.new(1, 0, 0, 18)
    Footer.Position = UDim2.new(0, 0, 1, -18)
    Footer.BackgroundTransparency = 1

    local FooterText = Instance.new("TextLabel", Footer)
    FooterText.Size = UDim2.new(0, 100, 1, 0)
    FooterText.Position = UDim2.new(0, 10, 0, 0)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = "HUSSIN V1"
    FooterText.TextColor3 = TEXT_DIM
    FooterText.TextSize = 9
    FooterText.Font = Enum.Font.GothamBold
    FooterText.TextXAlignment = Enum.TextXAlignment.Left

    print("[Settings] تم التحميل")
end

-- ============================================================
-- الكيبورد
-- ============================================================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if UIS:GetFocusedTextBox() then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        local newState = toggleBatAimbot()
        if buttonRefs and buttonRefs.aimbot then
            buttonRefs.aimbot.setActive(newState)
            buttonRefs.aimbot.btn.Text = newState and "ON" or "AIMBOT"
        end
        print("[HUSSIN] ⌨️ AIMBOT: " .. tostring(newState))
        return
    end
    
    if input.KeyCode == Enum.KeyCode.X then
        doDrop()
        return
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        doReset()
        return
    end
    
    if input.KeyCode == Enum.KeyCode.T then
        doTpDown()
        return
    end
end)

-- ============================================================
-- إعداد الشخصية
-- ============================================================
local function setupChar(char)
    task.wait(0.1)
    h = char:FindFirstChildOfClass("Humanoid")
    if h then
        if SpeedState.speedActive then
            startSpeed()
        end
    end
    if batAimbotOn then
        task.wait(0.3)
        startBatAimbot()
    end
    if tpBatToggled then
        task.wait(0.3)
        tpBatHRP = char:FindFirstChild("HumanoidRootPart")
        tpBatH = char:FindFirstChildOfClass("Humanoid")
        startTPBatMod()
    end
    if medusaEnabled then setupMedusa(char) end
    if autoTPEnabled then startAutoTP() end
    if removeAccEnabled then removeAccDo() end
    
    if boostEnabled then
        task.wait(0.3)
        applyBoost()
    end
end

LP.CharacterAdded:Connect(setupChar)

-- ============================================================
-- Name Tag
-- ============================================================
task.spawn(function()
    task.wait(1)
    createNameTag()
end)

-- ============================================================
-- التشغيل
-- ============================================================
task.spawn(function()
    task.wait(1)
    if LP.Character then setupChar(LP.Character) end
    CreateMainGUI()
end)

-- تطبيق الإعدادات المحفوظة
if batAimbotOn then
    task.wait(0.5)
    startBatAimbot()
end
if tpBatToggled then
    task.wait(0.5)
    local char = LP.Character
    if char then
        tpBatHRP = char:FindFirstChild("HumanoidRootPart")
        tpBatH = char:FindFirstChildOfClass("Humanoid")
    end
    startTPBatMod()
end

if antiLagEnabled then enableAntiLag() end
if stretchRezEnabled then enableStretchRez() end
if playerESPEnabled then togglePlayerESP(true) end

if nukeEnabled then nukeStart() end
if removeAccEnabled then removeAccStart() end
if antiLagV2Enabled then enableAntiLagV2() end

if infJumpOn then
    task.spawn(function()
        task.wait(0.5)
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 0 end
        end
    end)
end

if activeSky then applySky(activeSky) end
if autoTPEnabled then startAutoTP() end

print("[HUSSIN V1] ✅ تم التحميل - جميع السرعات تستخدم WhaleHub Booster")
print("[HUSSIN V1] ✅ AIMBOT يوقف WhaleHub تلقائياً ويعيد تشغيله بعد الإيقاف")
print("[HUSSIN V1] ✅ CARRY SPEED + AUTO CARRY SPEED + NORMAL SPEED = WhaleHub")
print("[HUSSIN V1] ✅ LAGGER فقط يستخدم النظام القديم")
print("انضم إلي قناة التحدثات: https://whatsapp.com/channel/0029VapogxN5kg6wlEflyZ3M")
