local controlls = {pc = {},mode = 'pc',func = {}}
controlls.pc.Keybinds = {
    Foward = {'w'}
}
controlls.KeysPressed = {}
controlls.Render = {}

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
    controlls.KeysPressed[key] = key
    if controlls[controlls.mode] then
        for i,v in controlls[controlls.mode] do
            if v[1] == key then
                if v[2] then
                    if type(v[2]) == "string" then
                        if controlls.func[v[2]] then
                            controlls.func[v[2]]()
                        end
                    else
                        v[2]()
                    end
                end
                break
            end
        end
    end
end)
uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end 
    local key = getkeyfrominput(input)
    controlls.KeysPressed[key] = nil
end)
function controlls.renderupdate(dt)
    for i,v in controlls.Render do
        task.spawn(v,dt)
    end
end
runservice.Stepped:Connect( controlls.renderupdate)
return controlls