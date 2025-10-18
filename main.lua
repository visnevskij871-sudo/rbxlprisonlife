-- ==============================================================
-- 🚀 RBXL CHEATS - Prison Life v2.1 (Optimized & Enhanced)
-- 🔒 Официальный канал: https://t.me/rbxlcheats
-- ⚠️ Используйте на свой страх и риск. Все скрипты — из открытых источников.
-- ==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ==================== СИСТЕМА КЛЮЧЕЙ ====================
local KeySystem = {
	_validKey = "PRISON-LIFE-FREE",
	_activated = false
}

function KeySystem:Validate(inputKey)
	if self._activated then return true end
	if inputKey == self._validKey then
		self._activated = true
		return true, "✅ АКТИВИРОВАНО!"
	else
		return false, "❌ НЕВЕРНЫЙ КЛЮЧ!"
	end
end

function KeySystem:IsValid()
	return self._activated
end

-- ==================== АНТИБАН ====================
local AntiBan = {
	_lastUpdate = tick(),
	_safeActions = 0,
	_randomDelays = true,
	_protectionEnabled = true
}

function AntiBan:SimulateHumanBehavior()
	if not self._protectionEnabled then return end
	if self._randomDelays and math.random(1, 100) < 25 then
		wait(math.random(0.05, 0.2))
	end
	local currentTime = tick()
	if currentTime - self._lastUpdate < 0.08 then
		self._safeActions = self._safeActions + 1
		if self._safeActions > 10 then
			wait(0.15)
		end
	else
		self._safeActions = 0
	end
	self._lastUpdate = currentTime
end

function AntiBan:ProtectScript()
	pcall(function()
		script.Name = HttpService:GenerateGUID(false)
		getfenv(0).debug = nil
	end)
end

-- ==================== ОСНОВНОЙ ИНСТРУМЕНТ ====================
local PrisonTool = {
	Version = "v2.1",
	HitBoxEnabled = false,
	FlyEnabled = false,
	NoClipEnabled = false,
	GhostEnabled = false,

	HitBoxColor = Color3.fromRGB(255, 50, 50),
	HitBoxTransparency = 0.65,
	MaxHitBoxDistance = 1500, -- ✅ Увеличено до 1500 метров

	HitBoxes = {},
	BodyVelocity = nil,
	Connections = {},
	UIMinimized = false,
	CurrentTab = "main",
	GUIInitialized = false,
	Dragging = false,
	DragStart = nil,
	FrameStart = nil
}

-- ==================== HITBOX ====================
function PrisonTool:ToggleHitBox()
	if not KeySystem:IsValid() then return end
	self.HitBoxEnabled = not self.HitBoxEnabled
	if self.HitBoxEnabled then
		self.Connections.hitbox = RunService.RenderStepped:Connect(function()
			AntiBan:SimulateHumanBehavior()
			self:UpdateHitBox()
		end)
	else
		if self.Connections.hitbox then
			self.Connections.hitbox:Disconnect()
			self.Connections.hitbox = nil
		end
		self:ClearHitBox()
	end
end

function PrisonTool:UpdateHitBox()
	local playerCharacter = player.Character
	if not playerCharacter then return end
	local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local character = otherPlayer.Character
			if character then
				self:CreateOrUpdateHitBox(otherPlayer, character, playerRoot)
			end
		end
	end

	-- Удаляем hitbox'ы для отключённых игроков
	for otherPlayer, hitBox in pairs(self.HitBoxes) do
		if not otherPlayer or not otherPlayer.Character or not Players:GetPlayerFromCharacter(otherPlayer.Character) then
			if hitBox and hitBox.Parent then hitBox:Destroy() end
			self.HitBoxes[otherPlayer] = nil
		end
	end
end

