local player     = game.Players.LocalPlayer
local uis        = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local Debris     = game:GetService("Debris")
local playerGui  = player:WaitForChild("PlayerGui")

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
screenGui.Name        = "HackCoreUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled     = true

-- 🎛️ Main Panel
local panel = Instance.new("Frame", screenGui)
panel.Size                   = UDim2.new(0, 420, 0, 710)
panel.Position               = UDim2.new(0.5, -210, 0.5, -235)
panel.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
panel.BackgroundTransparency = 0.5
panel.Active                 = true
panel.Draggable              = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", panel)
stroke.Thickness   = 2
stroke.Color       = Color3.fromRGB(0, 255, 0)
stroke.Transparency= 0.2

local title = Instance.new("TextLabel", panel)
title.Size               = UDim2.new(1, 0, 0, 40)
title.Text               = "⛧ ROVO V1 ⛧"
title.TextColor3         = Color3.fromRGB(0, 255, 0)
title.BackgroundTransparency = 1
title.Font               = Enum.Font.Code
title.TextScaled         = true

-- 🧾 Terminal Log (Scrollable)
local logFrame = Instance.new("ScrollingFrame", panel)
logFrame.Position             = UDim2.new(0, 20, 0, 50)
logFrame.Size                 = UDim2.new(1, -40, 0, 100)
logFrame.BackgroundTransparency = 1
logFrame.ScrollBarThickness   = 4
logFrame.AutomaticCanvasSize  = Enum.AutomaticSize.Y
logFrame.ScrollingDirection   = Enum.ScrollingDirection.Y

local log = Instance.new("TextLabel", logFrame)
log.Size               = UDim2.new(1, 0, 0, 0)
log.BackgroundTransparency = 1
log.TextColor3         = Color3.fromRGB(0, 255, 0)
log.Font               = Enum.Font.Code
log.TextSize           = 14
log.TextXAlignment     = Enum.TextXAlignment.Left
log.TextYAlignment     = Enum.TextYAlignment.Top
log.TextWrapped        = true
log.AutomaticSize      = Enum.AutomaticSize.Y
log.Text               = ""

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
tabFrame.Position           = UDim2.new(0, 0, 0, 160)
tabFrame.Size               = UDim2.new(1, 0, 1, -160)
tabFrame.BackgroundTransparency = 1

local function makeButton(text, y, callback)
	local btn = Instance.new("TextButton", tabFrame)
	btn.Position            = UDim2.new(0, 20, 0, y)
	btn.Size                = UDim2.new(0, 380, 0, 30)
	btn.Text                = text
	btn.BackgroundColor3    = Color3.fromRGB(25, 25, 25)
	btn.TextColor3          = Color3.fromRGB(0, 255, 0)
	btn.Font                = Enum.Font.Code
	btn.TextScaled          = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local glow = Instance.new("UIStroke", btn)
	glow.Thickness   = 1
	glow.Color       = Color3.fromRGB(0, 255, 0)
	glow.Transparency= 0.3

	btn.MouseButton1Click:Connect(callback)
end

-- 🚀 Flight System (unchanged)
local flying    = false
local flySpeed  = 50
local jumpPower = 100
local jumpBoost = false
local keysDown  = {}

uis.InputBegan:Connect(function(i,gp) if not gp then keysDown[i.KeyCode]=true end end)
uis.InputEnded:Connect(function(i,gp) if not gp then keysDown[i.KeyCode]=false end end)

local function getFlyDirection()
	local dir = Vector3.zero
	if keysDown[Enum.KeyCode.W] then dir+= Vector3.new(0,0,-1) end
	if keysDown[Enum.KeyCode.S] then dir+= Vector3.new(0,0,1) end
	if keysDown[Enum.KeyCode.A] then dir+= Vector3.new(-1,0,0) end
	if keysDown[Enum.KeyCode.D] then dir+= Vector3.new(1,0,0) end
	if keysDown[Enum.KeyCode.Space] then dir+=Vector3.new(0,1,0) end
	if keysDown[Enum.KeyCode.LeftShift] then dir+=Vector3.new(0,-1,0) end
	return dir
end

runService.Heartbeat:Connect(function()
	if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local move= workspace.CurrentCamera.CFrame:VectorToWorldSpace(getFlyDirection()).Unit*flySpeed
		root.Velocity = (move.Magnitude>0 and move) or Vector3.zero
	end
end)

-- 🕹️ Feature Buttons
makeButton("↯ Toggle Fly",      0, function()
	flying = not flying
	log.Text = log.Text.."[FLY] "..(flying and "Activated" or "Deactivated").."\n"
end)

