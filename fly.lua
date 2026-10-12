local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function setupFly(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Limpiar interfaz anterior si ya existía
    if player.PlayerGui:FindFirstChild("MobileFlyGui") then
        player.PlayerGui.MobileFlyGui:Destroy()
    end

    -- Crear interfaz gráfica flotante
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileFlyGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 180, 0, 100)
    MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- Botón Activar / Desactivar Vuelo
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 160, 0, 38)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    ToggleBtn.Text = "VUELO: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 15
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = ToggleBtn

    -- Botón Subir
    local UpBtn = Instance.new("TextButton")
    UpBtn.Size = UDim2.new(0, 75, 0, 35)
    UpBtn.Position = UDim2.new(0, 10, 0, 55)
    UpBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    UpBtn.Text = "SUBIR"
    UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpBtn.TextSize = 13
    UpBtn.Font = Enum.Font.GothamBold
    UpBtn.Parent = MainFrame

    local UpCorner = Instance.new("UICorner")
    UpCorner.CornerRadius = UDim.new(0, 8)
    UpCorner.Parent = UpBtn

    -- Botón Bajar
    local DownBtn = Instance.new("TextButton")
    DownBtn.Size = UDim2.new(0, 75, 0, 35)
    DownBtn.Position = UDim2.new(0, 95, 0, 55)
    DownBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 40)
    DownBtn.Text = "BAJAR"
    DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DownBtn.TextSize = 13
    DownBtn.Font = Enum.Font.GothamBold
    DownBtn.Parent = MainFrame

    local DownCorner = Instance.new("UICorner")
    DownCorner.CornerRadius = UDim.new(0, 8)
    DownCorner.Parent = DownBtn

    local flying = false
    local speed = 35
    local upState = false
    local downState = false

    ToggleBtn.MouseButton1Click:Connect(function()
        flying = not flying
        if flying then
            ToggleBtn.Text = "VUELO: ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        else
            ToggleBtn.Text = "VUELO: OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            
            if humanoidRootPart and humanoidRootPart.Parent and humanoid and humanoid.Parent then
                -- Detener velocidad por completo
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                -- Devolver el control al motor de Roblox para que se ponga de pie
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            end
        end
    end)

    UpBtn.MouseButton1Down:Connect(function() upState = true end)
    UpBtn.MouseButton1Up:Connect(function() upState = false end)
    DownBtn.MouseButton1Down:Connect(function() downState = true end)
    DownBtn.MouseButton1Up:Connect(function() downState = false end)

    -- Bucle físico del vuelo
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character.Parent or not humanoidRootPart or not humanoidRootPart.Parent or humanoid.Health <= 0 then
            if ScreenGui then ScreenGui:Destroy() end
            if connection then connection:Disconnect() end
            return
        end

        if flying then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)

            local camera = workspace.CurrentCamera
            local moveDir = humanoid.MoveDirection
            
            local verticalVel = 0
            if upState then verticalVel = speed end
            if downState then verticalVel = -speed end

            local horizontalVel = moveDir * speed
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(horizontalVel.X, verticalVel, horizontalVel.Z)
            
            if moveDir.Magnitude > 0 then
                local lookVec = camera.CFrame.LookVector
                local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z)
                if flatLook.Magnitude > 0 then
                    -- Mantener derecho el eje Y al orientar el personaje
                    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + flatLook.Unit)
                end
            end
        end
    end)
end

-- Reinicio automático cuando el personaje muere o reaparece
player.CharacterAdded:Connect(function(newCharacter)
    task.wait(1)
    setupFly(newCharacter)
end)

if player.Character then
    setupFly(player.Character)
end
 
