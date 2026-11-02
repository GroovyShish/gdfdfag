local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateHackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 70)
frame.Position = UDim2.new(0.5, -260, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local function createButton(text, posX, startColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 150, 0, 45)
	btn.Position = UDim2.new(0, posX, 0.5, -22)
	btn.BackgroundColor3 = startColor
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.BorderSizePixel = 0
	btn.Parent = frame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn
	return btn
end

local btnTornado = createButton("ВКЛЮЧИТЬ ТОРНАДО", 15, Color3.fromRGB(46, 204, 113))
local btnNoclip = createButton("ВКЛЮЧИТЬ НОКЛИП", 185, Color3.fromRGB(52, 152, 219))
local btnFly = createButton("ВКЛЮЧИТЬ ПОЛЕТ", 355, Color3.fromRGB(155, 89, 182))

local function tweenColor(btn, targetColor)
	TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
end

local RADIUS, SPEED, HEIGHT_OFFSET = 14, 5, 3
local isTornadoActive, tornadoConnection, angle = false, nil, 0

local function getUnanchoredParts()
	local parts = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj.Anchored then
			if not obj:FindFirstAncestorOfClass("Model") or not Players:GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model")) then
				table.insert(parts, obj)
			end
		end
	end
	return parts
end

btnTornado.MouseButton1Click:Connect(function()
	isTornadoActive = not isTornadoActive
	if isTornadoActive then
		btnTornado.Text = "ВЫКЛЮЧИТЬ ТОРНАДО"
		tweenColor(btnTornado, Color3.fromRGB(231, 76, 60))
		
		tornadoConnection = RunService.Heartbeat:Connect(function(deltaTime)
			local character = player.Character
			if not character or not character:FindFirstChild("HumanoidRootPart") then return end
			
			local centerPos = character.HumanoidRootPart.Position
			local parts = getUnanchoredParts()
			angle = angle + (SPEED * deltaTime)
			
			for i, part in ipairs(parts) do
				local partAngle = angle + (i * (math.pi * 2 / #parts))
				local offsetX = math.cos(partAngle) * RADIUS
				local offsetZ = math.sin(partAngle) * RADIUS
				local offsetY = math.sin(angle + i) * 2 + HEIGHT_OFFSET
				
				local targetPos = centerPos + Vector3.new(offsetX, offsetY, offsetZ)
				part.AssemblyLinearVelocity = (targetPos - part.Position) * 8
			end
		end)
	else
		btnTornado.Text = "ВКЛЮЧИТЬ ТОРНАДО"
		tweenColor(btnTornado, Color3.fromRGB(46, 204, 113))
		if tornadoConnection then tornadoConnection:Disconnect() tornadoConnection = nil end
		for _, part in ipairs(getUnanchoredParts()) do part.AssemblyLinearVelocity = Vector3.new(0,0,0) end
	end
end)

local isNoclipActive = false
local noclipConnection = nil

btnNoclip.MouseButton1Click:Connect(function()
	isNoclipActive = not isNoclipActive
	if isNoclipActive then
		btnNoclip.Text = "ВЫКЛЮЧИТЬ НОКЛИП"
		tweenColor(btnNoclip, Color3.fromRGB(230, 126, 34))
		
		noclipConnection = RunService.Stepped:Connect(function()
			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		btnNoclip.Text = "ВКЛЮЧИТЬ НОКЛИП"
		tweenColor(btnNoclip, Color3.fromRGB(52, 152, 219))
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	end
end)

local isFlying = false
local flyConnection = nil
local FLY_SPEED = 50

btnFly.MouseButton1Click:Connect(function()
	isFlying = not isFlying
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not hrp or not humanoid then isFlying = false return end
	
	if isFlying then
		btnFly.Text = "ВЫКЛЮЧИТЬ ПОЛЕТ"
		tweenColor(btnFly, Color3.fromRGB(192, 57, 43))
		
		humanoid.PlatformStand = true
		
		flyConnection = RunService.Heartbeat:Connect(function()
			local camera = workspace.CurrentCamera
			if not camera or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
			
			local currentHrp = player.Character.HumanoidRootPart
			local moveDirection = Vector3.new(0, 0, 0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDirection = moveDirection + camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDirection = moveDirection - camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDirection = moveDirection - camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDirection = moveDirection + camera.CFrame.RightVector
			end
			
			if moveDirection.Magnitude > 0 then
				currentHrp.AssemblyLinearVelocity = moveDirection.Unit * FLY_SPEED
			else
				currentHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end)
	else
		btnFly.Text = "ВКЛЮЧИТЬ ПОЛЕТ"
		tweenColor(btnFly, Color3.fromRGB(155, 89, 182))
		
		if flyConnection then
			flyConnection:Disconnect()
			flyConnection = nil
		end
		
		if humanoid then
			humanoid.PlatformStand = false
		end
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end
	end
end)