makeButton("⤴ Jump Boost",    40, function()
	jumpBoost = not jumpBoost
	if humanoid then humanoid.JumpPower = jumpBoost and jumpPower or 50 end
	log.Text = log.Text.."[JUMP] "..(jumpBoost and "Enabled" or "Disabled").."\n"
end)

makeButton("➕ Fly Speed +10",  80, function()
	flySpeed+=10
	log.Text = log.Text.."[FLY] Speed now "..flySpeed.."\n"
end)

makeButton("➕ Jump Power +10",120, function()
	jumpPower+=10
	if humanoid and jumpBoost then humanoid.JumpPower = jumpPower end
	log.Text = log.Text.."[JUMP] Power now "..jumpPower.."\n"
end)

makeButton("📂 Toggle ShopGui",160, function()
	local shop = playerGui:FindFirstChild("ShopGui")
	if shop then
		shop.Enabled = not shop.Enabled
		log.Text = log.Text.."[SHOPGUI] Toggled: "..tostring(shop.Enabled).."\n"
	else
		log.Text = log.Text.."[SHOPGUI] Not found.\n"
	end
end)

makeButton("🗃 Hud_UI > Shop", 200, function()
	local hud  = playerGui:FindFirstChild("Hud_UI")
	local shop = hud and hud:FindFirstChild("Shop")
	if shop then
		shop.Visible = not shop.Visible
		log.Text = log.Text.."[HUD SHOP] Visibility: "..tostring(shop.Visible).."\n"
	else
		log.Text = log.Text.."[HUD SHOP] Not found.\n"
	end
end)

-- ── Teleport-to-Player ─────────────────────────────────────────────
local Players   = game:GetService("Players")
local tpIndex   = 0

makeButton("⇄ Teleport Player", 240, function()
	local list = Players:GetPlayers()
	if #list <= 1 then
		log.Text ..= "[TP] No other players to teleport to.\n"
		return
	end

	tpIndex = (tpIndex % #list) + 1
	local target = list[tpIndex]
	if target == player then
		tpIndex = (tpIndex % #list) + 1
		target = list[tpIndex]
	end

	local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		player.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0,5,0)
		log.Text ..= "[TP] Teleported to "..target.Name.."\n"
	else
		log.Text ..= "[TP] "..target.Name.." not available.\n"
	end
end)

-- ── Click TP Tool ─────────────────────────────────────────────────
local clickTP = false
local mouse   = player:GetMouse()

makeButton("📍 Click TP", 280, function()
	clickTP = not clickTP
	log.Text = log.Text
		.. "[TP] Click TP "
		.. (clickTP and "Enabled" or "Disabled")
		.. "\n"
end)

mouse.Button1Down:Connect(function()
	if not clickTP then return end

	local char = player.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = mouse.Hit.Position + Vector3.new(0,5,0)
		hrp.CFrame = CFrame.new(pos)
		log.Text = log.Text .. "[TP] Teleported to click.\n"
	end
end)

-- ── Infinite Jump ──────────────────────────────────────────────────
local infiniteJumpEnabled = false

makeButton("⇑ Infinite Jump", 320, function()
	infiniteJumpEnabled = not infiniteJumpEnabled
	log.Text ..= "[JUMP] Infinite Jump "..(infiniteJumpEnabled and "Enabled" or "Disabled").."\n"
end)

uis.JumpRequest:Connect(function()
	if infiniteJumpEnabled and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- 🔒 Close GUI Button
local closeGUI = Instance.new("TextButton", panel)
closeGUI.Name             = "CloseGUI"
closeGUI.Size             = UDim2.new(0, 120, 0, 28)
closeGUI.Position         = UDim2.new(1, -130, 0, 6)
closeGUI.Text             = "✖ Close"
closeGUI.Font             = Enum.Font.Code
closeGUI.TextColor3       = Color3.fromRGB(0, 255, 0)
closeGUI.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
closeGUI.AutoButtonColor  = false
Instance.new("UICorner", closeGUI).CornerRadius = UDim.new(0, 6)

local closeStroke = Instance.new("UIStroke", closeGUI)
closeStroke.Thickness    = 1
closeStroke.Color        = Color3.fromRGB(0, 255, 0)
closeStroke.Transparency = 0.3

closeGUI.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
	flying = false
	log.Text = log.Text.."[SYSTEM] GUI closed by user.\n"
end)

-- 🎮 Ctrl hotkey to toggle panel
uis.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.LeftControl then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

-- ── WalkSpeed Slider with Manual Input ─────────────────────────────
-- Assumes you already have:
--   tabFrame = your button container Frame
--   humanoid = tracked Humanoid from updateHumanoid()
--   log      = your log TextBox/TextLabel
--   uis      = UserInputService

local minSpeed, maxSpeed = 0, 200
local sliderY = 360  -- change as needed

-- Slider container
local sliderFrame = Instance.new("Frame", tabFrame)
sliderFrame.Name                   = "WalkSpeedSlider"
sliderFrame.Position               = UDim2.new(0, 20, 0, sliderY)
sliderFrame.Size                   = UDim2.new(0, 380, 0, 40)
sliderFrame.BackgroundTransparency = 1

-- Label
local label = Instance.new("TextLabel", sliderFrame)
label.Size               = UDim2.new(0, 120, 1, 0)
label.Position           = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text               = "WalkSpeed:"
label.TextColor3         = Color3.fromRGB(0,255,0)
label.Font               = Enum.Font.Code
label.TextScaled         = true

-- Manual input box
local inputBox = Instance.new("TextBox", sliderFrame)
inputBox.AnchorPoint        = Vector2.new(1, 0)
inputBox.Position           = UDim2.new(1, 0, 0, 0)
inputBox.Size               = UDim2.new(0, 60, 1, 0)
inputBox.BackgroundColor3   = Color3.fromRGB(25,25,25)
inputBox.TextColor3         = Color3.fromRGB(0,255,0)
inputBox.Font               = Enum.Font.Code
inputBox.TextScaled         = true
inputBox.ClearTextOnFocus   = false
inputBox.Text               = tostring(humanoid and humanoid.WalkSpeed or minSpeed)
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,4)