function PrisonTool:CreateOrUpdateHitBox(otherPlayer, character, playerRoot)
	if not otherPlayer or not character or not playerRoot then return end

	local hitBox = self.HitBoxes[otherPlayer]
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not rootPart or not humanoid or not humanoid.Health then
		if hitBox then hitBox:Destroy() end
		self.HitBoxes[otherPlayer] = nil
		return
	end

	local distance = (playerRoot.Position - rootPart.Position).Magnitude
	if distance > self.MaxHitBoxDistance then
		if hitBox then hitBox:Destroy() end
		self.HitBoxes[otherPlayer] = nil
		return
	end

	if not hitBox then
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHitBox"
		highlight.FillColor = self.HitBoxColor
		highlight.FillTransparency = self.HitBoxTransparency
		highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
		highlight.OutlineTransparency = 0.3
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = character
		highlight.Parent = character
		self.HitBoxes[otherPlayer] = highlight
	end

	local hitBox = self.HitBoxes[otherPlayer]
	if hitBox then
		hitBox.FillColor = self.HitBoxColor
		hitBox.FillTransparency = self.HitBoxTransparency

		local health = math.floor(humanoid.Health)
		local billboard = hitBox:FindFirstChild("InfoBillboard")

		if not billboard then
			billboard = Instance.new("BillboardGui")
			billboard.Name = "InfoBillboard"
			billboard.Size = UDim2.new(0, 160, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 4, 0)
			billboard.AlwaysOnTop = true
			billboard.LightInfluence = 0
			billboard.ResetOnSpawn = false
			billboard.Adornee = rootPart
			billboard.Parent = hitBox

			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(1, 0, 1, 0)
			bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
			bg.BackgroundTransparency = 0.6
			bg.BorderSizePixel = 0
			bg.Parent = billboard

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = bg

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, 0, 0, 20)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = otherPlayer.Name
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextSize = 11
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.Parent = billboard

			local infoLabel = Instance.new("TextLabel")
			infoLabel.Name = "HPDistanceLabel"
			infoLabel.Size = UDim2.new(1, 0, 0, 20)
			infoLabel.Position = UDim2.new(0, 0, 0, 22)
			infoLabel.BackgroundTransparency = 1
			infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			infoLabel.TextSize = 10
			infoLabel.Font = Enum.Font.Gotham
			infoLabel.Parent = billboard
		end

		local infoLabel = billboard:FindFirstChild("HPDistanceLabel")
		if infoLabel then
			infoLabel.Text = string.format("❤️ %d HP | 📏 %d м", health, math.floor(distance))
			infoLabel.TextColor3 = health < 30 and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 255, 100)
		end
	end
end

function PrisonTool:ClearHitBox()
	for _, hitBox in pairs(self.HitBoxes) do
		if hitBox and hitBox.Parent then hitBox:Destroy() end
	end
	self.HitBoxes = {}
end

-- ==================== ПОЛЁТ ====================
function PrisonTool:ToggleFly()
	if not KeySystem:IsValid() then return end
	self.FlyEnabled = not self.FlyEnabled
	local character = player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	if self.FlyEnabled then
		if character:FindFirstChildOfClass("Humanoid") then
			character:FindFirstChildOfClass("Humanoid").PlatformStand = true
		end

		self.BodyVelocity = Instance.new("BodyVelocity")
		self.BodyVelocity.Velocity = Vector3.zero
		self.BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
		self.BodyVelocity.Parent = humanoidRootPart

		self.Connections.fly = RunService.RenderStepped:Connect(function()
			if not self.FlyEnabled or not humanoidRootPart.Parent then
				self:ToggleFly()
				return
			end

			local camera = workspace.CurrentCamera
			if not camera then return end

			local direction = Vector3.zero
			local speed = 100

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end

			if direction.Magnitude > 0 then
				direction = direction.Unit * speed
			end
			self.BodyVelocity.Velocity = direction
		end)
	else
		if self.BodyVelocity then
			self.BodyVelocity:Destroy()
			self.BodyVelocity = nil
		end
		if self.Connections.fly then
			self.Connections.fly:Disconnect()
			self.Connections.fly = nil
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
	end
end

-- ==================== NOCLIP ====================
function PrisonTool:ToggleNoClip()
	if not KeySystem:IsValid() then return end
	self.NoClipEnabled = not self.NoClipEnabled
	if self.NoClipEnabled then
		self.Connections.noclip = RunService.RenderStepped:Connect(function()
			local character = player.Character
			if character then
				for _, part in pairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if self.Connections.noclip then
			self.Connections.noclip:Disconnect()
			self.Connections.noclip = nil
		end
		local character = player.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end

-- ==================== ПРИЗРАК ====================
function PrisonTool:ToggleGhost()
	if not KeySystem:IsValid() then return end
	self.GhostEnabled = not self.GhostEnabled
	local character = player.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = self.GhostEnabled and 0.7 or 0
			end
		end
	end
end

-- ==================== UI: ПЕРЕТАСКИВАНИЕ ====================
local function makeDraggable(frame, dragBar)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			UserInputService.WindowFocused:Connect(function()
				if not dragging then return end
				local delta = UserInputService:GetMouseLocation() - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end)
		end
	end)

	dragBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- ==================== UI: СОЗДАНИЕ ====================
