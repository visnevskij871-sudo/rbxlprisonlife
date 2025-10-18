local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local KeySystem = {
	_validKey = "PRISON-LIFE-FREE", -- ✅ Ключ для активации
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

local AntiBan = {
	_lastUpdate = tick(),
	_safeActions = 0,
	_randomDelays = true,
	_protectionEnabled = true
}

function AntiBan:SimulateHumanBehavior()
	if not self._protectionEnabled then return end
	if self._randomDelays and math.random(1, 100) < 30 then
		wait(math.random(0.1, 0.3))
	end
	local currentTime = tick()
	if currentTime - self._lastUpdate < 0.1 then
		self._safeActions = self._safeActions + 1
		if self._safeActions > 8 then
			wait(0.2)
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

local PrisonTool = {
	HitBoxEnabled = false,
	FlyEnabled = false,
	NoClipEnabled = false,
	GhostEnabled = false,

	HitBoxColor = Color3.fromRGB(255, 0, 0),
	HitBoxTransparency = 0.7,
	MaxHitBoxDistance = 300,

	HitBoxes = {},
	BodyVelocity = nil,
	Connections = {},
	UIMinimized = false,
	CurrentTab = "main",
	GUIInitialized = false -- ✅ Флаг для предотвращения дублирования GUI
}

function PrisonTool:ToggleHitBox()
	if not KeySystem:IsValid() then return end
	self.HitBoxEnabled = not self.HitBoxEnabled
	if self.HitBoxEnabled then
		self.Connections.hitbox = RunService.Heartbeat:Connect(function()
			AntiBan:SimulateHumanBehavior()
			self:UpdateHitBox()
		end)
	else
		if self.Connections.hitbox then
			self.Connections.hitbox:Disconnect()
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
end

function PrisonTool:CreateOrUpdateHitBox(otherPlayer, character, playerRoot)
	local hitBox = self.HitBoxes[otherPlayer]
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not rootPart or not humanoid then
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
		highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
		highlight.OutlineTransparency = 0.2
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
			billboard.Size = UDim2.new(0, 150, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 4, 0)
			billboard.AlwaysOnTop = true
			billboard.Adornee = rootPart
			billboard.Parent = hitBox

			local background = Instance.new("Frame")
			background.Size = UDim2.new(1, 0, 1, 0)
			background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			background.BackgroundTransparency = 0.4
			background.BorderSizePixel = 0
			background.Parent = billboard

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = background

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, 0, 0, 20)
			nameLabel.Position = UDim2.new(0, 0, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = otherPlayer.Name
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextSize = 10
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.Parent = billboard

			local infoLabel = Instance.new("TextLabel")
			infoLabel.Size = UDim2.new(1, 0, 0, 20)
			infoLabel.Position = UDim2.new(0, 0, 0, 20)
			infoLabel.BackgroundTransparency = 1
			infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			infoLabel.TextSize = 9
			infoLabel.Font = Enum.Font.Gotham
			infoLabel.Parent = billboard
		end

		local infoLabel = billboard:FindFirstChild("TextLabel")
		if infoLabel then
			infoLabel.Text = string.format("❤️ %dHP | 📏 %dm", health, math.floor(distance))
			infoLabel.TextColor3 = health < 30 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
		end
	end
end

function PrisonTool:ClearHitBox()
	for _, hitBox in pairs(self.HitBoxes) do
		hitBox:Destroy()
	end
	self.HitBoxes = {}
end

function PrisonTool:ToggleFly()
	if not KeySystem:IsValid() then return end
	self.FlyEnabled = not self.FlyEnabled
	local character = player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	if self.FlyEnabled then
		self.BodyVelocity = Instance.new("BodyVelocity")
		self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		self.BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
		self.BodyVelocity.Parent = humanoidRootPart

		self.Connections.fly = RunService.Heartbeat:Connect(function()
			if not self.FlyEnabled or not humanoidRootPart.Parent then
				self:ToggleFly()
				return
			end

			local camera = workspace.CurrentCamera
			local direction = Vector3.new()

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end

			if direction.Magnitude > 0 then
				direction = direction.Unit * 50
			end
			self.BodyVelocity.Velocity = direction
		end)
	else
		if self.BodyVelocity then self.BodyVelocity:Destroy() end
		if self.Connections.fly then self.Connections.fly:Disconnect() end
	end
end

function PrisonTool:ToggleNoClip()
	if not KeySystem:IsValid() then return end
	self.NoClipEnabled = not self.NoClipEnabled
	if self.NoClipEnabled then
		self.Connections.noclip = RunService.Heartbeat:Connect(function()
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
		if self.Connections.noclip then self.Connections.noclip:Disconnect() end
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

function PrisonTool:ToggleGhost()
	if not KeySystem:IsValid() then return end
	self.GhostEnabled = not self.GhostEnabled
	local character = player.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = self.GhostEnabled and 0.8 or 0
			end
		end
	end
end

function PrisonTool:CreateModernUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RbxlCheatsPrison"
	screenGui.Parent = player.PlayerGui
	screenGui.ResetOnSpawn = false

	local mainContainer = Instance.new("Frame")
	mainContainer.Size = UDim2.new(0, 650, 0, 350)
	mainContainer.Position = UDim2.new(0.5, -325, 0.02, 0)
	mainContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	mainContainer.BackgroundTransparency = 0.05
	mainContainer.BorderSizePixel = 0
	mainContainer.Visible = false
	mainContainer.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainContainer

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainContainer

	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 12)
	topBarCorner.Parent = topBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 250, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Rbxl Cheats - Prison Life"
	title.TextColor3 = Color3.fromRGB(255, 60, 60)
	title.TextSize = 16
	title.Font = Enum.Font.GothamBlack
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar

	local tgLabel = Instance.new("TextLabel")
	tgLabel.Size = UDim2.new(0, 200, 1, 0)
	tgLabel.Position = UDim2.new(0.5, -100, 0, 0)
	tgLabel.BackgroundTransparency = 1
	tgLabel.Text = "📢 t.me/rbxlcheats"
	tgLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
	tgLabel.TextSize = 12
	tgLabel.Font = Enum.Font.GothamBold
	tgLabel.Parent = topBar

	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 30, 0, 25)
	minimizeBtn.Position = UDim2.new(1, -65, 0.5, -12)
	minimizeBtn.Text = "─"
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
	minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeBtn.TextSize = 16
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 25)
	closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
	closeBtn.Text = "×"
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = topBar

	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, -20, 0, 35)
	tabContainer.Position = UDim2.new(0, 10, 0, 45)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = mainContainer

	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -20, 0, 255)
	contentContainer.Position = UDim2.new(0, 10, 0, 85)
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

	local function setupControlButton(button)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = button

		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(
					math.min(button.BackgroundColor3.R * 255 + 30, 255),
					math.min(button.BackgroundColor3.G * 255 + 30, 255),
					math.min(button.BackgroundColor3.B * 255 + 30, 255)
				)
			}):Play()
		end)

		button.MouseLeave:Connect(function()
			if button == minimizeBtn then
				TweenService:Create(button, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(60, 70, 90)
				}):Play()
			else
				TweenService:Create(button, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(180, 60, 60)
				}):Play()
			end
		end)
	end

	setupControlButton(minimizeBtn)
	setupControlButton(closeBtn)

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
			mainContainer.Size = UDim2.new(0, 650, 0, 40)
		else
			mainContainer.Size = UDim2.new(0, 650, 0, 350)
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