-- Track bar
local track = Instance.new("Frame", sliderFrame)
track.Position           = UDim2.new(0, 130, 0, 12)
track.Size               = UDim2.new(0, 200, 0, 16)
track.BackgroundColor3   = Color3.fromRGB(25,25,25)
Instance.new("UICorner", track).CornerRadius = UDim.new(0,8)

-- Knob
local knob = Instance.new("Frame", track)
knob.Name                = "Knob"
knob.Size                = UDim2.new(0, 16, 1, 0)
knob.Position            = UDim2.new(0, 0, 0, 0)
knob.BackgroundColor3    = Color3.fromRGB(0,255,0)
Instance.new("UICorner", knob).CornerRadius = UDim.new(0,8)

-- Helper to update knob & humanoid
local function setSpeed(speed)
	speed = math.clamp(math.floor(speed), minSpeed, maxSpeed)
	if humanoid then humanoid.WalkSpeed = speed end

	-- update knob position
	local rel = (speed - minSpeed) / (maxSpeed - minSpeed)
	knob.Position = UDim2.new(rel, -8, 0, 0)

	-- update inputBox text
	inputBox.Text = tostring(speed)

	log.Text = log.Text .. "[FLY] WalkSpeed set to "..speed.."\n"
end

-- Drag logic
local dragging = false
knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)
knob.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
uis.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = input.Position.X
		local rel = (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
		setSpeed(minSpeed + rel * (maxSpeed - minSpeed))
	end
end)

-- Manual input logic (on Enter or focus lost)
inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(inputBox.Text)
		if num then
			setSpeed(num)
		else
			-- reset to current speed on invalid input
			inputBox.Text = tostring(humanoid and humanoid.WalkSpeed or minSpeed)
		end
	end
end)

-- Initialize knob & inputBox
if humanoid then
	setSpeed(humanoid.WalkSpeed)
end