function PrisonTool:CreateModernUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RbxlCheats_v2.1"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainContainer = Instance.new("Frame")
	mainContainer.Size = UDim2.new(0, 680, 0, 380)
	mainContainer.Position = UDim2.new(0.5, -340, 0.1, 0)
	mainContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
	mainContainer.BackgroundTransparency = 0.1
	mainContainer.BorderSizePixel = 0
	mainContainer.Visible = false
	mainContainer.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = mainContainer

	-- Верхняя панель для перетаскивания
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainContainer

	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 14)
	topBarCorner.Parent = topBar

	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "RBXL CHEATS • Prison Life " .. self.Version
	title.TextColor3 = Color3.fromRGB(255, 80, 80)
	title.TextSize = 15
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar

	-- Telegram
	local tgLabel = Instance.new("TextLabel")
	tgLabel.Size = UDim2.new(0, 180, 1, 0)
	tgLabel.Position = UDim2.new(0.5, -90, 0, 0)
	tgLabel.BackgroundTransparency = 1
	tgLabel.Text = "📢 t.me/rbxlcheats"
	tgLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
	tgLabel.TextSize = 12
	tgLabel.Font = Enum.Font.Gotham
	tgLabel.Parent = topBar

	-- Кнопки
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 32, 0, 26)
	minimizeBtn.Position = UDim2.new(1, -68, 0.5, -13)
	minimizeBtn.Text = "─"
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
	minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeBtn.TextSize = 16
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 26)
	closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
	closeBtn.Text = "×"
	closeBtn.BackgroundColor3 = Color3.fromRGB(190, 70, 70)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = topBar

	-- Делаем окно перетаскиваемым
	makeDraggable(mainContainer, topBar)

	-- Контент
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, -20, 0, 36)
	tabContainer.Position = UDim2.new(0, 10, 0, 48)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = mainContainer

	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -20, 0, 260)
	contentContainer.Position = UDim2.new(0, 10, 0, 90)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = mainContainer

	local mainTab = self:CreateTab("ГЛАВНАЯ", 0, tabContainer, true)
	local visualTab = self:CreateTab("ВИЗУАЛ", 1, tabContainer, false)
	local movementTab = self:CreateTab("ПЕРЕДВИЖЕНИЕ", 2, tabContainer, false)

	local mainContent = self:CreateMainTab(contentContainer)
	local visualContent = self:CreateVisualTab(contentContainer)
	local movementContent = self:CreateMovementTab(contentContainer)

	mainContent.Visible = true
	visualContent.Visible = false
	movementContent.Visible = false

	-- Обработка кнопок
	local function setupControlButton(btn, normalColor, hoverColor)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
		end)
	end

	setupControlButton(minimizeBtn, Color3.fromRGB(60, 70, 90), Color3.fromRGB(80, 90, 110))
	setupControlButton(closeBtn, Color3.fromRGB(190, 70, 70), Color3.fromRGB(220, 90, 90))

	mainTab.MouseButton1Click:Connect(function()
		self:SwitchTab(mainTab, mainContent, {visualTab, movementTab}, {visualContent, movementContent})
		self.CurrentTab = "main"
	end)

	visualTab.MouseButton1Click:Connect(function()
		self:SwitchTab(visualTab, visualContent, {mainTab, movementTab}, {mainContent, movementContent})
		self.CurrentTab = "visual"
	end)

	movementTab.MouseButton1Click:Connect(function()
		self:SwitchTab(movementTab, movementContent, {mainTab, visualTab}, {mainContent, visualContent})
		self.CurrentTab = "movement"
	end)

	minimizeBtn.MouseButton1Click:Connect(function()
		self.UIMinimized = not self.UIMinimized
		if self.UIMinimized then
			mainContainer.Size = UDim2.new(0, 680, 0, 40)
		else
			mainContainer.Size = UDim2.new(0, 680, 0, 380)
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Insert then
			mainContainer.Visible = not mainContainer.Visible
		end
	end)

	self.MainContainer = mainContainer
end

-- ==================== ВСПОМОГАТЕЛЬНЫЕ UI ФУНКЦИИ ====================
function PrisonTool:CreateTab(name, index, parent, active)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0.32, -5, 1, 0)
	tab.Position = UDim2.new(0.333 * index, 0, 0, 0)
	tab.Text = name
	tab.BackgroundColor3 = active and Color3.fromRGB(70, 85, 130) or Color3.fromRGB(50, 60, 85)
	tab.TextColor3 = Color3.fromRGB(250, 250, 255)
	tab.TextSize = 12
	tab.Font = Enum.Font.GothamBold
	tab.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tab

	tab.MouseEnter:Connect(function()
		if tab.BackgroundColor3 ~= Color3.fromRGB(70, 85, 130) then
			TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 75, 110)}):Play()
		end
	end)

	tab.MouseLeave:Connect(function()
		if tab.BackgroundColor3 ~= Color3.fromRGB(70, 85, 130) then
			TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 60, 85)}):Play()
		end
	end)

	return tab
end