function PrisonTool:CreateTab(name, index, parent, active)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0.32, -5, 1, 0)
	tab.Position = UDim2.new(0.33 * index, 0, 0, 0)
	tab.Text = name
	tab.BackgroundColor3 = active and Color3.fromRGB(70, 80, 120) or Color3.fromRGB(50, 60, 80)
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.TextSize = 12
	tab.Font = Enum.Font.GothamBold
	tab.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tab

	tab.MouseEnter:Connect(function()
		if tab.BackgroundColor3 ~= Color3.fromRGB(70, 80, 120) then
			TweenService:Create(tab, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 70, 100)
			}):Play()
		end
	end)

	tab.MouseLeave:Connect(function()
		if tab.BackgroundColor3 ~= Color3.fromRGB(70, 80, 120) then
			TweenService:Create(tab, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(50, 60, 80)
			}):Play()
		end
	end)

	return tab
end

function PrisonTool:SwitchTab(activeTab, activeContent, otherTabs, otherContents)
	activeTab.BackgroundColor3 = Color3.fromRGB(70, 80, 120)
	activeContent.Visible = true

	for i, tab in ipairs(otherTabs) do
		tab.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
		otherContents[i].Visible = false
	end
end

function PrisonTool:CreateMainTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0.6, 0, 0, 35)
	keyInput.Position = UDim2.new(0.2, 0, 0, 20)
	keyInput.PlaceholderText = "Введите ключ активации..."
	keyInput.Text = ""
	keyInput.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
	keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyInput.Parent = content

	local activateBtn = Instance.new("TextButton")
	activateBtn.Size = UDim2.new(0.3, 0, 0, 35)
	activateBtn.Position = UDim2.new(0.65, 0, 0, 20)
	activateBtn.Text = "⚡ АКТИВИРОВАТЬ"
	activateBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 80)
	activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	activateBtn.TextSize = 12
	activateBtn.Font = Enum.Font.GothamBold
	activateBtn.Parent = content

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 150)
	infoLabel.Position = UDim2.new(0, 10, 0, 70)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Rbxl Cheats - Prison Life\n\n📢 Получите ключ в Telegram:\nhttps://t.me/rbxlcheats  \n\n⚡ Функции:\n• HitBox игроков с HP и расстоянием\n• Полёт по карте\n• NoClip сквозь стены\n• Режим призрака\n\n🛡️ Мощный антибан активирован\n\n⌨️ Управление:\nInsert - Открыть/Закрыть меню"
	infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoLabel.TextSize = 12
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextYAlignment = Enum.TextYAlignment.Top
	infoLabel.Parent = content

	activateBtn.MouseButton1Click:Connect(function()
		local key = keyInput.Text:upper()
		if key == "" then return end
		local success, message = KeySystem:Validate(key)
		if success then
			keyInput.Visible = false
			activateBtn.Visible = false
			infoLabel.Text = "✅ " .. message .. "\n\n⚡ Все функции разблокированы!\n\n🔴 Rbxl Cheats - Prison Life\n📢 Telegram: t.me/rbxlcheats\n🛡️ Антибан активен"
		else
			infoLabel.Text = "❌ " .. message .. "\n\n📢 Получите ключ в Telegram:\nhttps://t.me/rbxlcheats  "
		end
	end)

	return content
