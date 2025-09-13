--[[ 
📜 MENU UNIFICADO: AutoCraft Pills + HerbHub
- Cola no executor
- GUI organizado em abas
- Toggle flutuante para abrir/fechar
- AutoCraft mostra nível e XP de alquimia
- HerbHub com Attract TP
--]]

-- // Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ======================
-- ESTADO GLOBAL GUI
-- ======================
if game.CoreGui:FindFirstChild("UnifiedHub_GUI") then
    game.CoreGui.UnifiedHub_GUI:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "UnifiedHub_GUI"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui

-- FRAME PRINCIPAL
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 320)
frame.Position = UDim2.new(0, 60, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 1
frame.Parent = screen
frame.Active = true
frame.Visible = false -- começa escondido

-- DRAGGING
local dragging, dragStartPos, frameStartPos = false, nil, nil
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        frame.Position = UDim2.new(
            frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- BOTÃO TOGGLE FLUTUANTE
local toggleBtn = Instance.new("TextButton", screen)
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "📂 Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 120)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ======================
-- SISTEMA DE ABAS
-- ======================
local tabs = Instance.new("Frame", frame)
tabs.Size = UDim2.new(1, 0, 0, 30)
tabs.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1

local function makeTab(name, order)
    local btn = Instance.new("TextButton", tabs)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, (order-1)*100, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    return btn
end

-- Frames das abas
local autoCraftPage = Instance.new("Frame", content)
autoCraftPage.Size = UDim2.new(1, 0, 1, 0)
autoCraftPage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
autoCraftPage.Visible = true

local herbHubPage = Instance.new("Frame", content)
herbHubPage.Size = UDim2.new(1, 0, 1, 0)
herbHubPage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
herbHubPage.Visible = false

-- Alternância
local tab1 = makeTab("AutoCraft", 1)
local tab2 = makeTab("HerbHub", 2)

tab1.MouseButton1Click:Connect(function()
    autoCraftPage.Visible = true
    herbHubPage.Visible = false
end)
tab2.MouseButton1Click:Connect(function()
    autoCraftPage.Visible = false
    herbHubPage.Visible = true
end)

-- ======================
-- ABA: AUTOCRAFT PILLS
-- ======================
local CraftPill = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CraftPill")
local autoCraft = false
local craftThread = nil
local selectedAge = "100000"
local herbName = "Herb_Moonlight Flower_"

local function startCraft()
    if autoCraft then return end
    autoCraft = true
    craftThread = task.spawn(function()
        while autoCraft do
            local args = {
                herbName .. selectedAge,
                herbName .. selectedAge,
                herbName .. selectedAge,
                herbName .. selectedAge,
                5
            }
            pcall(function()
                CraftPill:FireServer(unpack(args))
            end)
            task.wait(0.3)
        end
    end)
end
local function stopCraft()
    autoCraft = false
end

-- BOTÃO
local toggleCraftBtn = Instance.new("TextButton", autoCraftPage)
toggleCraftBtn.Size = UDim2.new(0, 300, 0, 40)
toggleCraftBtn.Position = UDim2.new(0, 20, 0, 20)
toggleCraftBtn.Text = "Ativar AutoCraft"
toggleCraftBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleCraftBtn.TextColor3 = Color3.new(1,1,1)
toggleCraftBtn.Font = Enum.Font.SourceSansBold
toggleCraftBtn.TextSize = 18

toggleCraftBtn.MouseButton1Click:Connect(function()
    if autoCraft then
        stopCraft()
        toggleCraftBtn.Text = "Ativar AutoCraft"
        toggleCraftBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    else
        startCraft()
        toggleCraftBtn.Text = "Desativar AutoCraft"
        toggleCraftBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
    end
end)

-- Dropdown Idade
local ages = {"100000", "10000", "1000", "100", "10", "1"}
local ageBox = Instance.new("TextButton", autoCraftPage)
ageBox.Size = UDim2.new(0, 300, 0, 30)
ageBox.Position = UDim2.new(0, 20, 0, 70)
ageBox.Text = "Idade: " .. selectedAge
ageBox.BackgroundColor3 = Color3.fromRGB(50,50,100)
ageBox.TextColor3 = Color3.new(1,1,1)

local dropFrame = Instance.new("Frame", autoCraftPage)
dropFrame.Size = UDim2.new(0, 300, 0, #ages * 28)
dropFrame.Position = UDim2.new(0, 20, 0, 100)
dropFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
dropFrame.Visible = false

for i, age in ipairs(ages) do
    local opt = Instance.new("TextButton", dropFrame)
    opt.Size = UDim2.new(1, 0, 0, 28)
    opt.Position = UDim2.new(0, 0, 0, (i-1)*28)
    opt.Text = age
    opt.BackgroundColor3 = Color3.fromRGB(60,60,60)
    opt.TextColor3 = Color3.new(1,1,1)
    opt.MouseButton1Click:Connect(function()
        selectedAge = age
        ageBox.Text = "Idade: " .. selectedAge
        dropFrame.Visible = false
    end)
end
ageBox.MouseButton1Click:Connect(function()
    dropFrame.Visible = not dropFrame.Visible
end)

-- MOSTRAR XP E NÍVEL DE ALCHEMY
local masteryTxt = Instance.new("TextLabel", autoCraftPage)
masteryTxt.Size = UDim2.new(0, 300, 0, 20)
masteryTxt.Position = UDim2.new(0, 20, 0, 140)
masteryTxt.BackgroundTransparency = 1
masteryTxt.TextColor3 = Color3.new(1,1,1)
masteryTxt.Text = "Mastery: ..."

local expTxt = Instance.new("TextLabel", autoCraftPage)
expTxt.Size = UDim2.new(0, 300, 0, 20)
expTxt.Position = UDim2.new(0, 20, 0, 160)
expTxt.BackgroundTransparency = 1
expTxt.TextColor3 = Color3.new(1,1,1)
expTxt.Text = "Exp: ..."

task.spawn(function()
    while task.wait(1) do
        local gui = PlayerGui:FindFirstChild("ScreenGui")
        if gui and gui:FindFirstChild("Menu") then
            local inv = gui.Menu:FindFirstChild("Frame")
            if inv and inv:FindFirstChild("InventoryFrame") then
                local af = inv.InventoryFrame:FindFirstChild("AlchemyFrame")
                if af then
                    local expObj = af:FindFirstChild("ExpTxt")
                    local masteryObj = af:FindFirstChild("MasteryTxt")
                    if expObj and masteryObj then
                        expTxt.Text = "Exp: " .. expObj.Text
                        masteryTxt.Text = "Mastery: " .. masteryObj.Text
                    end
                end
            end
        end
    end
end)

-- Detecta função de request universal
local request = nil
if syn and syn.request then
    request = syn.request
elseif http_request then
    request = http_request
elseif request then
    request = request
elseif fluxus and fluxus.request then
    request = fluxus.request
else
    local HttpService = game:GetService("HttpService")
    request = function(options)
        return {
            Success = pcall(function()
                HttpService:PostAsync(
                    options.Url,
                    options.Body,
                    Enum.HttpContentType.ApplicationJson
                )
            end)
        }
    end
end

-- Webhook do Discord
local WEBHOOK_URL = "https://discord.com/api/webhooks/1413688514427486218/53ThJI4rnuvLx19UrONlm3BL6n3Gb37lX7AJ60Nvt8Kv2sfFz79dZKdkVwq8cCf29VlS"
local startTime = os.time()
local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function formatElapsed(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02dh %02dm %02ds", h, m, s)
end

local function safeText(path)
    local ok, result = pcall(function() return path.Text end)
    return ok and result or "N/A"
end

local function sendDiscordMessage(mastery, expText)
    local elapsed = os.time() - startTime

    -- pega valores adicionais
    local ss = safeText(PlayerGui.ScreenGui.Menu.Menu2.SpiritStone.Txt)
    local tRolls = safeText(PlayerGui.ScreenGui.Menu.Menu2.TalentRolls.Txt)
    local fRolls = safeText(PlayerGui.ScreenGui.Menu.Menu2.FamilyRolls.Txt)

    local oreIron = safeText(PlayerGui.ScreenGui.Menu.Frame.MiningFrame.WorkersFrame.Iron.Txt)
    local oreGold = safeText(PlayerGui.ScreenGui.Menu.Frame.MiningFrame.WorkersFrame.Gold.Txt)
    local oreRuby = safeText(PlayerGui.ScreenGui.Menu.Frame.MiningFrame.WorkersFrame.Ruby.Txt)

    -- monta mensagem final
    local msg = string.format(
        "Tempo online: %s\nAlchemy maes: %s\nExp Alchemy: %s\n💎Quantidade de SS: %s\n🌀Rolls de Talento: %s  |  🚩De Familia: %s\n⛏Quantidade de minerios:  IRON: %s  |  GOLD: %s  |  RUBY: %s",
        formatElapsed(elapsed),
        mastery,
        expText,
        ss,
        tRolls,
        fRolls,
        oreIron,
        oreGold,
        oreRuby
    )

    local payload = HttpService:JSONEncode({content = msg})
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end

-- Loop que envia a cada 5 segundos (teste)
task.spawn(function()
    while true do
        task.wait(600)
        sendDiscordMessage(masteryTxt.Text, expTxt.Text)
    end
end)

-- ======================
-- ABA: HERBHUB
-- ======================
local HerbsFolder = workspace:WaitForChild("Herbs")
local CollectHerbRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectHerb")
local Skill4Remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Skills"):WaitForChild("Skill4"):WaitForChild("Activate")

local pulling, pullingThread = false, nil
local autoCollect, autoCollectThread = false, nil
local anchorEnabled, anchorCFrame = false, nil

local function getHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end
local function getRootPartFromObject(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function pullHerbsToPlayer()
    if pulling then return end
    pulling = true
    pullingThread = task.spawn(function()
        while pulling do
            local hrp = getHRP()
            if hrp then
                local headAbove = hrp.Position + Vector3.new(0, 5.5, 0)
                for _, herb in ipairs(HerbsFolder:GetChildren()) do
                    local root = getRootPartFromObject(herb)
                    if root then
                        root.CFrame = CFrame.new(headAbove + Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end
local function stopPulling() pulling = false end

local function collectAllNow()
    for _, herb in ipairs(HerbsFolder:GetChildren()) do
        for _, part in ipairs(herb:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                CollectHerbRemote:FireServer(part)
                task.wait(0.5)
            end
        end
    end
end

local function startAutoCollect()
    if autoCollect then return end
    autoCollect = true
    autoCollectThread = task.spawn(function()
        while autoCollect do
            for _, herb in ipairs(HerbsFolder:GetChildren()) do
                for _, part in ipairs(herb:GetChildren()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        CollectHerbRemote:FireServer(part)
task.wait(0.05)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end
local function stopAutoCollect() autoCollect = false end

local function setAnchor()
    local hrp = getHRP()
    if hrp then anchorCFrame = hrp.CFrame; anchorEnabled = true end
end
local function clearAnchor() anchorEnabled = false; anchorCFrame = nil end

LocalPlayer.CharacterAdded:Connect(function(char)
    if not anchorEnabled or not anchorCFrame then return end
    task.wait(1)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        for i=1,3 do
            hrp.CFrame = anchorCFrame
            task.wait(0.25)
        end
        if Skill4Remote then Skill4Remote:FireServer() end
    end
end)

-- Botões HerbHub
local function makeBtn(y, txt)
    local b = Instance.new("TextButton", herbHubPage)
    b.Size = UDim2.new(0, 300, 0, 32)
    b.Position = UDim2.new(0, 20, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(80,80,80)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 16
    b.Text = txt
    return b
end

local btnMagnet = makeBtn(20, "Ímã de Ervas (OFF)")
btnMagnet.MouseButton1Click:Connect(function()
    if pulling then 
        stopPulling()
        btnMagnet.Text="Ímã de Ervas (OFF)"
        btnMagnet.BackgroundColor3=Color3.fromRGB(120,30,30)
    else 
        pullHerbsToPlayer()
        btnMagnet.Text="Ímã de Ervas (ON)"
        btnMagnet.BackgroundColor3=Color3.fromRGB(20,150,20) 
    end
end)

local btnAutoCollect = makeBtn(60, "Auto Coletar (OFF)")
btnAutoCollect.MouseButton1Click:Connect(function()
    if autoCollect then 
        stopAutoCollect()
        btnAutoCollect.Text="Auto Coletar (OFF)"
        btnAutoCollect.BackgroundColor3=Color3.fromRGB(120,30,30)
    else 
        startAutoCollect()
        btnAutoCollect.Text="Auto Coletar (ON)"
        btnAutoCollect.BackgroundColor3=Color3.fromRGB(20,150,20) 
    end
end)

local btnCollectNow = makeBtn(100, "⚡ Coletar Agora")
btnCollectNow.BackgroundColor3 = Color3.fromRGB(30,110,190)
btnCollectNow.MouseButton1Click:Connect(collectAllNow)

local btnAnchor = makeBtn(140, "Âncora (OFF)")
btnAnchor.MouseButton1Click:Connect(function()
    if anchorEnabled then 
        clearAnchor()
        btnAnchor.Text="Âncora (OFF)"
        btnAnchor.BackgroundColor3=Color3.fromRGB(120,30,30)
    else 
        setAnchor()
        btnAnchor.Text="Âncora (ON)"
        btnAnchor.BackgroundColor3=Color3.fromRGB(20,150,20) 
    end
end)

-- ======================
-- BOTÃO: ATTRACT TP
-- ======================
local plantPositions = {
    ["Blood Flower"]     = CFrame.new(-1520.20142, 22.5533428, -3986.85571),
    ["Ginseng2"]         = CFrame.new(1492.98083, 5.57811737, -1127.26379),
    ["Ginseng3"]         = CFrame.new(241.119263, 6, -1345.15967, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Ginseng1"]         = CFrame.new(-1915.38123, 5.99999142, -994.244751, 0.999657929, 0.0261513311, -0.000366795459, -0.0261538941, 0.99954772, -0.0148434499, -2.15464243e-05, 0.014847965, 0.999889791),
    ["Lotus"]            = CFrame.new(1161.90088, 12.3708725, 431.83902, 0.948782086, -0.312628299, 0.0455648564, 0.31593135, 0.938857079, -0.136875108, 1.21332705e-05, 0.144260004, 0.989539802),
    ["Spirit Grass"]     = CFrame.new(-1429.65747, 16.3628483, 1006.74805),
    ["SP2"]         = CFrame.new(-1537.35608, 16.3737602, 418.096954, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Moonlight Flower"] = CFrame.new(1164.95801, 245, -4646.71191, 0.107544065, 0, 0.994200408, 0, 1, 0, -0.994200408, 0, 0.107544065)
}

local volcanoCFrame = CFrame.new(-1305.95667, 30.0674248, -4106.25439, 0.890702188, 0.0566254072, -0.451046765, -0.00185099617, 0.992655039, 0.12096487, 0.454583526, -0.106908783, 0.884264827)

local btnAttractTP = makeBtn(180, "Attract TP")
btnAttractTP.BackgroundColor3 = Color3.fromRGB(200, 150, 30)

btnAttractTP.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if not hrp then return end
    -- Teleporta para cada planta
    for _, cf in pairs(plantPositions) do
        hrp.CFrame = cf
        task.wait(1.5) -- cooldown de teleport
    end
    -- Teleporta para zona do vulcão
    hrp.CFrame = volcanoCFrame
end)