-- Player ESP Toggle
local espEnabled = false
makeButton("☢ Toggle ESP", 400, function()
	espEnabled = not espEnabled
	log.Text ..= "[ESP] "..(espEnabled and "Enabled" or "Disabled").."\n"

	for _, plr in ipairs(game.Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local h = hrp:FindFirstChild("HackESP")
				if espEnabled then
					if not h then
						h = Instance.new("Highlight", plr.Character)
						h.Name = "HackESP"
						h.FillColor = Color3.fromRGB(0,255,0)
						h.OutlineColor = Color3.fromRGB(0,0,0)
					end
				else
					if h then h:Destroy() end
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------
-- ▶️ Noclip Integration (Fix: properly disable collisions)
--------------------------------------------------------------------------------
-- State
local noclipEnabled = false

-- Helper: set CanCollide = false when noclipEnabled, true when disabled
local function applyNoclip(state)
	local char = player.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not state
		end
	end
end

-- Button (you already have makeButton)
makeButton("☵ Toggle Noclip", 440, function()
	noclipEnabled = not noclipEnabled
	log.Text = log.Text
		.. "[SYSTEM] Noclip " 
		.. (noclipEnabled and "Enabled" or "Disabled") 
		.. "\n"
	-- Apply immediately on toggle
	applyNoclip(noclipEnabled)
end)

-- Enforce collisions every frame
runService.Stepped:Connect(function()
	applyNoclip(noclipEnabled)
end)

-- Re-apply after character respawn
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart", 5)
	applyNoclip(noclipEnabled)
end)

-- 🔗 Social Links Footer (manual copy + auto‐destroy after 10s via Debris)

-- Services
local GuiService = game:GetService("GuiService")
local Debris     = game:GetService("Debris")

-- You must have these defined above:
-- local panel = <your main Frame inside ScreenGui>
-- local log   = <your TextLabel/TextBox for logging>

-- Create the link bar
local linkBar = Instance.new("Frame", panel)
linkBar.Name                   = "SocialLinks"
linkBar.Size                   = UDim2.new(1, -40, 0, 30)
linkBar.Position               = UDim2.new(0, 20, 1, -35)
linkBar.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", linkBar)
layout.FillDirection       = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding             = UDim.new(0, 12)

-- Popup: shows a TextBox ready for manual copy, auto‐destroys in 10s
local function showCopyPopup(url)
	-- dark overlay
	local overlay = Instance.new("Frame", panel)
	overlay.Name                   = "PopupOverlay"
	overlay.Size                   = UDim2.new(1, 0, 1, 0)
	overlay.Position               = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3       = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.ZIndex                 = 50

	-- ensure it auto‐cleans up
	Debris:AddItem(overlay, 5)

	-- popup container
	local popup = Instance.new("Frame", overlay)
	popup.Name                   = "CopyPopup"
	popup.AnchorPoint            = Vector2.new(0.5, 0.5)
	popup.Position               = UDim2.new(0.5, 0, 0.5, 0)
	popup.Size                   = UDim2.new(0, 350, 0, 120)
	popup.BackgroundColor3       = Color3.fromRGB(30, 30, 30)
	popup.BackgroundTransparency = 0
	popup.ZIndex                 = 51
	Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)

	-- info label
	local info = Instance.new("TextLabel", popup)
	info.Size                   = UDim2.new(1, -20, 0, 24)
	info.Position               = UDim2.new(0, 10, 0, 10)
	info.Text                   = "Press Ctrl+C to copy link"
	info.TextColor3             = Color3.fromRGB(0, 255, 0)
	info.BackgroundTransparency = 1
	info.Font                   = Enum.Font.Code
	info.TextScaled             = true
	info.ZIndex                 = 52

	-- URL TextBox
	local box = Instance.new("TextBox", popup)
	box.Size             = UDim2.new(1, -20, 0, 32)
	box.Position         = UDim2.new(0, 10, 0, 44)
	box.Text             = url
	box.ClearTextOnFocus = false
	box.MultiLine        = false
	box.TextColor3       = Color3.fromRGB(0, 255, 0)
	box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	box.Font             = Enum.Font.Code
	box.TextScaled       = true
	box.ZIndex           = 52
	box:CaptureFocus()
	box.SelectionStart   = 1
	box.SelectionEnd     = #url

	-- Close “✕” button
	local closeBtn = Instance.new("TextButton", popup)
	closeBtn.Name             = "ClosePopup"
	closeBtn.Size             = UDim2.new(0, 24, 0, 24)
	closeBtn.Position         = UDim2.new(1, -28, 0, 10)
	closeBtn.Text             = "✕"
	closeBtn.Font             = Enum.Font.Code
	closeBtn.TextColor3       = Color3.fromRGB(0, 255, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	closeBtn.AutoButtonColor  = false
	closeBtn.ZIndex           = 52
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
	closeBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
		log.Text = log.Text .. "[SOCIAL] Popup closed manually\n"
	end)
end

-- Create a link button that shows the copy popup
local function createLink(label, url)
	local btn = Instance.new("TextButton", linkBar)
	btn.Size             = UDim2.new(0, 120, 1, 0)
	btn.Text             = label
	btn.TextColor3       = Color3.fromRGB(0, 255, 0)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Font             = Enum.Font.Code
	btn.TextScaled       = true
	btn.AutoButtonColor  = false
	btn.ZIndex           = 2
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local glow = Instance.new("UIStroke", btn)
	glow.Thickness    = 0.5
	glow.Color        = Color3.fromRGB(0, 255, 0)
	glow.Transparency = 0.2

	btn.MouseButton1Click:Connect(function()
		log.Text = log.Text .. "[SOCIAL] Ready to copy: " .. label .. "\n"
		showCopyPopup(url)
	end)
end

-- Your social links
createLink("Discord", "https://discord.gg/r25xbMDqwf")
createLink("GitHub",  "https://github.com/RGameHUB/RobloxLUA")
