local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local speed = 50
local moveVector = Vector3.new(0, 0, 0)
local verticalInput = 0 -- 1 para subir, -1 para bajar, 0 quieto

-- Crear componentes de física modernos en el cliente
local attachment = Instance.new("Attachment", humanoidRootPart)
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.MaxForce = math.huge
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.Parent = humanoidRootPart

-- Capturar el movimiento del Joystick (funciona tanto para el dedo en pantalla como para WASD)
local function onMove(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Cancel then
        moveVector = Vector3.new(0, 0, 0)
        return
    end
    -- El Humanoid.MoveDirection ya detecta automáticamente el joystick de celular o las teclas WASD
    local cam = workspace.CurrentCamera
    local dir = humanoid.MoveDirection
    moveVector = dir * speed
end

ContextActionService:BindAction("FlyMove", onMove, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)

-- Controles para subir y bajar (Teclado y botones virtuales si aplica)
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
        verticalInput = 1
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonB then
        verticalInput = -1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA or 
       input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonB then
        verticalInput = 0
    end
end)

-- Bucle principal de vuelo sincronizado con el cliente
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart or humanoid.Health <= 0 then
        if linearVelocity then linearVelocity:Destroy() end
        if attachment then attachment:Destroy() end
        return
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local camera = workspace.CurrentCamera
    local lookVec = camera.CFrame.LookVector
    local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)
    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit else flatLook = Vector3.new(0, 0, 1) end

    -- Calcular dirección basada en hacia dónde apunta la cámara y el joystick del celular
    local moveDir = humanoid.MoveDirection
    local velocity = (moveDir * speed) + Vector3.new(0, verticalInput * speed, 0)

    linearVelocity.VectorVelocity = velocity

    if moveDir.Magnitude > 0 then
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + flatLook)
    end
end)
