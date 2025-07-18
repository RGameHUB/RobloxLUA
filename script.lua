local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")

-- Create GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "FakeHackGui"
screenGui.Enabled = true -- visible for loading animation

-- Loading Text
local loadingLabel = Instance.new("TextLabel", screenGui)
loadingLabel.Size = UDim2.new(0, 300, 0, 60)
loadingLabel.Position = UDim2.new(0.5, -150, 0.5, -30)
loadingLabel.BackgroundTransparency = 1
loadingLabel.TextColor3 = Color3.new(0, 1, 0)
loadingLabel.Font = Enum.Font.Code
loadingLabel.TextScaled = true

local loadingSequence = {
	"Loading Bypass...",
	"Loading Bypass..",
	"Loading Bypass.",
	"Loaded Bypass",
	"Loading...",
	"Loading..",
	"Loading.",
	"Loaded"
}

for _, msg in ipairs(loadingSequence) do
	loadingLabel.Text = msg
	wait(1)
end

loadingLabel:Destroy()

-- Main Panel
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 300, 0, 250)
panel.Position = UDim2.new(0.5, -150, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true

local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Fake Hack Panel"
title.TextColor3 = Color3.new(1, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- Features
local flyEnabled = false
local jumpBoostEnabled = false
local flySpeed = 50
local jumpPower = 100

local function makeButton(name, posY, callback)
	local btn = Instance.new("TextButton", panel)
	btn.Position = UDim2.new(0, 20, 0, posY)
	btn.Size = UDim2.new(0, 260, 0, 30)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true

	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(callback)
end

makeButton("Toggle Fly", 50, function()
	flyEnabled = not flyEnabled
end)

makeButton("Toggle Jump Boost", 90, function()
	jumpBoostEnabled = not jumpBoostEnabled
	if player.Character then
		player.Character:WaitForChild("Humanoid").JumpPower = jumpBoostEnabled and jumpPower or 50
	end
end)

makeButton("Fly Speed: +10", 130, function()
	flySpeed += 10
end)

makeButton("Jump Power: +10", 170, function()
	jumpPower += 10
	if jumpBoostEnabled and player.Character then
		player.Character:WaitForChild("Humanoid").JumpPower = jumpPower
	end
end)

makeButton("Toggle UI", 210, function()
	screenGui.Enabled = not screenGui.Enabled
end)

-- Fly mechanic
game:GetService("RunService").RenderStepped:Connect(function()
	if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.Velocity = Vector3.new(0, flySpeed, 0)
	end
end)

-- LeftCtrl toggles panel visibility
uis.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.LeftControl then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