function PrisonTool:SwitchTab(activeTab, activeContent, otherTabs, otherContents)
	activeTab.BackgroundColor3 = Color3.fromRGB(70, 85, 130)
	activeContent.Visible = true
	for i, tab in ipairs(otherTabs) do
		tab.BackgroundColor3 = Color3.fromRGB(50, 60, 85)
		otherContents[i].Visible = false
	end
end

function PrisonTool:CreateMainTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0.55, 0, 0, 34)
	keyInput.Position = UDim2.new(0.22, 0, 0, 20)
	keyInput.PlaceholderText = "Введите ключ активации..."
	keyInput.Text = ""
	keyInput.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
	keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyInput.ClearTextOnFocus = false
	keyInput.Parent = content

	local activateBtn = Instance.new("TextButton")
	activateBtn.Size = UDim2.new(0.28, 0, 0, 34)
	activateBtn.Position = UDim2.new(0.68, 0, 0, 20)
	activateBtn.Text = "⚡ АКТИВИРОВАТЬ"
	activateBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 90)
	activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	activateBtn.TextSize = 12
	activateBtn.Font = Enum.Font.GothamBold
	activateBtn.Parent = content

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 160)
	infoLabel.Position = UDim2.new(0, 10, 0, 70)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Rbxl Cheats — Prison Life\n\n📢 Получите ключ в Telegram:\nhttps://t.me/rbxlcheats\n\n⚡ Функции:\n• HitBox до 1500 м с HP и дистанцией\n• Полёт по карте\n• NoClip сквозь стены\n• Режим призрака\n\n🛡️ Антибан v2.1 активирован\n\n⌨️ Insert — открыть/закрыть меню"
	infoLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
	infoLabel.TextSize = 12
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextYAlignment = Enum.TextYAlignment.Top
	infoLabel.Parent = content

	activateBtn.MouseButton1Click:Connect(function()
		local key = keyInput.Text:upper():gsub("%s+", "")
		if key == "" then return end
		local success, message = KeySystem:Validate(key)
		if success then
			keyInput.Visible = false
			activateBtn.Visible = false
			infoLabel.Text = "✅ " .. message .. "\n\n⚡ Все функции разблокированы!\n\n🔴 RBXL CHEATS — Prison Life " .. self.Version .. "\n📢 Telegram: t.me/rbxlcheats\n🛡️ Антибан активен"
		else
			infoLabel.Text = "❌ " .. message .. "\n\n📢 Получите ключ в Telegram:\nhttps://t.me/rbxlcheats"
		end
	end)

	return content
end

function PrisonTool:CreateVisualTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🔴 HitBox (до 1500 м)", "Показывать хитбоксы с HP и расстоянием", 10, 10, content, function()
		self:ToggleHitBox()
	end)

	self:CreateFeatureButton("👻 Режим призрака", "Сделать персонажа полупрозрачным", 10, 60, content, function()
		self:ToggleGhost()
	end)

	return content
end

function PrisonTool:CreateMovementTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🦅 Полёт", "Свободное перемещение в воздухе", 10, 10, content, function()
		self:ToggleFly()
	end)

	self:CreateFeatureButton("👻 NoClip", "Проходить сквозь любые объекты", 10, 60, content, function()
		self:ToggleNoClip()
	end)

	return content
end

function PrisonTool:CreateFeatureButton(name, desc, x, y, parent, callback)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Size = UDim2.new(0.45, 0, 0, 42)
	buttonFrame.Position = UDim2.new(0, x, 0, y)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = parent

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
	button.TextColor3 = Color3.fromRGB(250, 250, 255)
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.Parent = buttonFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(75, 85, 105)}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 65, 85)}):Play()
	end)

	button.MouseButton1Click:Connect(callback)

	-- Описание (необязательно, но улучшает UX)
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 14)
	descLabel.Position = UDim2.new(0, 0, 1, -14)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
	descLabel.TextSize = 9
	descLabel.Font = Enum.Font.Gotham
	descLabel.Parent = button

	return button
end

-- ==================== ИНИЦИАЛИЗАЦИЯ ====================
AntiBan:ProtectScript()

local function init()
	if PrisonTool.GUIInitialized then return end
	PrisonTool.GUIInitialized = true
	PrisonTool:CreateModernUI()
end

if player.Character then
	init()
else
	player.CharacterAdded:Connect(init)
end

print("✅ RBXL CHEATS — Prison Life " .. PrisonTool.Version .. " загружен!")
print("📢 Официальный канал: https://t.me/rbxlcheats")
print("🔑 Ключ активации: PRISON-LIFE-FREE")
print("🛡️ Антибан и оптимизация включены")
print("⌨️ Нажмите Insert, чтобы открыть меню")
