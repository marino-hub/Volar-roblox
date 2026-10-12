local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Crear interfaz gráfica flotante para móviles
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileFlyGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 90)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Botón Activar / Desactivar
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "Vuelo: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- Botón Subir
local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 65, 0, 30)
UpBtn.Position = UDim2.new(0, 10, 0, 50)
UpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
UpBtn.Text = "SUBIR"
UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpBtn.TextSize = 12
UpBtn.Font = Enum.Font.SourceSansBold
UpBtn.Parent = MainFrame

local UpCorner = Instance.new("UICorner")
UpCorner.CornerRadius = UDim.new(0, 6)
UpCorner.Parent = UpBtn

-- Botón Bajar
local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 65, 0, 30)
DownBtn.Position = UDim2.new(0, 85, 0, 50)
DownBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
DownBtn.Text = "BAJAR"
DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DownBtn.TextSize = 12
DownBtn.Font = Enum.Font.SourceSansBold
DownBtn.Parent = MainFrame

local DownCorner = Instance.new("UICorner")
DownCorner.CornerRadius = UDim.new(0, 6)
DownCorner.Parent = DownBtn

-- Variables de estado de vuelo
local flying = false
local speed = 50
local upState = false
local downState = false

ToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleBtn.Text = "Vuelo: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
    else
        ToggleBtn.Text = "Vuelo: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

UpBtn.MouseButton1Down:Connect(function() upState = true end)
UpBtn.MouseButton1Up:Connect(function() upState = false end)
DownBtn.MouseButton1Down:Connect(function() downState = true end)
DownBtn.MouseButton1Up:Connect(function() downState = false end)

-- Bucle físico del vuelo móvil
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart or humanoid.Health <= 0 then return end

    if flying then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        local camera = workspace.CurrentCamera
        local lookVec = camera.CFrame.LookVector
        local moveDir = humanoid.MoveDirection
        
        local verticalVel = 0
        if upState then verticalVel = speed end
        if downState then verticalVel = -speed end

        local finalVelocity = (moveDir * speed) + Vector3.new(0, verticalVel, 0)
        humanoidRootPart.AssemblyLinearVelocity = finalVelocity

        if moveDir.Magnitude > 0 then
            local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)
            if flatLook.Magnitude > 0 then
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + flatLook.Unit)
            end
        end
    end
end)