end

function PrisonTool:CreateVisualTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🔴 HitBox игроков", "Показывать хитбоксы с HP", 10, 10, content, function()
		self:ToggleHitBox()
	end)

	self:CreateFeatureButton("👻 Режим призрака", "Полупрозрачность", 10, 60, content, function()
		self:ToggleGhost()
	end)

	return content
end

function PrisonTool:CreateMovementTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🦅 Полёт", "Летать в воздухе", 10, 10, content, function()
		self:ToggleFly()
	end)

	self:CreateFeatureButton("👻 NoClip", "Проходить сквозь стены", 10, 60, content, function()
		self:ToggleNoClip()
	end)

	return content
end

function PrisonTool:CreateFeatureButton(name, tooltip, x, y, parent, callback)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Size = UDim2.new(0.45, 0, 0, 40)
	buttonFrame.Position = UDim2.new(0, x, 0, y)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = parent

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.Parent = buttonFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(80, 90, 110)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 70, 90)
		}):Play()
	end)

	button.MouseButton1Click:Connect(callback)

	return button
end

-- ✅ ЗАЩИТА СКРИПТА И ИНИЦИАЛИЗАЦИЯ GUI ПОСЛЕ ЗАГРУЗКИ ПЕРСОНАЖА
AntiBan:ProtectScript()

local function initGUI()
	if not PrisonTool.GUIInitialized then
		PrisonTool:CreateModernUI()
		PrisonTool.GUIInitialized = true
	end
end

if player.Character then
	initGUI()
else
	player.CharacterAdded:Connect(initGUI)
end

print("Rbxl Cheats - Prison Life загружен!")
print("📢 Telegram: https://t.me/rbxlcheats")
print("🔑 Ключ: PRISON-LIFE-FREE") -- ✅ Совпадает с _validKey
print("🛡️ Антибан система активирована")
print("⌨️ Insert - открыть/закрыть меню")
