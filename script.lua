local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local playerGui = player:WaitForChild("PlayerGui")

-- 🧬 Humanoid Tracking
local humanoid
local function updateHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	humanoid = char:WaitForChild("Humanoid", 5)
end
player.CharacterAdded:Connect(updateHumanoid)
updateHumanoid()

-- 🖥️ ScreenGui Setup
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "HackCoreUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

-- 🎛️ Main Panel
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 420, 0, 470)
panel.Position = UDim2.new(0.5, -210, 0.5, -235)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
panel.BackgroundTransparency = 0.5
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", panel)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 0)
stroke.Transparency = 0.2

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "⛧ ROVO V1 ⛧"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.TextScaled = true

-- 🧾 Terminal Log (Scrollable)
local logFrame = Instance.new("ScrollingFrame", panel)
logFrame.Position = UDim2.new(0, 20, 0, 50)
logFrame.Size = UDim2.new(1, -40, 0, 100)
logFrame.BackgroundTransparency = 1
logFrame.ScrollBarThickness = 4
logFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local log = Instance.new("TextLabel", logFrame)
log.Size = UDim2.new(1, 0, 0, 0)
log.BackgroundTransparency = 1
log.TextColor3 = Color3.fromRGB(0, 255, 0)
log.Font = Enum.Font.Code
log.TextSize = 14
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextWrapped = true
log.AutomaticSize = Enum.AutomaticSize.Y
log.Text = ""

local bootMsgs = {
	"[INIT] Protocol handshake complete",
	"[TRACE] IP masked (43.92.210.16)",
	"[INJECT] Flight override module loaded",
	"[SPOOF] Root permission elevated",
	"[LOG] Uplink ready. Awaiting command..."
}
for _, msg in ipairs(bootMsgs) do
	log.Text = log.Text .. msg .. "\n"
	wait(0.3)
end

-- 🎮 Button Panel
local tabFrame = Instance.new("Frame", panel)
tabFrame.Position = UDim2.new(0, 0, 0, 160)
tabFrame.Size = UDim2.new(1, 0, 1, -160)
tabFrame.BackgroundTransparency = 1

local function makeButton(text, y, callback)
	local btn = Instance.new("TextButton", tabFrame)
	btn.Position = UDim2.new(0, 20, 0, y)
	btn.Size = UDim2.new(0, 380, 0, 30)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.TextColor3 = Color3.fromRGB(0, 255, 0)
	btn.Font = Enum.Font.Code
	btn.TextScaled = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local glow = Instance.new("UIStroke", btn)
	glow.Thickness = 1
	glow.Color = Color3.fromRGB(0, 255, 0)
	glow.Transparency = 0.3

	btn.MouseButton1Click:Connect(callback)
end

-- 🚀 Flight System
local flying = false
local flySpeed = 50
local jumpPower = 100
local jumpBoost = false
local keysDown = {}

uis.InputBegan:Connect(function(input, gp)
	if not gp then keysDown[input.KeyCode] = true end
end)
uis.InputEnded:Connect(function(input, gp)
	if not gp then keysDown[input.KeyCode] = false end
end)

local function getFlyDirection()
	local dir = Vector3.zero
	if keysDown[Enum.KeyCode.W] then dir += Vector3.new(0, 0, -1) end
	if keysDown[Enum.KeyCode.S] then dir += Vector3.new(0, 0, 1) end
	if keysDown[Enum.KeyCode.A] then dir += Vector3.new(-1, 0, 0) end
	if keysDown[Enum.KeyCode.D] then dir += Vector3.new(1, 0, 0) end
	if keysDown[Enum.KeyCode.Space] then dir += Vector3.new(0, 1, 0) end
	if keysDown[Enum.KeyCode.LeftShift] then dir += Vector3.new(0, -1, 0) end
	return dir
end

