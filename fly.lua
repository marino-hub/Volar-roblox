local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = true
local speed = 50
local keys = {W = false, S = false, A = false, D = false, Space = false, LeftShift = false}

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = false end
end)

RunService.RenderStepped:Connect(function()
    if not flying or not character or not humanoidRootPart or humanoid.Health <= 0 then return end

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local camera = workspace.CurrentCamera
    local moveDirection = Vector3.new(0, 0, 0)
    local cf = camera.CFrame

    if keys.W then moveDirection = moveDirection + cf.LookVector end
    if keys.S then moveDirection = moveDirection - cf.LookVector end
    if keys.A then moveDirection = moveDirection - cf.RightVector end
    if keys.D then moveDirection = moveDirection + cf.RightVector end
    if keys.Space then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
    if keys.LeftShift then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * speed
    end

    humanoidRootPart.AssemblyLinearVelocity = moveDirection
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + cf.LookVector)
end)
