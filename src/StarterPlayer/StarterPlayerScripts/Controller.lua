local controls = {pc = {},mode = 'pc',func = {}}
controls.pc.Keybinds = {
    Foward = {'w',"Foward"}-- Name = {key,function}
}
controls.KeysPressed = {}
controls.Render = {}
controls.Functionsdown = {}
local func = controls.func
local Render = controls.Render
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local function getkeyfrominput(input)
    if input.KeyCode then
        return input.KeyCode.Name
    elseif input.UserInputType then
        return input.UserInputType.Name
    end
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
                        controls.Functionsdown[v[2]] = controls.Functionsdown[v[2]] or {}
                        controls.Functionsdown[v[2]][key] = true
                        if controls.func[v[2]] then
                            task.spawn(controls.func[v[2]],key)
                        end
                    else
                        task.spawn(v[2],key)
                    end
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
        
    end
end)
function controls.renderupdate(dt)
    for i,v in controls.Render do
        task.spawn(v,dt)
    end
end
runservice.Stepped:Connect(controls.renderupdate)
return controls