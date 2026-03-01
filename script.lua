--// Jiggy Hub UI with Infinite Jump + God Mode + Obstacle-Only X-Ray, FPS + Ping, Draggable GUI, Red Dot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "JiggyHub"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN PANEL
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0.5, -130, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- OUTER NEON BORDER
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255, 0, 0)
border.Thickness = 1.8
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = frame

-- TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.BorderSizePixel = 0
title.Text = "Jiggy Hub Semi TP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- RED ACCENT LINE
local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 2)
line.Position = UDim2.new(0, 0, 0, 40)
line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
line.BorderSizePixel = 0
line.Parent = frame

--------------------------------------------------
-- FPS + PING LABEL
--------------------------------------------------

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -10, 0, 20)
stats.Position = UDim2.new(0, 5, 0, 45)
stats.BackgroundTransparency = 1
stats.Text = "FPS: 0 | PING: 0ms"
stats.TextColor3 = Color3.fromRGB(180, 180, 180)
stats.Font = Enum.Font.Gotham
stats.TextSize = 12
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Parent = frame

local fps = 0
local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
	frames += 1
	local now = tick()
	if now - lastTime >= 1 then
		fps = frames
		frames = 0
		lastTime = now

		local ping = "N/A"
		local network = StatsService:FindFirstChild("Network")
		if network then
			local serverStats = network:FindFirstChild("ServerStatsItem")
			if serverStats then
				local dataPing = serverStats:FindFirstChild("Data Ping")
				if dataPing then
					ping = math.floor(dataPing:GetValue())
				end
			end
		end

		stats.Text = "FPS: " .. fps .. " | PING: " .. ping .. "ms"
	end
end)

--------------------------------------------------
-- INFINITE JUMP + GOD MODE
--------------------------------------------------

local godModeEnabled = false

-- Infinite Jump
UIS.JumpRequest:Connect(function()
	if godModeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Keep health max and prevent death
RunService.Heartbeat:Connect(function()
	if godModeEnabled and LocalPlayer.Character then
		local char = LocalPlayer.Character
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			-- Prevent break joints from killing
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
					part.Anchored = false
				end
			end
		end
	end
end)

-- Prevent Humanoid from dying completely
local function preventDeath(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if godModeEnabled and humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(preventDeath)
if LocalPlayer.Character then
	preventDeath(LocalPlayer.Character)
end

--------------------------------------------------
-- TOGGLE CREATOR
--------------------------------------------------

local function createToggle(text, y, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.BorderSizePixel = 0
	btn.Text = text .. "  [OFF]"
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 1
	stroke.Parent = btn

	local on = false
	btn.MouseButton1Click:Connect(function()
		on = not on
		btn.Text = text .. (on and "  [ON]" or "  [OFF]")
		btn.TextColor3 = on and Color3.fromRGB(255,0,0) or Color3.fromRGB(200,200,200)
		if callback then callback(on) end
	end)

	return btn
end

-- INF JUMP Toggle
createToggle("INF JUMP", 75, function(state)
	godModeEnabled = state
end)

--------------------------------------------------
-- X-RAY SYSTEM (OBSTACLE ONLY)
--------------------------------------------------

local xrayEnabled = false
local xrayParts = {}

createToggle("X-RAY", 115, function(state)
	xrayEnabled = state

	for _, part in ipairs(workspace:GetDescendants()) do
		-- Only collidable BaseParts that are big enough (walls/obstacles)
		if part:IsA("BasePart") and part.CanCollide and part.Size.Magnitude > 2 and part.Name ~= "HumanoidRootPart" then
			if xrayEnabled then
				xrayParts[part] = part.Transparency
				part.Transparency = 0.5 -- see-through, collisions intact
			else
				if xrayParts[part] then
					part.Transparency = xrayParts[part]
				end
			end
		end
	end
end)

--------------------------------------------------
-- RED DOT SYSTEM
--------------------------------------------------

local redMarker

local placeButton = Instance.new("TextButton")
placeButton.Size = UDim2.new(1, -20, 0, 35)
placeButton.Position = UDim2.new(0, 10, 0, 155)
placeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
placeButton.BorderSizePixel = 0
placeButton.Text = "PLACE MARKER"
placeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
placeButton.Font = Enum.Font.GothamBold
placeButton.TextSize = 14
placeButton.Parent = frame

local placeCorner = Instance.new("UICorner")
placeCorner.CornerRadius = UDim.new(0, 10)
placeCorner.Parent = placeButton

placeButton.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local pos = character.HumanoidRootPart.Position

		if redMarker then redMarker:Destroy() end

		redMarker = Instance.new("Part")
		redMarker.Size = Vector3.new(1,1,1)
		redMarker.Anchored = true
		redMarker.CanCollide = false
		redMarker.Color = Color3.fromRGB(255,0,0)
		redMarker.Material = Enum.Material.Neon
		redMarker.Position = pos + Vector3.new(0,0.5,0)
		redMarker.Parent = workspace
	end
end)

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(1, -20, 0, 35)
tpButton.Position = UDim2.new(0, 10, 0, 200)
tpButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
tpButton.BorderSizePixel = 0
tpButton.Text = "TP TO MARKER"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 14
tpButton.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 10)
tpCorner.Parent = tpButton

tpButton.MouseButton1Click:Connect(function()
	if redMarker and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(redMarker.Position + Vector3.new(0,3,0))
	end
end)

--------------------------------------------------
-- ACTIVE LABEL
--------------------------------------------------

local active = Instance.new("TextLabel")
active.Size = UDim2.new(1, 0, 0, 30)
active.Position = UDim2.new(0, 0, 1, -30)
active.BackgroundTransparency = 1
active.Text = "ACTIVE"
active.TextColor3 = Color3.fromRGB(255, 0, 0)
active.Font = Enum.Font.GothamBold
active.TextSize = 18
active.Parent = frame

--------------------------------------------------
-- DRAGGABLE GUI
--------------------------------------------------

local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateInput(input)
	end
end)
