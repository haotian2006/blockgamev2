local controls = {pc = {},mode = 'pc',func = {}}
controls.pc = {
    Foward = {'w',"Foward"},-- Name = {key,function}
    Left = {{'a',"c"},"Left"},
    Right = {'d',"Right"},
    Back = {'s',"Back"},
}
controls.KeysPressed = {}
controls.Render = {}
controls.Functionsdown = {}
local Camera = game.Workspace.CurrentCamera
local func = controls.func
local Render = controls.Render
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local FD = controls.Functionsdown 
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower()
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower()
    end
end
local speed = .2--5.612
function Render.Move(dt)
    local LookVector = Camera.CFrame.LookVector
    local RightVector = Camera.CFrame.RightVector
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit
    local foward = LookVector*(FD["Foward"]and 1 or 0)
    local Back = -LookVector*(FD["Back"]and 1 or 0)
    local Left = -RightVector*(FD["Left"]and 1 or 0)
    local Right = RightVector*(FD["Right"]and 1 or 0)
    local velocity = foward + Back + Left+ Right
    velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit) *speed 
    game.ReplicatedStorage.Events.SendEntities:FireServer(velocity)
end
uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end 
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = key
    if controls[controls.mode] then
        for i,v in controls[controls.mode] do
            local function second()
                if v[2] then
                    if type(v[2]) == "string" then
                        if controls.func[v[2]] then
                            task.spawn(controls.func[v[2]],key)
                        end
                    else
                        task.spawn(v[2],key)
                    end
                    controls.Functionsdown[v[2]] = controls.Functionsdown[v[2]] or {}
                    controls.Functionsdown[v[2]][key] = true
                end
            end
            if v[1] == key then
                second()
            elseif type(v[1]) == "table" then
                if table.find(v[1],key) then
                    second()
                end
            end 
        end
    end
end)
uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end 
    local key = getkeyfrominput(input)
    controls.KeysPressed[key] = nil
    for i,v in controls.Functionsdown do
        if v[key] then
            controls.Functionsdown[i][key] = nil
            if next(controls.Functionsdown[i]) == nil then
                controls.Functionsdown[i] = nil
            end
        end
    end
end)
function controls.renderupdate(dt)
    for i,v in controls.Render do
        task.spawn(v,dt)
    end
end
runservice.Stepped:Connect(controls.renderupdate)
return controls