runService.Heartbeat:Connect(function()
	if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local move = workspace.CurrentCamera.CFrame:VectorToWorldSpace(getFlyDirection()).Unit * flySpeed
		root.Velocity = move.Magnitude > 0 and move or Vector3.zero
	end
end)

-- 🕹️ Feature Buttons
makeButton("↯ Toggle Fly", 0, function()
	flying = not flying
	log.Text = log.Text .. "[FLY] " .. (flying and "Activated" or "Deactivated") .. "\n"
end)

makeButton("⤴ Jump Boost", 40, function()
	jumpBoost = not jumpBoost
	if humanoid then
		humanoid.JumpPower = jumpBoost and jumpPower or 50
		log.Text = log.Text .. "[JUMP] " .. (jumpBoost and "Enabled" or "Disabled") .. "\n"
	else
		log.Text = log.Text .. "[ERROR] Humanoid not found.\n"
	end
end)

makeButton("➕ Fly Speed +10", 80, function()
	flySpeed += 10
	log.Text = log.Text .. "[FLY] Speed now " .. tostring(flySpeed) .. "\n"
end)

makeButton("➕ Jump Power +10", 120, function()
	jumpPower += 10
	if humanoid and jumpBoost then
		humanoid.JumpPower = jumpPower
	end
	log.Text = log.Text .. "[JUMP] Power now " .. tostring(jumpPower) .. "\n"
end)

makeButton("📂 Toggle ShopGui", 160, function()
	local shopGui = playerGui:FindFirstChild("ShopGui")
	if shopGui then
		shopGui.Enabled = not shopGui.Enabled
		log.Text = log.Text .. "[SHOPGUI] Toggled: " .. tostring(shopGui.Enabled) .. "\n"
	else
		log.Text = log.Text .. "[SHOPGUI] Not found.\n"
	end
end)

makeButton("🗃 Hud_UI > Shop Frame", 200, function()
	local hud = playerGui:FindFirstChild("Hud_UI")
	local shop = hud and hud:FindFirstChild("Shop")
	if shop and shop:IsA("Frame") then
		shop.Visible = not shop.Visible
		log.Text = log.Text .. "[HUD SHOP] Visibility: " .. tostring(shop.Visible) .. "\n"
	else
		log.Text = log.Text .. "[HUD SHOP] Not found.\n"
	end
end)

makeButton("🧯 Kill Panel", 240, function()
	screenGui.Enabled = false
	flying = false
	log.Text = log.Text .. "[SYSTEM] HackCoreUI Terminated.\n"
end)

-- 🎮 Ctrl hotkey to toggle panel
uis.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.LeftControl then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

-- 🔗 Social Links Footer
local linkBar = Instance.new("Frame", panel)
linkBar.Size = UDim2.new(1, -40, 0, 30)
linkBar.Position = UDim2.new(0, 20, 1, -35)
linkBar.BackgroundTransparency = 1
linkBar.Name = "SocialLinks"

local layout = Instance.new("UIListLayout", linkBar)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 12)

local function createLink(label, url)
	local btn = Instance.new("TextButton", linkBar)
	btn.Size = UDim2.new(0, 120, 1, 0)
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(0, 255, 0)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Font = Enum.Font.Code
	btn.TextScaled = true
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn)
	local glow = Instance.new("UIStroke", btn)
	glow.Thickness = 0.5
	glow.Color = Color3.fromRGB(0, 255, 0)
	glow.Transparency = 0.2

	btn.MouseButton1Click:Connect(function()
		-- Safe logging without URL opening
		log.Text = log.Text .. "[SOCIAL] Clicked: " .. label .. "\n"
		-- Uncomment if using an executor that supports clipboard or URL opening:
		-- if setclipboard then setclipboard(url) end
	end)
end

-- 🌐 Replace with your actual links
createLink("Discord", "https://discord.gg/your-server")
createLink("Reddit", "https://www.reddit.com/r/your-subreddit")
createLink("GitHub", "https://github.com/your-project")
