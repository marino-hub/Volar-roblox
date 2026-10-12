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

-- Crear un LinearVelocity moderno para el motor actual de Roblox
local attachment = Instance.new("Attachment", humanoidRootPart)
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = math.huge
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.Parent = humanoidRootPart

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
    if not flying or not character or not humanoidRootPart or humanoid.Health <= 0 then
        if linearVelocity then linearVelocity:Destroy() end
        if attachment then attachment:Destroy() end
        return
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local camera = workspace.CurrentCamera
    local lookVec = camera.CFrame.LookVector
    local rightVec = camera.CFrame.RightVector

    local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z).Unit
    local flatRight = Vector3.new(rightVec.X, 0, rightVec.Z).Unit

    local moveDirection = Vector3.new(0, 0, 0)
    if keys.W then moveDirection = moveDirection + flatLook end
    if keys.S then moveDirection = moveDirection - flatLook end
    if keys.A then moveDirection = moveDirection - flatRight end
    if keys.D then moveDirection = moveDirection + flatRight end

    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * speed
    end

    local verticalSpeed = 0
    if keys.Space then verticalSpeed = speed end
    if keys.LeftShift then verticalSpeed = -speed end

    -- Aplicar la velocidad exacta en los 3 ejes sin que la gravedad del motor interfiera
    linearVelocity.VectorVelocity = Vector3.new(moveDirection.X, verticalSpeed, moveDirection.Z)
    
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + flatLook)
end)
